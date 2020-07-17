# Network analysis of literature

This is a repository offering the source code used in reviewing the network of the bibliometric record in privacy as offered by the Scopus API.

The Readme describes how to use the source code and the requirements, but understand that it was not written as a reusable piece of software, so it's a bit glued together at points.

## Contents

1. Requirements and setup
2. Data collection
3. Network creation
4. General analysis
5. Network analysis

## 1. Requirements and Setup

I used the following set of tools:
- Node
- PHP
- MySQL MariaDb
- Gephi

To access the full Elsevier APIs you need to be on the university network.

Create a database and use queries/database.sql to set up all tables.

All scripts were run from the command line.

You can get API keys from https://dev.elsevier.com/

##  2. Data Collection

The data collection uses several scripts. The Scopus APIs are limited in what they offer outside of the university network, so be aware of that. The scripts are used in the following order:
- scopusSearch.js
- cleanupScopusId.js
- scopusBibliography.js
- citationsMatching.php

### 1

Set up the `scopusSearch.js` with your API variables: API key and query. Set the database variables to match your own settings. Then run this script. If you expect more than 4 million results this script won't be sufficient.

### 2

When the search script is done, run `cleanupScopusId.js` to normalise the Scopus ID of the collected publications. Make sure to enter your database connection before starting.

### 3

Next up is `scopusBibliography.js`. Most of the collection work is in executing this script. The Scopus API limits API keys to 20.000 requests per week. For 100.000 publications you'd need at least 6 API keys to do it all at once, but this can be seen as malicious.

It's possible to run several instances of this script simultaneously, but from my experience more than 4 processes at once may introduce some duplicates to the dataset. MySQL tries to be ACID and Node sends multiple requests. When I ran 8 processes it managed to add the same reference 39 times, and no references appeared missing after checking about 10% of them through citation counts.

Remember to set up the database variables once again.

This script is uses additional arguments to enable running it multiple times and defining starting and stopping points.

    node scopusBibliography.js <startAt> <stopAt> <API key>

startAt, stopAt - the internal id's from the articles table. A range of up to 20.000 can be done on a single API key.

API key - the API key you want to use for this instance

### 4

`citationsMatching.php` finds internal references and adds them to the matches table. I wrote this quickly in PHP because everything in a single query was a bit much. I wanted a synchronous language, as it collects matches, enriches them and then adds them to the table. Run `queries/matchDuplicateFilter.sql` to clean any duplicates.

Set up the database variables and run the script, you don't even need an internet connection for this one.

By now you have your initial dataset with the following tables filled: articles, citations and matches (your internal references).

## 3. Network creation

Run the scripts in `queries/networkBuild.sql` to populate the data tables for Gephi. Then open Gephi and create a directed network from the database.

## 4. General analysis

The file `queries/generalAnalysis.sql` contains the queries I used to get an impression of the total dataset.

## 5. Network analysis

While the visual network analysis is mostly a visual thing, I will shortly describe the techniques used to create a good-looking network. It mostly comes down to fiddling and getting a feel for the tool for a few hours.

Initially all nodes in Gephi are placed at random. I found the ForceAtlas 2 algorithm to create a good-looking network and ran it until not much changed. Through rotation, expansion and contraction you can fine-tune the outcome.

Next you want to run your Network Analysis. In the right-hand panel you want to calculate the modularity, degree, avg. clustering coefficient and eigenvector centrality. When that's completed go to the Data Laboratory tab and click the `Export table` button.

Open the exported csv file and remove its headers. Then import that CSV to fill the network table. Now you can run the final queries from `queries/networkAnalysis.sql`
