var sqlite3 = require('sqlite3').verbose()
const DBSOURCE = "db.sqlite"


let db = new sqlite3.Database(DBSOURCE, (err) => {
    if (err) {
        // Cannot open database
        console.error(err.message)
        throw err
    } else {
        console.log('Connected to the SQlite database.')
        db.run(`CREATE TABLE user (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL UNIQUE,
            timestamp TEXT
            )`, (err) => { });
        db.run(`CREATE TABLE logs (
                latitude NUMERIC,
                longitude NUMERIC,
                username TEXT,
                timestamp TEXT
                )`, (err) => { })
    }
})


module.exports = db
