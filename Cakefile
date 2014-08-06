{spawn, exec} = require 'child_process'
log = console.log

task 'build', ->
  run 'coffee -o lib -c src/*.coffee'

task 'test', ->
  # Set `ulimit -n 1024` if you run out of descriptors.
  run 'coffee tests/index.coffee'

task 'bench', ->
  run 'cd benchmarks && ./run'

task 'docs', ->
  run 'docco src/*.coffee'

task 'vendor', ->
  uglify = require 'uglify-js'
  fs = require 'fs'
  run 'mkdir -p vendor && cd vendor && curl -o jquery.js -L http://code.jquery.com/jquery-1.11.1.js', ->
    run 'cd vendor && curl -OL https://raw.github.com/quirkey/sammy/v0.7.4/lib/sammy.js', ->
      run 'cd vendor && curl -L https://cdn.socket.io/socket.io-1.0.3.js > socket.io.js', ->
        run 'head -n 2 vendor/jquery.js', ->
          run 'head -n 2 vendor/sammy.js', ->
            run 'head -n 1 vendor/socket.io.js', ->
              fs.writeFile 'vendor/jquery.min.js', uglify.minify('vendor/jquery.js').code, ->
                fs.writeFile 'vendor/sammy.min.js', uglify.minify('vendor/sammy.js').code, ->
                  fs.writeFile 'vendor/socket.io.min.js', uglify.minify('vendor/socket.io.js').code, ->

task 'setup', 'build + vendor', ->
  invoke 'build'
  invoke 'vendor'

task 'clean', ->
  run 'rm -r vendor node_modules lib/*.js benchmarks/out/*.dat benchmarks/out/*.out tests/*.js _site', ->
    run 'npm cache clear'

run = (args...) ->
  for a in args
    switch typeof a
      when 'string' then command = a
      when 'object'
        if a instanceof Array then params = a
        else options = a
      when 'function' then callback = a

  command += ' ' + params.join ' ' if params?
  cmd = spawn '/bin/sh', ['-c', command], options
  cmd.stdout.on 'data', (data) -> process.stdout.write data
  cmd.stderr.on 'data', (data) -> process.stderr.write data
  process.on 'SIGHUP', -> cmd.kill()
  cmd.on 'exit', (code) -> callback() if callback? and code is 0
