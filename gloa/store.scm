(define-module (gloa store)
  #:use-module (gloa config)
  #:use-module (gloa utils)
  #:export (create-store))

(define (create-store)
  "Create a new document store at @code{gloa-storage-directory}."
  (mkdir-p (gloa-storage-directory)))
