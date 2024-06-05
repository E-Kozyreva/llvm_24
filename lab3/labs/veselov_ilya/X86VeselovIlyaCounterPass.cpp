#include "X86.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

class X86VeselovIlyaCounterPass : public MachineFunctionPass {
public:
  static char ID;
  X86VeselovIlyaCounterPass() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &mFunc) override {
    Module &mod = *mFunc.getFunction().getParent();
    LLVMContext &context = mod.getContext();
    GlobalVariable *gVar = mod.getGlobalVariable("ic");
    if (!gVar) {
      gVar = new GlobalVariable(mod, Type::getInt64Ty(context), false,
                                GlobalValue::ExternalLinkage, nullptr, "ic");
      gVar->setInitializer(ConstantInt::get(Type::getInt64Ty(context), 0));
    }
    const TargetInstrInfo *tii = mFunc.getSubtarget().getInstrInfo();
    DebugLoc dl = mFunc.front().begin()->getDebugLoc();

    for (auto &mbb : mFunc) {
      unsigned InstrCount = 0;
      for (auto &mi : mbb) {
        if (!mi.isDebugInstr())
          ++InstrCount;
      }
      auto pos = mbb.getFirstTerminator();
      if (pos != mbb.begin() && pos != mbb.end() &&
          pos->getOpcode() >= X86::JCC_1 && pos->getOpcode() <= X86::JCC_4)
        --pos;
      BuildMI(mbb, pos, dl, tii->get(X86::ADD64mi32))
          .addReg(0)
          .addImm(1)
          .addReg(0)
          .addGlobalAddress(gVar)
          .addReg(0)
          .addImm(InstrCount);
    }
    return true;
  }
};

char X86VeselovIlyaCounterPass::ID = 0;

static RegisterPass<X86VeselovIlyaCounterPass>
    X("x86-veselov-ilya-counter-pass",
      "Count number of machine instructions performed during execution of a "
      "function (excluding instruction counter increment)",
      false, false);
