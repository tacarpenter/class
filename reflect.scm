#lang scheme
; reflect.scm
; Glenn G. Chappell
; 11 Apr 2016
;
; For CS 331 Spring 2016
; Code from 4/11: Scheme Reflection


; ***** Macros *****


; A Scheme *macro* is a code transformation. We can use macros to write
; flow-of-control structures. A useful macro-definition word is
; define-syntax.


; while loop
(define-syntax while
  (syntax-rules ()
    ((while cond body ...)
     (let loop ()
       (if cond
           (begin
             body ...
             (loop))
           (display "")
           )
       )
     )
    )
  )

; Try:
;   (define i 0)
;   (while (< i 10) (print i) (newline) (set! i (+ i 1))

; for-each loop
(define-syntax foreach
  (syntax-rules ()
    ((foreach id list body ...)
     (let loop ((list2 list))
       (if (null? list2)
           (display "")
           (begin
             (let ((id (car list2)))
               body ...)
             (loop (cdr list2))
             )
           )
       )
     )
    )
  )
; Try:
;   (foreach i '(1 2 3 4) (print (* i i) (newline))

; range
; (range a b) returns range of consecutive integers from a to b.
; For example, (range 2 5) returns (2 3 4 5).
(define (range a b)
  (if (> a b)
      '()
      (cons a (range (+ a 1) b))
      )
  )

; Try:
;   (range 3 8)

; for-loop
; (for id a b expression ...) evaluates the given expressions for id
; equal to a, then a+1, and so on, up to b.
; Constructs (range a b), and thus is rather inefficient in its use of
; memory. (This *can* be fixed.)
(define-syntax for
  (syntax-rules ()
    ((for id a b body ...)
     (foreach id (range a b) body ...)
     )
    )
  )

; Try:
;   (for i 2 7 (print i) (newline))

