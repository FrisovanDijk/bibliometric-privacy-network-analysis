# Gephi network results with title and citedByCount
SELECT a.title, citedByCount, eigencentrality, clustering, eccentricity, closenesscentrality, harmonicclosenesscentrality, betweennesscentrality, modularity_class
FROM articles a, network n
WHERE a.id = n.id
ORDER BY citedByCount
    DESC LIMIT 100;

# Gephi network results with title and internal cited count
SELECT i.citedTitle, i.citedDate, a.citedByCount, i.iCited, i.citedDate, eigencentrality, clustering, eccentricity, closenesscentrality, harmonicclosenesscentrality, betweennesscentrality, modularity_class
FROM (SELECT citedId, citedTitle, substr(citedDate, 1, 4) AS citedDate, COUNT(id) as iCited FROM matches GROUP BY citedId ORDER BY COUNT(id) DESC) AS i, network n, articles a
WHERE i.citedId = n.id AND n.id = a.id
ORDER BY `i`.`iCited`  DESC LIMIT 50

# Data for most influential publications
## Overall data
SELECT i.citedTitle as title, a.firstAuthor, i.citedDate as year, a.citedByCount as overallCited, i.iCited as internallyCited, eigencentrality, betweennesscentrality
FROM (SELECT citedId, citedTitle, substr(citedDate, 1, 4) AS citedDate, COUNT(id) as iCited FROM matches GROUP BY citedId ORDER BY COUNT(id) DESC) AS i, network n, articles a
WHERE i.citedId = n.id AND n.id = a.id
ORDER BY `i`.`iCited`  DESC LIMIT 50

## Last 5 years
SELECT i.citedTitle as title, a.firstAuthor, i.citedDate as year, a.citedByCount as overallCited, i.iCited as internallyCited, eigencentrality, betweennesscentrality
FROM (SELECT citedId, citedTitle, substr(citedDate, 1, 4) AS citedDate, COUNT(id) as iCited FROM matches WHERE substr(citingDate, 1, 4) > 2014 GROUP BY citedId ORDER BY COUNT(id) DESC) AS i, network n, articles a
WHERE i.citedId = n.id AND n.id = a.id
ORDER BY `i`.`iCited`  DESC LIMIT 50

## 5-10 years
SELECT i.citedTitle as title, a.firstAuthor, i.citedDate as year, a.citedByCount as overallCited, i.iCited as internallyCited, eigencentrality, betweennesscentrality
FROM (SELECT citedId, citedTitle, substr(citedDate, 1, 4) AS citedDate, COUNT(id) as iCited FROM matches WHERE substr(citingDate, 1, 4) < 2015 AND substr(citingDate, 1, 4) > 2009 GROUP BY citedId ORDER BY COUNT(id) DESC) AS i, network n, articles a
WHERE i.citedId = n.id AND n.id = a.id
ORDER BY `i`.`iCited`  DESC LIMIT 50