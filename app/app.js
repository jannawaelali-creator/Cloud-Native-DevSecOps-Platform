const express = require('express');
const app = express();
const PORT = process.env.API_PORT || 3000;
const ENVIRONMENT = process.env.NODE_ENV || 'development'
const { Pool } = require('pg');



const pool = new Pool({
    host: process.env.DB_HOST,         // Pulled from ConfigMap
    user: 'postgres',                  // Default PostgreSQL user
    password: process.env.DB_PASSWORD, // Securely pulled from Secret
    database: 'postgres',              // Default PostgreSQL database
    port: 5432,                        // Internal Postgres container port
});

pool.connect((err, client, release) => {
    if (err) {
        return console.error('❌ Error acquiring database client:', err.stack);
    }
    console.log('✅ Connected to PostgreSQL database successfully!');
    release();
});


app.get('/api', async (req, res) => {
    try {
        // Run a quick query to fetch the current server timestamp from the DB
        const dbResult = await pool.query('SELECT NOW()');
        res.send(`Hello from the Secure Node.js Backend! Database time is: ${dbResult.rows[0].now}`);
    } catch (err) {
        console.error(err);
        res.status(500).send('Hello from the Backend! (But database communication failed)');
    }
});

      

// Health check endpoint for Kubernetes liveness/readiness probes
app.get('/health', async (req, res) => {
    try {
        // Optional: Verify the database connection pool is still healthy too!
        await pool.query('SELECT 1'); 
        
        res.status(200).json({ 
            status: 'UP', 
            timestamp: new Date(),
            database: 'CONNECTED'
        });
    } catch (err) {
        console.error('Health check failed:', err);
        res.status(500).json({ 
            status: 'DOWN', 
            reason: 'Database connection lost' 
        });
    }
});

app.listen(PORT, () => {
    console.log(`Server running safely on port ${PORT}`);
});