"""
Adapted from http://sprunge.us/iFQc?python

Thanks to mloc.
"""

from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig
import logging, random, re, time

REG_WIKI = re.compile(r"\[\[([a-zA-Z0-9_ ]+)\]\]")

REPLY_LIMIT = 5

@Plugin
class MediaWikiPlugin(IPlugin):
    def __init__(self, bot):
        IPlugin.__init__(self, bot)
        
        self.data = None
        self.config = None
        self.url = 'http://tgstation13.org/wiki/'
        
        self.config = globalConfig.get('plugins.mediawiki')
        if self.config is None:
            logging.warn('MediaWiki: Disabled.') 
            return
        
        if 'url' in self.config:
            self.url = self.config['url']
                
    def findPage(self, event):
        matches = REG_WIKI.finditer(event.arguments[0])
        ids = []
        for match in matches:
            ids += [match.group(1)]
    
        replies = []
        for id in ids:
            replies += [self.url + id]
        return replies
        
    def OnChannelMessage(self, connection, event):
        if self.config is None:
            return
        
        channel = event.target
        
        replies = []
        replies += self.findPage(event)
        
        if len(replies) > 0:
            i = 0
            for reply in replies:
                if reply is None or reply.strip() == '': continue
                i += 1
                if i > REPLY_LIMIT:
                    self.bot.privmsg(channel, 'More than {} results found, aborting to prevent spam.'.format(REPLY_LIMIT))
                    return
                self.bot.privmsg(channel, reply)
