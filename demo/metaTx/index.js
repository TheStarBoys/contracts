var http = require('http');
var fs = require('fs');

http.createServer(function (request, response) {
    fs.readFile('./index.html','utf-8',function(err, data) {
        if(err) throw err;
        response.writeHead(200, {"Content-Type": "text/html;charset=utf-8"});
        response.write(data);
        response.end();
    });
}).listen(8888);

console.log('Server running at http://127.0.0.1:8888/');