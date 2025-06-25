require('dotenv').config();

let express = require('express');
let bodyParser = require('body-parser');
let app = express();

console.log("Hello World")

app.use((req, res, next) => {
    const {method, path, ip} = req;
    console.log(`${method} ${path} - ${ip}`);
    next();
})

app.get("/", (req, res) => {
    //res.send('Hello Express');
    res.sendFile(__dirname + '/views/index.html');
})

app.use("/", bodyParser.urlencoded({extended: false}));
app.use("/public", express.static(__dirname + "/public"))

app.get("/json", (req, res) => {
    const messageStyle = process.env.MESSAGE_STYLE;
    if (messageStyle === 'uppercase') {
        res.json({"message": "Hello json".toUpperCase()});
    } else {
        res.json({"message": "Hello json"});
    }
})

app.get('/now', (req, res, next) => {
    req.time = new Date().toString();
    next();
}, (req, res) => {
    res.json({time: req.time});
})

app.get("/:word/echo", (req, res, next) => {
    const word = req.params['word'];
    res.json({echo: word});
})

app.route("/name")
    .get((req, res) => {
        const {first: firstname, last: lastname} = req.query;
        res.json({name: `${firstname} ${lastname}`}); 
    })
    .post((req, res) => {
        const {first: firstname, last: lastname} = req.body;
        res.json({name: `${firstname} ${lastname}`}); 
    })
































 module.exports = app;
