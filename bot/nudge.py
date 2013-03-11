import sys,pickle,socket, CORE_DATA
#def pack():
#    path = "/home/ski/Nanotrasen/message.txt"
#    ip = sys.argv[1]
#    dictionary = {"ip":ip,"data":1}
#    try:
#        targetfile = open(path,"r")
#    except IOError:
#        targetfile = open(path,"w")
#        pickle.dump(dictionary,targetfile)
#        targetfile.close()
#        nudge()
#    else:
#        targetfile.close() #Professionals, have standards.
#        pass
def pack():
    ip = sys.argv[1]
    try:
        data = sys.argv[2:] #The rest of the arguments is data
    except:
        data = "NO DATA SPECIFIED"
    dictionary = {"ip":ip,"data":data}
    pickled = pickle.dumps(dictionary)
    nudge(pickled)
def nudge(data):
    if CORE_DATA.DISABLE_ALL_NON_MANDATORY_SOCKET_CONNECTIONS:
        pass
    else:
        HOST = "localhost"
        PORT = 45678
        size = 1024
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST,PORT))
        s.send(data)
        s.close()
    
if __name__ == "__main__" and len(sys.argv) > 1: # If not imported and more than one argument
    pack()
    
