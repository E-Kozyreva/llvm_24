#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"

using namespace mlir;

namespace {
class KorablevFuncCountPass
    : public PassWrapper<KorablevFuncCountPass, OperationPass<ModuleOp>> {
public:
  StringRef getArgument() const final { return "korablev-func-count-pass"; }
  StringRef getDescription() const final {
    return "A pass that counts the number of times it has been called by other "
           "functions in the module";
  }

  void runOnOperation() override {
    std::map<StringRef, int> callCounter;
    ModuleOp module = getOperation();

    module.walk([&](LLVM::LLVMFuncOp funcOp) {
      funcOp.walk([&](LLVM::CallOp callOp) {
        StringRef fName = callOp.getCallee().value();
        callCounter[fName]++;
      });
    });

    module.walk([&](LLVM::LLVMFuncOp funcOp) {
      StringRef funcName = funcOp.getName();
      auto attrValue = IntegerAttr::get(
          IntegerType::get(funcOp.getContext(), 32), callCounter[funcName]);
      funcOp->setAttr("funcCallsCount", attrValue);
    });
  }
};
} // namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(KorablevFuncCountPass)
MLIR_DEFINE_EXPLICIT_TYPE_ID(KorablevFuncCountPass)

PassPluginLibraryInfo getKorablevFuncCountPassPluginInfo() {
  return {MLIR_PLUGIN_API_VERSION, "korablev-func-count-pass",
          LLVM_VERSION_STRING,
          []() { PassRegistration<KorablevFuncCountPass>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getKorablevFuncCountPassPluginInfo();
}
