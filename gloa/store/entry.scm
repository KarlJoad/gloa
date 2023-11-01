(define-module (gloa store entry)
  #:use-module (gloa config)
  #:use-module (gloa store hash)
  #:use-module (gloa article)
  #:use-module (gloa store hash)
  #:export (base32-file-name))

;; On Linux, most file systems have a maximum path length of 255 characters.
;; The hash we get is 52 characters, and if we assume the average user's storage
;; directory is ~50 characters, we still have ~150 to work with, so we should be
;; fine.
(define (base32-file-name article article-file-path)
  (let* ((title (article-title article))
         (title-down (string-downcase title))
         (fixed-title (string-join
                       (string-split title-down #\SPACE)
                       "-"
                       'infix))
         (extension (substring article-file-path
                               (string-index-right article-file-path #\.))))
    (string-append (hash-document article-file-path)
                   "-"
                   fixed-title
                   extension)))
