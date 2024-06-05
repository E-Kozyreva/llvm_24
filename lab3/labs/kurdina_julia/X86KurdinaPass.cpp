#include "X86.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include <utility>
#include <vector>

using namespace llvm;

namespace {
class X86MulAddPass : public MachineFunctionPass {
public:
  static char ID;
  X86MulAddPass() : MachineFunctionPass(ID) {}
  bool runOnMachineFunction(MachineFunction &MF) override {
    const TargetInstrInfo *info = MF.getSubtarget().getInstrInfo();
    std::vector<std::pair<MachineInstr *, MachineInstr *>> del_instr;
    bool change = false;
    bool reg = false;

    for (auto &MBB : MF) {
      MachineInstr *mul_instr = nullptr;
      MachineInstr *add_instr = nullptr;
      Register reg_mul;
      Register reg_add_1;
      Register reg_add_2;
      for (auto &instr : MBB) {
        if (instr.getOpcode() == X86::MULPDrr) {
          mul_instr = &instr;
          auto next_instr = std::next(instr.getIterator());
          for (next_instr; next_instr != MBB.end(); ++next_instr) {
            if (next_instr->getOpcode() == X86::ADDPDrr) {
              add_instr = &*next_instr;
              reg_mul = mul_instr->getOperand(0).getReg();
              reg_add_1 = add_instr->getOperand(1).getReg();
              reg_add_2 = add_instr->getOperand(2).getReg();
              if (reg_mul == reg_add_1 || reg_mul == reg_add_2) {
                del_instr.emplace_back(mul_instr, add_instr);
                change = true;
                if (reg_mul == reg_add_1) {
                  reg = false;
                } else {
                  reg = true;
                }
                break;
              }
            } else if (next_instr->definesRegister(
                           mul_instr->getOperand(0).getReg())) {
              break;
            }
          }
        }
      }
    }

    for (auto &[mul, add] : del_instr) {
      MachineInstrBuilder builder =
          BuildMI(*mul->getParent(), *mul, mul->getDebugLoc(),
                  info->get(X86::VFMADD213PDZ128r));
      builder.addReg(add->getOperand(0).getReg(), RegState::Define);
      builder.addReg(mul->getOperand(1).getReg());
      builder.addReg(mul->getOperand(2).getReg());
      if (reg) {
        builder.addReg(add->getOperand(1).getReg());
      } else {
        builder.addReg(add->getOperand(2).getReg());
      }
      mul->eraseFromParent();
      add->eraseFromParent();
    }

    return change;
  }
};
} // namespace

char X86MulAddPass::ID = 0;
static RegisterPass<X86MulAddPass> X("x86-mul-add-pass", "X86 Kurdina Pass",
                                     false, false);
