'''
Created on Dec 12, 2013

@author: Rob
'''

from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig
import thread, socket, logging

@Plugin
class NudgePlugin(IPlugin):
    
    def __init__(self, bot):
        IPlugin.__init__(self, bot)
        
        self.RegisterCommand('shaddap', self.OnShaddap, help='Bot will stop processing nudges.')
        self.RegisterCommand('speak', self.OnSpeak, help='Bot will start processing nudges.')
        
        self.dropNudges = False
        
        self.config = globalConfig.get('plugins.nudge')
        if self.config is None:
            logging.warning('plugin.nudge not present in config.  Aborting load.')
            return
        
        thread.start_new_thread(self.nudge_listener, ())
        
    def OnShaddap(self, event, args):
        self.dropNudges = True
        self.bot.notice(event.source.nick, 'Now dropping nudges.')
        return True
        
    def OnSpeak(self, event, args):
        self.dropNudges = False
        self.bot.notice(event.source.nick, 'No longer dropping nudges.')
        return True
        
    def nudge_listener(self):
        import pickle
        nudgeconfig = globalConfig.get('plugins.nudge')
        port = nudgeconfig['port']
        host = nudgeconfig['hostname']
        backlog = 5
        size = 1024
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind((host, port))
        s.listen(backlog)
        while True:
            # Second arg is address.
            client, _ = s.accept()  # Address == "?.?.?.?"
            data = client.recv(size)
            client.close()  # Throw the bum out!
            truedata = pickle.loads(data)
            to = None
            msg = None
            if truedata.get('key', '') != nudgeconfig['key']:
                logging.info('Dropped nudge (BAD KEY): {0}'.format(repr(truedata)))
                continue
            if truedata.get("channel", None) is not None:
                to = truedata["channel"]
            msg = 'AUTOMATIC ANNOUNCEMENT: [{0}] {1}'.format(truedata['id'], truedata["data"])
                
            if self.dropNudges:
                if to == None:
                    to = 'All'
                logging.info('Dropped nudge to {0}: {1}'.format(to, msg))
                continue
            else:
                if to is None:
                    self.bot.sendToAllFlagged('nudges', msg)
                else:
                    self.bot.sendToAllFlagged(to, msg)
