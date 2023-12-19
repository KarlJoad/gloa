(define-module (gloa db)
  #:use-module (sqlite3)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 exceptions)
  #:use-module (gloa utils)
  #:export (init-db
            open-db
            close-db

            sqlite-operation
            query*
            with-db

            &no-sql-match-exception
            make-no-sql-match-exception
            no-sql-match-exception?))

(define %GLOA_SCHEMA_FILE "data/schema.sql")

;; See https://www.sqlite.org/capi3ref.html for how SQLite behaves internally,
;; which directs how guile-sqlite3 and its API behave.

(define (create-db db-path)
  "Create a SQLite3 database with FILENAME and open for reading and writing,
returning it."
  (when (string-index-right db-path #\/)
    (mkdir-p (substring db-path 0
                        (string-index-right db-path #\/))))
  (sqlite-open db-path (logior SQLITE_OPEN_READWRITE SQLITE_OPEN_CREATE)))

(define (init-db db-path)
  "Initialize the database with the schema in %GLOA_SCHEMA_FILE."
  (let ((db (create-db db-path)))
    (sqlite-exec db (call-with-input-file %GLOA_SCHEMA_FILE get-string-all))
    db))

(define (open-db db-path)
  "Open the SQLite3 database at the provided DB-PATH.
If the database has not been created at DB-PATH, an error is raised.
Requires that db-path actually be an SQLite3 database."
  (sqlite-open db-path (logior SQLITE_OPEN_READWRITE)))

(define (close-db db)
  "Close the provided DB connection."
  (sqlite-close db))


;;; A more useful/higher-level API to interact with the database.
;;; Thanks oldiob for the code. It makes understanding and using guile-sqlite3
;;; possible.
;;; From https://gitlab.com/oldiob/inf8601-handout/-/blob/master/handout/db.scm

(define (sqlite-operation db transform sql . bindings)
  "Perform a database operation on DB according to the SQL provided. By default,
a list of vectors is returned, i.e. the form (list (vector 'data1 'data2) ...).
You can transform the elements by providing a TRANSFORM function, which must take
in a vector and return your desired data type. The SQL string may contain
identifiers of the form \":identifier\" which are substituted based on the
\"alists\" provided.

For example, (sqlite-transaction the-db identity \"DELETE FROM :table\" (table \"theTable\"))
would delete \"theTable\" by substituting \":table\" from the SQL statement with
the value of \"table\" in the list of bindings."
  (let ((stmt (sqlite-prepare db sql))) ; Prepare the database for an operation
    ;; For each :id, bind :id in the SQL statement to its corresponding value from key+val
    (for-each (lambda (key+val)
                (sqlite-bind stmt
                             (car key+val)
                             (cdr key+val)))
              bindings)
    ;; Take the result we will get from evaluating the SQL with the provided
    ;; bindings and map the transform function over the result.
    (let ((result (sqlite-map transform stmt)))
      (sqlite-finalize stmt) ; Finalize database operation, ending the transaction
      result)))

;; See (guile) Parameters for how make-parameter works in detail.
;; In summary, parameters are thread-local unwind-protected dynamic variables,
;; which may be changed for a local dynamic scope.
(define current-connection (make-parameter #f))

;; Macro to transform/inline our database queries into a single procedure call.
(define-syntax query*
  ;; FIXME: Throw an error if query* is used outside of a with-db context.
  ;; See (guix monads) for an idea on how to implement this.
  (syntax-rules ()
    ;; If we do not specify a transformer function, then we call query* again,
    ;; using identity as the transformer function. (identity x) |- x.
    ((_ fmt (key value) ...)
     (query* identity fmt (key value) ...))
    ;; If a transformer function is specified, then we use the sqlite-query*
    ;; function and apply the transform to the data returned from the database.
    ;; Data is returned as a list of vectors, where each element in the list is
    ;; a vector of data (a row) from the database's tables and SQL query.
    ((_ transformer fmt (key value) ...)
     (sqlite-operation (current-connection) transformer fmt
                       `(key . ,value) ...))))

(define-syntax-rule (with-db uri body body* ...)
  "Perform actions inside the database specified by URI.
The body may be any sequence of actions to take on the database. Note that this
is implemented with a dynamic-wind, so the database may be opened and closed any
number of times."
  (dynamic-wind
    (lambda ()
      (current-connection (open-db uri)))
    (lambda () body body* ...)
    (lambda ()
      (and=> (current-connection #f) close-db))))

(define-exception-type &no-sql-match-exception &external-error
  make-no-sql-match-exception
  no-sql-match-exception?
  ;; (reason no-sql-match-exception-reason)
  )

(define (list-all-tables)
  "List all the tables in the current database."
  (query* "SELECT name FROM sqlite_schema WHERE type='table' ORDER BY name;"))
