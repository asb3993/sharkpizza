connect = require 'connect'
showdown = new (require('showdown').converter)()
fs = require 'fs'
coffeeplate = require('./lib/coffeeplate')(noCache: true)

module.exports = app = require('express')()

config =
    template_path:"#{__dirname}/templates"
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
    entry = entries[req.params.id]
    fs.readFile "#{config.entry_path}/#{entry.content}", "UTF8", (err, md) ->
        return next err if err
        params =
            page_title: "Timeyoutakeit"
            page_body: showdown.makeHtml md
        coffeeplate.run "#{config.template_path}/template.html", params, (err, html) ->
            res.writeHead 200, 'OK'
            res.write html
            res.end()
 
