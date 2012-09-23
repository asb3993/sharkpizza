connect = require 'connect'
showdown = require 'showdown'
fs = require 'fs'
module.exports = app = require('express')()
converter = new showdown.converter()

config =
    static_path:"#{__dirname}/static"
    entry_path:"#{__dirname}/entries"

entries = JSON.parse fs.readFileSync "#{config.entry_path}/entries.json","UTF8"

app.configure ->
    @use connect.logger "short"
    @use app.router
    @use connect.static config.static_path

app.get '/hello', (req, res, next) ->
    res.writeHead 200, 'OK'
    res.write 'Hello world!'
    res.end()

app.get '/', (req, res, next) ->
    fs.readdir config.entry_path, (err, files) ->
        return next err if err
        console.log files

app.get '/blog/:id/*', (req, res, next) ->
    res.writeHead 200, 'OK'
    entry = entries[req.params.id]
    fs.readFile "#{config.entry_path}/#{entry.content}", "UTF8", (err, md) ->
       return next err if err
       res.write converter.makeHtml md
       res.end()
 
