const express = require('express');
const app = express();
const PORT = 3000;

// Application baseline route
app.get('/', (req, res) => {
    res.send('Phase 1 DevSecOps Pipeline: Secure and Operational!');
});

// Health check endpoint for Kubernetes liveness/readiness probes
app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

app.listen(PORT, () => {
    console.log(`Server running safely on port ${PORT}`);
});