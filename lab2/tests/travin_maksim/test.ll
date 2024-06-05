; RUN: opt -load-pass-plugin=%llvmshlibdir/TravinInlinePass%pluginext -passes=travin-inline-pass -S %s | FileCheck %s

;void func1() {
;  float a = 1.0f;
;  a += 1.0f;
;}
;
;void bar1() {
;  int a = 2;
;  func1();
;  a+=3;
;}

define dso_local void @_Z5func1v() {
entry:
  %a = alloca float, align 4
  store float 1.000000e+00, ptr %a, align 4
  %0 = load float, ptr %a, align 4
  %add = fadd float %0, 1.000000e+00
  store float %add, ptr %a, align 4
  ret void
}

define dso_local void @_Z4bar1v() {
entry:
  %a = alloca i32, align 4
  store i32 2, ptr %a, align 4
  call void @_Z5func1v()
  %0 = load i32, ptr %a, align 4
  %add = add nsw i32 %0, 3
  store i32 %add, ptr %a, align 4
  ret void
}

; CHECK: define dso_local void @_Z4bar1v() {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %a = alloca i32, align 4
; CHECK-NEXT:   store i32 2, ptr %a, align 4
; CHECK-NEXT:   br label %post-call
; CHECK: 0:                                                
; CHECK-NEXT:   %1 = alloca float, align 4
; CHECK-NEXT:   store float 1.000000e+00, ptr %1, align 4
; CHECK-NEXT:   %2 = load float, ptr %1, align 4
; CHECK-NEXT:   %3 = fadd float %2, 1.000000e+00
; CHECK-NEXT:   store float %3, ptr %1, align 4
; CHECK-NEXT:   br label %post-call
; CHECK: post-call:                                        
; CHECK-NEXT:   %4 = load i32, ptr %a, align 4
; CHECK-NEXT:   %add = add nsw i32 %4, 3
; CHECK-NEXT:   store i32 %add, ptr %a, align 4
; CHECK-NEXT:   ret void

;void func2(int) {
;  float a = 1.0f;
;  a += 1.0f;
;}
;
;void bar2() {
;  int a = 2;
;  func2(a);
;  a+=3;
;}

define dso_local void @_Z5func2i(i32 noundef %0) {
entry:
  %.addr = alloca i32, align 4
  %a = alloca float, align 4
  store i32 %0, ptr %.addr, align 4
  store float 1.000000e+00, ptr %a, align 4
  %1 = load float, ptr %a, align 4
  %add = fadd float %1, 1.000000e+00
  store float %add, ptr %a, align 4
  ret void
}

define dso_local void @_Z4bar2v() {
entry:
  %a = alloca i32, align 4
  store i32 2, ptr %a, align 4
  %0 = load i32, ptr %a, align 4
  call void @_Z5func2i(i32 noundef %0)
  %1 = load i32, ptr %a, align 4
  %add = add nsw i32 %1, 3
  store i32 %add, ptr %a, align 4
  ret void
}

; CHECK: define dso_local void @_Z4bar2v() {
; CHECK-NEXT: entry:
; CHECK-NEXT:  %a = alloca i32, align 4
; CHECK-NEXT:  store i32 2, ptr %a, align 4
; CHECK-NEXT:  %0 = load i32, ptr %a, align 4
; CHECK-NEXT:  call void @_Z5func2i(i32 noundef %0)
; CHECK-NEXT:  %1 = load i32, ptr %a, align 4
; CHECK-NEXT:  %add = add nsw i32 %1, 3
; CHECK-NEXT:  store i32 %add, ptr %a, align 4
; CHECK-NEXT:  ret void

;float func3() {
;  float a = 1.0f;
;  a += 1.0f;
;  return a;
;}
;
;void bar3() {
;  int a = 2;
;  func3();
;  a+=3;
;}

define dso_local noundef float @_Z5func3v() #0 {
entry:
  %a = alloca float, align 4
  store float 1.000000e+00, ptr %a, align 4
  %0 = load float, ptr %a, align 4
  %add = fadd float %0, 1.000000e+00
  store float %add, ptr %a, align 4
  %1 = load float, ptr %a, align 4
  ret float %1
}

define dso_local void @_Z4bar3v() #0 {
entry:
  %a = alloca i32, align 4
  store i32 2, ptr %a, align 4
  %call = call noundef float @_Z5func3v()
  %0 = load i32, ptr %a, align 4
  %add = add nsw i32 %0, 3
  store i32 %add, ptr %a, align 4
  ret void
}

; CHECK: define dso_local void @_Z4bar3v() {
; CHECK-NEXT:entry:
; CHECK-NEXT:  %a = alloca i32, align 4
; CHECK-NEXT:  store i32 2, ptr %a, align 4
; CHECK-NEXT:  %call = call noundef float @_Z5func3v()
; CHECK-NEXT:  %0 = load i32, ptr %a, align 4
; CHECK-NEXT:  %add = add nsw i32 %0, 3
; CHECK-NEXT:  store i32 %add, ptr %a, align 4
; CHECK-NEXT:  ret void

;void func4() {
;  float a = 1.0f;
;  a += 1.0f;
;}
;
;void bar4() {
;  int a = 2;
;  func4();
;  func4();
;  a+=3;
;}

define dso_local void @_Z5func4v() #0 {
entry:
  %a = alloca float, align 4
  store float 1.000000e+00, ptr %a, align 4
  %0 = load float, ptr %a, align 4
  %add = fadd float %0, 1.000000e+00
  store float %add, ptr %a, align 4
  ret void
}

define dso_local void @_Z4bar4v() #0 {
entry:
  %a = alloca i32, align 4
  store i32 2, ptr %a, align 4
  call void @_Z5func4v()
  call void @_Z5func4v()
  %0 = load i32, ptr %a, align 4
  %add = add nsw i32 %0, 3
  store i32 %add, ptr %a, align 4
  ret void
}

; CHECK: define dso_local void @_Z4bar4v() {
; CHECK-NEXT: entry:
; CHECK-NEXT: %a = alloca i32, align 4
; CHECK-NEXT: store i32 2, ptr %a, align 4
; CHECK-NEXT: br label %post-call
; CHECK: 0:                                             
; CHECK-NEXT: %1 = alloca float, align 4
; CHECK-NEXT: store float 1.000000e+00, ptr %1, align 4
; CHECK-NEXT: %2 = load float, ptr %1, align 4
; CHECK-NEXT: %3 = fadd float %2, 1.000000e+00
; CHECK-NEXT: store float %3, ptr %1, align 4
; CHECK-NEXT: br label %post-call
; CHECK: post-call:                                        
; CHECK-NEXT: br label %post-call1
; CHECK: 4:                                                
; CHECK-NEXT: %5 = alloca float, align 4
; CHECK-NEXT: store float 1.000000e+00, ptr %5, align 4
; CHECK-NEXT: %6 = load float, ptr %5, align 4
; CHECK-NEXT: %7 = fadd float %6, 1.000000e+00
; CHECK-NEXT: store float %7, ptr %5, align 4
; CHECK-NEXT: br label %post-call1
; CHECK: post-call1:                                       
; CHECK-NEXT: %8 = load i32, ptr %a, align 4
; CHECK-NEXT: %add = add nsw i32 %8, 3
; CHECK-NEXT: store i32 %add, ptr %a, align 4
; CHECK-NEXT: ret void
