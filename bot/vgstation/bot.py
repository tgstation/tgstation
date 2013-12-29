import string
import irc.bot
import vgstation.common.config as globalConfig
import logging

class Bot(irc.bot.SingleServerIRCBot):
    def __init__(self, hostname, config):
        logging.info('Starting up.' + repr(config))
        port = config['port']
        nickname = config['nick']
        
        irc.bot.SingleServerIRCBot.__init__(self, [(hostname, port)], nickname, nickname)
        
        self.chanconfig = config['channels']
        
        self.command = {}
        self.plugins = []
        for i in ["ping"]:
            self.connection.add_global_handler(i, getattr(self, "on_" + i), 0)
        self.welcomeReceived = False
        
        self.messageQueue = []
        self.connection.execute_every(1, self.SendQueuedMessage)
        
    def SendQueuedMessage(self):
        if len(self.messageQueue) == 0: return
        msg = self.messageQueue[0]
        msgtype, target, message = msg 
        logging.info('{0} -> {1}: {2}'.format(msgtype, target, self.stripUnprintable(message)))
        if msgtype == 'PRIVMSG':
            self.connection.privmsg(target, message)
        elif msgtype == 'NOTICE':
            self.connection.notice(target, message)
        self.messageQueue.remove(msg)
        
    def on_join(self, c, e):
        ch = e.target
        nick = e.source.nick
        for plugin in self.plugins:
            if plugin.OnJoin(ch, nick): break
        
    def on_ping(self, c, e):
        for plugin in self.plugins:
            if plugin.OnPing(): break
        
    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        self.welcomeReceived = True
        for channel, channelconfig in self.chanconfig.items():
            password = channelconfig.get('password', None)
            logging.info('Joining {0}...'.format(channel))
            if password is None:
                c.join(channel)
            else:
                c.join(channel, password)

    def on_privmsg(self, c, e):
        msg = e.arguments[0]
        msg = self.stripUnprintable(msg)
        logging.info('PRIVMSG: <{0}> {1}'.format(e.source.nick, msg))
        self.do_command(e, e.arguments[0])

    def on_pubmsg(self, c, e):
        # logging.info(msg.source)
        msg = e.arguments[0]
        msg = self.stripUnprintable(msg)
        logging.info('PUBMSG: <{0}:{1}> {2}'.format(e.source.nick, e.target, msg))
        if ',' in msg:
            args = msg.split(',', 1)
            logging.debug(repr(args))
            if len(args) > 1 and args[0] in globalConfig.get('names', []):
                self.do_command(e, args[1].strip())
        else:
            for plugin in self.plugins:
                if plugin.OnChannelMessage(c, e): break
        return

    def on_dccmsg(self, c, e):
        c.privmsg('Please speak to me in chat or in a PRIVMSG.')

    def on_dccchat(self, c, e):
        return
    
    def stripUnprintable(self, msg):
        return filter(lambda x: x in string.printable, msg)
    
    def notice(self, nick, message):
        self.messageQueue += [('NOTICE', nick, message)]
        # self.connection.notice(nick, message)
    
    def privmsg(self, nick, message):
        self.messageQueue += [('PRIVMSG', nick, message)]
        # self.connection.privmsg(nick, message)

    def do_command(self, e, cmd):
        nick = e.source.nick
        channel = nick
        if e.target:
            channel = e.target
        args = cmd.split(' ')
        cmd = args[0]
        c = self.connection
        if cmd == 'help':
            self.privmsg(nick, '-- VGBot 1.0 Help: (All commands are accessed with {0}, <command> [args]'.format(c.get_nickname()))
            for name in sorted(self.command.keys()):
                self.privmsg(nick, ' {0}: {1}'.format(name, self.command[name].get('help', 'No help= argument for this command.')))
        elif cmd == 'version':
            self.notice(channel, 'VGBot 1.0 - By N3X15')  # pls to not change
        elif cmd in self.command:
            self.command[cmd]['handler'](e, args)
        else:
            self.notice(channel, 'I don\'t know that command, sorry.  Say "{0}, help" for available commands.'.format(c.get_nickname()))
            
    def sendToAllFlagged(self, flag, msg):
        for channel, chandata in self.chanconfig.items():
            if chandata.get(flag, False) == True:
                self.privmsg(channel, msg)
                
    def haveJoined(self, channel):
        return channel in self.channels
        
