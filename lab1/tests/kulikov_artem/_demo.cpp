// RUN: split-file %s %t
// RUN: %clang_cc1 -load %llvmshlibdir/DeprecatedWarningPlugin%pluginext -add-plugin warn-deprecated -verify %t/bad_one.cpp 
// RUN: %clang_cc1 -load %llvmshlibdir/DeprecatedWarningPlugin%pluginext -add-plugin warn-deprecated -verify %t/good_one.cpp 

//--- good_one.cpp
// expected-no-diagnostics  
int sum(int a, int b) {
    return a + b;
}

void deprecate_sum(int a, int b) {
    ;
}


//--- bad_one.cpp
int _deprecated_sum(int a, int b) { // expected-warning {{Function '_deprecated_sum' contains 'deprecated' in its name}}
    return a + b;
}

void _sumdeprecated_(int a, int b) { // expected-warning {{Function '_sumdeprecated_' contains 'deprecated' in its name}}
    ;
}

void _sum_deprecated(int a, int b) { // expected-warning {{Function '_sum_deprecated' contains 'deprecated' in its name}}
    ;
}