add_llvm_library(vyunovAlwaysInlinePlugin MODULE AlwaysInlinePlugin.cpp PLUGIN_TOOL clang)

if(WIN32 OR CYGWIN)
  set(LLVM_LINK_COMPONENTS
    Support
  )
  clang_target_link_libraries(vyunovAlwaysInlinePlugin PRIVATE
    clangAST
    clangBasic
    clangFrontend
    )
endif()

set(CLANG_TEST_DEPS "vyunovAlwaysInlinePlugin" ${CLANG_TEST_DEPS} PARENT_SCOPE)
