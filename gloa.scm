(define-module (gloa)
  #:use-module (gloa config)
  #:use-module (gloa hello)
  #:use-module (system repl repl)
  #:declarative? #f
  #:export (gloa-main))

(define (set-user-module)
  (when (and ;; (not (assoc-ref opts 'ignore-dot-guile?)) ;; TODO: CLI flag for ignoring .guile
             guile-user-config
             (file-exists? guile-user-config))
    (load guile-user-config)))

(define* (gloa-main arg0 . args)
  ;; Add gloa site directory to Guile's load path so that user's can
  ;; easily import their own modules.
  (add-to-load-path (getcwd))
  (setlocale LC_ALL "")
  (hello-world)
  (save-module-excursion
   (lambda ()
     (set-user-module)
     ;; Do not exit repl on SIGINT.
     ((@@ (ice-9 top-repl) call-with-sigint)
      (lambda ()
        (start-repl))))))
