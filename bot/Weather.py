# -*- coding: cp1252 -*-
import urllib,xml.sax.handler
# S10 COMPATIABLE
def message(data):
    if data["type"] == "PRIVMSG":
        try:
            splitdata = data["content"].lower().split(" ")
            if splitdata[0] == ":weather" and len(splitdata) > 1:
                data = Weather(" ".join(splitdata[1:]))
                
                data["conn"].privmsg(data["target"],"Weather for "+data[1]+": "+data[0])
                return True
        except KeyError:
            print "WUT"
    else:
        return -1
def Weather(question):
    question = question.replace("ä","a")
    url = "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query="+question
    opener = urllib.FancyURLopener({})
    f = opener.open(url)
    data = f.read()
    f.close()
    bufferi = []
    seen = False
    for i in data.split("\n"):
        if "<temperature_string>" in i:
            stuff = cutter(i,"<temperature_string>")
            if len(stuff) > 7:
                bufferi.append("Temperature: "+stuff)
        elif "<observation_time>" in i:
            stuff = cutter(i,"<observation_time>")
            if len(stuff) > 19:
                bufferi.append(stuff)
        elif "<weather>" in i:
            stuff = cutter(i,"<weather>")
            if len(stuff) > 0:
                bufferi.append("Weather: "+stuff)
        elif "<relative_humidity>" in i:
            stuff = cutter(i,"<relative_humidity>")
            if len(stuff) > 0:
                bufferi.append("Humidity: "+stuff)
        elif "<wind_string>" in i:
            stuff = cutter(i,"<wind_string>")
            if len(stuff) > 0:
                bufferi.append("Wind blows "+stuff)
        elif "<pressure_string>" in i:
            stuff = cutter(i,"<pressure_string>")
            if len(stuff) > 9:
                bufferi.append("Air pressure is "+stuff)
        elif "<full>" in i and seen == False:
            seen = True
            where = cutter(i,"<full>")
            if len(where) == 4:
                where = "Location doesn't exist"
    return [", ".join(bufferi),where]
def cutter(fullstring,cut):
    fullstring = fullstring.replace(cut,"")
    fullstring = fullstring.replace("</"+cut[1:],"")
    fullstring = fullstring.replace("\t","")
    return fullstring
