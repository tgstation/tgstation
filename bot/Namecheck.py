
def Namecheck_allinone(name, against, sender=None):
    __doc__ = "False = No match, True = Match"
    if not isinstance(against, iterable):
        return False

    if isinstance(against, dict): 
        for key, value in against.iteritems():
            if i.lower() in name.lower() and (sender and sender.lower() not in name.lower()):
                return True
    for item in against:
        if i.lower() in name.lower() and sender.lower() not in name.lower():
            return True
            
    return False

def Namecheck(name,against,sender):
    __doc__ = "False = No match, True = Match"
    for item in against:
        
    for i in against:
        if i.lower() in name.lower() and sender.lower() not in name.lower():
            return True
        else:
            pass
def Namecheck_dict(name,against):
    __doc__ = "False = No match, True = Match"
    fuse = False
    for a,i in against.items():
        if i.lower() in name.lower():
            fuse = True
            break
        else:
            pass
    return fuse,a
    
    
