const express = require('express');
const app = express();
const PORT = process.env.API_PORT || 3000;
const ENVIRONMENT = process.env.NODE_ENV || 'development'


const DB_SIGNING_KEY = process.env.API_SIGNING_KEY;


app.get('/api', (req, res) => {
    if (!DB_SIGNING_KEY) {
        res.status(500).send(`[Backend Error]: API_SIGNING_KEY is missing! Connection to DB refused.`);
    } else {
        res.send(`Hello from the Backend API! Connected securely to the ${ENVIRONMENT} database using signing key: ${DB_SIGNING_KEY.substring(0, 5)}*****`);
    }
});
      

// Health check endpoint for Kubernetes liveness/readiness probes
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.listen(PORT, () => {
    console.log(`Server running safely on port ${PORT}`);
});