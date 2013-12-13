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

    def on_nicknameinuse(self, c, e):
        c.nick(c.get_nickname() + "_")

    def on_welcome(self, c, e):
        for channel, channelconfig in self.chanconfig.items():
            password = channelconfig.get('password', None)
            logging.info('Joining {0}...'.format(channel))
            if password is None:
                c.join(channel)
            else:
                c.join(channel, password)

    def on_privmsg(self, c, e):
        logging.info('PRIVMSG: <{0}> {1}'.format(e.source.nick, e.arguments[0]))
        self.do_command(e, e.arguments[0])

    def on_pubmsg(self, c, msg):
        if ',' in msg.arguments[0]:
            args = msg.arguments[0].split(',', 1)
            logging.debug(repr(args))
            if len(args) > 1 and args[0] in globalConfig.get('names', []):
                self.do_command(msg, args[1].strip())
        else:
            for plugin in self.plugins:
                if plugin.OnChannelMessage(c, msg): break
        return

    def on_dccmsg(self, c, e):
        c.privmsg('Please speak to me in chat or in a PRIVMSG.')

    def on_dccchat(self, c, e):
        return
    
    def notice(self, nick, message):
        logging.info('NOTICE -> {0}: {1}'.format(nick, message))
        self.connection.notice(nick, message)
    
    def privmsg(self, nick, message):
        logging.info('PRIVMSG -> {0}: {1}'.format(nick, message))
        self.connection.privmsg(nick, message)

    def do_command(self, e, cmd):
        nick = e.source.nick
        c = self.connection
        if cmd == 'help':
            self.privmsg(nick, '-- VGBot 1.0 Help: (All commands are accessed with {0}, <command> [args]'.format(c.get_nickname()))
            for name in self.command:
                self.privmsg(nick, ' {0}: {1}'.format(name, self.command[name].get('help', 'No help= argument for this command.')))
        elif cmd == 'version':
            self.notice(nick, 'VGBot 1.0 - By N3X15')  # pls to not change
        elif cmd in self.command:
            self.command[cmd]['handler'](e)
        else:
            self.notice(nick, 'I don\'t know that command, sorry.')
            
    def sendToAllFlagged(self, flag, msg):
        for channel, chandata in self.chanconfig.items():
            if chandata.get(flag, False)==True:
                self.privmsg(channel, msg)
        
