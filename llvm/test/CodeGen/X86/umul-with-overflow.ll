; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-linux-gnu | FileCheck %s --check-prefix=X86
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu | FileCheck %s --check-prefix=X64

declare {i32, i1} @llvm.umul.with.overflow.i32(i32 %a, i32 %b)

define zeroext i1 @a(i32 %x)  nounwind {
; X86-LABEL: a:
; X86:       # %bb.0:
; X86-NEXT:    movl $3, %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    seto %al
; X86-NEXT:    retl
;
; X64-LABEL: a:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    movl $3, %ecx
; X64-NEXT:    mull %ecx
; X64-NEXT:    seto %al
; X64-NEXT:    retq
  %res = call {i32, i1} @llvm.umul.with.overflow.i32(i32 %x, i32 3)
  %obil = extractvalue {i32, i1} %res, 1
  ret i1 %obil
}

define i32 @test2(i32 %a, i32 %b) nounwind readnone {
; X86-LABEL: test2:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    retl
;
; X64-LABEL: test2:
; X64:       # %bb.0: # %entry
; X64-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    leal (%rdi,%rsi), %eax
; X64-NEXT:    addl %eax, %eax
; X64-NEXT:    retq
entry:
	%tmp0 = add i32 %b, %a
	%tmp1 = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %tmp0, i32 2)
	%tmp2 = extractvalue { i32, i1 } %tmp1, 0
	ret i32 %tmp2
}

define i32 @test3(i32 %a, i32 %b) nounwind readnone {
; X86-LABEL: test3:
; X86:       # %bb.0: # %entry
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    addl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl $4, %ecx
; X86-NEXT:    mull %ecx
; X86-NEXT:    retl
;
; X64-LABEL: test3:
; X64:       # %bb.0: # %entry
; X64-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    leal (%rdi,%rsi), %eax
; X64-NEXT:    movl $4, %ecx
; X64-NEXT:    mull %ecx
; X64-NEXT:    retq
entry:
	%tmp0 = add i32 %b, %a
	%tmp1 = call { i32, i1 } @llvm.umul.with.overflow.i32(i32 %tmp0, i32 4)
	%tmp2 = extractvalue { i32, i1 } %tmp1, 0
	ret i32 %tmp2
}

