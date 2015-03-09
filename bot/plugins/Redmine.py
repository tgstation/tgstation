"""
Adapted from the Supybot plugin.
"""
from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig
import logging, random, re, time
# import restkit
from restkit import BasicAuth, Resource, RequestError
from restkit.errors import RequestFailed, ResourceNotFound
import simplejson as json

BUG_CHECK_DELAY = 60  # 60sec

@Plugin
class RedminePlugin(IPlugin):
    def __init__(self, bot):
        IPlugin.__init__(self, bot)
        
        self.data=None
        self.config=None
        self.url=None
        self.ignored=[]
        self.auth=None
        self.project_id=None
        self.resource=None
        self.lastCheck=0
        
        self.config = globalConfig.get('plugins.redmine')
        if self.config is None:
            logging.error('Redmine: Disabled.') 
            return
        
        self.data = {
            'last-bug-created': 0,
            'ignored-names': [
                '/^Not\-[0-9]+/' # Notifico bots
            ]
        }
        
        self.LoadPluginData()
        
        self.url = globalConfig.get('plugins.redmine.url', None)
        if self.url is None:
            logging.error('Redmine: Disabled.') 
            
            return
        self.ignored = []
        for ignoretok in self.data.get('ignored-names',['/^Not\-[0-9]/']):
            if ignoretok.startwith('/') and ignoretok.endwith('/'):
                self.ignored+=[re.compile(ignoretok[1:-1])]
            else:
                self.ignored+=[re.compile('^'+re.escape(ignoretok)+'$')]
        self.auth = BasicAuth(globalConfig.get('plugins.redmine.apikey', None), str(random.random()))
        self.project_id = globalConfig.get('plugins.redmine.project', None)
        if self.project_id is None: logging.warning('Redmine: Not going to check for bug updates.')
        self.bug_info_format = globalConfig.get('plugins.redmine.bug-info-format', 'Redmine #{ID} - {AUTHOR} - {STATUS} - {SUBJECT}{CRLF}{URL}')
        self.new_bug_format = globalConfig.get('plugins.redmine.new-bug-format', 'NEW ISSUE: {URL} (#{ID}: {SUBJECT})')
        self.resource = Resource(self.url, filters=[self.auth])
        
        self.bug_regex = re.compile(r'#(\d+)\b')
        
        self.lastCheck = 0
        
    def checkIgnore(self, nick):
        for ignored in self.ignored:
            m = ignored.search(nick)
            if m is not None:
                return True
        return False
        
    def OnChannelMessage(self, connection, event):
        if self.data is None:
            return
        channel = event.target
        if self.checkIgnore(event.source.nick): return
        matches = self.bug_regex.finditer(event.arguments[0])
        ids = []
        for match in matches:
            ids += [match.group(1)]

        strings = self.getBugs(ids, self.bug_info_format)
        for s in strings:
            self.bot.privmsg(channel, s)
        
    def OnPing(self):
        if self.data is None:
            return
        if not self.bot.welcomeReceived:
            logging.info('Received PING, but no welcome yet.')
            return
        now = time.time()
        if self.lastCheck + BUG_CHECK_DELAY < now:
            self.lastCheck = now
            bugs = self.getAllBugs(project_id=self.project_id, sort='created_on:desc')
            if bugs is None: return
            # print(repr(bugs))
            lbc = ''
            for bug in bugs['issues']:
                if bug['created_on'] != self.data['last-bug-created']:
                    if lbc == '':
                        lbc = bug['created_on']
                    strings = self.getBugs([bug['id']], self.new_bug_format)
                    for s in strings:
                        self.bot.sendToAllFlagged('redmine-' + self.project_id, s)
                else:
                    break
            if lbc == '':
                return
            self.data['last-bug-created'] = lbc
            self.SavePluginData()
            
    def getBugs(self, ids, fmt):
        if self.data is None:
            return
        strings = []
        for id in ids:
            # Getting response
            try:
                response = self.resource.get('/issues/' + str(id) + '.json')
                data = response.body_string()
                result = json.loads(data)
                # Formatting reply
                # self.log.info("info " + bugmsg);
                bugmsg = fmt
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
                
            except ResourceNotFound:
                # strings.append("Unable to find redmine issue {0}.".format(id))
                continue

        return strings
            
    def getAllBugs(self, **kwargs):
        if self.data is None:
            return
        # Getting response
        try:
            response = self.resource.get('/issues.json', **kwargs)
            data = response.body_string()
            return json.loads(data)
            
        except RequestFailed as e:
            logging.error('HTTP Error {0}: {1}'.format(e.status_int, e.message))
            return None
