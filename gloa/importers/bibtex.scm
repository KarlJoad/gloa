(define-module (gloa importers bibtex)
  #:use-module (ice-9 rdelim)
  #:use-module (srfi srfi-1)
  #:declarative? #t
  #:export (import-bibtex))

(define %tags-with-numbers
  '(number volume year))

(define (import-bibtex filename)
  "Import a BibTeX file to GLoA by parsing the file into an alist, which is
returned."
  ;; (with-input-from-file filename thunk) could work here too
  (let ((bibtex-info  (call-with-input-file filename parse-bibtex)))
    ;; TODO: Maybe convert dates too? Relevant Guile info manual sections.
    ;; (guile) Time
    ;; (guile) SRFI-19 Date
    ;; Usually the exact day is not important, only year and month.
    (organize-authors (convert-fields bibtex-info))))

(define (organize-authors bibtex-alist)
  "Split up and organize authors in BIBTEX-ALIST."
  (define author-delimiter " and ")
  (define (split-authors authors-string)
    "Split the AUTHORS-STRING into a list of strings of author names"
    (let ((start 0)
          (end (string-length authors-string))
          (split-idx (string-contains-ci authors-string author-delimiter))
          (authors-list '()))
      ;; Continue building up the list
      (while split-idx
        (set! authors-list (cons (substring/copy authors-string start split-idx) authors-list))
        (set! start (+ split-idx (string-length author-delimiter)))
        (set! split-idx (string-contains-ci authors-string author-delimiter start end)))
      ;; On last author or an article with just one author
      (set! authors-list (cons (substring/copy authors-string start end) authors-list))
      ;; Reverse and return the final list, as we cons-d later authors to the front
      (reverse authors-list)))
  ;; Make a copy of the original alist, so this update is not done in-place
  (let ((unmodified-tags (list-copy bibtex-alist))
        (authors-string (assoc-ref bibtex-alist 'author)))
    ;; Remove old author string and use new authors list
    (assoc-set! (assoc-remove! unmodified-tags 'author)
                'authors (split-authors authors-string))))

(define (convert-fields bibtex-alist)
  (define (check-field field-pair matching-list)
    "Check if the FIELD-PAIR (tag . val) has a tag in MATCHING-LIST."
    (let ((tag (car field-pair))
          (val (cdr field-pair)))
      (find (lambda (v) (eq? tag v)) matching-list)))
  (define (convert-tag tag-pair convert-fn)
    "Convert TAG-PAIR's value's type using CONVERT-FN."
    (let ((tag (car tag-pair))
          (val (cdr tag-pair)))
      (cons tag (convert-fn val))))
  (map (lambda (tag)
         (cond
          ((check-field tag %tags-with-numbers)
           (convert-tag tag string->number))
          (else tag)))
       bibtex-alist))

(define (parse-bibtex file-port)
  "Parse an opened file into an alist."
  (define trimming-character-set (char-set-union char-set:whitespace char-set:punctuation))
  (define (split-tag-string s) (string-split s #\=))
  (define (create-tag-pair tag-as-string)
    (cons (string->symbol (car tag-as-string))
          (string-trim (string-trim (cadr tag-as-string) trimming-character-set))))
  (with-input-from-port file-port
    (lambda ()
      ;; Use let* because reading must be properly sequenced
      (let* ((article-type (string-trim-both (read-delimited "{") trimming-character-set))
             (article-id   (string-trim-both (read-line) trimming-character-set))
             (tags-list    (read-bibtex-body)))
        ;; Convert list of tags to alist. Map tag -> entry
        `((type . ,article-type)
          (id . ,article-id)
          ,@(map (lambda (s) (create-tag-pair (split-tag-string s)))
             ;; Remove leading/trailing whitespace and trailing punctuation
             (map (lambda (s) (string-trim-both s trimming-character-set)) tags-list)))))))

(define (read-bibtex-body)
  "Read the body of tags for a BibTeX entry, returning a list of strings.
Each LINE of the BibTeX tag body is turned into one element of the list."
  (let ((tags-list '())
        (tag-line  (read-line)))
    (while (not (eof-object? tag-line))
      (set! tags-list (cons tag-line tags-list))
      (set! tag-line (read-line)))
    tags-list))
