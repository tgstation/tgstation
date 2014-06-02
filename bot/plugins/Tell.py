# Inspired by Skilibliaasdadas's bot.

# nt, tell nickname something
# nt, received

from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig

@Plugin
class TellPlugin(IPlugin):
    def __init__(self, bot):
        IPlugin.__init__(self, bot)
        
        # Recipient => Messages ({from,message})
        self.data = {}
        self.LoadPluginData()
        
        # {from,to,message}
        self.lastMessages = []
        
        self.RegisterCommand('tell', self.OnTell, help='Leave a message for someone.')
        self.RegisterCommand('received', self.OnReceived, help='Bot will mark messages sent to you as read.')
        self.RegisterCommand('messages', self.OnMessages, help='Rattle off the messages sent to you.')
        self.RegisterCommand('belay', self.OnBelay, help='Remove last message you sent.')
        
    def OnTell(self, event, args):
        channel = event.target
        nick = event.source.nick
        if len(args) < 3:
            self.bot.notice(nick,'The format is: bot, tell NICKNAME MESSAGE TO SEND')
        msg = ' '.join(args[2:])
        to = args[1]
        message = {'from':nick, 'to':to, 'message':msg}
        self.lastMessages += [message]
        if to not in self.data:
            self.data[to] = []
        else:
            if len(self.data[to]) == 5:
                self.bot.privmsg(channel, '{to} has too many messages. They need to use the received command before I can add more.'.format(**message))
                return True
        self.data[to] += [message]
        self.SavePluginData()
        self.bot.privmsg(channel, 'Your message has been sent.  It will be displayed the next time {to} joins or uses messages.'.format(**message))
        return True
        
    def OnReceived(self, event, args):
        channel = event.target
        nick = event.source.nick
        self.data[nick] = []
        self.SavePluginData()
        self.bot.privmsg(channel, 'Your messages have been cleared.')
        return True
        
    def OnBelay(self, event, args):
        channel = event.target
        nick = event.source.nick
        lm = None
        for m in self.lastMessages:
            if m['from'] == nick:
                lm = m
        if lm is not None:
            self.data[lm['to']].remove(lm)
            self.bot.privmsg(channel, 'Your message to {to} was removed.'.format(**lm))
            self.SavePluginData()
        return True
        
    def OnJoin(self, channel, nick):
        self.SendMessages(channel, nick)
        return False  # Let other plugins use it.
        
    def OnMessages(self, event, args):
        channel = event.target
        nick = event.source.nick
        
        self.SendMessages(channel,nick)
        return True
    
    def SendMessages(self,channel,nick):
        if nick in self.data:
            if len(self.data[nick]) > 0:
                self.bot.privmsg(channel, '{0}, you have {1} messages.  Say "{2}, received" to clear them.'.format(nick, len(self.data[nick]), globalConfig.get('names', ['nt'])[0]))
                for message in self.data[nick]:
                    self.bot.privmsg(channel, '{from}: {message}'.format(**message))
        
