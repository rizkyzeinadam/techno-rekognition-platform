const express = require('express');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const port = process.env.PORT || 3000;
const backendTarget = process.env.BACKEND_API_URL || 'http://localhost:5000';
const publicDir = path.join(__dirname, 'public');
const indexFile = path.join(publicDir, 'index.html');

app.disable('x-powered-by');

app.get('/health', (_req, res) => {
  res.json({
    status: 'healthy',
    service: 'techno-rekognition-frontend',
    backendTarget
  });
});

app.use(
  '/api',
  createProxyMiddleware({
    target: backendTarget,
    changeOrigin: true,
    pathRewrite: {
      '^/api': ''
    },
    onError(err, _req, res) {
      res.status(502).json({
        status: 'error',
        message: 'Backend service unavailable',
        details: err.message
      });
    }
  })
);

app.use(express.static(publicDir));

app.get('/', (_req, res) => {
  res.sendFile(indexFile);
});

app.get('*', (_req, res) => {
  res.sendFile(indexFile);
});

app.listen(port, () => {
  console.log(`Frontend running on port ${port}`);
  console.log(`Proxying backend requests to ${backendTarget}`);
});