// RUN: split-file %s %t
// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/BorovkovDepthMaxPass%shlibext --pass-pipeline="builtin.module(func.func(Bdepthmaxpass))" %t/firsttest.mlir | FileCheck %t/firsttest.mlir
// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/BorovkovDepthMaxPass%shlibext --pass-pipeline="builtin.module(func.func(Bdepthmaxpass))" %t/secondtest.mlir | FileCheck %t/secondtest.mlir
// RUN: mlir-opt -load-pass-plugin=%mlir_lib_dir/BorovkovDepthMaxPass%shlibext --pass-pipeline="builtin.module(func.func(Bdepthmaxpass))" %t/thirdtest.mlir | FileCheck %t/thirdtest.mlir

//--- firsttest.mlir
module{
    // CHECK: func.func @firsttest() attributes {DepthMax = 2 : i32} {
    func.func @firsttest() {
        %cond = arith.constant 1 : i1
        %0 = scf.if %cond -> (i1) {
            %inner_cond = arith.constant 1 : i1
            scf.yield %inner_cond : i1
        } else {
            %inner_cond = arith.constant 0 : i1
            scf.yield %inner_cond : i1
        }
        func.return
    }    
}

//--- secondtest.mlir
module{ 
    // CHECK: func.func @secondtest() -> i32 attributes {DepthMax = 1 : i32} {
    func.func @secondtest() -> i32 {
        %val = arith.constant 42 : i32
        func.return %val : i32
    }   
}

//--- thirdtest.mlir
module{
    // CHECK: func.func @thirdtest() attributes {DepthMax = 3 : i32} {
    func.func @thirdtest() {
        %cond = arith.constant 1 : i1
        %0 = scf.if %cond -> (i1) {
            %1 = scf.if %cond -> (i1) {
                %inner_cond = arith.constant 1 : i1
                scf.yield %inner_cond : i1
            } else {
                %inner_cond = arith.constant 0 : i1
                scf.yield %inner_cond : i1
            }
            scf.yield %cond : i1
        } else {
            %inner_cond = arith.constant 0 : i1
            scf.yield %inner_cond : i1
        }
        func.return
    }
}
