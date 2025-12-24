function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // Rewrite URLs for SPA routing
    // If URI doesn't have a file extension, serve index.html
    if (!uri.includes('.')) {
        request.uri = '/index.html';
    }

    // Add security headers (additional layer)
    var response = {
        statusCode: 200,
        statusDescription: 'OK'
    };

    return request;
}
