(define-module (gloa store remove)
  #:use-module (gloa config)
  #:export (remove-from-store))

(define (remove-from-store article-path)
  (let ((out (string-append (gloa-storage-directory) article-path)))
    (delete-file out)))
