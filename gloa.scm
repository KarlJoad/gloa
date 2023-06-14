(define-module (gloa)
  #:use-module (gloa hello)
  #:use-module (system repl repl)
  #:declarative? #f
  #:export (gloa-main))

(define guile-user-config
  ;; The user's personal Guile REPL configuration.
  (and=> (getenv "HOME")
         (lambda (home)
           (string-append home "/.guile"))))

(define (set-user-module)
  (when (and ;; (not (assoc-ref opts 'ignore-dot-guile?)) ;; TODO: CLI flag for ignoring .guile
             guile-user-config
             (file-exists? guile-user-config))
    (load guile-user-config)))

(define (%default-db-location)
  "The default location of Gloa's tracking database."
  (string-append
   (or (getenv "XDG_CACHE_HOME")
       (format #f "~a/.cache" (getenv "HOME")))
   "/gloa/gloa.sqlite"))

(define (%default-user-config-location)
  "Location of user's configuration of Gloa.
Searches for @code{$XDG_CONFIG_HOME/gloa/init.scm} first, if that is not found,
Gloa falls back to @code{$HOME/.gloa.d/init.scm}, and if that fails,
@code{$HOME/.gloa.scm} is searched for.
If none of those are found, no configuration changes to Gloa occur."
  (let ((config-dot-d (format #f "~a/.gloa.d" (getenv "HOME")))
        (dot-config (format #f "~a/.gloa.scm" (getenv "HOME"))))
    (cond ((getenv "XDG_CONFIG_HOME")
           (string-append (getenv "XDG_CONFIG_HOME") "/gloa/init.scm"))
          ((and (file-exists? config-dot-d) (file-is-directory? config-dot-d))
           (format #f "~a/init.scm" config-dot-d))
          (#t dot-config))))

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
