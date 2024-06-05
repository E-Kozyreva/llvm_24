#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

using namespace llvm;

namespace {

struct TravinInlinePass : public PassInfoMixin<TravinInlinePass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    SmallVector<CallInst *, 8> CallsToInline;
    IRBuilder<> Builder(F.getContext());

    for (BasicBlock &BB : F) {
      for (Instruction &Instr : BB) {
        if (auto *CI = dyn_cast<CallInst>(&Instr)) {
          Function *Call = CI->getCalledFunction();

          if (Call && Call->arg_empty() && Call->getReturnType()->isVoidTy()) {
            CallsToInline.push_back(CI);
          }
        }
      }
    }

    for (auto *CI : CallsToInline) {
      BasicBlock *InsertionBlock = CI->getParent();
      ValueToValueMapTy ValueMap;

      BasicBlock *PostCallBB =
          InsertionBlock->splitBasicBlock(CI->getIterator(), "post-call");

      Function *Call = CI->getCalledFunction();
      BasicBlock *PrevBB = nullptr;
      BasicBlock *CurrentBB = nullptr;
      for (BasicBlock &CallBB : *Call) {
        CurrentBB = BasicBlock::Create(F.getContext(), "", &F, PostCallBB);
        ValueMap[&CallBB] = CurrentBB;

        Builder.SetInsertPoint(CurrentBB);
        for (Instruction &Inst : CallBB) {
          if (!Inst.isTerminator()) {
            Instruction *NewInst = Inst.clone();
            Builder.Insert(NewInst);
            ValueMap[&Inst] = NewInst;
          }
        }

        if (PrevBB) {
          if (PrevBB->getTerminator()) {
            PrevBB->getTerminator()->eraseFromParent();
          }
          Builder.SetInsertPoint(PrevBB);
          Builder.CreateBr(CurrentBB);
        }

        PrevBB = CurrentBB;
      }

      if (PrevBB) {
        if (PrevBB->getTerminator()) {
          PrevBB->getTerminator()->eraseFromParent();
        }
        Builder.SetInsertPoint(PrevBB);
        Builder.CreateBr(PostCallBB);
      }

      for (auto Iter = ValueMap.begin(); Iter != ValueMap.end(); ++Iter) {
        if (BasicBlock *NewBB = dyn_cast<BasicBlock>(Iter->second)) {
          for (Instruction &Inst : *NewBB) {
            for (Use &Op : Inst.operands()) {
              if (ValueMap.count(Op)) {
                Op.set(ValueMap[Op]);
              }
            }
          }
        }
      }

      for (auto &Use : CI->uses()) {
        User *User = Use.getUser();
        for (int i = 0; i < User->getNumOperands(); i++) {
          if (ValueMap.count(User->getOperand(i))) {
            User->getOperand(i)->replaceAllUsesWith(
                ValueMap[User->getOperand(i)]);
          }
        }
      }

      BasicBlock *PostCallBBNext = PostCallBB->getNextNode();
      if (PostCallBBNext) {
        Instruction *Term = PostCallBB->getTerminator();
        Term->eraseFromParent();
        Builder.SetInsertPoint(PostCallBB);
        Builder.CreateBr(PostCallBBNext);
      }

      CI->eraseFromParent();
    }

    return PreservedAnalyses::none();
  }
};

} // namespace

PassPluginLibraryInfo getTravinInlinePassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "TravinInlinePass", "v1.0",
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "travin-inline-pass") {
                    FPM.addPass(TravinInlinePass());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return getTravinInlinePassPluginInfo();
}
