(define-module (gloa entry)
  #:use-module (gloa article)
  #:export (entry))

(define-record-type <entry>
  (make-entry metadata store-path)
  entry?
  ;; metadata is the document's metadata, which is stored in the database
  (metadata entry-metadata)
  ;; store-hash is the document's content's hash as a Base32-encoded SHA256
  ;; string
  (store-hash entry-store-hash)
  ;; store-path is the document's path inside of the store
  (store-path entry-store-path))
