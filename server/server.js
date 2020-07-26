const express = require('express');
const app = express();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('./db.js');
const authenticateToken = require('./authenticate_token.js');

require('dotenv').config();

app.use(express.json());

app.get('/log', authenticateToken, (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    var params = [jwt.decode(token)];
    var query = "select * from logs where username = ?";
    db.all(query, params, (err, rows) => {
        if (err) {
            return res.status(400).json({
                "error": err.errno,
            });
        }
        return res.status(200).send(rows);
    });
})

app.post('/log', authenticateToken, (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    console.log(req.body);
    var params = [
        req.body.latitude,
        req.body.longitude,
        jwt.decode(token),
        Date.now()
    ];

    console.log(params);
    const query = "INSERT INTO logs (latitude, longitude, username, timestamp) VALUES(?,?,?,?)";
    db.run(query, params, (err, result) => {
        if (err) {
            console.log(err);
            return res.status(400).json({ "error": err.errno });
        }
        res.sendStatus(200);
    });
});

app.post('/login', (req, res, next) => {
    const username = req.body.username;
    const password = req.body.password;
    const query = "select * from user where username = ?";
    db.get(query, [username], (err, row) => {
        if (err) {
            return res.status(400).json({
                "error": err.errno,
                "message" : "db Error"
            })
        }
        if (row == null) {
            return res.status(404).json({
                "message": "Not found"
            })
        }
        try {
            if (bcrypt.compareSync(password, row.password)) {
                const accessToken = jwt.sign(username, process.env.ACCESS_TOKEN_SECRET);
                return res.json({
                    accessToken: accessToken
                });
            }
            return res.status(403).json({
                "message": "Incorrect Password"
            });

        } catch (e) {
            console.log(e);
            return res.status(500).json({
                "message": "Internal server error"
            });
        }
    });
});

app.post("/signup", (req, res, next) => {
    var sql = 'INSERT INTO user (username, password, timestamp) VALUES (?,?,?)';
    var user = {
        username: req.body.username,
        password: bcrypt.hashSync(req.body.password, 8),
        timestamp: Date.now()
    }
    var params = [user.username, user.password, user.timestamp];
    db.run(sql, params, function (err, result) {
        if (err) {
            return res.status(400).json({ "error": err.errno, "message": err.message, })
        }
        const accessToken = jwt.sign(req.body.username, process.env.ACCESS_TOKEN_SECRET);
        return res.json({
            "message": "success",
            accessToken: accessToken
        });
    });

});

app.listen(3000, () => {
    console.log("Server running");
});