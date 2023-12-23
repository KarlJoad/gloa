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
    (copy-file article-file-path out)
    (chmod out #o644)))
