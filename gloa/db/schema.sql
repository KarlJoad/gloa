PRAGMA foreign_keys = ON;

-- Write-Ahead Log helps prevent SQLITE_LOCKED errors when there are several
-- readers. It does not work on Hurd though...
PRAGMA journal_mode = WAL;
-- TODO: When WAL2 goes mainline, switch journal_mode to that.
-- https://www.sqlite.org/cgi/src/doc/wal2/doc/wal2.md
-- Need to make an upgrade script for that.

DROP TABLE IF EXISTS documents;
CREATE TABLE IF NOT EXISTS documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT NOT NULL
    -- Path to document inside Gloa's configured store
    -- path TEXT NOT NULL DEFAULT ''
);

DROP TABLE IF EXISTS authors;
CREATE TABLE IF NOT EXISTS authors (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT NOT NULL COLLATE NOCASE,
    UNIQUE(name)
);

DROP TABLE IF EXISTS documents_authors_link;
CREATE TABLE documents_authors_link (
    id INTEGER PRIMARY KEY NOT NULL,
    author_id INTEGER NOT NULL,
    document_id INTEGER NOT NULL,
    FOREIGN KEY(author_id) REFERENCES authors(id),
    FOREIGN KEY(document_id) REFERENCES documents(id),
    UNIQUE(author_id,document_id) -- Pairing of document and author must be unique
);

DROP TABLE IF EXISTS doc_blobs;
CREATE TABLE IF NOT EXISTS files (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    path TEXT NOT NULL DEFAULT ''
);
