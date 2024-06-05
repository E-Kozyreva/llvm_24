#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/Transforms/Utils/BasicBlockUtils.h"

using namespace llvm;

namespace {

class X86IsaevDMCounter : public MachineFunctionPass {
public:
  static char ID;
  X86IsaevDMCounter() : MachineFunctionPass(ID) {}
  bool runOnMachineFunction(llvm::MachineFunction &MF) override;
};
} // namespace

char X86IsaevDMCounter::ID = 0;

bool X86IsaevDMCounter::runOnMachineFunction(llvm::MachineFunction &MF) {
  auto *GV = MF.getFunction().getParent()->getNamedGlobal("ic");
  if (!GV) {
    LLVMContext &context = MF.getFunction().getParent()->getContext();
    GV = new GlobalVariable(*MF.getFunction().getParent(),
                            IntegerType::get(context, 64), false,
                            GlobalValue::ExternalLinkage, nullptr, "ic");
    GV->setAlignment(Align(8));
    if (!GV) {
      return false;
    }
  }
  auto DL = MF.front().begin()->getDebugLoc();
  auto *TII = MF.getSubtarget().getInstrInfo();

  for (auto &MBB : MF) {
    int Counter = std::distance(MBB.begin(), MBB.end());
    auto Place = MBB.getFirstTerminator();
    if (Place != MBB.end() && Place != MBB.begin() &&
        Place->getOpcode() >= X86::JCC_1 && Place->getOpcode() <= X86::JCC_4) {
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

static RegisterPass<X86IsaevDMCounter> X("x86-isaev-inst-counter",
                                         "Instruction counter", false, false);