; Check that shifts larger than the shift amount type are handled.
; Intentionally not testing codegen here, only that this doesn't assert.
declare {i300, i1} @llvm.umul.with.overflow.i300(i300 %a, i300 %b)
define i300 @test4(i300 %a, i300 %b) nounwind {
; X86-LABEL: test4:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    pushl %ebx
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    subl $76, %esp
; X86-NEXT:    movl $4095, %ecx # imm = 0xFFF
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    andl %ecx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    andl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    addl %esi, %ebp
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %ecx, %ebx
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    addl %ebp, %eax
; X86-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X86-NEXT:    adcl %edi, %esi
; X86-NEXT:    setb %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ebx
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    addl %esi, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    adcl %eax, %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %edx, %ebp
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    addl %esi, %ecx
; X86-NEXT:    adcl $0, %ebp
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %ebx
; X86-NEXT:    addl %ecx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl %ebp, %ebx
; X86-NEXT:    setb %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %eax, %esi
; X86-NEXT:    addl %ebx, %esi
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    adcl %eax, %edx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Folded Reload
; X86-NEXT:    adcl (%esp), %edx # 4-byte Folded Reload
; X86-NEXT:    movl %edx, (%esp) # 4-byte Spill
; X86-NEXT:    adcl $0, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl %edi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ebx
; X86-NEXT:    movl %eax, %edi
; X86-NEXT:    addl %ecx, %edi
; X86-NEXT:    adcl $0, %ebx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %edx, %ebp
; X86-NEXT:    addl %edi, %eax
; X86-NEXT:    movl %eax, %edi
; X86-NEXT:    adcl %ebx, %ebp
; X86-NEXT:    setb {{[-0-9]+}}(%e{{[sb]}}p) # 1-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    addl %ebp, %ebx
; X86-NEXT:    movzbl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 1-byte Folded Reload
; X86-NEXT:    adcl %eax, %ecx
; X86-NEXT:    addl %esi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl (%esp), %edi # 4-byte Folded Reload
; X86-NEXT:    movl %edi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %ebx
; X86-NEXT:    adcl $0, %ecx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %ebx # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 4-byte Folded Reload
; X86-NEXT:    setb {{[-0-9]+}}(%e{{[sb]}}p) # 1-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    addl %esi, %ebp
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    mull %edx
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    addl %ebp, %eax
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    adcl %edi, %esi
; X86-NEXT:    setb (%esp) # 1-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull {{[0-9]+}}(%esp)
; X86-NEXT:    addl %esi, %eax
; X86-NEXT:    movzbl (%esp), %esi # 1-byte Folded Reload
; X86-NEXT:    adcl %esi, %edx
; X86-NEXT:    addl %ebx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl %ecx, %ebp
; X86-NEXT:    movl %ebp, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movzbl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 1-byte Folded Reload
; X86-NEXT:    adcl %ecx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %edx
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    addl %ecx, %ebx
; X86-NEXT:    adcl $0, %esi
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    addl %ebx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl %esi, %ecx
; X86-NEXT:    setb %bl
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    addl %ecx, %eax
; X86-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X86-NEXT:    movzbl %bl, %eax
; X86-NEXT:    adcl %eax, %edx
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    mull %ebp
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ebp
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    addl %ecx, %ebx
; X86-NEXT:    adcl $0, %esi
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    movl %edi, %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    addl %ebx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl %esi, %ecx
; X86-NEXT:    setb %bl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    addl %ecx, %eax
; X86-NEXT:    movzbl %bl, %ecx
; X86-NEXT:    adcl %ecx, %edx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %edx # 4-byte Folded Reload
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, (%esp) # 4-byte Folded Spill
; X86-NEXT:    adcl $0, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    movl %ebp, %ebx
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, %edi
; X86-NEXT:    addl %ecx, %edi
; X86-NEXT:    adcl $0, %esi
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    mull %ebx
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    addl %edi, %eax
; X86-NEXT:    movl %eax, %edi
; X86-NEXT:    adcl %esi, %ecx
; X86-NEXT:    setb {{[-0-9]+}}(%e{{[sb]}}p) # 1-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ebx
; X86-NEXT:    movl %edx, %ebx
; X86-NEXT:    movl %eax, %esi
; X86-NEXT:    addl %ecx, %esi
; X86-NEXT:    movzbl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 1-byte Folded Reload
; X86-NEXT:    adcl %eax, %ebx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %ebp # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %edi # 4-byte Folded Reload
; X86-NEXT:    movl %edi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %esi
; X86-NEXT:    adcl $0, %ebx
; X86-NEXT:    addl (%esp), %esi # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ebx # 4-byte Folded Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    imull %edx, %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    mull %edx
; X86-NEXT:    addl %edx, %ecx
; X86-NEXT:    imull {{[0-9]+}}(%esp), %edi
; X86-NEXT:    addl %ecx, %edi
; X86-NEXT:    movl %eax, %edx
; X86-NEXT:    addl %esi, %edx
; X86-NEXT:    adcl %ebx, %edi
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    addl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    adcl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ebp # 4-byte Folded Reload
; X86-NEXT:    movl %ebp, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %edx
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl %edi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %ecx
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %edi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    addl %ecx, %ebx
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %ecx, %esi
; X86-NEXT:    movl %edx, %ebp
; X86-NEXT:    addl %ebx, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl %edi, %ebp
; X86-NEXT:    setb %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    addl %ebp, %eax
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    adcl %eax, %edx
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %ebx
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    addl %edi, %ebp
; X86-NEXT:    adcl $0, %ebx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    addl %ebp, %eax
; X86-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X86-NEXT:    adcl %ebx, %edi
; X86-NEXT:    setb %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    addl %edi, %ebp
; X86-NEXT:    movzbl %cl, %eax
; X86-NEXT:    adcl %eax, %edx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %ebp # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %edx # 4-byte Folded Reload
; X86-NEXT:    movl %edx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl $0, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %edx, %esi
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    addl %esi, %ecx
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %ebx
; X86-NEXT:    addl %ecx, %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    adcl %edi, %ebx
; X86-NEXT:    setb {{[-0-9]+}}(%e{{[sb]}}p) # 1-byte Folded Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    mull %esi
; X86-NEXT:    movl %edx, %edi
; X86-NEXT:    movl %eax, %esi
; X86-NEXT:    addl %ebx, %esi
; X86-NEXT:    movzbl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 1-byte Folded Reload
; X86-NEXT:    adcl %eax, %edi
; X86-NEXT:    addl %ebp, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Folded Spill
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 4-byte Folded Reload
; X86-NEXT:    movl %ecx, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %esi
; X86-NEXT:    adcl $0, %edi
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %edi # 4-byte Folded Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    imull %ecx, %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    mull %ecx
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    addl %edx, %ebp
; X86-NEXT:    imull {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    addl %ebp, %ebx
; X86-NEXT:    addl %esi, %ecx
; X86-NEXT:    adcl %edi, %ebx
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl (%esp), %eax # 4-byte Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %eax # 4-byte Folded Reload
; X86-NEXT:    movl %eax, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    adcl $0, %ecx
; X86-NEXT:    adcl $0, %ebx
; X86-NEXT:    addl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 4-byte Folded Reload
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ebx # 4-byte Folded Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    imull %edx, %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    mull %edx
; X86-NEXT:    movl %eax, %edi
; X86-NEXT:    addl %edx, %ebp
; X86-NEXT:    imull {{[0-9]+}}(%esp), %esi
; X86-NEXT:    addl %ebp, %esi
; X86-NEXT:    addl %ecx, %edi
; X86-NEXT:    adcl %ebx, %esi
; X86-NEXT:    movl %esi, {{[-0-9]+}}(%e{{[sb]}}p) # 4-byte Spill
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    imull {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 4-byte Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    imull %edx, %ecx
; X86-NEXT:    mull %edx
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    addl %edx, %esi
; X86-NEXT:    addl %ecx, %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl %ecx, %eax
; X86-NEXT:    imull {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %ebp # 4-byte Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    imull %edx, %ebp
; X86-NEXT:    mull %edx
; X86-NEXT:    addl %edx, %ecx
; X86-NEXT:    addl %ebp, %ecx
; X86-NEXT:    addl %ebx, %eax
; X86-NEXT:    adcl %esi, %ecx
; X86-NEXT:    addl %edi, %eax
; X86-NEXT:    adcl {{[-0-9]+}}(%e{{[sb]}}p), %ecx # 4-byte Folded Reload
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 4(%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, (%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 8(%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 12(%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 16(%edx)
; X86-NEXT:    movl (%esp), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 20(%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 24(%edx)
; X86-NEXT:    movl {{[-0-9]+}}(%e{{[sb]}}p), %esi # 4-byte Reload
; X86-NEXT:    movl %esi, 28(%edx)
; X86-NEXT:    movl %eax, 32(%edx)
; X86-NEXT:    andl $4095, %ecx # imm = 0xFFF
; X86-NEXT:    movw %cx, 36(%edx)
; X86-NEXT:    movl %edx, %eax
; X86-NEXT:    addl $76, %esp
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    popl %ebx
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl $4
;
; X64-LABEL: test4:
; X64:       # %bb.0:
; X64-NEXT:    pushq %rbp
; X64-NEXT:    pushq %r15
; X64-NEXT:    pushq %r14
; X64-NEXT:    pushq %r13
; X64-NEXT:    pushq %r12
; X64-NEXT:    pushq %rbx
; X64-NEXT:    movq %r9, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; X64-NEXT:    movq %r8, %r11
; X64-NEXT:    movq %rcx, %r8
; X64-NEXT:    movq %rdx, %rcx
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r9
; X64-NEXT:    movq %rsi, %rax
; X64-NEXT:    mulq %r10
; X64-NEXT:    movq %rdx, %rbx
; X64-NEXT:    movq %rax, {{[-0-9]+}}(%r{{[sb]}}p) # 8-byte Spill
; X64-NEXT:    movq %rcx, %rax
; X64-NEXT:    mulq %r10
; X64-NEXT:    movq %r10, %rbp
; X64-NEXT:    movq %rdx, %r14
; X64-NEXT:    movq %rax, %r15
; X64-NEXT:    addq %rbx, %r15
; X64-NEXT:    adcq $0, %r14
; X64-NEXT:    movq %rsi, %rax
; X64-NEXT:    mulq %r9
; X64-NEXT:    movq %rdx, %r12
; X64-NEXT:    movq %rax, %rbx
; X64-NEXT:    addq %r15, %rbx
; X64-NEXT:    adcq %r14, %r12
; X64-NEXT:    setb %al
; X64-NEXT:    movzbl %al, %r10d
; X64-NEXT:    movq %rcx, %rax
; X64-NEXT:    mulq %r9
; X64-NEXT:    movq %rdx, %r15
; X64-NEXT:    movq %rax, %r13
; X64-NEXT:    addq %r12, %r13
; X64-NEXT:    adcq %r10, %r15
; X64-NEXT:    movq %r8, %rax
; X64-NEXT:    mulq %rbp
; X64-NEXT:    movq %rdx, %r12
; X64-NEXT:    movq %rax, %r14
; X64-NEXT:    movq %r11, %rax
; X64-NEXT:    mulq %rbp
; X64-NEXT:    movq %rdx, %rbp
; X64-NEXT:    movq %rax, %r10
; X64-NEXT:    addq %r12, %r10
; X64-NEXT:    adcq $0, %rbp
; X64-NEXT:    movq %r8, %rax
; X64-NEXT:    mulq %r9
; X64-NEXT:    movq %rax, %r12
; X64-NEXT:    addq %r10, %r12
; X64-NEXT:    adcq %rbp, %rdx
; X64-NEXT:    imulq %r9, %r11
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r9
; X64-NEXT:    addq %r13, %r14
; X64-NEXT:    adcq %r15, %r12
; X64-NEXT:    adcq %rdx, %r11
; X64-NEXT:    movq %rsi, %rax
; X64-NEXT:    mulq %r9
; X64-NEXT:    movq %rdx, %r10
; X64-NEXT:    movq %rax, %r15
; X64-NEXT:    movq %rcx, %rax
; X64-NEXT:    mulq %r9
; X64-NEXT:    movq %rdx, %r13
; X64-NEXT:    movq %rax, %rbp
; X64-NEXT:    addq %r10, %rbp
; X64-NEXT:    adcq $0, %r13
; X64-NEXT:    movq {{[0-9]+}}(%rsp), %r10
; X64-NEXT:    movq %rsi, %rax
; X64-NEXT:    mulq %r10
; X64-NEXT:    addq %rbp, %rax
; X64-NEXT:    adcq %r13, %rdx
; X64-NEXT:    imulq %r10, %rcx
; X64-NEXT:    addq %rdx, %rcx
; X64-NEXT:    addq %r14, %r15
; X64-NEXT:    adcq %r12, %rax
; X64-NEXT:    adcq %r11, %rcx
; X64-NEXT:    imulq %r9, %r8
; X64-NEXT:    movq {{[-0-9]+}}(%r{{[sb]}}p), %rdx # 8-byte Reload
; X64-NEXT:    imulq {{[0-9]+}}(%rsp), %rdx
; X64-NEXT:    imulq {{[0-9]+}}(%rsp), %rsi
; X64-NEXT:    addq %rdx, %rsi
; X64-NEXT:    addq %r8, %rsi
; X64-NEXT:    addq %rcx, %rsi
; X64-NEXT:    movq %rbx, 8(%rdi)
; X64-NEXT:    movq {{[-0-9]+}}(%r{{[sb]}}p), %rcx # 8-byte Reload
; X64-NEXT:    movq %rcx, (%rdi)
; X64-NEXT:    movq %r15, 16(%rdi)
; X64-NEXT:    movq %rax, 24(%rdi)
; X64-NEXT:    movl %esi, 32(%rdi)
; X64-NEXT:    shrq $32, %rsi
; X64-NEXT:    andl $4095, %esi # imm = 0xFFF
; X64-NEXT:    movw %si, 36(%rdi)
; X64-NEXT:    movq %rdi, %rax
; X64-NEXT:    popq %rbx
; X64-NEXT:    popq %r12
; X64-NEXT:    popq %r13
; X64-NEXT:    popq %r14
; X64-NEXT:    popq %r15
; X64-NEXT:    popq %rbp
; X64-NEXT:    retq
  %x = call {i300, i1} @llvm.umul.with.overflow.i300(i300 %a, i300 %b)
  %y = extractvalue {i300, i1} %x, 0
  ret i300 %y
}
