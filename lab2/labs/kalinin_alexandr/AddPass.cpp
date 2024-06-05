#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Pass.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"

using namespace llvm;

struct AddPass : public PassInfoMixin<AddPass> {
  PreservedAnalyses run(Function &Func,
                        FunctionAnalysisManager &FuncAnalysisMgr) {

    LoopInfo &LoopInf = FuncAnalysisMgr.getResult<LoopAnalysis>(Func);
    auto &Context = Func.getContext();
    Module *ParentModule = Func.getParent();
    FunctionType *FuncType = FunctionType::get(Type::getVoidTy(Context), false);

    for (auto &Loop : LoopInf) { // Iterate over all loops in the function
      BasicBlock *LoopHeader = Loop->getHeader();
      BasicBlock *PreheaderBlock = Loop->getLoopPreheader();
      IRBuilder<> IRBuild(LoopHeader->getContext());

      if (PreheaderBlock != nullptr) { // Check if the loop has a preheader
        bool IsLoopStartFunc = false;
        for (Instruction &Inst : *PreheaderBlock) {
          if (CallInst *Call = dyn_cast<CallInst>(&Inst)) {
            if (Call->getCalledFunction() &&
                Call->getCalledFunction()->getName() == "loop_start") {
              IsLoopStartFunc = true;
              break;
            }
          }
        }
        if (!IsLoopStartFunc) { // Check if the preheader block has a call to
                                // loop_start
          IRBuild.SetInsertPoint(PreheaderBlock->getTerminator());
          IRBuild.CreateCall(
              ParentModule->getOrInsertFunction("loop_start", FuncType));
        }
      }

      SmallVector<BasicBlock *, 8> ExitBlocks;
      Loop->getExitBlocks(ExitBlocks); // Get all exit blocks of the loop
      bool IsLoopEndFunc = false;
      for (BasicBlock *ExitBlock : ExitBlocks) { // Iterate over all exit blocks
        IsLoopEndFunc = false;
        for (Instruction &Inst : *ExitBlock) {
          if (CallInst *Call = dyn_cast<CallInst>(&Inst)) {
            if (Call->getCalledFunction() &&
                Call->getCalledFunction()->getName() == "loop_end") {
              IsLoopEndFunc = true;
              break;
            }
          }
        }
        if (!IsLoopEndFunc) { // Check if the exit block has a call to loop_end
          IRBuild.SetInsertPoint(&*ExitBlock->getFirstInsertionPt());
          IRBuild.CreateCall(
              ParentModule->getOrInsertFunction("loop_end", FuncType));
        }
      }
    }
    return PreservedAnalyses::all();
  }
};

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "AddNewPlugin", LLVM_VERSION_STRING,
          [](llvm::PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](llvm::StringRef Name, llvm::FunctionPassManager &PM,
                   llvm::ArrayRef<llvm::PassBuilder::PipelineElement>) {
                  if (Name == "loop_func_kalinin") {
                    PM.addPass(AddPass());
                    return true;
                  }
                  return false;
                });
          }};
}
