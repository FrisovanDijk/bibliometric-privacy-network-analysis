/**
 * Simple script to clean up the Scopus ID as it was gathered from the API and stored in the database.
 * Complementary to scopusSearch.js
 */

const mysql = require('mysql')

// connect to db
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'secret',
    database: 'database'
})
connection.connect()

run()

async function run() {
    connection.query(`SELECT id, scopusId FROM articles`, await async function(error, results) {
            if(error) throw error
            for(i = 0; i < results.length; i++) {
                const internalId = results[i]['id']
                const trueScopusId = results[i]['scopusId'].split('SCOPUS_ID:').pop()
                const query = 'UPDATE articles SET scopusId = ? WHERE id = ?'

                connection.query(query, [trueScopusId, internalId],
                    await function(error, results, fields) {
                        if(error) throw error
                    }
                )
            }
            console.log('Finished batch')
        }
    )
}