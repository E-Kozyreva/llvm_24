#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"

using namespace mlir;

namespace {
class VeselovIlyaCounterFuncCalls
    : public PassWrapper<VeselovIlyaCounterFuncCalls, OperationPass<ModuleOp>> {
public:
  StringRef getArgument() const final { return "VeselovIlyaCounterFuncCalls"; }
  StringRef getDescription() const final {
    return "Counts amount of times it was called by other functions in the "
           "module";
  }

  void runOnOperation() override {
    ModuleOp mod = getOperation();
    std::map<StringRef, int> calls;
    mod.walk([&](LLVM::CallOp callOper) {
      StringRef callee = callOper.getCallee().value();
      calls[callee]++;
    });
    mod.walk([&](LLVM::LLVMFuncOp funcOper) {
      StringRef name = funcOper.getName();
      int countOfCalls = calls[name];
      auto val = IntegerAttr::get(IntegerType::get(funcOper.getContext(), 32),
                                  countOfCalls);
      funcOper->setAttr("countOfCalls", val);
    });
  }
};
} //  namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(VeselovIlyaCounterFuncCalls)
MLIR_DEFINE_EXPLICIT_TYPE_ID(VeselovIlyaCounterFuncCalls)

PassPluginLibraryInfo getVeselovIlyaCounterFuncCallsInfo() {
  return {MLIR_PLUGIN_API_VERSION, "VeselovIlyaCounterFuncCalls",
          LLVM_VERSION_STRING,
          []() { PassRegistration<VeselovIlyaCounterFuncCalls>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getVeselovIlyaCounterFuncCallsInfo();
}