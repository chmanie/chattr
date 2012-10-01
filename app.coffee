express = require 'express'
socket = require 'socket.io'
app = express()
server = app.listen 8080
io = socket.listen server

app.set 'view engine', 'jade'
app.set 'views', 'views/'

app.use('/', express.static(__dirname + '/public'))

app.get '/:page', (req, res) ->
  if req.params.page != 'favicon.ico'
    res.render req.params.page

app.get '/', (req, res) ->
  res.render 'home'

# auslagern
padStr = (i) ->
  if i < 10
    "0" + i
  else "" + i

localTime = () ->
  curDate = new Date()
  time = { string: padStr(curDate.getHours()) + ':' + padStr(curDate.getMinutes()) + ':' + padStr(curDate.getSeconds()), hour: curDate.getHours()}
# auslagern ende

getClients = (socket) ->
  cList = socket.clients()
  console.log(cList[0].store)
  clients = {}
  for client in cList
    clients[client.id] = { id: client.id, nickname: client.store.data.cdata.nickname }
  clients

io.sockets.on 'connection', (client) ->
  console.log localTime().string + ' - New connection'
  client.on 'message', (data) ->
    client.get 'cdata', (err, cdata) ->
      io.sockets.emit 'newmsg', { nick: cdata.nickname, msg: data.msg }
      console.log localTime().string + ' - ' + cdata.nickname + ': ' + data.msg
  client.on 'join', (data) ->
    userdata = { id: client.id, nickname: data.nickname}
    client.set 'cdata', { nickname: data.nickname }
    ulist = getClients(io.sockets)
    # hier vllt nur dem neuen client die userliste schicken
    io.sockets.emit 'join', { userdata: userdata, userlist: ulist }
    console.log localTime().string + ' - ' + data.nickname + ' connected with ID: ' + client.id
  client.on 'disconnect', () ->
    client.get 'cdata', (err, cdata) ->
      client.broadcast.emit 'disconnect', { id: client.id, nickname: cdata.nickname }