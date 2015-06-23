from urllib2 import urlopen
from json import loads
from pickle import dump,load
from CORE_DATA import no_absolute_paths
def xkcd(link):
    try:
        filename = link[link.find("xkcd.com")+9:].replace("/","").replace("\\","")
        if no_absolute_paths:
            tiedosto = open("xkcdcache/"+filename,"rb")
        else:
            tiedosto = open(directory+"xkcdcache/"+filename,"rb")
    except:
        try:
            if no_absolute_paths:
                tiedosto = open("xkcdcache/"+filename,"wb")
            else:
                tiedosto = open(directory+"xkcdcache/"+filename,"wb")
        except IOError:
            return "NOTHING"
    else:
        try:
            return load(tiedosto)
        except EOFError:
            tiedosto = open("xkcdcache/"+filename,"wb")
            pass #Corrupt cache, moving on.
    if link[-1] == "/" or link[-1] == "\\": #Ending is fine.
        link += "info.0.json"
    else:
        link += "/info.0.json"
    try:
        data = urlopen(link).read()
    except:
        return "NOTHING"
    try:
        newdata = loads(data)["title"]
        dump(newdata,tiedosto)
        return newdata
    except:
        return "NOTHING"
    
