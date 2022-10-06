; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -opaque-pointers -mtriple=powerpc64le-unknown-unknown < %s | FileCheck --check-prefix=CHECK-LE %s
; RUN: llc -opaque-pointers -mtriple=powerpc64-unknown-unknown < %s | FileCheck %s

define ptr @foo(ptr %p) {
; CHECK-LE-LABEL: foo:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    ld 3, 0(3)
; CHECK-LE-NEXT:    cmpd 7, 3, 3
; CHECK-LE-NEXT:    bne- 7, .+4
; CHECK-LE-NEXT:    isync
; CHECK-LE-NEXT:    blr
;
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld 3, 0(3)
; CHECK-NEXT:    cmpd 7, 3, 3
; CHECK-NEXT:    bne- 7, .+4
; CHECK-NEXT:    isync
; CHECK-NEXT:    blr
entry:
  %0 = load atomic ptr, ptr %p acquire, align 8
  ret ptr %0
}

define void @foobar({} addrspace(10)* addrspace(11)* %p) {
; CHECK-LE-LABEL: foobar:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    ld 3, 0(3)
; CHECK-LE-NEXT:    cmpd 7, 3, 3
; CHECK-LE-NEXT:    bne- 7, .+4
; CHECK-LE-NEXT:    isync
;
; CHECK-LABEL: foobar:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    ld 3, 0(3)
; CHECK-NEXT:    cmpd 7, 3, 3
; CHECK-NEXT:    bne- 7, .+4
; CHECK-NEXT:    isync
entry:
  %0 = load atomic {} addrspace(10)*, {} addrspace(10)* addrspace(11)* %p acquire, align 8
  unreachable
}