const express = require('express');
const cors = require('cors');
const { S3Client, GetObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../frontend')));

const port = process.env.PORT || 3000;
const BUCKET_NAME = process.env.RESUME_BUCKET_NAME;
const REGION = process.env.AWS_REGION || 'ap-south-1';

const s3Client = new S3Client({ region: REGION });

const LOG_FILE = '/var/log/resume-app/events.log';

function logEvent(message) {
    const timestamp = new Date().toISOString();
    const logLine = `[${timestamp}] ${message}\n`;
    try {
        if (fs.existsSync(LOG_FILE)) {
            fs.appendFileSync(LOG_FILE, logLine);
        } else {
            console.log(logLine.trim());
        }
    } catch (e) {
        console.error("Failed to write to log file:", e);
    }
}

app.get('/api/health', (req, res) => {
    let healthState = {
        overall: "healthy",
        services: {
            nginx: "unknown",
            application: "healthy",
            monitoring: "unknown",
            storage: "unknown"
        },
        updatedAt: new Date().toISOString()
    };

    try {
        if (fs.existsSync('/var/lib/resume-monitor/state.json')) {
            const stateData = JSON.parse(fs.readFileSync('/var/lib/resume-monitor/state.json', 'utf8'));
            healthState = stateData;
            healthState.services.application = "healthy"; // Since we are responding!
        }
    } catch (err) {
        console.error("Could not read monitor state:", err);
    }
    
    res.json(healthState);
});

app.get('/api/resume', async (req, res) => {
    if (!BUCKET_NAME) {
        return res.status(500).json({ error: "S3 bucket name not configured" });
    }
    
    try {
        const command = new GetObjectCommand({
            Bucket: BUCKET_NAME,
            Key: "YahyaShaikhResume.pdf"
        });
        const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 3600 });
        res.json({ url: signedUrl });
    } catch (err) {
        console.error("S3 error:", err);
        res.status(500).json({ error: "Could not generate resume URL" });
    }
});

app.get('/api/events', (req, res) => {
    try {
        if (fs.existsSync(LOG_FILE)) {
            const logs = fs.readFileSync(LOG_FILE, 'utf8').trim().split('\n').slice(-20);
            res.json({ events: logs });
        } else {
            res.json({ events: ["No events logged yet."] });
        }
    } catch (err) {
        res.status(500).json({ error: "Could not read events" });
    }
});

app.post('/api/crash/:service', (req, res) => {
    const service = req.params.service;
    const ALLOWED_SERVICES = ['nginx', 'application'];
    
    if (!ALLOWED_SERVICES.includes(service)) {
        return res.status(403).json({ error: "Service crash not allowed" });
    }
    
    logEvent(`User requested ${service} crash`);
    
    if (service === 'application') {
        res.json({ message: "Crashing application now..." });
        setTimeout(() => {
            process.exit(1);
        }, 500);
    } else if (service === 'nginx') {
        try {
            fs.writeFileSync('/var/lib/resume-monitor/crash_nginx.flag', 'crash');
            res.json({ message: "Requested Nginx crash" });
        } catch (err) {
            console.error(err);
            res.status(500).json({ error: "Failed to request nginx crash" });
        }
    }
});

app.listen(port, () => {
    console.log(`Resume app listening on port ${port}`);
    logEvent("Application started");
});
