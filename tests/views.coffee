zappa = require '../src/zappa'
port = 15600

@tests =
  inline: (t) ->
    t.expect 1, 2
    t.wait 3000

    zapp = zappa port++, ->
      @get '/bar': ->
        @render 'index', foo: 'bar', layout: no
      @get '/foobar': ->
        @render 'index', foo: 'foobar', layout: no

      {h2} = @teacup
      @view index: -> h2 "CoffeeKup inline template: #{@foo}"

    c = t.client(zapp.server)
    c.get '/bar', (err, res) ->
      t.equal 1, res.body, '<h2>CoffeeKup inline template: bar</h2>'
    c.get '/foobar', (err, res) ->
      t.equal 2, res.body, '<h2>CoffeeKup inline template: foobar</h2>'

  'inline + default layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @enable 'default layout'

      {h2} = @teacup

      @get '/': ->
        # @render 'index', foo: 'bar'
        @render 'index', foo: 'bar', title: 'CoffeeKup default layout'

      @view index: ->
        # This no longer works in Express 3.x
        # @title = 'CoffeeKup default layout'
        h2 "CoffeeKup inline template: #{@foo}"

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeKup default layout</title></head><body><h2>CoffeeKup inline template: bar</h2></body></html>'

  'inline + inline layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @get '/': ->
        @render 'index', foo: 'bar'

      {h2,doctype,html,head,title,body} = @teacup

      @view index: -> h2 "CoffeeKup inline template: #{@foo}"

      @view layout: ->
        doctype 5
        html ->
          head ->
            title 'CoffeeKup inline layout'
          body @body

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeKup inline layout</title></head><body><h2>CoffeeKup inline template: bar</h2></body></html>'

  'inline + inline non-default layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @get '/': ->
        @render 'index', foo: 'bar', layout: 'layout'

      {h2,doctype,html,head,title,body} = @teacup

      @view index: -> h2 "CoffeeCup inline template: #{@foo}"

      @view 'layout': ->
        doctype 5
        html ->
          head ->
            title 'CoffeeCup inline layout'
          body @body

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeCup inline layout</title></head><body><h2>CoffeeCup inline template: bar</h2></body></html>'

  'inline + inline non-default layout with name': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @get '/': ->
        @render 'index', foo: 'bar', layout: 'bart'

      {h2,doctype,html,head,title,body} = @teacup

      @view index: -> h2 "CoffeeCup inline template: #{@foo}"

      @view bart: ->
        doctype 5
        html ->
          head ->
            title 'CoffeeCup inline layout'
          body @body

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeCup inline layout</title></head><body><h2>CoffeeCup inline template: bar</h2></body></html>'

  file: (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @get '/': ->
        @render 'index', foo: 'bar', layout: no

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>CoffeeKup file template: bar</h2>'

  'file + file layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @get '/': ->
        @render 'index', foo: 'bar'

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeKup file layout</title></head><body><h2>CoffeeKup file template: bar</h2></body></html>'

  'response.render, file': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @get '/': ->
        @response.render 'index', foo: 'bar', layout: no

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>CoffeeKup file template: bar</h2>'

  'response.render, file + file layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @get '/': ->
        @response.render 'index', foo: 'bar'

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>CoffeeKup file layout</title></head><body><h2>CoffeeKup file template: bar</h2></body></html>'

  'eco, inline': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @app.engine 'eco', require('consolidate').eco
      @set 'view engine': 'eco'

      @get '/': ->
        @render 'index', foo: 'bar', layout: no

      @view index: "<h2>Eco inline template: <%= @foo %></h2>"

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>Eco inline template: bar</h2>'

  'eco, inline + inline layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @app.engine 'eco', require('consolidate').eco
      @use 'partials'
      @set 'view engine': 'eco'

      @get '/': ->
        @render 'index', foo: 'bar'

      @view index: "<h2>Eco inline template: <%= @foo %></h2>"

      @view layout: '''
        <!DOCTYPE html>
        <html>
          <head>
            <title>Eco inline layout</title>
          </head>
          <body><%- @body %></body>
        </html>
      '''

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html>\n<html>\n  <head>\n    <title>Eco inline layout</title>\n  </head>\n  <body><h2>Eco inline template: bar</h2></body>\n</html>'

  'eco, file': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @app.engine 'eco', require('consolidate').eco
      @use 'partials'
      @set 'view engine': 'eco'

      @get '/': ->
        @render 'index', foo: 'bar', layout: no

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>Eco file template: bar</h2>'

  'eco, file + file layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @app.engine 'eco', require('consolidate').eco
      @use 'partials'
      @set 'view engine': 'eco'

      @get '/': ->
        @render 'index', foo: 'bar'

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html>\n<html>\n  <head>\n    <title>Eco file layout</title>\n  </head>\n  <body><h2>Eco file template: bar</h2></body>\n</html>'

  'eco, zappa adapter, inline + inline layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @set 'view engine': 'eco'
      @app.engine 'eco', require('consolidate').eco
      @use partials:
        eco: zappa.adapter 'eco'

      @get '/': ->
        @render 'index', foo: 'bar'

      @view index: "<h2>Eco inline template: <%= @foo %></h2>"

      @view layout: '''
        <!DOCTYPE html>
        <html>
          <head>
            <title>Eco inline layout</title>
          </head>
          <body><%- @body %></body>
        </html>
      '''

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html>\n<html>\n  <head>\n    <title>Eco inline layout</title>\n  </head>\n  <body><h2>Eco inline template: bar</h2></body>\n</html>'

  'jade, inline': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @set 'view engine': 'jade'

      @get '/': ->
        @render 'index', foo: 'bar', layout: no

      @view index: "h2= 'Jade inline template: ' + foo"

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>Jade inline template: bar</h2>'

  'jade, inline + inline layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @set 'view engine': 'jade'

      @get '/': ->
        @render 'index', foo: 'bar'

      @view index: "h2= 'Jade inline template: ' + foo"

      @view layout: '''
        doctype html
        html
          head
            title Jade inline layout
          body!= body
      '''

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>Jade inline layout</title></head><body><h2>Jade inline template: bar</h2></body></html>'

  'jade, inline + include': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @set 'view engine': 'jade'

      @get '/': ->
        @render 'index', foo: 'bar'

      @view index: '''
        doctype html
        html
          include head
          body
            h2= 'Jade inline template: ' + foo
            include foot
      '''

      @view head: '''
        head
          title Jade inline template
      '''

      @view foot: '''
        div= 'This was an example.'
      '''

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>Jade inline template</title></head><body><h2>Jade inline template: bar</h2><div>This was an example.</div></body></html>'

  'jade, file': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @set 'view engine': 'jade'

      @get '/': ->
        @render 'index', foo: 'bar', layout: no

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<h2>Jade file template: bar</h2>'

  'jade, file + file layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @use 'partials'
      @set 'view engine': 'jade'

      @get '/': ->
        @render 'index', foo: 'bar'

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>Jade file layout</title></head><body><h2>Jade file template: bar</h2></body></html>'

  'jade, zappa adapter, inline + inline layout': (t) ->
    t.expect 1
    t.wait 3000

    zapp = zappa port++, ->
      @set 'view engine': 'jade'
      @use partials:
        jade: zappa.adapter 'jade'

      @get '/': ->
        @render 'index', foo: 'bar'

      @view index: "h2= 'Jade inline template: ' + foo"

      @view layout: '''
        doctype html
        html
          head
            title Jade inline layout
          body!= body
      '''

    c = t.client(zapp.server)
    c.get '/', (err, res) ->
      t.equal 1, res.body, '<!DOCTYPE html><html><head><title>Jade inline layout</title></head><body><h2>Jade inline template: bar</h2></body></html>'
