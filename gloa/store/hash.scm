(define-module (gloa store hash)
  #:use-module (gloa config)
  #:use-module (gcrypt hash)
  #:use-module (rnrs bytevectors)
  #:use-module (gloa article)
  #:use-module (basexx base32) ;; bytevector->base32-string
  #:export (hash-document))

(define (hash-document file-path)
  "Return the hash for the document at FILE-PATH."
  (if (file-exists? file-path)
      (bytevector->base32-string (file-sha256 file-path))
      "0000000000000000000000000000000000000000000000000000"))
