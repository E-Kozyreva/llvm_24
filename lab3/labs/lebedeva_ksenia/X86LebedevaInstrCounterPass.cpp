#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

class X86LebedevaInstrCounterPass : public MachineFunctionPass {
public:
  static inline char ID = 0;
  X86LebedevaInstrCounterPass() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &machFunc) override {
    DebugLoc debugLoc = machFunc.front().begin()->getDebugLoc();
    const TargetInstrInfo *instrInfo = machFunc.getSubtarget().getInstrInfo();

    Module &module = *machFunc.getFunction().getParent();
    GlobalVariable *globalVar = module.getGlobalVariable("ic");
    if (!globalVar) {
      globalVar = new GlobalVariable(
          module, IntegerType::get(module.getContext(), 64), false,
          GlobalValue::ExternalLinkage, nullptr, "ic");
    }

    for (auto &basicBlock : machFunc) {
      size_t count = basicBlock.size();
      BuildMI(basicBlock, basicBlock.begin(), debugLoc,
              instrInfo->get(X86::ADD64mi32))
          .addGlobalAddress(globalVar, 0, 0)
          .addImm(count);
    }

    return true;
  }
};

static RegisterPass<X86LebedevaInstrCounterPass>
    X("x86-lebedeva-instr-counter",
      "A pass counting the number of X86 machine instructions", false, false);
