// CloudFront Function to rewrite URLs for SPA routing
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Check if the URI is missing a file extension
    if (!uri.includes('.')) {
        // Rewrite to index.html for SPA routing
        request.uri = '/index.html';
    }

    return request;
}
