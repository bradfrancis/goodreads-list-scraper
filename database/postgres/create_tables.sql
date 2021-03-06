-- DO
-- $$
-- BEGIN
--   IF NOT EXISTS(SELECT 1 FROM pg_database WHERE datname = 'GoodReads') THEN
--     PERFORM dblink_exec('dbname=' || current_database()
--       , 'CREATE DATABASE GoodReads'
--     );
--   END IF;
-- END
-- $$;

CREATE SCHEMA IF NOT EXISTS Staging;

DROP TABLE IF EXISTS Staging.JSONImport;

CREATE TABLE Staging.JSONImport
(
    json_import_id INT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    raw_data JSON,
    inserted_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC')
);

CREATE SCHEMA IF NOT EXISTS dbo;

DROP TABLE IF EXISTS dbo.ListItem;
DROP TABLE IF EXISTS dbo.Novel;
DROP TABLE IF EXISTS dbo.List;
DROP TABLE IF EXISTS dbo.Author;
DROP TABLE IF EXISTS dbo.Cover;
DROP TABLE IF EXISTS dbo.RatingInfo;

CREATE TABLE dbo.Author
(
    author_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    author_name varchar(150) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_AuthorID PRIMARY KEY (author_id),
    CONSTRAINT AK_AuthorName UNIQUE (author_name)
);

CREATE TABLE dbo.Cover
(
    cover_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    image_url varchar(500) NOT NULL,
    image_data bytea NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_CoverID PRIMARY KEY (cover_id),
    CONSTRAINT AK_ImageURL UNIQUE (image_url)
);

CREATE TABLE dbo.RatingInfo
(
    ratinginfo_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    avg_rating NUMERIC(3,2) NULL DEFAULT 0.00,
    total_ratings BIGINT NULL DEFAULT 0,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_RatingInfoID PRIMARY KEY (ratinginfo_id)
);

CREATE TABLE dbo.Novel
(
    novel_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    title varchar(250) NOT NULL,
    author_id INTEGER NOT NULL,
    cover_id INTEGER NULL,
    ratinginfo_id INTEGER NULL,
    started_reading TIMESTAMP WITHOUT TIME ZONE NULL,
    finished_reading TIMESTAMP WITHOUT TIME ZONE NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_NovelID PRIMARY KEY (novel_id),
    CONSTRAINT FK_Author_AuthorID FOREIGN KEY (author_id) REFERENCES dbo.Author(author_id),
    CONSTRAINT FK_Cover_CoverID FOREIGN KEY (cover_id) REFERENCES dbo.Cover(cover_id),
    CONSTRAINT FK_RatingInfo_RatingInfoID FOREIGN KEY (ratinginfo_id) REFERENCES dbo.RatingInfo(ratinginfo_id)
);

CREATE TABLE dbo.List
(
    list_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    list_name varchar(200) NOT NULL,
    description text NULL,
    url varchar(250) NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_ListID PRIMARY KEY (list_id)
);

CREATE TABLE dbo.ListItem
(
    list_item_id INT GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    list_id INT NOT NULL,
    current_rank smallint NOT NULL,
    previous_rank smallint NOT NULL,
    novel_id INT NOT NULL,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    modified TIMESTAMP WITHOUT TIME ZONE DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'),
    CONSTRAINT PK_ListItemID PRIMARY KEY (list_item_id),
    CONSTRAINT FK_List_ListID FOREIGN KEY (list_id) REFERENCES dbo.List(list_id),
    CONSTRAINT FK_Novel_NovelID FOREIGN KEY (novel_id) REFERENCES dbo.Novel(novel_id)
);



