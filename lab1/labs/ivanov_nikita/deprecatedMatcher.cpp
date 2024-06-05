#include "clang/AST/ASTConsumer.h"
#include "clang/AST/RecursiveASTVisitor.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/FrontendPluginRegistry.h"

using namespace clang;

class DepConsumer : public ASTConsumer {
  CompilerInstance &Instance;

public:
  explicit DepConsumer(CompilerInstance &CI) : Instance(CI) {}

  void HandleTranslationUnit(ASTContext &Context) override {
    struct Visitor : public RecursiveASTVisitor<Visitor> {
      ASTContext *Context;

      Visitor(ASTContext *Context) : Context(Context) {}

      bool VisitFunctionDecl(FunctionDecl *Func) {
        if (Func->getNameInfo().getAsString().find("deprecated") !=
            std::string::npos) {
          DiagnosticsEngine &Diags = Context->getDiagnostics();
          unsigned DiagID = Diags.getCustomDiagID(
              DiagnosticsEngine::Warning, "Deprecated in function name");
          Diags.Report(Func->getLocation(), DiagID)
              << Func->getNameInfo().getAsString();
        }
        return true;
      }
    } v(&Instance.getASTContext());

    v.TraverseDecl(Context.getTranslationUnitDecl());
  }
};

class DeprecatedPlugin : public PluginASTAction {
protected:
  std::unique_ptr<ASTConsumer>
  CreateASTConsumer(CompilerInstance &Compiler,
                    llvm::StringRef InFile) override {
    return std::make_unique<DepConsumer>(Compiler);
  }

  bool ParseArgs(const CompilerInstance &Compiler,
                 const std::vector<std::string> &args) override {
    if (!args.empty() && args[0] == "help")
      PrintHelp(llvm::errs());

    return true;
  }

  void PrintHelp(llvm::raw_ostream &ros) {
    ros << "Deprecated Plugin version 1.0\n";
  }
};

static FrontendPluginRegistry::Add<DeprecatedPlugin> X("deprecated-match",
                                                       "deprecated match");
