//===--- Builtins.cpp - Builtin function implementation -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//  This file implements various things for builtin functions.
//
//===----------------------------------------------------------------------===//

#include "clang/Basic/Builtins.h"
#include "BuiltinTargetFeatures.h"
#include "clang/Basic/IdentifierTable.h"
#include "clang/Basic/LangOptions.h"
#include "clang/Basic/TargetInfo.h"
#include "llvm/ADT/StringRef.h"
using namespace clang;

static constexpr Builtin::Info BuiltinInfo[] = {
    {"not a builtin function", nullptr, nullptr, nullptr, ALL_LANGUAGES,
     nullptr},
#define BUILTIN(ID, TYPE, ATTRS)                                               \
  { #ID, TYPE, ATTRS, nullptr, ALL_LANGUAGES, nullptr },
#define LANGBUILTIN(ID, TYPE, ATTRS, LANGS)                                    \
  { #ID, TYPE, ATTRS, nullptr, LANGS, nullptr },
#define LIBBUILTIN(ID, TYPE, ATTRS, HEADER, LANGS)                             \
  { #ID, TYPE, ATTRS, HEADER, LANGS, nullptr },
#include "clang/Basic/Builtins.def"
};

const Builtin::Info &Builtin::Context::getRecord(unsigned ID) const {
  if (ID < Builtin::FirstTSBuiltin)
    return BuiltinInfo[ID];
  assert(((ID - Builtin::FirstTSBuiltin) <
          (TSRecords.size() + AuxTSRecords.size())) &&
         "Invalid builtin ID!");
  if (isAuxBuiltinID(ID))
    return AuxTSRecords[getAuxBuiltinID(ID) - Builtin::FirstTSBuiltin];
  return TSRecords[ID - Builtin::FirstTSBuiltin];
}

void Builtin::Context::InitializeTarget(const TargetInfo &Target,
                                        const TargetInfo *AuxTarget) {
  assert(TSRecords.empty() && "Already initialized target?");
  TSRecords = Target.getTargetBuiltins();
  if (AuxTarget)
    AuxTSRecords = AuxTarget->getTargetBuiltins();
}

bool Builtin::Context::isBuiltinFunc(llvm::StringRef FuncName) {
  bool InStdNamespace = FuncName.consume_front("std-");
  for (unsigned i = Builtin::NotBuiltin + 1; i != Builtin::FirstTSBuiltin;
       ++i) {
    if (FuncName.equals(BuiltinInfo[i].Name) &&
        (bool)strchr(BuiltinInfo[i].Attributes, 'z') == InStdNamespace)
      return strchr(BuiltinInfo[i].Attributes, 'f') != nullptr;
  }

  return false;
}

/// Is this builtin supported according to the given language options?
static bool builtinIsSupported(const Builtin::Info &BuiltinInfo,
                               const LangOptions &LangOpts) {
  if (bool BuiltinsUnsupported =
          LangOpts.NoBuiltin && strchr(BuiltinInfo.Attributes, 'f') != nullptr)
    return false;
  if (bool CorBuiltinsUnsupported =
          !LangOpts.Coroutines && (BuiltinInfo.Langs & COR_LANG))
    return false;
  if (bool MathBuiltinsUnsupported =
          LangOpts.NoMathBuiltin && BuiltinInfo.HeaderName &&
          llvm::StringRef(BuiltinInfo.HeaderName).equals("math.h"))
    return false;
  if (bool GnuModeUnsupported =
          !LangOpts.GNUMode && (BuiltinInfo.Langs & GNU_LANG))
    return false;
  if (bool MSModeUnsupported =
          !LangOpts.MicrosoftExt && (BuiltinInfo.Langs & MS_LANG))
    return false;
  if (bool ObjCUnsupported = !LangOpts.ObjC && BuiltinInfo.Langs == OBJC_LANG)
    return false;
  if (bool OclCUnsupported =
          !LangOpts.OpenCL && (BuiltinInfo.Langs & ALL_OCL_LANGUAGES))
    return false;
  if (bool OclGASUnsupported =
          !LangOpts.OpenCLGenericAddressSpace && (BuiltinInfo.Langs & OCL_GAS))
    return false;
  if (bool OclPipeUnsupported =
          !LangOpts.OpenCLPipes && (BuiltinInfo.Langs & OCL_PIPE))
    return false;

  // Device side enqueue is not supported until OpenCL 2.0. In 2.0 and higher
  // support is indicated with language option for blocks.
  if (bool OclDSEUnsupported =
          (LangOpts.getOpenCLCompatibleVersion() < 200 || !LangOpts.Blocks) &&
          (BuiltinInfo.Langs & OCL_DSE))
    return false;
  if (bool OpenMPUnsupported =
          !LangOpts.OpenMP && BuiltinInfo.Langs == OMP_LANG)
    return false;
  if (bool CUDAUnsupported = !LangOpts.CUDA && BuiltinInfo.Langs == CUDA_LANG)
    return false;
  if (bool CPlusPlusUnsupported =
          !LangOpts.CPlusPlus && BuiltinInfo.Langs == CXX_LANG)
    return false;
  return true;
}

/// initializeBuiltins - Mark the identifiers for all the builtins with their
/// appropriate builtin ID # and mark any non-portable builtin identifiers as
/// such.
void Builtin::Context::initializeBuiltins(IdentifierTable &Table,
                                          const LangOptions& LangOpts) {
  // Step #1: mark all target-independent builtins with their ID's.
  for (unsigned i = Builtin::NotBuiltin+1; i != Builtin::FirstTSBuiltin; ++i)
    if (builtinIsSupported(BuiltinInfo[i], LangOpts)) {
      Table.get(BuiltinInfo[i].Name).setBuiltinID(i);
    }

  // Step #2: Register target-specific builtins.
  for (unsigned i = 0, e = TSRecords.size(); i != e; ++i)
    if (builtinIsSupported(TSRecords[i], LangOpts))
      Table.get(TSRecords[i].Name).setBuiltinID(i + Builtin::FirstTSBuiltin);

  // Step #3: Register target-specific builtins for AuxTarget.
  for (unsigned i = 0, e = AuxTSRecords.size(); i != e; ++i)
    Table.get(AuxTSRecords[i].Name)
        .setBuiltinID(i + Builtin::FirstTSBuiltin + TSRecords.size());

  // Step #4: Unregister any builtins specified by -fno-builtin-foo.
  for (llvm::StringRef Name : LangOpts.NoBuiltinFuncs) {
    bool InStdNamespace = Name.consume_front("std-");
    auto NameIt = Table.find(Name);
    if (NameIt != Table.end()) {
      unsigned ID = NameIt->second->getBuiltinID();
      if (ID != Builtin::NotBuiltin && isPredefinedLibFunction(ID) &&
          isInStdNamespace(ID) == InStdNamespace) {
        Table.get(Name).setBuiltinID(Builtin::NotBuiltin);
      }
    }
  }
}

unsigned Builtin::Context::getRequiredVectorWidth(unsigned ID) const {
  const char *WidthPos = ::strchr(getRecord(ID).Attributes, 'V');
  if (!WidthPos)
    return 0;

  ++WidthPos;
  assert(*WidthPos == ':' &&
         "Vector width specifier must be followed by a ':'");
  ++WidthPos;

  char *EndPos;
  unsigned Width = ::strtol(WidthPos, &EndPos, 10);
  assert(*EndPos == ':' && "Vector width specific must end with a ':'");
  return Width;
}

bool Builtin::Context::isLike(unsigned ID, unsigned &FormatIdx,
                              bool &HasVAListArg, const char *Fmt) const {
  assert(Fmt && "Not passed a format string");
  assert(::strlen(Fmt) == 2 &&
         "Format string needs to be two characters long");
  assert(::toupper(Fmt[0]) == Fmt[1] &&
         "Format string is not in the form \"xX\"");

  const char *Like = ::strpbrk(getRecord(ID).Attributes, Fmt);
  if (!Like)
    return false;

  HasVAListArg = (*Like == Fmt[1]);

  ++Like;
  assert(*Like == ':' && "Format specifier must be followed by a ':'");
  ++Like;

  assert(::strchr(Like, ':') && "Format specifier must end with a ':'");
  FormatIdx = ::strtol(Like, nullptr, 10);
  return true;
}

bool Builtin::Context::isPrintfLike(unsigned ID, unsigned &FormatIdx,
                                    bool &HasVAListArg) {
  return isLike(ID, FormatIdx, HasVAListArg, "pP");
}

bool Builtin::Context::isScanfLike(unsigned ID, unsigned &FormatIdx,
                                   bool &HasVAListArg) {
  return isLike(ID, FormatIdx, HasVAListArg, "sS");
}

bool Builtin::Context::performsCallback(unsigned ID,
                                        SmallVectorImpl<int> &Encoding) const {
  const char *CalleePos = ::strchr(getRecord(ID).Attributes, 'C');
  if (!CalleePos)
    return false;

  ++CalleePos;
  assert(*CalleePos == '<' &&
         "Callback callee specifier must be followed by a '<'");
  ++CalleePos;

  char *EndPos;
  int CalleeIdx = ::strtol(CalleePos, &EndPos, 10);
  assert(CalleeIdx >= 0 && "Callee index is supposed to be positive!");
  Encoding.push_back(CalleeIdx);

  while (*EndPos == ',') {
    const char *PayloadPos = EndPos + 1;

    int PayloadIdx = ::strtol(PayloadPos, &EndPos, 10);
    Encoding.push_back(PayloadIdx);
  }

  assert(*EndPos == '>' && "Callback callee specifier must end with a '>'");
  return true;
}

bool Builtin::Context::canBeRedeclared(unsigned ID) const {
  return ID == Builtin::NotBuiltin || ID == Builtin::BI__va_start ||
         ID == Builtin::BI__builtin_assume_aligned ||
         (!hasReferenceArgsOrResult(ID) && !hasCustomTypechecking(ID)) ||
         isInStdNamespace(ID);
}

bool Builtin::evaluateRequiredTargetFeatures(
    StringRef RequiredFeatures, const llvm::StringMap<bool> &TargetFetureMap) {
  // Return true if the builtin doesn't have any required features.
  if (RequiredFeatures.empty())
    return true;
  assert(!RequiredFeatures.contains(' ') && "Space in feature list");

  TargetFeatures TF(TargetFetureMap);
  return TF.hasRequiredFeatures(RequiredFeatures);
}
