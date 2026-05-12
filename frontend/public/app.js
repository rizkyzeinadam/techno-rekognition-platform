const fileInput = document.getElementById('image-file');
const urlInput = document.getElementById('image-url');
const previewImage = document.getElementById('image-preview');
const previewEmpty = document.getElementById('preview-empty');
const resultsOutput = document.getElementById('results-output');
const backendStatus = document.getElementById('backend-status');
const clearResultsButton = document.getElementById('clear-results');
const actionButtons = document.querySelectorAll('[data-endpoint]');

function formatPayload(data) {
  return JSON.stringify(data, null, 2);
}

function setStatus(message, tone = 'neutral') {
  backendStatus.textContent = message;
  backendStatus.className = `status-pill status-${tone}`;
}

function showPreviewFromFile(file) {
  if (!file) {
    previewImage.style.display = 'none';
    previewImage.removeAttribute('src');
    previewEmpty.style.display = 'block';
    return;
  }

  const reader = new FileReader();
  reader.onload = event => {
    previewImage.src = event.target.result;
    previewImage.style.display = 'block';
    previewEmpty.style.display = 'none';
  };
  reader.readAsDataURL(file);
}

fileInput.addEventListener('change', event => {
  const [file] = event.target.files;
  showPreviewFromFile(file);
  if (file) {
    urlInput.value = '';
  }
});

urlInput.addEventListener('input', () => {
  if (urlInput.value.trim()) {
    fileInput.value = '';
    previewImage.src = urlInput.value.trim();
    previewImage.style.display = 'block';
    previewEmpty.style.display = 'none';
  } else if (!fileInput.files.length) {
    previewImage.style.display = 'none';
    previewImage.removeAttribute('src');
    previewEmpty.style.display = 'block';
  }
});

clearResultsButton.addEventListener('click', () => {
  resultsOutput.textContent = 'Waiting for analysis...';
});

async function checkBackend() {
  try {
    const response = await fetch('/api/health');
    const data = await response.json();
    if (response.ok) {
      setStatus(`Backend online: ${data.service}`, 'ok');
    } else {
      setStatus('Backend reported an error', 'bad');
    }
  } catch (error) {
    setStatus('Backend unavailable', 'bad');
  }
}

async function runAnalysis(endpoint) {
  const selectedFile = fileInput.files[0];
  const selectedUrl = urlInput.value.trim();

  if (!selectedFile && !selectedUrl) {
    resultsOutput.textContent = formatPayload({
      error: 'Choose a file or paste an image URL first.'
    });
    return;
  }

  const payload = selectedFile ? new FormData() : new FormData();
  if (selectedFile) {
    payload.append('file', selectedFile);
  } else {
    payload.append('image_url', selectedUrl);
  }

  resultsOutput.textContent = 'Analyzing image...';

  try {
    const response = await fetch(`/api/${endpoint}`, {
      method: 'POST',
      body: payload
    });

    const data = await response.json();
    resultsOutput.textContent = formatPayload(data);
  } catch (error) {
    resultsOutput.textContent = formatPayload({
      error: 'Request failed',
      details: error.message
    });
  }
}

actionButtons.forEach(button => {
  button.addEventListener('click', () => {
    runAnalysis(button.dataset.endpoint);
  });
});

checkBackend();