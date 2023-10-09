(define emit (lambda args (apply simple-format #t args)
                          (newline)))

(define fixnum-shift 2)
(define fixnum-mask 3)

(define ptr-mask 7) ; mask for pointer type tag
(define ptr-mask-inv #xfffffff8) ; mask for pointer value

(define pair-tag 1)
(define vec-tag 2)
(define str-tag 3)
(define sym-tag 5)
(define closure-tag 6)

(define char-mask 255) ; character type mask
(define char-shift 8)
(define char-tag 7)

(define bool-mask 255)
(define bool-shift 8)
(define bool-tag 15)

;; Convenient function
(define (b<< x n) (ash x n))
(define (bor a b) (logior a b))
(define (band a b) (logand a b))

(define (immediate? x) (or (integer? x) (char? x) (boolean? x) (null? x)))

(define (immediate-rep x)
  (cond ((integer? x) (logand (ash x fixnum-shift) #xffffffff))
        ((char? x) (logior (ash (char->integer x) char-shift) char-tag))
        ((boolean? x)
         (if x 
             (logior (ash 1 bool-shift) bool-tag)
             bool-tag))))

(define (compile-expr e)
  (cond 
   ((immediate? e) (emit "    i32.const ~a" (immediate-rep e)))
   ((primitive-call? e) (compile-primitive-call e))))

(define (emit-is-equal-to val)
  (emit "    i32.const ~a" val)
  (emit "    i32.eq")
  (emit "    i32.const 0")
  (emit "    call $sete")
  (emit "    i32.const ~a" bool-shift)
  (emit "    i32.shl")
  (emit "    i32.const ~a" bool-tag)
  (emit "    i32.or"))

(define (compile-primitive-call form)
  (case (primitive-op form)
    ((add1)
     (compile-expr (primitive-op-arg1 form))
     (emit "    i32.const ~a" (immediate-rep 1))
     (emit "    i32.add"))
    ((sub1)
     (compile-expr (primitive-op-arg1 form))
     (emit "    i32.const ~a" (immediate-rep 1))
     (emit "    i32.sub"))
    ; integer? - check whether the first arg is an integer
    ((integer?)
     (compile-expr (primitive-op-arg1 form))
     (emit "    i32.const ~a" fixnum-mask)
     (emit "    i32.and")
     (emit-is-equal-to 0))
    ; boolean? - check whether the first arg is a boolean
    ((boolean?)
     (compile-expr (primitive-op-arg1 form))
     (emit "    i32.const ~a" bool-mask)
     (emit "    i32.and")
     (emit-is-equal-to bool-tag))
    ; char? - check whether the first arg is a character
    ((char?)
     (compile-expr (primitive-op-arg1 form))
     (emit "    i32.const ~a" char-mask)
     (emit "    i32.and")
     (emit-is-equal-to char-tag))
    ; zero? - check whether the first arg is zero
    ((zero?)
     (compile-expr (primitive-op-arg1 form))
     (emit-is-equal-to 0))
    ((+)
     (compile-expr (primitive-op-arg1 form))
     (compile-expr (primitive-op-arg2 form))
     (emit "    i32.add"))
    ((-)
     (compile-expr (primitive-op-arg1 form))
     (compile-expr (primitive-op-arg2 form))
     (emit "    i32.sub"))
    ((*)
     (compile-expr (primitive-op-arg1 form))
     (compile-expr (primitive-op-arg2 form))
     (emit "    i32.const ~a" fixnum-shift)
     (emit "    i32.shr_u")
     (emit "    i32.mul"))
    ((=)
     (compile-expr (primitive-op-arg1 form))
     (compile-expr (primitive-op-arg2 form))
     (emit "    i32.eq")
     (emit "    i32.const 0")
     (emit "    call $sete")
     (emit "    i32.const ~a" bool-shift)
     (emit "    i32.shl")
     (emit "    i32.const ~a" bool-tag)
     (emit "    i32.or"))
    ((<)
     (compile-expr (primitive-op-arg1 form))
     (compile-expr (primitive-op-arg2 form))
     (emit "    call $cmpl")
     (emit "    i32.const 0")
     (emit "    call $setl")
     (emit "    i32.const ~a" bool-shift)
     (emit "    i32.shl")
     (emit "    i32.const ~a" bool-tag)
     (emit "    i32.or"))
    ((char=?)
     ;; Get the first character arg
     (compile-expr (primitive-op-arg1 form))
     ;; Convert to the real character binary value
     (emit "    i32.const ~a" char-shift)
     (emit "    i32.shr_u")
     ;; Get the second character arg
     (compile-expr (primitive-op-arg2 form))
     (emit "    i32.const ~a" char-shift)
     (emit "    i32.shr_u")
     (emit "    i32.eq")
     (emit "    i32.const 0")
     (emit "    call $sete")
     (emit "    i32.const ~a" bool-shift)
     (emit "    i32.shl")
     (emit "    i32.const ~a" bool-tag)
     (emit "    i32.or"))))


(define (compile-program program)
  (emit "(module")
  (emit "  (import \"asm_x86\" \"sete\" (func $sete (param i32 i32) (result i32)))")
  (emit "  (import \"asm_x86\" \"setl\" (func $setl (param i32 i32) (result i32)))")
  (emit "  (import \"asm_x86\" \"cmpl\" (func $cmpl (param i32 i32) (result i32)))")
  (emit "  (func (export \"scheme_entry\") (result i32)")
  (compile-expr program)
  (emit "  )")
  (emit ")"))

; Check whether the passed form is a primitive call (primcall) form
(define (primitive-call? form) (eq? 'primcall (car form)))

; Get the primitive operation from a passed primcall form
(define (primitive-op form) (cadr form))

; Get the Nth argument of a passed primcall form
(define (primitive-op-arg1 form) (caddr form))
(define (primitive-op-arg2 form) (cadddr form))

; Get all arguments of a passed primcall form
(define (primitive-op-args form) (cddr form))

(define (compile-to-wasm program)
  (begin
    (with-output-to-file "modules/compiled.wat"
      (lambda () (compile-program program)))
    ; (system "cargo run --release --bin wasm-compile rts/modules/compiled.wat modules/out.wat")
    (system "/Users/pancy/Code/practical-webassembly/wabt/bin/wat2wasm modules/compiled.wat -o bin/compiled.wasm")))

(define (compile-and-run program)
  (begin (compile-to-wasm program)
    (system "cd rts; cargo run")))


