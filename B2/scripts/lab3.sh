#!/usr/bin/env bash

sudo apt install -y nodejs npm

cat > helloworld.js <<EOL
// Importing 'http' module
const http = require('http');

// Setting Port Number as 80
const port = 8080;

// Creating Server
const server = http.createServer((req,res)=>{

	// Handling Request and Response
	res.statusCode=200;
	res.setHeader('Content-Type', 'text/html')
	res.end('<html><head></head><body><h1>Hello World!</h1></body></html>')
});

// Making the server to listen to required
// hostname and port number
server.listen(port,()=>{

	// Callback
	console.log(\`Server running at http://127.0.0.1:\${port}/\`);
});
EOL


## Start server
sudo tee -a /etc/systemd/system/server.service <<EOL
[Unit]
Description=Server service
[Service]
ExecStart=/bin/bash -c "cd /home/vagrant && node helloworld.js"
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl enable server --now