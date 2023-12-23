(define-module (gloa store entry)
  #:use-module (gloa config)
  #:use-module (gloa utils)
  #:use-module (gloa store hash)
  #:use-module (gloa article)
  #:export (base32-file-name))

;; On Linux, most file systems have a maximum path length of 255 characters.
;; The hash we get is 52 characters, and if we assume the average user's storage
;; directory is ~50 characters, we still have ~150 to work with, so we should be
;; fine.
(define (base32-file-name article article-file-path)
  "Create a base32-prefixed file name for the provided ARTICLE which exists at
ARTICLE-FILE-PATH.
NOTE: Gloa expects and requires that the @code{article-file-path} have a file
extension, which is started with a period!"
  (let* ((title (article-title article))
         (title-down (string-downcase title))
         (fixed-title (string-join
                       (string-split title-down #\SPACE)
                       "-"
                       'infix))
         ;; TODO: If extension is empty string, query user for file-type extension?
         (extension (find-extension article-file-path)))
    (string-append (hash-document article-file-path)
                   "-"
                   fixed-title
                   extension)))
