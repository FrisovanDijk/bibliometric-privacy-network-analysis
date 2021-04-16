/**
 * Script to call on the Scopus Bibliography API
 *
 * START SCRIPT: node scopusBibliography.js <startAt> <stopAt> <API key>
 *     startAt - The internal publication id to start at
 *     stopAt - The internal publication id to stop at
 *     API key - The API key to use for this run
 */

// Packages for network requests and mysql
const axios = require('axios')
const mysql = require('mysql')

// Api variables
const startAt = process.argv[2]
const stopAt = process.argv[3]
const apiKey = process.argv[4]

// connect to db
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'secret',
    database: 'database'
})
connection.connect()

if(startAt && stopAt && apiKey) {
    run()
} else {
    console.log('Missing arguments')
    process.exit(0)
}

// Orchestrator
async function run() {
    connection.query(`SELECT id, url FROM articles WHERE id >= ${startAt} AND id <= ${stopAt}`, await async function(error, results) {
            if(error) throw error
            for(i = 0; i < results.length; i++) {
                const apiData = await apiRequest(results[i]['url'])
                const internalId = results[i]['id']

                if(apiData['item'].bibrecord.tail) {
                    const bibliography = apiData['item'].bibrecord.tail.bibliography.reference
                    await getIdFromBib(internalId, bibliography)
                }
            }
            console.log('Finished batch')
            process.exit(0)
        }
    )
}

// Get bibliography from scopus abstract API
async function apiRequest(url) {
    try {
        const { data } = await axios.get(url, {
            params: {
                'apiKey' : apiKey,
                'httpAccept' : 'application/json'
            }
        })
        return data['abstracts-retrieval-response']
    } catch (error) {
        console.error(error)
    }
}

async function getIdFromBib(articleId, bibliography) {

    if(bibliography instanceof Array) {
        bibliography.forEach(item => {
            try {
                const ids = item['ref-info']['refd-itemidlist'].itemid
                if(Array.isArray(ids)) {
                    ids.forEach(async itemId => {
                        if(itemId['@idtype'] === 'SGR') {
                            await addToDb({
                                'referencedBy': articleId,
                                'scopusId': itemId['$']
                            })
                        }
                    })
                } else {
                    if(ids instanceof Object) {
                        if(ids['@idtype'] === 'SGR') {
                            addToDb({
                                'referencedBy': articleId,
                                'scopusId': ids['$']
                            })
                        }
                    }
                }
            } catch (error) {
                console.log(item['ref-info']['refd-itemidlist'])
                throw error
            }
        })
    } else {
        // Because sometimes it's an object instead of an array
        if(bibliography instanceof Object) {
            try {
                const ids = bibliography['ref-info']['refd-itemidlist'].itemid
                if(Array.isArray(ids)) {
                    ids.forEach(async itemId => {
                        if(itemId['@idtype'] === 'SGR') {
                            await addToDb({
                                'referencedBy': articleId,
                                'scopusId': itemId['$']
                            })
                        }
                    })
                } else {
                    if(ids instanceof Object) {
                        if(ids['@idtype'] === 'SGR') {
                            addToDb({
                                'referencedBy': articleId,
                                'scopusId': ids['$']
                            })
                        }
                    }
                }
            } catch (error) {
                console.log(item['ref-info']['refd-itemidlist'])
                throw error
            }
        }
    }

    let length = 1
    if(bibliography instanceof Array) {
        length = bibliography.length
    }
    console.log('Added ' + length + ' citations for ' + articleId)
}

async function addToDb(item) {
    const query = 'INSERT INTO citations (articleId, scopusId) VALUES (?,?)'

    connection.query(query, [item.referencedBy, item.scopusId], await function(error, results, fields) {
            if(error) throw error
        }
    )
}