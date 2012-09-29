// Generated by CoffeeScript 1.3.3
var app, curServerTime, express, io, padStr, server, socket;

express = require('express');

socket = require('socket.io');

app = express();

server = app.listen(8080);

io = socket.listen(server);

app.set('view engine', 'jade');

app.set('views', 'views/');

app.use('/scripts', express["static"]('scripts/'));

app.get('/', function(req, res) {
  return res.render('index');
});

padStr = function(i) {
  if (i < 10) {
    return "0" + i;
  } else {
    return "" + i;
  }
};

curServerTime = function() {
  var curDate, dateStr;
  curDate = new Date();
  return dateStr = padStr(curDate.getHours()) + ':' + padStr(curDate.getMinutes()) + ':' + padStr(curDate.getSeconds());
};

io.sockets.on('connection', function(client) {
  console.log(curServerTime() + ' - New connection');
  client.on('message', function(data) {
    var cTime;
    console.log(data.msg);
    cTime = curServerTime();
    return client.get('nick', function(err, name) {
      client.broadcast.emit('newmsg', {
        time: cTime,
        nick: name,
        msg: data.msg
      });
      return client.emit('newmsg', {
        time: cTime,
        nick: 'Du',
        msg: data.msg
      });
    });
  });
  return client.on('join', function(nickname) {
    console.log(curServerTime() + ' - ' + nickname + ' connected');
    client.set('nick', nickname);
    return client.broadcast.emit('sysmsg', curServerTime() + ' - ' + nickname + ' connected');
  });
});