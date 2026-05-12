"""
AWS Rekognition Flask Application
Integrates with AWS Rekognition service for image analysis
"""
import os
import json
import logging
from flask import Flask, render_template, request, jsonify
import boto3
from botocore.exceptions import ClientError
import urllib.parse

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# AWS Configuration
REGION = os.getenv('AWS_REGION', 'us-east-1')
rekognition_client = boto3.client('rekognition', region_name=REGION)
s3_client = boto3.client('s3', region_name=REGION)

# S3 bucket for storing images
S3_BUCKET = os.getenv('S3_BUCKET_NAME', 'techno-rekognition-images')

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'techno-rekognition-app'}), 200

@app.route('/', methods=['GET'])
def index():
    """Render main page"""
    return jsonify({
        'message': 'Welcome to Techno Rekognition Service',
        'version': '1.0.0',
        'endpoints': {
            '/health': 'GET - Health check',
            '/detect-labels': 'POST - Detect labels in image',
            '/detect-faces': 'POST - Detect faces in image',
            '/detect-text': 'POST - Detect text in image'
        }
    }), 200

@app.route('/detect-labels', methods=['POST'])
def detect_labels():
    """
    Detect objects, scenes, and concepts in an image
    Expected: JSON with 'image_url' or multipart form with 'file'
    """
    try:
        image_bytes = None
        image_key = None
        
        # Handle file upload
        if 'file' in request.files:
            file = request.files['file']
            if file and file.filename:
                image_bytes = file.read()
                image_key = f"uploads/{file.filename}"
        
        # Handle URL-based image
        elif 'image_url' in request.json or request.get_json():
            data = request.get_json() or {}
            image_url = data.get('image_url')
            
            if image_url:
                try:
                    import requests
                    response = requests.get(image_url, timeout=10)
                    response.raise_for_status()
                    image_bytes = response.content
                    image_key = f"urls/{urllib.parse.quote(image_url, safe='')}"
                except Exception as e:
                    logger.error(f"Failed to download image: {str(e)}")
                    return jsonify({'error': f'Failed to download image: {str(e)}'}), 400
        
        if not image_bytes:
            return jsonify({'error': 'No image file or URL provided'}), 400
        
        # Detect labels using Rekognition
        response = rekognition_client.detect_labels(
            Image={'Bytes': image_bytes},
            MaxLabels=10,
            MinConfidence=70
        )
        
        labels = [
            {
                'Name': label['Name'],
                'Confidence': label['Confidence'],
                'Instances': label.get('Instances', []),
                'Parents': label.get('Parents', [])
            }
            for label in response.get('Labels', [])
        ]
        
        return jsonify({
            'status': 'success',
            'labels': labels,
            'total_labels': len(labels),
            'request_id': response.get('ResponseMetadata', {}).get('RequestId')
        }), 200
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        logger.error(f"AWS Error: {error_code} - {e}")
        return jsonify({'error': f'AWS Error: {error_code}', 'details': str(e)}), 500
    except Exception as e:
        logger.error(f"Error detecting labels: {str(e)}")
        return jsonify({'error': 'Internal server error', 'details': str(e)}), 500

