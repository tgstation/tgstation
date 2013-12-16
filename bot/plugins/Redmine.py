"""
Adapted from the Supybot plugin.
"""
from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig
import thread, socket, logging, random, re
from restkit import BasicAuth, Resource, RequestError
import simplejson as json

@Plugin
class RedminePlugin(IPlugin):
    def __init__(self, bot):
        IPlugin.__init__(self,bot)
     
        self.url = globalConfig.get('plugins.redmine.url',None)
        if self.url is None:
            logging.error('Redmine: Disabled.') 
            return
        self.auth = BasicAuth(globalConfig.get('plugins.redmine.apikey',None), str(random.random()))
        self.bug_msg_format = globalConfig.get('plugins.redmine.response-format','Redmine #{ID} - {AUTHOR} - {STATUS} - {SUBJECT}{CRLF}{URL}')
        self.resource = Resource(self.url, filters=[self.auth])
        
        self.bug_regex = re.compile(r'#(\d+)\b')
        
        self.bugs_being_fetched=[]
        
    def OnChannelMessage(self, connection, event):
        if self.url is None: return
        channel = event.target
        matches = self.bug_regex.finditer(event.arguments[0])
        ids = []
        for match in matches:
            ids += [match.group(1)]
        logging.info('Snarfed ID(s): ' + ', '.join(ids))

        strings = self.getBugs(ids)
        for s in strings:
            self.bot.privmsg(channel,s)
            
    def getBugs(self, ids):
        if self.url is None: return
        strings = []
        for id in ids:
            # Getting response
            try:
                response = self.resource.get('/issues/' + str(id) + '.json')
                data = response.body_string()
                result = json.loads(data)
                
                # Formatting reply
                #self.log.info("info " + bugmsg);
                bugmsg = self.bug_msg_format
                bugmsg = bugmsg.replace('{ID}', str(id))
                bugmsg = bugmsg.replace('{AUTHOR}', result['issue']['author']['name'])
                bugmsg = bugmsg.replace('{SUBJECT}', result['issue']['subject'])
                bugmsg = bugmsg.replace('{STATUS}', result['issue']['status']['name'])
                bugmsg = bugmsg.replace('{PROJECT}', result['issue']['project']['name'])
                try:
                    bugmsg = bugmsg.replace('{CATEGORY}', result['issue']['category']['name'])
                except Exception:
                    bugmsg = bugmsg.replace('{CATEGORY}', 'uncategorized')
                bugmsg = bugmsg.replace('{URL}', "%s/issues/%s" % (self.url, id))
                bugmsg = bugmsg.split('{CRLF}')
                
                for msg in bugmsg:
                    strings.append(msg)
                
            except RequestError as e:
                strings.append("An error occured when trying to query Redmine: " + str(e))

        return strings