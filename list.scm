#lang scheme
; list.scm
; Glenn G. Chappell
; 8 Apr 2016
;
; For CS 331 Spring 2016
; Code from 4/8: Scheme Lists


; ***** Lists *****


; advance
; Given list (a b), returns (b a+b)
; Used by fibofast
(define (advance ab)
  (list (cadr ab) (+ (car ab) (cadr ab))
        )
  )

; Try:
;   (advance '(3 5))

(define (fibopair n)
  (if (= 0 n)
      '(1 0)
      (advance (fibopair (- n 1)))
      )
  )

; Try:
;   (fibopair 20)

(define (fibofast n)
  (cadr (fibopair n))
  )

; Try:
;   (fibofast 20)


; square
; One numeric parameter; returns its square
(define (square n)
  (* n n)
  )

; square2
; Same as square; defined using a lambda function
(define square2
  (lambda (n) (* n n))
  )

; mymap
; Same as map
(define (mymap f xs)
  (if (null? xs) '()
      (cons (f (car xs)) (map f (cdr xs)))
      )
  )

; Try:
;   (mymap square '(1 2 3 4 5))

(define (range a b)
  (if (>= a b)
      (list a)
      (cons a (range (+ 1 a) b))
      )
  )

; Try:
;   (mymap square (range 1 10))


; ***** Functions Taking Arbitrary Numbers of Parameters *****


; add2
; Addition of two numbers
; (add2 a b) is a+b
; Used by add
(define (add2 a b) (+ a b))

; add
; Same as +, but defined using only addition of pairs
; Example of function taking arbitrary number of arguments
; Uses a2
(define (add . p)
  (if (null? p) 0
      (add2 (car p) (apply add (cdr p)))
      )
  )
; Note: In our "define" above, we have (add . p), not (add p).
; Also, function "apply" is a nice convenience


; ***** Trees *****


; recinc
; 1 parameter, treated as binary tree of numbers
; Returns binary tree with same structure, and each number incremented
(define (recinc t)
  (if (null? t) '()
      (if (pair? t)
          (cons (recinc (car t)) (recinc (cdr t)))
          (+ 1 t)
          )
      )
  )
; Note the 3 cases above: null, pair, atom.

; Try:
;   (recinc '(1 2 (3 4) 5))

