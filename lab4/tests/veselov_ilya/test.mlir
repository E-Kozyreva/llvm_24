// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/VeselovIlyaCounterFuncCalls%shlibext --pass-pipeline="builtin.module(VeselovIlyaCounterFuncCalls)" %s | FileCheck %s

module {
  llvm.func @_Z5emptyv() attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: llvm.func @_Z5emptyv() attributes {{.*}}countOfCalls = 2 : i32
    llvm.return
  }
  llvm.func @_Z3sumii(%arg0: i32 {llvm.noundef}, %arg1: i32 {llvm.noundef}) -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: llvm.func @_Z3sumii(%arg0: i32 {llvm.noundef}, %arg1: i32 {llvm.noundef}) -> (i32 {llvm.noundef}) attributes {{.*}}countOfCalls = 2 : i32
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
  llvm.func @_Z9test_funcv() -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: llvm.func @_Z9test_funcv() -> (i32 {llvm.noundef}) attributes {{.*}}countOfCalls = 0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(5 : i32) : i32
    %2 = llvm.mlir.constant(7 : i32) : i32
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %1, %3 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.store %2, %4 {alignment = 4 : i64} : i32, !llvm.ptr
    %5 = llvm.load %3 {alignment = 4 : i64} : !llvm.ptr -> i32
    %6 = llvm.load %4 {alignment = 4 : i64} : !llvm.ptr -> i32
    %7 = llvm.call @_Z3sumii(%5, %6) : (i32, i32) -> i32
    llvm.return %7 : i32
  }
  llvm.func @_Z10call_emptyv() attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: llvm.func @_Z10call_emptyv() attributes {{.*}}countOfCalls = 1 : i32
    llvm.call @_Z5emptyv() : () -> ()
    llvm.return
  }
  llvm.func @_Z13sum_and_emptyv() attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: llvm.func @_Z13sum_and_emptyv() attributes {{.*}}countOfCalls = 0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(2 : i32) : i32
    %2 = llvm.mlir.constant(3 : i32) : i32
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.call @_Z3sumii(%0, %1) : (i32, i32) -> i32
    llvm.store %4, %3 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.call @_Z5emptyv() : () -> ()
    %5 = llvm.load %3 {alignment = 4 : i64} : !llvm.ptr -> i32
    %6 = llvm.icmp "eq" %5, %2 : i32
    llvm.cond_br %6, ^bb1, ^bb2
  ^bb1:  // pred: ^bb0
    llvm.call @_Z10call_emptyv() : () -> ()
    llvm.br ^bb2
  ^bb2:  // 2 preds: ^bb0, ^bb1
    llvm.return
  }
}
