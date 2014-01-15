###
 QuickSocket (Beta).
 author: info@andrevenancio.com (Andre Venancio).
###
do ->
  ROOMS = {};


  #require
  express = require 'express'
  http = require 'http'
  ejs = require 'ejs'


  #html
  app = express()
  .set('views', __dirname)
  .engine('html', ejs.renderFile)
  .get '/[a-zA-Z\-\_0-9]{0,6}', (req, res) ->
    res.render 'test.html'
  

  #server
  server = http.createServer(app)
  .listen(process.env.PORT || 8080);
  

  #socket.io
  io = require('socket.io').listen(server);
  io.configure ->
    io.enable('browser client minification');
    io.enable('browser client etag');
    io.enable('browser client gzip');
    io.set('log level', 1);

  
  #quicksocket
  io.sockets.on 'connection', (socket) ->

    socket.on 'disconnect', ->
      socket.get 'controller', (err, controller) ->
        return if controller is null
        #this guy controller.id left room controller.room
        updateRoom()

    socket.on 'enter-room', (roomID) ->
      #someone joined the room
      room = getRoom(roomID)
      room.connections++
      socket.join roomID
      socket.emit 'on-enter-room', roomID
      updateRoom()


    socket.on 'leave-room', (roomID) ->
      #someone left the room
      ROOMS[roomID].connections--
      socket.leave roomID
      socket.emit 'on-leave-room', roomID;
      if ROOMS[roomID].connections is 0
        #nobody in the room, delete it
        delete(ROOMS[roomID]);

      updateRoom()

    socket.on 'controller-join', (roomID) ->
      room = getRoom(roomID)
      controller = room.addController()
      socket.set 'controller', controller
      socket.join roomID
      socket.emit 'on-controller-join', controller.id

      console.log 'controller', controller.id, 'join', roomID
      updateRoom()

    socket.on 'controller-leave', (controllerID) ->
      controller = getController controllerID
      room = ROOMS[controller.room]
      room.connections--
      #socket.set('controller', controller);
      socket.leave controller.room

      socket.emit 'on-controller-left', controller.id
      console.log 'controller', controller.id, 'left', controller.room
      room.removeController controller.id
      updateRoom()
  

  updateRoom = (roomID) ->
    io.sockets.in(roomID)
    .emit('on-room-update', ROOMS);

  getRoom = (id) ->
    if ROOMS[id] is undefined
      room = new Room id
      ROOMS[id] = room
    else
      room = ROOMS[id]

  getController = (id) ->
    for k of ROOMS
      room = ROOMS[k]
      for j of room.controllers
        controller = room.controllers[j]
        if controller.id is id
          return controller



### ROOM ###
class Room
  constructor: (id) ->
    @id = id
    @connections = 0
    @controllers = {}
    @data = {}
  
  addController: ->
    controller = new Controller()
    controller.room = @id
    @controllers[controller.id] = controller
    @data[controller.id] = {}
    return controller

  removeController: (id) ->
    if @controllers[id] isnt undefined
      delete(@data[id])
      delete(@controllers[id])

  getControllers: ->
    out = {}
    for key of @controllers
      out[key] = @controllers[key].getProperties()
    return out

  updateData: (id, data) ->
    @data[id] = data

  getData: ->
    return @data


### CONTROLLER ###
class Controller
  constructor: ->
    @id = @generateGuid()
    @room = ''
    @data = {}

  getProperties: ->
    return {
      id: @id,
      room: @room
      data: @data
    }


  update: (data) ->
    @data = data


  generateGuid: ->
    result = ''
    for j in [0...32]
      if j is 8 or j is 12 or j is 16 or j is 20
        result = result + '-'
      
      i = Math.floor(Math.random() * 16).toString(16).toUpperCase()
      result = result + i

    return result