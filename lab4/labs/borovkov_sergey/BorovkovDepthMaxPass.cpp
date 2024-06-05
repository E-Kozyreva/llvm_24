#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/IR/Region.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Tools/Plugins/PassPlugin.h"
using namespace mlir;

namespace {
class BorovkovDepthMaxPass
    : public PassWrapper<BorovkovDepthMaxPass, OperationPass<func::FuncOp>> {
public:
  StringRef getArgument() const final { return "Bdepthmaxpass"; }
  StringRef getDescription() const final {
    return "Counts the max depth of region nests in a function.";
  }

  void runOnOperation() override {
    Operation *func = getOperation();
    int DepthMax = 1;
    func->walk([&](Operation *cur) {
      DepthMax = std::max(DepthMax, getDepthMax(cur, 0));
    });
    func->setAttr(
        "DepthMax",
        IntegerAttr::get(IntegerType::get(func->getContext(), 32), DepthMax));
  }

private:
  int getDepthMax(Operation *op, int currentDepth) {
    int DepthMax = currentDepth;
    for (auto &region : op->getRegions()) {
      for (auto &block : region.getBlocks()) {
        for (auto &nestedOp : block) {
          DepthMax =
              std::max(DepthMax, getDepthMax(&nestedOp, currentDepth + 1));
        }
      }
    }
    return DepthMax;
  }
};
} // namespace

MLIR_DECLARE_EXPLICIT_TYPE_ID(BorovkovDepthMaxPass)
MLIR_DEFINE_EXPLICIT_TYPE_ID(BorovkovDepthMaxPass)

PassPluginLibraryInfo getBorovkovDepthMaxPassPluginInfo() {
  return {MLIR_PLUGIN_API_VERSION, "Bdepthmaxpass", LLVM_VERSION_STRING,
          []() { PassRegistration<BorovkovDepthMaxPass>(); }};
}

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo mlirGetPassPluginInfo() {
  return getBorovkovDepthMaxPassPluginInfo();
}
