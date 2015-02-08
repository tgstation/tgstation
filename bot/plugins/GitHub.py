"""
Adapted from http://sprunge.us/iFQc?python

Thanks to mloc.
"""
from vgstation.common.plugin import IPlugin, Plugin
import vgstation.common.config as globalConfig
import logging, random, re, time

import github3

BUG_CHECK_DELAY = 60  # 60sec

REG_PATH = re.compile(r"\[([a-zA-Z\-_/][a-zA-Z0-9\- _/]*\.[a-zA-Z]+)\]", re.I)
REG_ISSUE = re.compile(r"\[#?([0-9]+)\]")

TREE_CHECK_DELAY = 300 # 5 minutes

REPLY_LIMIT=5

@Plugin
class GitHubPlugin(IPlugin):
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
        
        self.tree = None
        self.nextTreeDownload=0
        
        self.config = globalConfig.get('plugins.github')
        if self.config is None:
            logging.warn('GitHub: Disabled.') 
            return
        
        self.data = {
            'last-bug-created': 0,
            'ignored-names': [
                '/^Not\-[0-9]+/' # Notifico bots
            ]
        }
        
        self.LoadPluginData()
        
        self.url = globalConfig.get('plugins.github.url', None)
        if self.url is None:
            logging.error('GitHub: Disabled.') 
            return
        # http://github.com/user/repo
        repodata = self.url[18:]
        if repodata.startswith('/'):
            repodata = repodata[1:]
        repoChunks = repodata.split('/')
        self.user_id = repoChunks[0]
        self.repo_id = repoChunks[1]
        
        self.ignored = []
        for ignoretok in self.data.get('ignored-names',['/^Not\-[0-9]/']):
            if ignoretok.startswith('/') and ignoretok.endswith('/'):
                self.ignored+=[re.compile(ignoretok[1:-1])]
            else:
                self.ignored+=[re.compile('^'+re.escape(ignoretok)+'$')]
                
        self.bug_info_format = globalConfig.get('plugins.github.bug-info-format', 'GitHub #{ID}: \'{SUBJECT}\' - {URL} ({STATUS})')
                
        #auth_user = globalConfig.get('plugins.github.username', None)
        auth_key = globalConfig.get('plugins.github.apikey', None)
        self.github = github3.login(token=auth_key)
        self.repo = self.github.repository(self.user_id, self.repo_id)
        self.default_branch = globalConfig.get('plugins.github.default_branch','master')
        
        self.getTree()
        
    def getTree(self):
        if self.nextTreeDownload < time.time():
            self.nextTreeDownload = time.time() + TREE_CHECK_DELAY
            self.tree = self.repo.tree("HEAD").recurse().to_json()
            
    def findPath(self, path):
        pattern = re.compile("^.*(^|/){}$".format(path), re.I)
        for entry in self.tree["tree"]:
            if pattern.match(entry["path"]):
                return(entry["path"])
        
    def checkIgnore(self, nick):
        for ignored in self.ignored:
            m = ignored.search(nick)
            if m is not None:
                return True
        return False
    
    def issueToString(self,issue):
        bugmsg = self.bug_info_format
        bugmsg = bugmsg.replace('{ID}', str(issue.number))
        bugmsg = bugmsg.replace('{AUTHOR}', issue.user.login)
        bugmsg = bugmsg.replace('{SUBJECT}', issue.title)
        bugmsg = bugmsg.replace('{STATUS}', issue.state)
        bugmsg = bugmsg.replace('{URL}', issue.html_url)
        return bugmsg.split('{CRLF}')
    
    def findBugs(self, event):
        matches = REG_ISSUE.finditer(event.arguments[0])
        ids = []
        for match in matches:
            ids += [match.group(1)]
    
        replies  = []
        for id in ids:
            issue = self.repo.issue(id)
            if issue:
                replies += self.issueToString(issue)
        return replies
                
    def findPaths(self, event):
        matches = REG_PATH.finditer(event.arguments[0])
        ids = []
        for match in matches:
            ids += [match.group(1)]
    
        replies  = []
        for id in ids:
            path = self.findPath(id)
            if path:
                replies += ['{}/blob/{}/{}'.format(self.url,self.default_branch,path)]
        return replies
        
    def OnChannelMessage(self, connection, event):
        if self.data is None:
            return
        
        channel = event.target
        
        if self.checkIgnore(event.source.nick):
            return
        
        replies=[]
        replies += self.findBugs(event)
        replies += self.findPaths(event)
        
        if len(replies) > 0:
            i=0
            for reply in replies:
                if reply is None or reply.strip() == '': continue
                i+=1
                if i > REPLY_LIMIT:
                    self.bot.privmsg(channel, 'More than {} results found, aborting to prevent spam.'.format(REPLY_LIMIT))
                    return
                self.bot.privmsg(channel, reply)