@app.route('/detect-faces', methods=['POST'])
def detect_faces():
    """
    Detect and analyze faces in an image
    Expected: JSON with 'image_url' or multipart form with 'file'
    """
    try:
        image_bytes = None
        
        # Handle file upload
        if 'file' in request.files:
            file = request.files['file']
            if file and file.filename:
                image_bytes = file.read()
        
        # Handle URL-based image
        elif 'image_url' in request.json or request.get_json():
            data = request.get_json() or {}
            image_url = data.get('image_url')
            
            if image_url:
                try:
                    import requests
                    response = requests.get(image_url, timeout=10)
                    response.raise_for_status()
                    image_bytes = response.content
                except Exception as e:
                    logger.error(f"Failed to download image: {str(e)}")
                    return jsonify({'error': f'Failed to download image: {str(e)}'}), 400
        
        if not image_bytes:
            return jsonify({'error': 'No image file or URL provided'}), 400
        
        # Detect faces using Rekognition
        response = rekognition_client.detect_faces(
            Image={'Bytes': image_bytes},
            Attributes=['ALL']
        )
        
        faces = []
        for face_detail in response.get('FaceDetails', []):
            faces.append({
                'BoundingBox': face_detail.get('BoundingBox'),
                'AgeRange': face_detail.get('AgeRange'),
                'Smile': face_detail.get('Smile'),
                'EyesOpen': face_detail.get('EyesOpen'),
                'MouthOpen': face_detail.get('MouthOpen'),
                'Confidence': face_detail.get('Confidence'),
                'Emotions': face_detail.get('Emotions', []),
                'Gender': face_detail.get('Gender')
            })
        
        return jsonify({
            'status': 'success',
            'faces_detected': len(faces),
            'faces': faces,
            'request_id': response.get('ResponseMetadata', {}).get('RequestId')
        }), 200
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        logger.error(f"AWS Error: {error_code} - {e}")
        return jsonify({'error': f'AWS Error: {error_code}', 'details': str(e)}), 500
    except Exception as e:
        logger.error(f"Error detecting faces: {str(e)}")
        return jsonify({'error': 'Internal server error', 'details': str(e)}), 500

@app.route('/detect-text', methods=['POST'])
def detect_text():
    """
    Detect text in an image (OCR)
    Expected: JSON with 'image_url' or multipart form with 'file'
    """
    try:
        image_bytes = None
        
        # Handle file upload
        if 'file' in request.files:
            file = request.files['file']
            if file and file.filename:
                image_bytes = file.read()
        
        # Handle URL-based image
        elif 'image_url' in request.json or request.get_json():
            data = request.get_json() or {}
            image_url = data.get('image_url')
            
            if image_url:
                try:
                    import requests
                    response = requests.get(image_url, timeout=10)
                    response.raise_for_status()
                    image_bytes = response.content
                except Exception as e:
                    logger.error(f"Failed to download image: {str(e)}")
                    return jsonify({'error': f'Failed to download image: {str(e)}'}), 400
        
        if not image_bytes:
            return jsonify({'error': 'No image file or URL provided'}), 400
        
        # Detect text using Rekognition
        response = rekognition_client.detect_text(
            Image={'Bytes': image_bytes}
        )
        
        text_detections = []
        for detection in response.get('TextDetections', []):
            if detection['Type'] == 'LINE':  # Only include lines, not individual words for brevity
                text_detections.append({
                    'Text': detection.get('DetectedText'),
                    'Confidence': detection.get('Confidence'),
                    'BoundingBox': detection.get('Geometry', {}).get('BoundingBox')
                })
        
        return jsonify({
            'status': 'success',
            'text_detected': text_detections,
            'total_text_blocks': len(text_detections),
            'request_id': response.get('ResponseMetadata', {}).get('RequestId')
        }), 200
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        logger.error(f"AWS Error: {error_code} - {e}")
        return jsonify({'error': f'AWS Error: {error_code}', 'details': str(e)}), 500
    except Exception as e:
        logger.error(f"Error detecting text: {str(e)}")
        return jsonify({'error': 'Internal server error', 'details': str(e)}), 500

@app.route('/status', methods=['GET'])
def status():
    """Get application status and configuration"""
    try:
        # Test Rekognition connection
        rekognition_client.describe_stream_processor()
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceNotFoundException':
            logger.warning(f"Rekognition connection issue: {e}")
    
    return jsonify({
        'status': 'running',
        'service': 'Techno Rekognition Service',
        'version': '1.0.0',
        'region': REGION,
        'uptime': 'Running'
    }), 200

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # In production, use a proper WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)), debug=False)
