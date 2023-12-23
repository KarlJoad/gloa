(define-module (gloa utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 ftw)
  #:export (string-split-substring
            mkdir-p
            delete-file-recursively
            find-extension))

(define (string-split-substring str substr)
  "Split the string @var{str} into a list of substrings delimited by the
substring @var{substr}."

  (define substrlen (string-length substr))
  (define strlen (string-length str))

  (define (loop index start)
    (cond
     ((>= start strlen) (list ""))
     ((not index) (list (substring str start)))
     (else
      (cons (substring str start index)
            (let ((new-start (+ index substrlen)))
              (loop (string-contains str substr new-start)
                    new-start))))))

  (cond
   ((string-contains str substr) => (lambda (idx) (loop idx 0)))
   (else (list str))))

;; Taken directly from (guix build utils)
(define (mkdir-p dir)
  "Create directory DIR and all its ancestors."
  (define absolute?
    (string-prefix? "/" dir))

  (define not-slash
    (char-set-complement (char-set #\/)))

  (let loop ((components (string-tokenize dir not-slash))
             (root       (if absolute?
                             ""
                             ".")))
    (match components
      ((head tail ...)
       (let ((path (string-append root "/" head)))
         (catch 'system-error
           (lambda ()
             (mkdir path)
             (loop tail path))
           (lambda args
             (if (= EEXIST (system-error-errno args))
                 (loop tail path)
                 (apply throw args))))))
      (() #t))))

;; Taken from (guix build utils)
(define-syntax-rule (warn-on-error expr file)
  (catch 'system-error
    (lambda ()
      expr)
    (lambda args
      (format (current-error-port)
              "warning: failed to delete ~a: ~a~%"
              file (strerror
                    (system-error-errno args))))))

;; Taken from (guix build utils), modified slightly for ease of reading.
(define* (delete-file-recursively dir
                                  #:key follow-mounts?)
  "Delete DIR recursively, like `rm -rf', without following symlinks.  Don't
follow mount points either, unless FOLLOW-MOUNTS? is true.  Report but ignore
errors."
  (define (enter? dir stat result) ;; Should this directory/device be entered?
    (let ((dev (stat:dev (lstat dir))))
      (or follow-mounts?
          (= dev (stat:dev stat)))))
  (define (del-file file stat result)
    (warn-on-error (delete-file file) file))
  (define (del-dir dir stat result)
    (warn-on-error (rmdir dir) dir))

  (define (error file stat errno result)
    (format (current-error-port)
            "warning: failed to delete ~a: ~a~%"
            file (strerror errno)))

  (file-system-fold enter?     ; enter?
                    del-file   ; leaf
                    (const #t) ; down
                    del-dir    ; up
                    (const #t) ; skip
                    error      ; error
                    #t         ; init
                    dir        ; start-file-name
                    ;; Don't follow symlinks.
                    lstat))

(define (find-extension file)
  "Return the extension code (including the period) of FILE.
If FILE does not have an extension, the empty string is returned."
  (let ((extension-start-idx (string-index-right file #\.)))
    (if extension-start-idx
        (substring file extension-start-idx)
        "")))
