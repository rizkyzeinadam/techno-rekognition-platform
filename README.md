# Techno Rekognition

Production-style test stack for AWS Rekognition on EKS.

## Architecture

- Backend: Flask in `app/`
- Frontend: Node.js in `frontend/`
- Infrastructure: Terraform in `terraform/`
- Kubernetes manifests: `deployment/`
- CI/CD: GitHub Actions in `.github/workflows/`

## How It Works

- The Node.js app serves the UI and proxies API calls to the Flask backend.
- The Flask backend handles Rekognition requests.
- Docker images are built in CI/CD, pushed to ECR, and deployed to EKS.
- Node.js dependencies are installed during the frontend image build, not inside the running pod.

## Local Frontend Build

```bash
cd frontend
npm ci
npm start
```

## Docker Build

Backend:

```bash
docker build -t techno-backend .
```

Frontend:

```bash
docker build -t techno-frontend -f frontend/Dockerfile .
```

## CI/CD Flow

1. Run backend checks.
2. Run frontend checks.
3. Build backend and frontend images.
4. Push both images to ECR.
5. Deploy manifests to EKS.

## Notes

- `zein.jpg` can be used as a sample test image.
- Frontend runtime should not run `npm install` in the pod.