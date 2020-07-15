### GENERAL ANALYSIS QUERIES

# Number of collected publications
SELECT COUNT(id) FROM articles;

# Number of collected citations
SELECT COUNT(id) FROM citations;

# Total numbers for internal references, publications citing internally, publications cited internally
SELECT COUNT(id), COUNT(DISTINCT citingId), COUNT(DISTINCT citedId) FROM matches;

# Internal references per publication
SELECT citedTitle, COUNT(id) FROM matches GROUP BY citedId ORDER BY COUNT(id) DESC;

# Distribution of internal citations
SELECT cnt AS numberOfCitations, COUNT(*) AS occurrences
FROM ( SELECT COUNT(id) AS cnt FROM matches GROUP BY citedId) AS grp
GROUP BY cnt
ORDER BY occurrences DESC;

# Ratio distribution of internal vs external citations
SELECT res AS ratio, COUNT(*) as distribution
FROM ( SELECT cnt / articles.citedByCount AS res
       FROM (SELECT citedId, COUNT(id) AS cnt FROM matches GROUP BY citedId) AS grp, articles
       WHERE articles.id = grp.citedId ) AS fin
GROUP BY res
ORDER BY ratio DESC;

# The same query with a much fancier return
SELECT concat(10*floor(res/10), '-', 10*floor(res/10) + 9) AS ratio, COUNT(*) as distribution
FROM ( SELECT cnt / articles.citedByCount * 100 AS res
       FROM (SELECT citedId, COUNT(id) AS cnt FROM matches GROUP BY citedId) AS grp, articles
       WHERE articles.id = grp.citedId ) AS fin
GROUP BY ratio;

# Distribution of citings per year
SELECT substr(citingDate, 1, 4), COUNT(*) FROM matches GROUP BY substr(citingDate, 1, 4) ORDER BY substr(citingDate, 1, 4) DESC;
# Distributions of cited per year
SELECT substr(citedDate, 1, 4), COUNT(*) FROM matches GROUP BY substr(citedDate, 1, 4) ORDER BY substr(citedDate, 1, 4) DESC;
# Distributions of publications per year
SELECT substr(publicationDate, 1, 4), COUNT(*) FROM articles GROUP BY substr(publicationDate, 1, 4) ORDER BY substr(publicationDate, 1, 4) DESC;

# Citings per paper by publication year
SELECT substr(publicationDate, 1, 4) as PublicationYear,
       COUNT(*) as '# of pubs',
       cnt as '# of citings',
       cnt/COUNT(*) as 'citings per paper'
FROM articles, (
    SELECT substr(citingDate, 1, 4) as yr, COUNT(*) as cnt
    FROM matches
    GROUP BY substr(citingDate, 1, 4)
) as grp
WHERE yr = substr(publicationDate, 1, 4)
GROUP BY substr(publicationDate, 1, 4)
ORDER BY substr(publicationDate, 1, 4) DESC;

# Top cited externally
SELECT title, substr(publicationDate, 1, 4), citedByCount FROM articles ORDER BY citedByCount DESC LIMIT 25;

# Top cited internally
SELECT citedId, citedTitle, substr(citedDate, 1, 4), COUNT(id) FROM matches GROUP BY citedId ORDER BY COUNT(id) DESC LIMIT 25;