(define-module (gloa utils)
  #:export (string-split-substring))

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
