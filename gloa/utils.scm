(define-module (gloa utils)
  #:use-module (ice-9 match)
  #:export (string-split-substring
            mkdir-p))

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
