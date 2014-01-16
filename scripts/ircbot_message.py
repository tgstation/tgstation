#!/usr/bin/env python2

# nudge.py --channel="nudges|ahelps" --id="Server ID" --key="access key" Message! More message!

import sys, pickle, socket, HTMLParser, argparse

def pack(host, port, key, server_id, channel, message):
    ht = HTMLParser.HTMLParser()
    
    data = {}
    
    data['key'] = key
    data['id'] = server_id
    data['channel'] = channel
    
    try:
        d = []
        for in_data in message:  # The rest of the arguments is data
            d += [ht.unescape(in_data)]
        data['data'] = ' '.join(d)
        
        # Buffer overflow prevention.
        if len(data['data']) > 400:
            data['data'] = data['data'][:400] 
    except:
        data['data'] = "NO DATA SPECIFIED"
    pickled = pickle.dumps(data)
    nudge(host, port, pickled)
    
def nudge(hostname, port, data):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((hostname, port))
    s.send(data)
    s.close()

if __name__ == "__main__" and len(sys.argv) > 1:  # If not imported and more than one argument
    argp = argparse.ArgumentParser()
    
    argp.add_argument('message', nargs='*', type=str, help='String to send to the server.')
    
    argp.add_argument('--host', dest='hostname', default='localhost', help='Hostname expecting a nudge.')
    argp.add_argument('--port', dest='port', type=int, default=45678, help='Port expecting a nudge.')
    argp.add_argument('--channel', dest='channel', default='nudges', help='Channel flag to direct this message to.')
    argp.add_argument('--id', dest='server_id', default='', help='String identifying the server.')
    argp.add_argument('--key', dest='key', default='', help='Access key of the bot or receiving script.')
    
    args = argp.parse_args()

    pack(args.hostname, args.port, args.key, args.server_id, args.channel, args.message)
