#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

namespace {

class X86UlyanovInstCounterPass : public MachineFunctionPass {
public:
  static char ID;
  X86UlyanovInstCounterPass() : MachineFunctionPass(ID) {}
  bool runOnMachineFunction(llvm::MachineFunction &MF) override {
    auto *GV = MF.getFunction().getParent()->getNamedGlobal("ic");
    if (!GV) {
      Module *M = MF.getFunction().getParent();
      GV = new GlobalVariable(*M, IntegerType::get(M->getContext(), 64), false,
                              GlobalValue::ExternalLinkage, nullptr, "ic");
    }

    auto DL = MF.front().begin()->getDebugLoc();
    auto *TII = MF.getSubtarget().getInstrInfo();

    for (auto &MBB : MF) {
      int Counter = std::distance(MBB.begin(), MBB.end());
      auto Place = MBB.getFirstTerminator();

      if (Place != MBB.end() && Place != MBB.begin() &&
          Place->getOpcode() >= X86::JCC_1 &&
          Place->getOpcode() <= X86::JCC_4) {
        --Place;
      }
      BuildMI(MBB, Place, DL, TII->get(X86::ADD64mi32))
          .addReg(0)
          .addImm(1)
          .addReg(0)
          .addGlobalAddress(GV)
          .addReg(0)
          .addImm(Counter);
    }
    return true;
  }
};
} // namespace

char X86UlyanovInstCounterPass::ID = 0;
static RegisterPass<X86UlyanovInstCounterPass>
    X("x86-ulyanov-inst-cnt", "Instruction counter pass", false, false);
