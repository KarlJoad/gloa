(define-module (gloa config)
  #:export (guile-user-config
            %default-db-location
            %default-storage-directory
            %default-user-config-location))

(define guile-user-config
  ;; The user's personal Guile REPL configuration.
  (and=> (getenv "HOME")
         (lambda (home)
           (string-append home "/.guile"))))

(define (%default-db-location)
  "The default location of Gloa's tracking database."
  (string-append
   (or (getenv "XDG_CACHE_HOME")
       (format #f "~a/.cache" (getenv "HOME")))
   "/gloa/gloa.sqlite"))

(define (%default-storage-directory)
  "The default location of Gloa's tracked documents."
  (string-append
   (or (getenv "XDG_DATA_HOME")
       (format #f "~a/.local" (getenv "HOME")))
   "/gloa/"))

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