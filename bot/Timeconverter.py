#Sources:
# http://wwp.greenwichmeantime.com/time-zone/usa/eastern-time/convert/
# http://www.timeanddate.com/library/abbreviations/timezones/na/
# Times are GMT +- x
# For eq.
# EST = -5
# GMT = 0
# UTC = 0
#Times are in hours,
#2.5 = 2 and half hours
global times
times = {"ADT":-3,"HAA":-3, #Synonyms on the same line
         "AKDT":-8,"HAY":-8,
         "AKST":-9,"HNY":-9,
         "AST":-4,"HNA":-4,
         "CDT":-5,"HAC":-5,
         "CST":-6,"HNC":-6,
         "EDT":-4,"HAE":-4,
         "EGST":0,
         "EGT":-1,
         "EST":-5,"HNE":-5,"ET":-5,
         "HADT":-9,
         "HAST":-10,
         "MDT":-6,"HAR":-6,
         "MST":-7,"HNR":-7,
         "NDT":-2.5,"HAT":-2.5,
         "NST":-3.5,"HNT":-3.5,
         "PDT":-7,"HAP":-7,
         "PMDT":-2,
         "PMST":-3,
         "PST":-8,"HNP":-8,"PT":-8,
         "WGST":-2,
         "WGT":-3,
         "GMT":0,
         "UTC":0}
def converter(zones,time):
    #Zones should be a list containing
    # ( From zone
    #   To zone )
    global times
    #from_z = for example UTC+00:00, WGT or GMT-05:30
    #to_z = same style as above.
    from_z,to_z = zones
    from_z = from_z.upper()
    to_z = to_z.upper()
    if from_z.find("+") != -1:
        from_zone_offset = from_z[from_z.find("+"):]
        if ":" in from_zone_offset:
            try:
                from_zone_offset1,from_zone_offset2 = from_zone_offset.split(":")
            except ValueError:
                return "Too many or too small amount of values"
            try:
                from_zone_offset = int(from_zone_offset1) + int(from_zone_offset2)/60.0
            except:
                return "Error, the 'From Zone' variable has an incorrect offset number"
        else:
            try:
                from_zone_offset = float(from_zone_offset)
            except:
                return "Error, the 'From Zone' variable has an incorrect offset number"
        try:
            from_zone_realtime = from_zone_offset + times[from_z[:from_z.find("+")]]
        except KeyError:
            return "Incorrect From zone"
        
    elif "-" in from_z:
        from_zone_offset = from_z[from_z.find("-"):]
        if ":" in from_zone_offset:
            from_zone_offset1,from_zone_offset2 = from_zone_offset.split(":")
            try:
                from_zone_offset = -int(from_zone_offset1) + int(from_zone_offset2)/60.0
            except:
                return "Error, the 'From Zone' variable has an incorrect offset number"
        else:
            try:
                from_zone_offset = -float(from_zone_offset)
            except:
                return "Error, the 'From Zone' variable has an incorrect offset number"
        from_zone_realtime = times[from_z[:from_z.find("-")]] - from_zone_offset
        pass
    else:
        from_zone_offset = 0
        try:
            from_zone_realtime = from_zone_offset + times[from_z]
        except KeyError:
            return "Incorrect From zone"
    if to_z.find("+") != -1:
        to_zone_offset = to_z[to_z.find("+"):]
        if ":" in to_zone_offset:
            try:
                to_zone_offset1,to_zone_offset2 = to_zone_offset.split(":")
            except ValueError:
                return "Too many or too small amount of values"
            try:
                to_zone_offset = int(to_zone_offset1) + int(to_zone_offset2)/60.0
            except:
                return "Error, the 'To Zone' variable has an incorrect offset number"
        else:
            try:
                to_zone_offset = float(to_zone_offset)
            except:
                return "Error, the 'To Zone' variable has an incorrect offset number"
        try:
            to_zone_realtime = to_zone_offset + times[to_z[:to_z.find("+")]]
        except KeyError:
            return "The zone you want the time to be changed to is not found"
        
    elif "-" in to_z:
        to_zone_offset = to_z[to_z.find("-"):]
        if ":" in to_zone_offset:
            to_zone_offset1,to_zone_offset2 = to_zone_offset.split(":")
            try:
                to_zone_offset = -int(to_zone_offset1) + int(to_zone_offset2)/60.0
            except:
                return "Error, the 'To Zone' variable has an incorrect offset number"
        else:
            try:
                to_zone_offset = -float(to_zone_offset)
            except:
                return "Error, the 'To Zone' variable has an incorrect offset number"
        to_zone_realtime = times[to_z[:to_z.find("-")]] -to_zone_offset
        
        pass
    else:
        to_zone_offset = 0
        try:
            to_zone_realtime = to_zone_offset + times[to_z]
        except KeyError:
            return "Incorrect To zone"
    try:
        time_hour,time_minute = time.split(":")
        time_hour,time_minute = int(time_hour),int(time_minute)
        string = ":"
    except:
        try:
            time_hour,time_minute = time.split(".")
            time_hour,time_minute = int(time_hour),int(time_minute)
            string = "."
        except ValueError:
            return "The time was input in an odd way"
    if to_zone_realtime % 1.0 == 0.0 and from_zone_realtime % 1.0 == 0.0:
        time_hour = time_hour + (to_zone_realtime - from_zone_realtime)
        return str(int(time_hour))+string+str(int(time_minute))
    else:
        if to_zone_realtime % 1.0 != 0.0 and from_zone_realtime % 1.0 != 0.0:
            time_minute = time_minute + (((to_zone_realtime % 1.0) * 60) - ((from_zone_realtime % 1.0) * 60))
        elif to_zone_realtime % 1.0 != 0.0 and from_zone_realtime % 1.0 == 0.0:
            time_minute = time_minute + (((to_zone_realtime % 1.0) * 60) - 0)
        elif to_zone_realtime % 1.0 == 0.0 and from_zone_realtime % 1.0 != 0.0:
            time_minute = time_minute + (0 - ((from_zone_realtime % 1.0) * 60))
        else:
            print "Wut?"
        time_hour = time_hour + (int(to_zone_realtime//1) - int(from_zone_realtime//1))
        return str(int(time_hour))+string+str(int(time_minute))
            
        
def formatter(time):
    if "." in time:
        string = "."
    elif ":" in time:
        string = ":"
    else:
        return time
    hours,minutes = time.split(string)
    days = 0
    if int(minutes) < 0:
        buphours = int(hours)
        hours,minutes = divmod(int(minutes),60)
        hours += buphours
    if int(minutes) > 60:
        hours,minutes = divmod(int(minutes),60)
        hours += int(hours)
    if int(hours) < 0:
        days = 0
        days,hours = divmod(int(hours),24)
    if int(hours) > 24:
        days = 0
        days,hours = divmod(int(hours),24)
        if int(hours) == 24 and int(minutes) > 0:
            days += 1
            hours = int(hours) - 24
    hours = str(hours)
    minutes = str(minutes)
    if len(minutes) == 1:
        minutes = "0"+minutes
    if len(hours) == 1:
        hours = "0"+hours
    if days > 0:
        if days == 1:
            return hours+string+minutes+" (Tomorrow)"
        else:
            return hours+string+minutes+" (After "+str(days)+" days)"
    elif days < 0:
        if days == -1:
            return hours+string+minutes+" (Yesterday)"
        else:
            return hours+string+minutes+" ("+str(abs(days))+" days ago)"
    return hours+string+minutes
    
    
        
         

