#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"

using namespace mlir;

namespace {
class VyunovFMAPass
    : public PassWrapper<VyunovFMAPass, OperationPass<LLVM::LLVMFuncOp>> {
private:
  void handleMulOp(LLVM::FAddOp &addOp, LLVM::FMulOp &mulOp,
                   Value &otherOperand) {
    OpBuilder builder(addOp);
    Value fma = builder.create<LLVM::FMAOp>(addOp.getLoc(), mulOp.getOperand(0),
                                            mulOp.getOperand(1), otherOperand);
    addOp.replaceAllUsesWith(fma);
    addOp.erase();
  }

public:
  void runOnOperation() override {
    LLVM::LLVMFuncOp func = getOperation();
    // Add operation.
    func.walk([this](LLVM::FAddOp addOp) {
      Value addLHS = addOp.getOperand(0);
      Value addRHS = addOp.getOperand(1);
      if (auto mulOpLHS = addLHS.getDefiningOp<LLVM::FMulOp>()) {
        handleMulOp(addOp, mulOpLHS, addRHS);
      } else if (auto mulOpRHS = addRHS.getDefiningOp<LLVM::FMulOp>()) {
        handleMulOp(addOp, mulOpRHS, addLHS);
      }
    });

    // Mul operation.
    func.walk([](LLVM::FMulOp mulOp) {
      if (mulOp.use_empty()) {
        mulOp.erase();
      }
    });
  }
  StringRef getArgument() const final { return "vyunov_danila_fma"; }
  StringRef getDescription() const final {
    return "Replaces add and multiply operations with a single instruction.";
  }
};
} // namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(VyunovFMAPass)
MLIR_DEFINE_EXPLICIT_TYPE_ID(VyunovFMAPass)

PassPluginLibraryInfo getVyunovFMAPassPluginInfo() {
  return {MLIR_PLUGIN_API_VERSION, "vyunov_danila_fma", LLVM_VERSION_STRING,
          []() { PassRegistration<VyunovFMAPass>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getVyunovFMAPassPluginInfo();
}
