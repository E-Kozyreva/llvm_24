// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/ulyanovFuncCallCount%shlibext --pass-pipeline="builtin.module(ulyanovFuncCallCount)" %s | FileCheck %s

module {
  llvm.func @_Z5func1v() -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @_Z5func1v() {{.*}}attributes {{.*}}numCalls = 5 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(2 : i32) : i32
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %1, %2 {alignment = 4 : i64} : i32, !llvm.ptr
    %3 = llvm.load %2 {alignment = 4 : i64} : !llvm.ptr -> i32
    %4 = llvm.add %3, %1  : i32
    llvm.return %4 : i32
  }
  func.func @function1() -> i32 attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: func.func @function1() {{.*}}attributes {{.*}}numCalls = 2 : i32
    %0 = arith.constant 1 : i32
    return %0 : i32
  }
  func.func @function2() -> i32 attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: func.func @function2() {{.*}}attributes {{.*}}numCalls = 1 : i32
    %0 = call @function1() : () -> i32
    return %0 : i32
  }
  func.func @function3() -> i32 attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    // CHECK: func.func @function3() {{.*}}attributes {{.*}}numCalls = 0 : i32
    %0 = call @function1() : () -> i32
    %1 = call @function2() : () -> i32
    %2 = arith.addi %0, %1 : i32
    return %2 : i32
  }
  llvm.func @_Z5func2v() -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @_Z5func2v() {{.*}}attributes {{.*}}numCalls = 2 : i32
    %0 = llvm.call @_Z5func1v() : () -> i32
    %1 = llvm.call @_Z5func1v() : () -> i32
    %2 = llvm.add %0, %1  : i32
    llvm.return %2 : i32
  }
  llvm.func @_Z5func3v() attributes {passthrough = ["mustprogress", "noinline", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @_Z5func3v() {{.*}}attributes {{.*}}numCalls = 0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %2 = llvm.call @_Z5func1v() : () -> i32
    %3 = llvm.call @_Z5func2v() : () -> i32
    %4 = llvm.add %2, %3  : i32
    llvm.store %4, %1 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.return
  }
  llvm.func @main() -> (i32 {llvm.noundef}) attributes {passthrough = ["mustprogress", "noinline", "norecurse", "nounwind", "optnone", ["uwtable", "2"], ["frame-pointer", "all"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
  // CHECK: llvm.func @main() {{.*}}attributes {{.*}}numCalls = 0 : i32
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %3 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %4 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    %5 = llvm.alloca %0 x i32 {alignment = 4 : i64} : (i32) -> !llvm.ptr
    llvm.store %1, %2 {alignment = 4 : i64} : i32, !llvm.ptr
    %6 = llvm.call @_Z5func1v() : () -> i32
    llvm.store %6, %3 {alignment = 4 : i64} : i32, !llvm.ptr
    %7 = llvm.call @_Z5func2v() : () -> i32
    llvm.store %7, %4 {alignment = 4 : i64} : i32, !llvm.ptr
    %8 = llvm.call @_Z5func1v() : () -> i32
    %9 = llvm.load %3 {alignment = 4 : i64} : !llvm.ptr -> i32
    %10 = llvm.add %8, %9  : i32
    %11 = llvm.load %4 {alignment = 4 : i64} : !llvm.ptr -> i32
    %12 = llvm.add %10, %11  : i32
    llvm.store %12, %5 {alignment = 4 : i64} : i32, !llvm.ptr
    llvm.return %1 : i32
  }
}
