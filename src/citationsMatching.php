<?php
$host = 'localhost';
$user = 'root';
$pass = 'secret';
$db = 'database';

$connection = mysqli_connect($host, $user, $pass, $db);

if(mysqli_connect_errno()) {
    echo 'Connection failed';
    exit();
}

$query1 = 'SELECT a.id as citedId, a.title as citedTitle, a.publicationDate as citedDate, c.articleId as citingId FROM articles a, citations c WHERE a.scopusId=c.scopusId AND a.id=?';
$query1a = 'SELECT a.title as citingTitle, a.publicationDate as citingDate FROM articles a WHERE a.id=?';
$query2 = 'INSERT INTO matches (citedId, citedTitle, citedDate, citingId, citingTitle, citingDate) VALUES (?, ?, ?, ?, ?, ?)';

for($i = $argv[1]; $i <= $argv[2]; $i++) {
    $matches = getMatches($i);

    if($matches) {
        foreach($matches as $match) {
            $enrich = enrichMatch($match['citingId'])->fetch_row();
            $match['citingTitle'] = $enrich[0];
            $match['citingDate'] = $enrich[1];
            addMatchToDb($match);
        }
    }
}

function getMatches($id) {
    global $connection, $query1;
    $statement = $connection->prepare($query1);
    $statement->bind_param('i', $id);
    $statement->execute();
    $results = $statement->get_result();
    $statement->close();

    echo 'Checked ' . $id . PHP_EOL;

    return $results;
}

function enrichMatch($citingId) {
    global $connection, $query1a;
    $statement = $connection->prepare($query1a);
    $statement->bind_param('i', $citingId);
    $statement->execute();
    $results = $statement->get_result();
    $statement->close();

    return $results;
}

function addMatchToDb($match) {
    global $connection, $query2;
    $statement = $connection->prepare($query2);
    $statement->bind_param('ississ', $match['citedId'], $match['citedTitle'], $match['citedDate'], $match['citingId'], $match['citingTitle'], $match['citingDate']);
    $statement->execute();
    echo 'Matched citation from ' . $match['citingId'] . ' to ' . $match['citedId'] . PHP_EOL;
    $statement->close();
}
