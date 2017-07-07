{Robot, Adapter, TextMessage, User} = require.main.require 'hubot'

restify = require 'restify'
builder = require 'botbuilder'

class BotFrameworkBot extends Adapter

  constructor: ->
    super
    @server = restify.createServer()

  send: (envelope, strings...) ->
    session = @robot.brain.get envelope.message.id
    session.send strings...
    return
    
  reply: (envelope, strings...) ->
    session = @robot.brain.get envelope.message.id
    session.send strings...
    return

  run: ->
    @robot.logger.info "Run"
    
    return @robot.logger.error "No Microsoft App ID provided to Hubot" unless process.env.MICROSOFT_APP_ID
    return @robot.logger.error "No Microsoft App Password provided to Hubot" unless process.env.MICROSOFT_APP_PASSWORD
    
    @server.listen process.env.port or process.env.PORT or 3978, =>
      @robot.logger.info "#{@server.name} listening to #{@server.url}"
      return
    
    @connector = new builder.ChatConnector { appId: process.env.MICROSOFT_APP_ID, appPassword: process.env.MICROSOFT_APP_PASSWORD }
    
    @server.post '/api/messages', @connector.listen()
    
    @emit "connected"
    
    bot = new builder.UniversalBot @connector, (session) =>
      @robot.brain.set session.message.address.id, session
      user = new User session.message.user.id, { name : session.message.user.name }
      message = new TextMessage user, session.message.text, session.message.address.id
      @robot.receive message
      return
    
    return

exports.use = (robot) ->
  new BotFrameworkBot robot