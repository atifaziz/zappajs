# test.coffee for mocha
server  = require('../..').app ->
  @include '../app.coffee'
express = server.app

supertest = require 'supertest'

describe 'GET /health', ->

  it 'returns a 200 OK', ->
    supertest(express)
    .get '/health'
    .expect 'Content-Type', /json/
    .expect 200
