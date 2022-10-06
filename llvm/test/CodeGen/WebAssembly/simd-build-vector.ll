; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -verify-machineinstrs -disable-wasm-fallthrough-return-opt -wasm-disable-explicit-locals -wasm-keep-registers -mattr=+simd128 | FileCheck %s

; Test that the logic to choose between v128.const vector
; initialization and splat vector initialization and to optimize the
; choice of splat value works correctly.

target triple = "wasm32-unknown-unknown"

define <8 x i16> @same_const_one_replaced_i16x8(i16 %x) {
; CHECK-LABEL: same_const_one_replaced_i16x8:
; CHECK:         .functype same_const_one_replaced_i16x8 (i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 42, 42, 42, 42, 42, 0, 42, 42
; CHECK-NEXT:    i16x8.replace_lane $push1=, $pop0, 5, $0
; CHECK-NEXT:    return $pop1
  %v = insertelement
    <8 x i16> <i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42, i16 42>,
    i16 %x,
    i32 5
  ret <8 x i16> %v
}

define <8 x i16> @different_const_one_replaced_i16x8(i16 %x) {
; CHECK-LABEL: different_const_one_replaced_i16x8:
; CHECK:         .functype different_const_one_replaced_i16x8 (i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 1, -2, 3, -4, 5, 0, 7, -8
; CHECK-NEXT:    i16x8.replace_lane $push1=, $pop0, 5, $0
; CHECK-NEXT:    return $pop1
  %v = insertelement
    <8 x i16> <i16 1, i16 -2, i16 3, i16 -4, i16 5, i16 -6, i16 7, i16 -8>,
    i16 %x,
    i32 5
  ret <8 x i16> %v
}

define <4 x float> @same_const_one_replaced_f32x4(float %x) {
; CHECK-LABEL: same_const_one_replaced_f32x4:
; CHECK:         .functype same_const_one_replaced_f32x4 (f32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 0x1.5p5, 0x1.5p5, 0x0p0, 0x1.5p5
; CHECK-NEXT:    f32x4.replace_lane $push1=, $pop0, 2, $0
; CHECK-NEXT:    return $pop1
  %v = insertelement
    <4 x float> <float 42., float 42., float 42., float 42.>,
    float %x,
    i32 2
  ret <4 x float> %v
}

define <4 x float> @different_const_one_replaced_f32x4(float %x) {
; CHECK-LABEL: different_const_one_replaced_f32x4:
; CHECK:         .functype different_const_one_replaced_f32x4 (f32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 0x1p0, 0x1p1, 0x0p0, 0x1p2
; CHECK-NEXT:    f32x4.replace_lane $push1=, $pop0, 2, $0
; CHECK-NEXT:    return $pop1
  %v = insertelement
    <4 x float> <float 1., float 2., float 3., float 4.>,
    float %x,
    i32 2
  ret <4 x float> %v
}

define <4 x i32> @splat_common_const_i32x4() {
; CHECK-LABEL: splat_common_const_i32x4:
; CHECK:         .functype splat_common_const_i32x4 () -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 0, 3, 3, 1
; CHECK-NEXT:    return $pop0
  ret <4 x i32> <i32 undef, i32 3, i32 3, i32 1>
}

define <8 x i16> @splat_common_arg_i16x8(i16 %a, i16 %b, i16 %c) {
; CHECK-LABEL: splat_common_arg_i16x8:
; CHECK:         .functype splat_common_arg_i16x8 (i32, i32, i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i16x8.splat $push0=, $2
; CHECK-NEXT:    i16x8.replace_lane $push1=, $pop0, 0, $1
; CHECK-NEXT:    i16x8.replace_lane $push2=, $pop1, 2, $0
; CHECK-NEXT:    i16x8.replace_lane $push3=, $pop2, 4, $1
; CHECK-NEXT:    i16x8.replace_lane $push4=, $pop3, 7, $1
; CHECK-NEXT:    return $pop4
  %v0 = insertelement <8 x i16> undef, i16 %b, i32 0
  %v1 = insertelement <8 x i16> %v0, i16 %c, i32 1
  %v2 = insertelement <8 x i16> %v1, i16 %a, i32 2
  %v3 = insertelement <8 x i16> %v2, i16 %c, i32 3
  %v4 = insertelement <8 x i16> %v3, i16 %b, i32 4
  %v5 = insertelement <8 x i16> %v4, i16 %c, i32 5
  %v6 = insertelement <8 x i16> %v5, i16 %c, i32 6
  %v7 = insertelement <8 x i16> %v6, i16 %b, i32 7
  ret <8 x i16> %v7
}

define <16 x i8> @swizzle_one_i8x16(<16 x i8> %src, <16 x i8> %mask) {
; CHECK-LABEL: swizzle_one_i8x16:
; CHECK:         .functype swizzle_one_i8x16 (v128, v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i8x16.swizzle $push0=, $0, $1
; CHECK-NEXT:    return $pop0
  %m0 = extractelement <16 x i8> %mask, i32 0
  %s0 = extractelement <16 x i8> %src, i8 %m0
  %v0 = insertelement <16 x i8> undef, i8 %s0, i32 0
  ret <16 x i8> %v0
}

define <16 x i8> @swizzle_all_i8x16(<16 x i8> %src, <16 x i8> %mask) {
; CHECK-LABEL: swizzle_all_i8x16:
; CHECK:         .functype swizzle_all_i8x16 (v128, v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i8x16.swizzle $push0=, $0, $1
; CHECK-NEXT:    return $pop0
  %m0 = extractelement <16 x i8> %mask, i32 0
  %s0 = extractelement <16 x i8> %src, i8 %m0
  %v0 = insertelement <16 x i8> undef, i8 %s0, i32 0
  %m1 = extractelement <16 x i8> %mask, i32 1
  %s1 = extractelement <16 x i8> %src, i8 %m1
  %v1 = insertelement <16 x i8> %v0, i8 %s1, i32 1
  %m2 = extractelement <16 x i8> %mask, i32 2
  %s2 = extractelement <16 x i8> %src, i8 %m2
  %v2 = insertelement <16 x i8> %v1, i8 %s2, i32 2
  %m3 = extractelement <16 x i8> %mask, i32 3
  %s3 = extractelement <16 x i8> %src, i8 %m3
  %v3 = insertelement <16 x i8> %v2, i8 %s3, i32 3
  %m4 = extractelement <16 x i8> %mask, i32 4
  %s4 = extractelement <16 x i8> %src, i8 %m4
  %v4 = insertelement <16 x i8> %v3, i8 %s4, i32 4
  %m5 = extractelement <16 x i8> %mask, i32 5
  %s5 = extractelement <16 x i8> %src, i8 %m5
  %v5 = insertelement <16 x i8> %v4, i8 %s5, i32 5
  %m6 = extractelement <16 x i8> %mask, i32 6
  %s6 = extractelement <16 x i8> %src, i8 %m6
  %v6 = insertelement <16 x i8> %v5, i8 %s6, i32 6
  %m7 = extractelement <16 x i8> %mask, i32 7
  %s7 = extractelement <16 x i8> %src, i8 %m7
  %v7 = insertelement <16 x i8> %v6, i8 %s7, i32 7
  %m8 = extractelement <16 x i8> %mask, i32 8
  %s8 = extractelement <16 x i8> %src, i8 %m8
  %v8 = insertelement <16 x i8> %v7, i8 %s8, i32 8
  %m9 = extractelement <16 x i8> %mask, i32 9
  %s9 = extractelement <16 x i8> %src, i8 %m9
  %v9 = insertelement <16 x i8> %v8, i8 %s9, i32 9
  %m10 = extractelement <16 x i8> %mask, i32 10
  %s10 = extractelement <16 x i8> %src, i8 %m10
  %v10 = insertelement <16 x i8> %v9, i8 %s10, i32 10
  %m11 = extractelement <16 x i8> %mask, i32 11
  %s11 = extractelement <16 x i8> %src, i8 %m11
  %v11 = insertelement <16 x i8> %v10, i8 %s11, i32 11
  %m12 = extractelement <16 x i8> %mask, i32 12
  %s12 = extractelement <16 x i8> %src, i8 %m12
  %v12 = insertelement <16 x i8> %v11, i8 %s12, i32 12
  %m13 = extractelement <16 x i8> %mask, i32 13
  %s13 = extractelement <16 x i8> %src, i8 %m13
  %v13 = insertelement <16 x i8> %v12, i8 %s13, i32 13
  %m14 = extractelement <16 x i8> %mask, i32 14
  %s14 = extractelement <16 x i8> %src, i8 %m14
  %v14 = insertelement <16 x i8> %v13, i8 %s14, i32 14
  %m15 = extractelement <16 x i8> %mask, i32 15
  %s15 = extractelement <16 x i8> %src, i8 %m15
  %v15 = insertelement <16 x i8> %v14, i8 %s15, i32 15
  ret <16 x i8> %v15
}

; Ensure we don't us swizzle
define <8 x i16> @swizzle_one_i16x8(<8 x i16> %src, <8 x i16> %mask) {
; CHECK-LABEL: swizzle_one_i16x8:
; CHECK:         .functype swizzle_one_i16x8 (v128, v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    global.get $push7=, __stack_pointer
; CHECK-NEXT:    i32.const $push8=, 16
; CHECK-NEXT:    i32.sub $push10=, $pop7, $pop8
; CHECK-NEXT:    local.tee $push9=, $2=, $pop10
; CHECK-NEXT:    v128.store 0($pop9), $0
; CHECK-NEXT:    i16x8.extract_lane_u $push0=, $1, 0
; CHECK-NEXT:    i32.const $push1=, 7
; CHECK-NEXT:    i32.and $push2=, $pop0, $pop1
; CHECK-NEXT:    i32.const $push3=, 1
; CHECK-NEXT:    i32.shl $push4=, $pop2, $pop3
; CHECK-NEXT:    i32.or $push5=, $2, $pop4
; CHECK-NEXT:    v128.load16_splat $push6=, 0($pop5)
; CHECK-NEXT:    return $pop6
  %m0 = extractelement <8 x i16> %mask, i32 0
  %s0 = extractelement <8 x i16> %src, i16 %m0
  %v0 = insertelement <8 x i16> undef, i16 %s0, i32 0
  ret <8 x i16> %v0
}

define <4 x i32> @half_shuffle_i32x4(<4 x i32> %src) {
; CHECK-LABEL: half_shuffle_i32x4:
; CHECK:         .functype half_shuffle_i32x4 (v128) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i8x16.shuffle $push0=, $0, $0, 0, 0, 0, 0, 8, 9, 10, 11, 0, 1, 2, 3, 0, 0, 0, 0
; CHECK-NEXT:    i32.const $push1=, 0
; CHECK-NEXT:    i32x4.replace_lane $push2=, $pop0, 0, $pop1
; CHECK-NEXT:    i32.const $push3=, 3
; CHECK-NEXT:    i32x4.replace_lane $push4=, $pop2, 3, $pop3
; CHECK-NEXT:    return $pop4
  %s0 = extractelement <4 x i32> %src, i32 0
  %s2 = extractelement <4 x i32> %src, i32 2
  %v0 = insertelement <4 x i32> undef, i32 0, i32 0
  %v1 = insertelement <4 x i32> %v0, i32 %s2, i32 1
  %v2 = insertelement <4 x i32> %v1, i32 %s0, i32 2
  %v3 = insertelement <4 x i32> %v2, i32 3, i32 3
  ret <4 x i32> %v3
}

define <16 x i8> @mashup_swizzle_i8x16(<16 x i8> %src, <16 x i8> %mask, i8 %splatted) {
  ; swizzle 0
; CHECK-LABEL: mashup_swizzle_i8x16:
; CHECK:         .functype mashup_swizzle_i8x16 (v128, v128, i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i8x16.swizzle $push0=, $0, $1
; CHECK-NEXT:    i8x16.replace_lane $push1=, $pop0, 3, $2
; CHECK-NEXT:    i32.const $push2=, 42
; CHECK-NEXT:    i8x16.replace_lane $push3=, $pop1, 4, $pop2
; CHECK-NEXT:    i8x16.replace_lane $push4=, $pop3, 12, $2
; CHECK-NEXT:    i32.const $push6=, 42
; CHECK-NEXT:    i8x16.replace_lane $push5=, $pop4, 14, $pop6
; CHECK-NEXT:    return $pop5
  %m0 = extractelement <16 x i8> %mask, i32 0
  %s0 = extractelement <16 x i8> %src, i8 %m0
  %v0 = insertelement <16 x i8> undef, i8 %s0, i32 0
  ; swizzle 7
  %m1 = extractelement <16 x i8> %mask, i32 7
  %s1 = extractelement <16 x i8> %src, i8 %m1
  %v1 = insertelement <16 x i8> %v0, i8 %s1, i32 7
  ; splat 3
  %v2 = insertelement <16 x i8> %v1, i8 %splatted, i32 3
  ; splat 12
  %v3 = insertelement <16 x i8> %v2, i8 %splatted, i32 12
  ; const 4
  %v4 = insertelement <16 x i8> %v3, i8 42, i32 4
  ; const 14
  %v5 = insertelement <16 x i8> %v4, i8 42, i32 14
  ret <16 x i8> %v5
}

define <16 x i8> @mashup_const_i8x16(<16 x i8> %src, <16 x i8> %mask, i8 %splatted) {
  ; swizzle 0
; CHECK-LABEL: mashup_const_i8x16:
; CHECK:         .functype mashup_const_i8x16 (v128, v128, i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    global.get $push8=, __stack_pointer
; CHECK-NEXT:    i32.const $push9=, 16
; CHECK-NEXT:    i32.sub $push11=, $pop8, $pop9
; CHECK-NEXT:    local.tee $push10=, $3=, $pop11
; CHECK-NEXT:    v128.store 0($pop10), $0
; CHECK-NEXT:    i8x16.extract_lane_u $push0=, $1, 0
; CHECK-NEXT:    i32.const $push1=, 15
; CHECK-NEXT:    i32.and $push2=, $pop0, $pop1
; CHECK-NEXT:    i32.or $push3=, $3, $pop2
; CHECK-NEXT:    v128.const $push4=, 0, 0, 0, 0, 42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 42, 0
; CHECK-NEXT:    v128.load8_lane $push5=, 0($pop3), $pop4, 0
; CHECK-NEXT:    i8x16.replace_lane $push6=, $pop5, 3, $2
; CHECK-NEXT:    i8x16.replace_lane $push7=, $pop6, 12, $2
; CHECK-NEXT:    return $pop7
  %m0 = extractelement <16 x i8> %mask, i32 0
  %s0 = extractelement <16 x i8> %src, i8 %m0
  %v0 = insertelement <16 x i8> undef, i8 %s0, i32 0
  ; splat 3
  %v1 = insertelement <16 x i8> %v0, i8 %splatted, i32 3
  ; splat 12
  %v2 = insertelement <16 x i8> %v1, i8 %splatted, i32 12
  ; const 4
  %v3 = insertelement <16 x i8> %v2, i8 42, i32 4
  ; const 14
  %v4 = insertelement <16 x i8> %v3, i8 42, i32 14
  ret <16 x i8> %v4
}

define <16 x i8> @mashup_splat_i8x16(<16 x i8> %src, <16 x i8> %mask, i8 %splatted) {
  ; swizzle 0
; CHECK-LABEL: mashup_splat_i8x16:
; CHECK:         .functype mashup_splat_i8x16 (v128, v128, i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    global.get $push8=, __stack_pointer
; CHECK-NEXT:    i32.const $push9=, 16
; CHECK-NEXT:    i32.sub $push11=, $pop8, $pop9
; CHECK-NEXT:    local.tee $push10=, $3=, $pop11
; CHECK-NEXT:    v128.store 0($pop10), $0
; CHECK-NEXT:    i8x16.extract_lane_u $push0=, $1, 0
; CHECK-NEXT:    i32.const $push1=, 15
; CHECK-NEXT:    i32.and $push2=, $pop0, $pop1
; CHECK-NEXT:    i32.or $push3=, $3, $pop2
; CHECK-NEXT:    i8x16.splat $push4=, $2
; CHECK-NEXT:    v128.load8_lane $push5=, 0($pop3), $pop4, 0
; CHECK-NEXT:    i32.const $push6=, 42
; CHECK-NEXT:    i8x16.replace_lane $push7=, $pop5, 4, $pop6
; CHECK-NEXT:    return $pop7
  %m0 = extractelement <16 x i8> %mask, i32 0
  %s0 = extractelement <16 x i8> %src, i8 %m0
  %v0 = insertelement <16 x i8> undef, i8 %s0, i32 0
  ; splat 3
  %v1 = insertelement <16 x i8> %v0, i8 %splatted, i32 3
  ; splat 12
  %v2 = insertelement <16 x i8> %v1, i8 %splatted, i32 12
  ; const 4
  %v3 = insertelement <16 x i8> %v2, i8 42, i32 4
  ret <16 x i8> %v3
}

define <4 x float> @undef_const_insert_f32x4() {
; CHECK-LABEL: undef_const_insert_f32x4:
; CHECK:         .functype undef_const_insert_f32x4 () -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    v128.const $push0=, 0x0p0, 0x1.5p5, 0x0p0, 0x0p0
; CHECK-NEXT:    return $pop0
  %v = insertelement <4 x float> undef, float 42., i32 1
  ret <4 x float> %v
}

define <4 x i32> @undef_arg_insert_i32x4(i32 %x) {
; CHECK-LABEL: undef_arg_insert_i32x4:
; CHECK:         .functype undef_arg_insert_i32x4 (i32) -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    i32x4.splat $push0=, $0
; CHECK-NEXT:    return $pop0
  %v = insertelement <4 x i32> undef, i32 %x, i32 3
  ret <4 x i32> %v
}

define <16 x i8> @all_undef_i8x16() {
; CHECK-LABEL: all_undef_i8x16:
; CHECK:         .functype all_undef_i8x16 () -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    return $0
  %v = insertelement <16 x i8> undef, i8 undef, i32 4
  ret <16 x i8> %v
}

define <2 x double> @all_undef_f64x2() {
; CHECK-LABEL: all_undef_f64x2:
; CHECK:         .functype all_undef_f64x2 () -> (v128)
; CHECK-NEXT:  # %bb.0:
; CHECK-NEXT:    return $0
  ret <2 x double> undef
}