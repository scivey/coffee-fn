_ = require 'underscore'
path = require 'path'
fs = require 'fs'

inDir = (fname) ->
	path.join __dirname, fname

main = require inDir('lib/main.js')

outs = _.extend {}, main

module.exports = outs