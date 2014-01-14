'''
Created on Jul 28, 2013

@author: Rob
'''
import os, yaml
config = {
        'names': [
            'NT',
            'VGTestServer'
        ],
        'servers':{
            'irc.server.tld': {
                'port':6667,
                'password':None,
                'channels':{
                    '#vgstation': {
                        'nudges':True,
                        'status':True
                    }        
                }
            }
        },
        'plugins':
        {
            'redmine': {
                'url': '',
                'apikey':''
            },
            'nudge': {
                'hostname': '',
                'port':     45678,
                'key':      'passwordgoeshere'
            }
        }
}

def ReadFromDisk():
    global config
    config_file = 'config.yml'
    if not os.path.isfile(config_file):
        with open(config_file, 'w') as cw:
            yaml.dump(config, cw, default_flow_style=False)
        
    with open(config_file, 'r') as cr:
        config = yaml.load(cr)
        
    # if config['database']['username'] == '' or config['database']['password'] == '' or config['database']['schema'] == '': 
    #    print('!!! Default config.yml detected.  Please edit it before continuing.')
    #    sys.exit(1)
        
def get(key,default=None):
    global config
    try:
        parts = key.split('.')
        value = config[parts[0]]
        if len(parts) == 1:
            return value
        for part in parts[1:]:
            value = value[part]
        return value
    except KeyError:
        return default