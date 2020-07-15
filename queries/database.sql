CREATE TABLE articles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  url VARCHAR(255) NOT NULL,
  scopusId VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  firstAuthor VARCHAR(255),
  publicationName VARCHAR(255),
  publicationDate VARCHAR(255),
  doi VARCHAR(255),
  citedByCount INT NOT NULL
);

CREATE TABLE citations (
   id INT AUTO_INCREMENT PRIMARY KEY,
   articleId INT,
   scopusId BIGINT
);

CREATE TABLE matchedCitations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  citedBy BIGINT,
  cited BIGINT,
  title VARCHAR(255) NOT NULL
);

CREATE TABLE matches (
 id INT AUTO_INCREMENT PRIMARY KEY,
 citingId INT NOT NULL,
 citingTitle VARCHAR(255),
 citingDate VARCHAR(255),
 citedId INT NOT NULL,
 citedTitle VARCHAR(255),
 citedDate VARCHAR(255)
);

CREATE TABLE nodes (
    id INT NOT NULL,
    label VARCHAR(255),
    size INT
);

CREATE TABLE edges (
    source INT,
    target INT,
    weight INT
);

CREATE TABLE network (
 id INT PRIMARY KEY NOT NULL,
 title VARCHAR(255),
 eigencentrality DECIMAL(7,6),
 clustering DECIMAL(7,6),
 eccentricity INT,
 closenesscentrality DECIMAL(9,6),
 harmonicclosenesscentrality DECIMAL(9,6),
 betweennesscentrality DECIMAL(13,6),
 modularity_class INT
);