# Use this query to remove duplicate matches
DELETE FROM matches WHERE id IN (SELECT id FROM (SELECT id FROM matches GROUP BY citingId, citedId HAVING COUNT(*)>=2 ORDER BY COUNT(*) DESC ) AS m);