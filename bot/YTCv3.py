from urllib2 import urlopen
from CORE_DATA import directory,no_absolute_paths
def YTCV2(youtube_url,cache=1,debug=0):
    import time
    __doc__ = "Cache 0 = No cache access, Cache 1 = Cache access (Default)"
    if cache == 1:
        import md5
        import pickle
        crypt = md5.md5(youtube_url)
        try:
            cryp = crypt.hexdigest()
            if no_absolute_paths:
                tiedosto = open("YTCache/"+cryp,"r")
            else:
                tiedosto = open(directory+"\NanoTrasen\YTCache\\"+cryp,"r")
            aha = pickle.load(tiedosto)
            tiedosto.close()
            return aha[0]
        except:
            if no_absolute_paths:
                tiedosto = open("YTCache/"+crypt.hexdigest(),"w")
            else:
                tiedosto = open(directory+"\NanoTrasen\YTCache\\"+crypt.hexdigest(),"w")
    else:
        pass
    youtube_url = youtube_url.replace("http//","http://")
    if youtube_url.lower()[0:7] != "http://" and youtube_url[0:4] == "www.":
        youtube_url = "http://" + youtube_url
    if youtube_url.count("/") + youtube_url.count("\\") < 3:
        return "Reflex: Video cannot exist"
    else:
        if youtube_url[0:7].lower() != "http://":
            return "Reflex: Incorrect link start"
    try:
        website = urlopen(youtube_url)
    except:
        return "Reflex: Incorrect link!"
    for i in website:
        if i.count('<meta name="title" content') == 1:
            epoch = time.time()
            if type(i[30:-3]) != str:
                if cache == 1:
                    aha = ["No title for video",epoch]
                    pickle.dump(aha,tiedosto)
                    tiedosto.close()
                tiedosto.close()
                return "Video deleted"
            else:
                result = i[30:-3]
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
                if cache == 1:
                    aha = [result,epoch]
                    pickle.dump(aha,tiedosto)
                    tiedosto.close()
                tiedosto.close()
                return result
        
    if cache == 1:
        epoch = time.time()
        aha = ["No title for video, could be removed / does not exist at all",epoch]
        pickle.dump(aha,tiedosto)
        tiedosto.close()
    tiedosto.close()
    return "No title for video, could be removed / does not exist at all"
