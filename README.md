#Quicksockets
QuickSocket is a painless HTML5 websocket server for rapid prototyping.

* Run the server
* include this in your html `<head>`
```html
<script src="http://localhost:8080/socket.io/socket.io.js"></script>
```

##Running the server
Make sure you have both [node.js](http://nodejs.org/) and [npm](https://npmjs.org/) installed.
* Install all dependencies in your package.json
```shell
npm install 
```
* Run local Gruntfile
```shell
coffee server/quicksockets.coffee -n
```
* Debug Client
```shell
http://localhost:8080/
```
* Debug Controller
```shell
http://localhost:8080/controller
```

