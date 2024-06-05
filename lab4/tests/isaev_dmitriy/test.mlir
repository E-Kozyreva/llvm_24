// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/IsaevFMAPass%shlibext --pass-pipeline="builtin.module(llvm.func(IsaevFMAPass))" %s | FileCheck %s

module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<!llvm.ptr<272>, dense<64> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<271>, dense<32> : vector<4xi32>>, #dlti.dl_entry<!llvm.ptr<270>, dense<32> : vector<4xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<!llvm.ptr, dense<64> : vector<4xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<"dlti.stack_alignment", 128 : i32>, #dlti.dl_entry<"dlti.endianness", "little">>} {
  // CHECK-LABEL: @_Z8funcZerodd
  llvm.func local_unnamed_addr @_Z8funcZerodd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg0, %arg2  : f64
    %1 = llvm.fadd %0, %arg1  : f64
    llvm.return %1 : f64

    // CHECK: %0 = math.fma %arg0, %arg2, %arg1 : f64
    // CHECK-NEXT: llvm.return %0 : f64
  }

  // CHECK-LABEL: @_Z7funcOnedd
  llvm.func local_unnamed_addr @_Z7funcOnedd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}, %arg3: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg0, %arg1  : f64
    %1 = llvm.fadd %0, %arg2  : f64
    %2 = llvm.fmul %arg2, %arg3  : f64
    %3 = llvm.fadd %1, %2  : f64
    llvm.return %3 : f64

    // CHECK: %0 = math.fma %arg0, %arg1, %arg2 : f64
    // CHECK-NEXT: %1 = math.fma %arg2, %arg3, %0 : f64
    // CHECK-NEXT: llvm.return %1 : f64
  }

  // CHECK-LABEL: @_Z7funcTwodd
  llvm.func local_unnamed_addr @_Z7funcTwodd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg1, %arg2  : f64
    %1 = llvm.fadd %arg0, %arg1  : f64
    %2 = llvm.fsub %1, %arg2  : f64
    %3 = llvm.fadd %0, %arg0  : f64
    %4 = llvm.fadd %2, %3  : f64
    llvm.return %4 : f64

    // CHECK: %0 = llvm.fadd %arg0, %arg1  : f64
    // CHECK-NEXT: %1 = llvm.fsub %0, %arg2  : f64
    // CHECK-NEXT: %2 = math.fma %arg1, %arg2, %arg0 : f64
    // CHECK-NEXT: %3 = llvm.fadd %1, %2  : f64
    // CHECK-NEXT: llvm.return %3 : f64
  }

  // CHECK-LABEL: @_Z9funcThreedd
  llvm.func local_unnamed_addr @_Z9funcThreedd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.mlir.constant(-2.000000e+00 : f64) : f64
    %1 = llvm.fmul %arg0, %arg2  : f64
    %2 = llvm.fadd %1, %0  : f64
    %3 = llvm.fadd %2, %arg1  : f64
    llvm.return %3 : f64

    // CHECK: %0 = llvm.mlir.constant(-2.000000e+00 : f64) : f64
    // CHECK-NEXT: %1 = math.fma %arg0, %arg2, %0 : f64
    // CHECK-NEXT: %2 = llvm.fadd %1, %arg1  : f64
    // CHECK-NEXT: llvm.return %2 : f64
  }

  // CHECK-LABEL: @_Z8funcFourdd
  llvm.func local_unnamed_addr @_Z8funcFourdd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg0, %arg2  : f64
    %1 = llvm.fmul %0, %arg1  : f64
    %2 = llvm.fadd %0, %arg0  : f64
    %3 = llvm.fadd %2, %1  : f64
    llvm.return %3 : f64

    // CHECK: %0 = llvm.fmul %arg0, %arg2  : f64
    // CHECK-NEXT: %1 = llvm.fadd %0, %arg0  : f64
    // CHECK-NEXT: %2 = math.fma %0, %arg1, %1 : f64
    // CHECK-NEXT: llvm.return %2 : f64
  }

  // CHECK-LABEL: @_Z8funcFivedd
  llvm.func local_unnamed_addr @_Z8funcFivedd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg0, %arg1  : f64
    %1 = llvm.fadd %0, %arg2  : f64
    llvm.return %1 : f64

    // CHECK: %0 = math.fma %arg0, %arg1, %arg2 : f64
    // CHECK-NEXT: llvm.return %0 : f64
  }

  // CHECK-LABEL: @_Z7funcSixdd
  llvm.func local_unnamed_addr @_Z7funcSixdd(%arg0: f64 {llvm.noundef}, %arg1: f64 {llvm.noundef}, %arg2: f64 {llvm.noundef}) -> (f64 {llvm.noundef}) attributes {memory = #llvm.memory_effects<other = none, argMem = none, inaccessibleMem = none>, passthrough = ["mustprogress", "nofree", "norecurse", "nosync", "nounwind", "willreturn", ["uwtable", "2"], ["min-legal-vector-width", "0"], ["no-trapping-math", "true"], ["stack-protector-buffer-size", "8"], ["target-cpu", "x86-64"], ["target-features", "+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87"], ["tune-cpu", "generic"]]} {
    %0 = llvm.fmul %arg0, %arg1  : f64
    %1 = llvm.fadd %0, %arg2  : f64
    %2 = llvm.fadd %0, %1  : f64
    llvm.return %2 : f64

    // CHECK: %0 = llvm.fmul %arg0, %arg1  : f64
    // CHECK-NEXT: %1 = llvm.fadd %0, %arg2  : f64
    // CHECK-NEXT: %2 = llvm.fadd %0, %1  : f64
    // CHECK-NEXT: llvm.return %2 : f64
  }
}