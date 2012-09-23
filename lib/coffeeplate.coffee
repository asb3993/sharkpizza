# Simple coffee-script templating
# By chkn

fs = require 'fs'
CoffeeScript = require 'coffee-script'

 # template cache (used unless noCache option is set)
 # for performance, we don't bother stat'ing the file
 # cache['templateName'] = function(parameters) { ... }
 cache = {}

module.exports = (options) ->
	{noCache} = options

	run: (templateFile, params, cb) ->
		fn = cache[templateFile]
		if noCache or not fn
			fs.readFile templateFile, 'utf8', (err, template) ->
				return cb err if err
				code = "with(params) return " + CoffeeScript.compile("\"\"\"\n#{template}\n\"\"\"", bare: on)
				fn = new Function "params", code
				cache[templateFile] = fn if not noCache
				cb null, fn params
		else
			cb null, fn params
