zappa = require '../src/zappa'
port = 15900

@tests =
  'powered by': (t) ->
    t.expect 'express handles errors', 'zappa handles successful queries'
    t.wait 3000

    zapp = zappa port++, ->
      @get '/foo', -> 'ok'

    c = t.client(zapp.server)

    c.get '/', (err, res) ->
      t.ok 'express handles errors', res.headers['x-powered-by'].match /^Express/
    c.get '/foo', (err, res) ->
      t.ok 'zappa handles successful queries', res.headers['x-powered-by'].match /^Zappa/

  'silent zappa': (t) ->
    t.expect 'silent zappa'
    t.wait 3000

    zapp = zappa port++, ->
      @enable 'silent_zappa'
      @get '/', -> 'ok'

    c = t.client(zapp.server)

    c.get '/', (err, res) ->
      t.ok 'silent zappa', res.body is 'ok'

  'format': (t) ->
    t.expect 1,2,3
    t.wait 3000

    zapp = zappa port++, ->
      @get '/clients/:id', ->
        client = _id: @params.id, name:'Bob'
        @format
          'json': =>
            @json client
          'html': =>
            @render 'index', client
      {div} = @teacup
      @view index: ->
        div id:@_id, => @name

    c = t.client(zapp.server)

    c.get '/clients/3', headers:{Accept:'application/json'}, (err, res) ->
      body = JSON.parse res.body
      t.equal 1, body._id, '3'
      t.equal 2, body.name, 'Bob'
    c.get '/clients/3', headers:{Accept:'text/html'}, (err, res) ->
      t.equal 3, res.body, '<div id="3">Bob</div>'

  'default': (t) ->
    t.expect 1,2
    zapp = zappa port++, ->
      @get '/text', ->
        'goo'

      @get '/async', ->
        Promise.resolve 'blar'

    c = t.client(zapp.server)

    c.get '/text', (err, res) ->
      t.equal 1, res.body, 'goo'
    c.get '/async', (err, res) ->
      t.equal 2, res.body, 'blar'
