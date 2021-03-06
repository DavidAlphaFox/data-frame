#lang racket/base

;; slr.rkt -- simple linear regression utilities
;;
;; This file is part of data-frame -- https://github.com/alex-hhh/data-frame
;; Copyright (c) 2018, 2020 Alex Harsányi <AlexHarsanyi@gmail.com>
;;
;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU Lesser General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
;; License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(require math/statistics
         plot/no-gui
         plot/utils
         racket/contract
         racket/format)

;; Simple linear regression parameters Y = alpha + beta * X.  r is the
;; correlation coefficient.
(struct slr (alpha beta r))

;; Compute linear regression parameters for the list of samples XS, YS,
;; optionally weighted by WS.
;;
;; https://en.wikipedia.org/wiki/Simple_linear_regression
(define (make-slr xs ys (ws #f))
  (let ((x-stats (update-statistics* empty-statistics xs ws))
        (y-stats (update-statistics* empty-statistics ys ws))
        (r (correlation xs ys)))
    (let* ((beta (* r (/ (statistics-stddev y-stats) (statistics-stddev x-stats))))
           (alpha (- (statistics-mean y-stats) (* beta (statistics-mean x-stats)))))
      ;; NOTE: +nan.0 and +inf.0 are numbers as far as `number?` is concerned.
      (and (rational? alpha) (rational? beta) (rational? r) (slr alpha beta r)))))

;; Return a function renderer for the linear regression defined by SLR
(define (slr-renderer slr)
  (function
   (lambda (x) (+ (slr-alpha slr) (* (slr-beta slr) x)))
   #:color '(#x2f #x4f #x4f)
   #:width 2
   #:label (format "r = ~a" (~r (slr-r slr) #:precision 2))))


;;............................................................. provides ....

(provide/contract
 (slr? (-> any/c boolean?))
 (make-slr (->* ((listof number?) (listof number?))
                ((listof number?))
                (or/c slr? #f)))
 (slr-renderer (-> slr? (treeof renderer2d?))))
