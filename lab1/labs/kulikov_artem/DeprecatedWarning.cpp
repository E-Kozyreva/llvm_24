#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendPluginRegistry.h"

using namespace clang;

class WarnVisitor : public RecursiveASTVisitor<WarnVisitor> {
public:
    explicit WarnVisitor(ASTContext *Context) : Context(Context) {}

    bool VisitFunctionDecl(FunctionDecl *Func) {
        const char *name_data = Func->getName().data();
        if (std::string(name_data).find("deprecated") != std::string::npos) {
            DiagnosticsEngine &Diags = Context->getDiagnostics();
            unsigned DiagID = Diags.getCustomDiagID(DiagnosticsEngine::Warning,
                                                   "Function '%0' contains 'deprecated' in its name");
            Diags.Report(Func->getLocation(), DiagID) << name_data;
        }
        return true;
    }

private:
    ASTContext *Context;
};

class WarnConsumer : public ASTConsumer {
public:
    explicit WarnConsumer(CompilerInstance &CI) : Visitor(&CI.getASTContext()) {}

    void HandleTranslationUnit(ASTContext &Context) override {
        Visitor.TraverseDecl(Context.getTranslationUnitDecl());
    }

private:
    WarnVisitor Visitor;
};

class WarnPlugin : public clang::PluginASTAction {
public:
  std::unique_ptr<clang::ASTConsumer> CreateASTConsumer (
    clang::CompilerInstance &Compiler, llvm::StringRef InFile) override {
      return std::unique_ptr<clang::ASTConsumer>(new WarnConsumer(Compiler));
    }

protected:
  bool ParseArgs(const clang::CompilerInstance &Compiler, 
                 const std::vector<std::string> &args) override {
    return true;
  }
};

static FrontendPluginRegistry::Add<WarnPlugin>
X("warn-deprecated", "Prints a warning if a function name contains 'deprecated'");