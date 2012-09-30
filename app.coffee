express = require 'express'
socket = require 'socket.io'
app = express()
server = app.listen 8080
io = socket.listen server

app.set 'view engine', 'jade'
app.set 'views', 'views/'

app.use('/', express.static(__dirname + '/public'))

app.get '/:page', (req, res) ->
  res.render req.params.page

app.get '/', (req, res) ->
  res.render 'home'

# auslagern
padStr = (i) ->
  if i < 10
    "0" + i
  else "" + i

localTime = (offset) ->
  offset = 0 if !offset?
  curDate = new Date()
  time = { string: padStr(curDate.getHours() + offset) + ':' + padStr(curDate.getMinutes()) + ':' + padStr(curDate.getSeconds()), hour: curDate.getHours()}
# auslagern ende

# on disconnect hinzufügen
io.sockets.on 'connection', (client) ->
  console.log localTime().string + ' - New connection'
  client.on 'message', (data) ->
    console.log data.msg
    client.get 'cdata', (err, cdata) ->
      cTime = localTime(cdata.offset).string
      client.broadcast.emit 'newmsg', { time: cTime, nick: cdata.nickname, msg: data.msg }
      client.emit 'newmsg', { time: cTime, nick: cdata.nickname, msg: data.msg }
  client.on 'join', (data) ->
    offset = data.localHour - localTime().hour
    client.set 'cdata', { nickname: data.nickname, offset: offset }
    client.emit 'sysmsg', 'Hallo, <b>' + data.nickname + '</b>!'
    client.broadcast.emit 'sysmsg', localTime(offset).string + ' - <b>' + data.nickname + '</b> connected'
    console.log localTime().string + ' - ' + data.nickname + ' connected. Offset: ' + offset