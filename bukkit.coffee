# Description:
#   Fetches a serendipitous image from Ethan Marcotte's legendary bukk.it, possibly matching your choice of word.
#
# Dependencies:
#   "htmlparser": "1.7.6"
#   "soupselect: "0.2.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot bukkit (.*)
#
# Author:
#   David Yee (@tangentialism)
#

#
# bukkits = [['yiss.gif', 'bukkit'], ['foo.jpg', 'misatkes']]
#

htmlparser = require "htmlparser"
Select     = require("soupselect").select

module.exports = (robot) ->
  bukkit_bucket = []

  sources = {
    'bukkit': 'http://bukk.it/',
    'misatkes': 'http://misatkes.com/',
    'wilto': 'http://wil.to/_/'
  }

  bukkits = () ->
    if bukkit_bucket.length == 0
      for own key, source of sources
        bukkit_bucket.concat fill_bukkit(key, source)
        return bukkit_bucket
    else
      return bukkit_bucket

  bukkits_that_look_like = (word) ->
    reggie = new RegExp(word, "i");
    return bukkits().filter (x) -> x[0].match(reggie)

  fill_bukkit = (key, source) ->
    robot.http(source)
      .get() (err, res, body) ->
        handler = new htmlparser.DefaultHandler()
        parser = new htmlparser.Parser(handler)
        parser.parseComplete(body)
        bukkitz_elementz = Select handler.dom, "tr td a"
        console.log(bukkitz_elementz)
        bukkit_contentz = ([link.attribs.href, source] for link in bukkitz_elementz)
        return bukkit_contentz

  giffize_url = (result) ->
    return "#{sources[result[1]]}#{sources[0]}"

  bukkits()

  robot.respond /bukkit( \w+)?$/i, (msg) ->
    if msg.match[1]
      # Let's look for something... *special*
      term = msg.match[1].replace(/\s+/, '')
      my_bukkit = msg.random bukkits_that_look_like(term)
      if my_bukkit
        msg.send giffize_url(my_bukkit)
      else
        msg.reply "There is a curious void in the bukk.itz for “#{term}”"
    else
      my_bukkit = msg.random bukkits()
      msg.send giffize_url(my_bukkit)