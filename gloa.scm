(define-module (gloa)
  #:use-module (gloa hello)
  #:export (gloa-main))

(define* (gloa-main arg0 . args)
  ;; Add gloa site directory to Guile's load path so that user's can
  ;; easily import their own modules.
  (add-to-load-path (getcwd))
  (setlocale LC_ALL "")
  (hello-world))
