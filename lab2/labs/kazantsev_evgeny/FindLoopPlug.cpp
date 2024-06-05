#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/GraphTraits.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Support/Compiler.h"

using namespace llvm;

namespace {

struct ForWrapper : PassInfoMixin<ForWrapper> {
  llvm::PreservedAnalyses run(llvm::Function &F,
                              llvm::FunctionAnalysisManager &FA) {
    auto *FM = FunctionType::get(Type::getVoidTy(F.getContext()), false);
    auto LoopStartFunction =
        F.getParent()->getOrInsertFunction("loop_start", FM);
    auto LoopEndFunction = F.getParent()->getOrInsertFunction("loop_end", FM);
    IRBuilder<> Builder(F.getContext());

    auto &LA =
        FA.getResult<LoopAnalysis>(F); // Gets the result of loop analysis

    for (auto &L : LA) {
      auto *Head = L->getHeader();
      for (auto *const Pred : children<Inverse<BasicBlock *>>(Head)) {
        if (!L->contains(Pred)) {
          bool loopStartPresent = false;
          for (auto &I : *Pred) {
            if (auto *Call = dyn_cast<CallInst>(&I)) {
              if (Call->getCalledFunction() == LoopStartFunction.getCallee()) {
                loopStartPresent = true;
                break;
              }
            }
          }
          if (!loopStartPresent) {
            Builder.SetInsertPoint(Pred->getTerminator());
            Builder.CreateCall(
                LoopStartFunction); // вставка loop_start только если его нет
          }
        }
      }

      SmallVector<BasicBlock *, 8> ExitB;
      L->getUniqueExitBlocks(ExitB);
      for (auto *const Bb : ExitB) {
        bool loopEndPresent = false;
        for (auto &I : *Bb) {
          if (auto *Call = dyn_cast<CallInst>(&I)) {
            if (Call->getCalledFunction() == LoopEndFunction.getCallee()) {
              loopEndPresent = true;
              break;
            }
          }
        }
        if (!loopEndPresent) {
          Builder.SetInsertPoint(Bb->getFirstNonPHI());
          Builder.CreateCall(
              LoopEndFunction); // вставка loop_end только если его нет
        }
      }
    }

    auto PA = PreservedAnalyses::all();
    PA.abandon<LoopAnalysis>();
    return PA;
  }
};

} // namespace

extern "C" LLVM_ATTRIBUTE_WEAK ::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "KazantsevFindLoopPlug", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback( // Registers a callback function
                [](StringRef Name, llvm::FunctionPassManager &PM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "kazantsev-loop-pass") {
                    PM.addPass(ForWrapper());
                    return true;
                  }
                  return false;
                });
          }};
}
