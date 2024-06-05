#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"

using namespace mlir;

namespace {
class FunctionCallCounterPass
    : public PassWrapper<FunctionCallCounterPass, OperationPass<ModuleOp>> {
public:
  StringRef getArgument() const final { return "ulyanovFuncCallCount"; }
  StringRef getDescription() const final {
    return "Counts the number of calls to each function in the module";
  }

  void runOnOperation() override {
    std::map<StringRef, int> callCounter;

    getOperation()->walk([&](Operation *op) {
      if (auto call = dyn_cast<func::CallOp>(op)) {
        StringRef funcName = call.getCallee();
        callCounter[funcName]++;
      }
      if (auto call = dyn_cast<LLVM::CallOp>(op)) {
        StringRef funcName = call.getCallee().value();
        callCounter[funcName]++;
      }
    });

    getOperation()->walk([&](Operation *op) {
      if (auto func = dyn_cast<LLVM::LLVMFuncOp>(op)) {
        StringRef attrName = "numCalls";
        int numCalls = callCounter[func.getName()];
        auto attrValue =
            IntegerAttr::get(IntegerType::get(func.getContext(), 32), numCalls);
        func->setAttr(attrName, attrValue);
      }
      if (auto func = dyn_cast<func::FuncOp>(op)) {
        StringRef attrName = "numCalls";
        int numCalls = callCounter[func.getName()];
        auto attrValue =
            IntegerAttr::get(IntegerType::get(func.getContext(), 32), numCalls);
        func->setAttr(attrName, attrValue);
      }
    });
  }
};
} // namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(FunctionCallCounterPass)
MLIR_DEFINE_EXPLICIT_TYPE_ID(FunctionCallCounterPass)

PassPluginLibraryInfo getFunctionCallCounterPassPluginInfo() {
  return {MLIR_PLUGIN_API_VERSION, "ulyanovFuncCallCount", LLVM_VERSION_STRING,
          []() { PassRegistration<FunctionCallCounterPass>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getFunctionCallCounterPassPluginInfo();
}
