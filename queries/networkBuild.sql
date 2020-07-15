# Create nodes for Gephi network graph
INSERT INTO nodes (id, label)
SELECT DISTINCT a.id, a.title FROM articles AS a, matches AS m WHERE a.id IN (m.citingId, m.citedId);
# Create edges for Gephi
INSERT INTO edges (`source`, target, weight)
SELECT citingId, citedId, 1 FROM matches;