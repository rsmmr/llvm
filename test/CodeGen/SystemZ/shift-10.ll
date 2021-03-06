; Test compound shifts.
;
; RUN: llc < %s -mtriple=s390x-linux-gnu | FileCheck %s

; Test a shift right followed by a sign extension.  This can use two shifts.
define i64 @f1(i32 %a) {
; CHECK-LABEL: f1:
; CHECK: sllg [[REG:%r[0-5]]], %r2, 62
; CHECK: srag %r2, [[REG]], 63
; CHECK: br %r14
  %shr = lshr i32 %a, 1
  %trunc = trunc i32 %shr to i1
  %ext = sext i1 %trunc to i64
  ret i64 %ext
}

; ...and again with the highest shift count.
define i64 @f2(i32 %a) {
; CHECK-LABEL: f2:
; CHECK: sllg [[REG:%r[0-5]]], %r2, 32
; CHECK: srag %r2, [[REG]], 63
; CHECK: br %r14
  %shr = lshr i32 %a, 31
  %trunc = trunc i32 %shr to i1
  %ext = sext i1 %trunc to i64
  ret i64 %ext
}

; Test a left shift that of an extended right shift in a case where folding
; is possible.
define i64 @f3(i32 %a) {
; CHECK-LABEL: f3:
; CHECK: risbg %r2, %r2, 27, 181, 9
; CHECK: br %r14
  %shr = lshr i32 %a, 1
  %ext = zext i32 %shr to i64
  %shl = shl i64 %ext, 10
  %and = and i64 %shl, 137438952960
  ret i64 %and
}

; ...and again with a larger right shift.
define i64 @f4(i32 %a) {
; CHECK-LABEL: f4:
; CHECK: risbg %r2, %r2, 30, 158, 3
; CHECK: br %r14
  %shr = lshr i32 %a, 30
  %ext = sext i32 %shr to i64
  %shl = shl i64 %ext, 33
  %and = and i64 %shl, 8589934592
  ret i64 %and
}

; Repeat the previous test in a case where all bits outside the
; bottom 3 matter.
define i64 @f5(i32 %a) {
; CHECK-LABEL: f5:
; CHECK: risbg %r2, %r2, 29, 158, 3
; CHECK: lhi %r2, 7
; CHECK: br %r14
  %shr = lshr i32 %a, 30
  %ext = sext i32 %shr to i64
  %shl = shl i64 %ext, 33
  %or = or i64 %shl, 7
  ret i64 %or
}
