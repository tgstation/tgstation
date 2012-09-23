from urllib2 import urlopen
import os
import pickle
from CORE_DATA import directory,no_absolute_paths
global did_tell, no_absolute_paths
no_absolute_paths = True
did_tell = False
def YTCV4(youtube_url,cache=1,debug=0):
    global did_tell, no_absolute_paths
    Do_not_open = True
    __doc__ = "Cache does not affect anything, it's legacy for skibot."
    try:
        cut_down = youtube_url.split("watch?v=")[1].split("&")[0]
        if len(cut_down) > 11: #Longer than normal, presume troll.
            youtube_url.replace(cut_down,cut_down[:11])
        elif len(cut_down) < 11: #Shorter than normal
            pass
    except IndexError:
        return "Reflex: Where's the watch?v=?"
    first_two = cut_down[0:2]
    try:
        if no_absolute_paths:
            tiedosto = open("YTCache/"+first_two+".tcc","r")
        else:
            tiedosto = open(directory+"YTCache/"+first_two+".tcc","r")
    except:
        prev_dict = {}
    else:
        try:
            prev_dict = pickle.load(tiedosto)
        except EOFError: # Cache is corrupt
            os.remove(directory+"/nano/"+tiedosto.name)
            print "REMOVED CORRUPT CACHE: "+tiedosto.name
            prev_dict = {}
        tiedosto.close() # I think this should belong here.
        if cut_down in prev_dict.keys():
            return prev_dict[cut_down]
        else:
            pass
    try:
        if no_absolute_paths:
            tiedosto = open("YTCache/"+first_two+".tcc","w")
        else:
            tiedosto = open(directory+"YTCache/"+first_two+".tcc","w")
    except IOError,error:
        if len(prev_dict.keys()) > 0:
            try:
                tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
            except IOError:
                if did_tell == False:
                    did_tell = True
                    return "COULD NOT ACCESS FILE "+first_two+".tcc! The next time you run this link, it checks it through the web"
                Do_not_open = False
            else:
                did_tell = False
                pickle.dump(prev_dict,tiedosto)
                tiedosto.close()
        else:
            pass
        return "Very odd error occurred: " + str(error)
    youtube_url = youtube_url.replace("http//","http://")
    if youtube_url.lower()[0:7] != "http://" and youtube_url[0:4] == "www.":
        youtube_url = "http://" + youtube_url
    if youtube_url.count("/") + youtube_url.count("\\") < 3:
        if len(prev_dict.keys()) > 0:
            if Do_not_open == True:   
                tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
                pickle.dump(prev_dict,tiedosto)
                tiedosto.close()
        else:
            pass
        return "Reflex: Video cannot exist"
    else:
        if "http://" in youtube_url[0:12].lower() and youtube_url[0:7].lower() != "http://":
            youtube_url = youtube_url[youtube_url.find("http://"):]
        elif youtube_url[0:7].lower() != "http://":
            if len(prev_dict.keys()) > 0:
                if Do_not_open == True:
                    tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
                    pickle.dump(prev_dict,tiedosto)
                    tiedosto.close()
            return "Reflex: Incorrect link start"
    if "?feature=player_embedded&" in youtube_url:
        youtube_url = youtube_url.replace("?feature=player_embedded&","?")
    try:
        website = urlopen(youtube_url)
    except:
        if len(prev_dict.keys()) > 0:
            if Do_not_open == True:
                tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
                pickle.dump(prev_dict,tiedosto)
                tiedosto.close()
        else:
            pass
        return "Reflex: Incorrect link!"
    for i in website.readlines():
        if i.count('<meta name="title" content') == 1:
            if type(i[30:-3]) != str:
                if Do_not_open == True:
                    tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
                    prev_dict[cut_down] = "No title for video"
                    pickle.dump(prev_dict,tiedosto)
                    tiedosto.close()
                return "Video deleted"
            else:
                #result = i[30:-3]
                contentvar = i.find('content="')
                result = i[contentvar+5:i.find('">',contentvar)]
                if "&amp;quot;" in result:
                    result = result.replace("&amp;quot;",'"')
                else:
                    pass
                if "&amp;amp;" in result:
                    result = result.replace("&amp;amp;","&")
                else:
                    pass
                if "&amp;#39;" in result:
                    result = result.replace("&amp;#39;","'")
                else:
                    pass
                if Do_not_open == True:
                    tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
                    prev_dict[cut_down] = result
                    pickle.dump(prev_dict,tiedosto)
                    tiedosto.close()
                return result
    if Do_not_open == True:
        tiedosto = open(directory+"YTCache/"+first_two+".tcc","w") #This is a Just In Case
        prev_dict[cut_down] = "No title for video, Removed / Needs Age verification / Does not exist"
        pickle.dump(prev_dict,tiedosto)
        tiedosto.close()
    return "No title for video, Removed / Needs age verification / Does not exist"
