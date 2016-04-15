% fibo.pro
% Glenn G. Chappell
% 13 Apr 2016
%
% For CS 331 Spring 2016
% Compute Fibonacci Numbers


% fibo(+n, ?f)
% Has severe problems with stack overflow. Use fibofast instead.
fibo(0, 0).
fibo(1, 1).
fibo(N, F) :- N > 1,
              N1 is N-1, fibo(N1, F1),
              N2 is N-2, fibo(N2, F2),
              F is F1 + F2.

% Try:
%   fibo(3, 2).
%   fibo(3, 100).
%   fibo(3, F).


% advance([+a, ?b], [?c, ?d]).
advance([A, B], [C, D]) :- C = B, D is A + B.

% Try:
%   advance([5, 8], [8, 13]).
%   advance([5, 8], [10, 10]).
%   advance([5, 8], [C, D]).
%   advance([5, 8], P).
%   advance([5, B], [8, D]).

% fibopair(+n, [?a, ?b])
fibopair(0, [1, 0]).
fibopair(N, [X, Y]) :- N > 0, N1 is N-1, fibopair(N1, [A, B]),
                       advance([A, B], [X, Y]).

% Try:
%   fibopair(5, [3, 5]).
%   fibopair(5, [10, 20]).
%   fibopair(5, P).

% fibofast(+n, ?f)
fibofast(N, F) :- N >= 0, fibopair(N, [_, F]).

% Try:
%   fibofast(20, F).


% printfibos/0
printfibos :- write('Fibonacci Numbers'), nl, nl,
              for(I, 0, 42),
                fibofast(I, F),
                write('F('),
                write(I),
                write(') = '),
                write(F),
                nl,
              fail.

% Try:
%   printfibos.

