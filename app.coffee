express = require 'express'
socket = require 'socket.io'
app = express()
server = app.listen 8080
io = socket.listen server

app.set 'view engine', 'jade'
app.set 'views', 'views/'

app.use('/scripts', express.static('scripts/'))

app.get '/', (req, res) ->
  res.render 'index'

# auslagern
padStr = (i) ->
  if i < 10
    "0" + i
  else "" + i

curServerTime = () ->
  curDate = new Date()
  dateStr =  padStr(curDate.getHours()) + ':' + padStr(curDate.getMinutes()) + ':' + padStr(curDate.getSeconds())
# timeOffset zu clients berechnen als Parameter zu curServerTime
# auslagern ende

# disconnect hinzufügen
io.sockets.on 'connection', (client) ->
  console.log curServerTime() + ' - New connection'
  client.on 'message', (data) ->
    console.log data.msg
    cTime = curServerTime()
    client.get 'nick', (err, name) ->
      client.broadcast.emit 'newmsg', { time: cTime, nick: name, msg: data.msg }
      client.emit 'newmsg', { time: cTime, nick: 'Du', msg: data.msg }
  client.on 'join', (nickname) ->
    console.log curServerTime() + ' - ' + nickname + ' connected'
    client.set 'nick', nickname 
    client.broadcast.emit 'sysmsg', curServerTime() + ' - <b>' + nickname + '</b> connected'