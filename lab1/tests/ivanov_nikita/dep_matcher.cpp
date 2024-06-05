// RUN: %clang_cc1 -load %llvmshlibdir/clangDepMatcher%pluginext -plugin deprecated-match %s 2>&1 | FileCheck %s --check-prefix=DEPRECATED
// REQUIRES: plugins

// DEPRECATED: warning: Deprecated in function name
void foo_deprecated(int a, int b);

// DEPRECATED: warning: Deprecated in function name
void deprecated(int c);

// DEPRECATED-NOT: warning: Deprecated in function name
void abc();

// RUN: %clang_cc1 -load %llvmshlibdir/clangDepMatcher%pluginext -plugin deprecated-match %s -plugin-arg-deprecated-match help 2>&1 | FileCheck %s --check-prefix=HELP
// REQUIRES: plugins

// HELP: Deprecated Plugin version 1.0
