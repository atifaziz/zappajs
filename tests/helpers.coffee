zappa = require '../src/zappa'
port = 15100

@tests =
  http: (t) ->
    t.expect 1, 2
    t.wait 3000

    zapp = zappa port++, ->
      @helper role: (name) ->
        if @request?
          @redirect '/login' unless @user.role is name

      @get '/': ->
        @user = role: 'commoner'
        @role 'lord'

    c = t.client(zapp.server)

    c.get '/', (err, res) ->
      t.equal 1, res.statusCode, 302
      t.ok 2, res.headers.location.match /\/login$/

  multiple: (t) ->
    t.expect 1, 2
    t.wait 3000

    zapp = zappa port++, ->
      @helper sum: (a, b) -> a + b
      @helper subtract: (a, b) -> a - b

      @get '/': ->
        t.equal 1, @sum(1, 2), 3
        t.equal 2, @subtract(1, 2), -1

    c = t.client(zapp.server)
    c.get '/'

  multiple_in_one: (t) ->
    t.expect 1, 2
    t.wait 3000

    zapp = zappa port++, ->
      @helper
        sum: (a, b) -> a + b
        subtract: (a, b) -> a - b

      @get '/': ->
        t.equal 1, @sum(1, 2), 3
        t.equal 2, @subtract(1, 2), -1

    c = t.client(zapp.server)
    c.get '/'

  objects: (t) ->
    t.expect 1, 2
    t.wait 3000

    zapp = zappa port++, ->
      @helper foo: [1,2,3]
      @helper bar: "foo bar"

      @get '/': ->
        t.equal 1, @foo[2], 3
        t.equal 2, @bar, "foo bar"

    c = t.client(zapp.server)
    c.get '/'
