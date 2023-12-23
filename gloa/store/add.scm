(define-module (gloa store add)
  #:use-module (gloa config)
  #:use-module (gloa store entry)
  #:use-module (gloa utils)
  #:export (add-to-store))

(define (add-to-store article article-file-path)
  "Add ARTICLE to the document store and copying ARTICLE-FILE-PATH to the
document store."
  ;; TODO: Throw error if store has not already been created.
  (let* ((result-path (base32-file-name article article-file-path))
         (out (string-append (gloa-storage-directory) result-path)))
    (if (not (file-exists? out))
        (begin
          (copy-file article-file-path out)
          (chmod out #o644)
          (format (current-error-port) "Adding ~a to store with path ~a~%"
                  article out))
        (format (current-error-port) "~a already present in store at ~a! Not adding~%"
                article out))))
