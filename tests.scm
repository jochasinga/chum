(use-modules (ice-9 popen) (ice-9 format) (ice-9 textual-ports))
(include "compiler.scm")

(define (pad-both str length pad-char)
  (let* ((str-length (string-length str))
         (total-padding (- length str-length))
         (left-padding (quotient total-padding 2))
         (right-padding (- total-padding left-padding)))
    (if (<= total-padding 0)
        str
        (string-append
         (make-string left-padding pad-char)
         str
         (make-string right-padding pad-char)))))

(define (compile-and-run-for-result pgm)
  (begin (compile-to-binary pgm)
         (chdir "rts")
         (let* ((port (open-input-pipe "./target/debug/rts"))
                (data (get-string-all port)))
           (chdir "../")
           (close-pipe port)
           (string-trim-both data))))

(define (test-section name) 
  (display (pad-both (format #f " ~a " name) 70 #\#)) (newline))

(define (test-case pgm result)
  (let ((res (compile-and-run-for-result pgm)))
    (if (equal? res result)
        (simple-format #t "success: ~a" pgm)
        (simple-format #t "FAILURE: ~a (~a | ~a)" pgm res result))
    (newline)))

(begin
  (test-section "Immediates: Fixnum")
  (test-case 1 "1")
  (test-case -17 "-17")
  (test-case 299999 "299999")
  (test-case 0 "0")

  (test-section "Immediates: Char")
  (test-case #\a "#\\a")

  (test-section "Immediates: Boolean")
  (test-case #t "#t")
  (test-case #f "#f")

  (test-section "Integer Unary Primitives")
  (test-case '(primcall add1 0) "1")
  (test-case '(primcall add1 7) "8")
  (test-case '(primcall add1 -1) "0")
  (test-case '(primcall add1 -1000) "-999")

  (test-case '(primcall sub1 0) "-1")
  (test-case '(primcall boolean? -12356) "#f")
  (test-case '(primcall boolean? #t) "#t")
  (test-case '(primcall boolean? #f) "#t")
  (test-case '(primcall boolean? #\q) "#f")

  (test-case '(primcall char? 0) "#f")
  (test-case '(primcall char? 1) "#f")
  (test-case '(primcall char? #\a) "#t")
  (test-case '(primcall char? #t) "#f")
  (test-case '(primcall char? #\f) "#t")
  (test-case '(primcall char? #\q) "#t")

  (test-section "Binary Integer Ops")
  (test-case '(primcall + 1 2) "3")
  (test-case '(primcall + -1 1) "0")
  (test-case '(primcall + -127 -909) "-1036")

  (test-case '(primcall - 123 23) "100")
  (test-case '(primcall - 4 8) "-4")

  (test-case '(primcall * 1000 1000) "1000000")
  (test-case '(primcall * 8 -2) "-16")

  (test-case '(primcall = 2 3) "#f")
  (test-case '(primcall = 3 3) "#t")
  (test-case '(primcall = 0 9) "#f")
  (test-case '(primcall = -7 -7) "#t")

  (test-case '(primcall < -7 7) "#t")
  (test-case '(primcall < -7 0) "#t")
  (test-case '(primcall < -7 -2) "#t")
  (test-case '(primcall < 0 5) "#t")
  (test-case '(primcall < 0 -5) "#f")
  (test-case '(primcall < 1 5) "#t")

  (test-section "Other Binary Ops")
  (test-case '(primcall char=? #\a #\b) "#f")
  (test-case '(primcall char=? #\a #\a) "#t"))
