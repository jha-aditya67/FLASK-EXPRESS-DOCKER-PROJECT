const express = require('express');
const axios = require('axios');

const app = express();

app.set('view engine', 'ejs');

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.get('/', (req, res) => {
    res.render('index', { result: null });
});

app.post('/submit', async (req, res) => {
    try {
        const response = await axios.post(
            'http://51.20.128.93:5000/submit',
            {
                name: req.body.name,
                email: req.body.email
            }
        );

        res.render('index', {
            result: response.data
        });

    } catch (error) {
        console.error('Backend request error:', error.message, error.response && error.response.data ? error.response.data : '');
        res.render('index', {
            result: { message: 'Error connecting to backend: ' + (error.message || 'unknown error') }
        });
    }
});

app.listen(3000, () => {
    console.log('Frontend running on port 3000');
});
