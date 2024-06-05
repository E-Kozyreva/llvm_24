add_llvm_library(clangDepMatcher MODULE deprecatedMatcher.cpp PLUGIN_TOOL clang)

if(WIN32 OR CYGWIN)
  set(LLVM_LINK_COMPONENTS
      Support
  )
  clang_target_link_libraries(clangDepMatcher PRIVATE
    clangAST
    clangBasic
    clangFrontend
    )
endif()

set(CLANG_TEST_DEPS "clangDepMatcher" ${CLANG_TEST_DEPS} PARENT_SCOPE)
