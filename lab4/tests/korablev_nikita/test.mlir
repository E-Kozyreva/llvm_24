// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/KorablevFuncCountPass%shlibext --pass-pipeline="builtin.module(korablev-func-count-pass)" %s | FileCheck %s

module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr<270>, dense<32> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<271>, dense<32> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<272>, dense<64> : vector<4xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>, #dlti.dl_entry<"dlti.endianness", "little">>} {
  llvm.func @_Z3sumii(%arg0: i32 {llvm.noundef}, %arg1: i32 {llvm.noundef}) -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @_Z3sumii
  // CHECK-SAME: attributes {funcCallsCount = 2 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %1 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.store %arg1, %2 {alignment = 4 : i64} : i32, !llvm.ptr
    %3 = llvm.load %1 {alignment = 4 : i64} : !llvm.ptr -> i32
    %4 = llvm.load %2 {alignment = 4 : i64} : !llvm.ptr -> i32
    %5 = llvm.add %3, %4  : i32
    llvm.return %5 : i32
  }
  llvm.func @_Z4multii(%arg0: i32 {llvm.noundef}, %arg1: i32 {llvm.noundef}) -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @_Z4multii
  // CHECK-SAME: attributes {funcCallsCount = 1 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %arg0, %1 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.store %arg1, %2 {alignment = 4 : i64} : i32, !llvm.ptr
    %3 = llvm.load %1 {alignment = 4 : i64} : !llvm.ptr -> i32
    %4 = llvm.load %2 {alignment = 4 : i64} : !llvm.ptr -> i32
    %5 = llvm.mul %3, %4  : i32
    llvm.return %5 : i32
  }
  llvm.func @main() -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "norecurse", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @main
  // CHECK-SAME: attributes {funcCallsCount = 0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.mlir.constant(5 : i32) : i32
    %3 = llvm.mlir.constant(2 : i32) : i32
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %1, %4 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.store %2, %5 {alignment = 4 : i64} : i32, !llvm.ptr
    %6 = llvm.load %5 {alignment = 4 : i64} : !llvm.ptr -> i32
    %7 = llvm.call @_Z3sumii(%6, %3) : (i32, i32) -> i32
    llvm.store %7, %5 {alignment = 4 : i64} : i32, !llvm.ptr
    %8 = llvm.load %5 {alignment = 4 : i64} : !llvm.ptr -> i32
    %9 = llvm.call @_Z4multii(%8, %2) : (i32, i32) -> i32
    llvm.store %9, %5 {alignment = 4 : i64} : i32, !llvm.ptr
    %10 = llvm.load %5 {alignment = 4 : i64} : !llvm.ptr -> i32
    %11 = llvm.load %5 {alignment = 4 : i64} : !llvm.ptr -> i32
    %12 = llvm.call @_Z3sumii(%10, %11) : (i32, i32) -> i32
    llvm.store %12, %5 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.return %1 : i32
  }
}
