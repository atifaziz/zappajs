zappa = require '../src/zappa'
port = 15800

@tests =
  'default host and port (INADDR_ANY / 3000)': (t) ->
    if process.env.SKIP_IPV6
      t.expect 'localhost', '127.0.0.1', '0.0.0.0'
    else
      t.expect 'localhost', '127.0.0.1', '0.0.0.0', '::1'
    t.wait 3000

    zapp = zappa ->
      @get '/': 'default'

    c = t.client 'http://localhost:3000'
    c.get '/', (err, res) -> t.equal 'localhost', res.body, 'default'
    c2 = t.client 'http://127.0.0.1:3000'
    c2.get '/', (err, res) -> t.equal '127.0.0.1', res.body, 'default'
    c3 = t.client 'http://0.0.0.0:3000'
    c3.get '/', (err, res) -> t.equal '0.0.0.0', res.body, 'default'
    unless process.env.SKIP_IPV6
      c4 = t.client 'http://[::1]:3000'
      c4.get '/', (err, res) -> t.equal '::1', res.body, 'default'

  'default host, specified port as number': (t) ->
    t.expect 'localhost', '127.0.0.1'
    t.wait 3000

    zapp = zappa 15801, ->
      @get '/': 'number port'

    c = t.client 'http://localhost:15801'
    c.get '/', (err, res) -> t.equal 'localhost', res.body, 'number port'
    c2 = t.client 'http://127.0.0.1:15801'
    c2.get '/', (err, res) -> t.equal '127.0.0.1', res.body, 'number port'

  'default host, specified port as string': (t) ->
    t.expect 'localhost', '127.0.0.1'
    t.wait 3000

    zapp = zappa '15802', ->
      @get '/': 'string port'

    c = t.client 'http://localhost:15802'
    c.get '/', (err, res) -> t.equal 'localhost', res.body, 'string port'
    c2 = t.client 'http://127.0.0.1:15802'
    c2.get '/', (err, res) -> t.equal '127.0.0.1', res.body, 'string port'

  'specified host, specified port as string': (t) ->
    t.expect 'localhost', '127.0.0.1'
    t.wait 3000

    zapp = zappa 'localhost', '15803', ->
      @get '/': 'host + string port'

    setTimeout ->
      c = t.client 'http://localhost:15803'
      c.get '/', (err, res) -> t.equal 'localhost', res.body, 'host + string port'
      c2 = t.client 'http://127.0.0.1:15803'
      c2.get '/', (err, res) -> t.equal '127.0.0.1', res.body, 'host + string port'
    , 1000

  'path (IPC)': (t) ->
    t.expect 'ipc'

    zapp = zappa path:'/tmp/zappa_ipc', ->
      @get '/': 'ipc'

    zapp.server.on 'listening', ->
      request = require 'request'
      request.get ('http://unix:/tmp/zappa_ipc:' + '/'), (err,res) ->
        console.log(err);
        t.equal 'ipc', res.body, 'ipc'

        zapp.server.close ->
          (require 'fs').unlink '/tmp/zappa_ipc', -> true
