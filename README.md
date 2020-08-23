# tor-reverse-proxy
Docker container for proxying static pages and websocket connections from .onion address to webservers

## Testing
confirm `wscat -c localhost/wss` passes through to the target websocket