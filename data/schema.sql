PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS documents;
CREATE TABLE IF NOT EXISTS documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT NOT NULL,
    authors TEXT NOT NULL
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
    document INTEGER NOT NULL,
    author INTEGER NOT NULL,
    UNIQUE(document, author) -- Pairing of document and author must be unique
);
