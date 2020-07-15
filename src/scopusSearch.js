/**
 * Script to query the Scopus Search API
 */

// Packages for network requests and mysql connection
const axios = require('axios')
const mysql = require('mysql')

// Api variables
const apiKey = 'YOUR-API-KEY'
const query = 'TITLE-ABS-KEY(privacy)'
const cursorStart = '*'

// connect to db
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'secret',
    database: 'database'
})
connection.connect()

run(query, cursorStart, apiKey)

// Orchestrator
async function run(query, start, apiKey) {
    // Perform search
    const count = 200    // API default is 25, can query up to 200 articles each
    var run = true

    while(run) {
        const data = await searchQuery(start, count, query, apiKey)
        if(data.entry) {
            data.entry.forEach(e => addEntryToDb(e))
        } else {
            console.log('no entries')
            run = false
        }

        if(data.cursor['@next']) {
            start = data.cursor['@next']
        }
        console.log('Next cursor ' + start) // So you know where it stopped working
    }
}

// Perform search on Scopus search API
async function searchQuery(start, count, query, apiKey) {
    try {
        const { data } = await axios.get('https://api.elsevier.com/content/search/scopus', {
            params: {
                'apiKey' : apiKey,
                'query': query,
                'count': count,
                'cursor': start
            }
        })

        return data['search-results']
    } catch (error) {
        console.error(error)
    }
}

// Add article result to database
async function addEntryToDb(entry) {
    const article = {
        'url'            : entry['prism:url'],
        'scopusId'       : entry['dc:identifier'],
        'title'          : entry['dc:title'],
        'firstAuthor'    : entry['dc:creator'],
        'publicationName': entry['prism:publicationName'],
        'publicationDate': entry['prism:coverDate'],
        'doi'            : entry['prism:doi'],
        'citedByCount'   : entry['citedby-count'],
    }

    if(!article.title) { article.title = "" }

    const query = 'INSERT INTO articles (url, scopusId, title, firstAuthor, publicationName, publicationDate, doi, citedByCount) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'

    connection.query(query, [article.url, article.scopusId, article.title, article.firstAuthor,
        article.publicationName, article.publicationDate, article.doi, article.citedByCount],
        await function(error, results, fields) {
            if(error) throw error
        }
    )
}