def Namecheck(name,against,sender):
    __doc__ = "False = No match, True = Match"
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
    
    
