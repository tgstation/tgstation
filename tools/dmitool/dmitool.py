""" Python 2.7 wrapper for dmitool.
"""

import os
from subprocess import Popen, PIPE

_JAVA_PATH = ["java"]
_DMITOOL_CMD = ["-jar", "dmitool.jar"]

def _dmitool_call(*dmitool_args, **popen_args):
    return Popen(_JAVA_PATH + _DMITOOL_CMD + [str(arg) for arg in dmitool_args], **popen_args)

def _safe_parse(dict, key, deferred_value):
    try:
        dict[key] = deferred_value()
    except Exception as e: 
        print "Could not parse property '%s': %s"%(key, e)
        return e
    return False

def version():
    """ Returns the version as a string. """
    stdout, stderr = _dmitool_call("version", stdout=PIPE).communicate()
    return str(stdout).strip()

def help():
    """ Returns the help text as a string. """
    stdout, stderr = _dmitool_call("help", stdout=PIPE).communicate()
    return str(stdout).strip()

def info(filepath):
    """ Totally not a hack that parses the output from dmitool into a dictionary. 
        May break at any moment.
    """
    subproc = _dmitool_call("info", filepath, stdout=PIPE)
    stdout, stderr = subproc.communicate()
    
    result = {}
    data = stdout.split(os.linesep)[1:]
    #for s in data: print s
    
    #parse header line
    if len(data) > 0:
        header = data.pop(0).split(",")
        #don't need to parse states, it's redundant
        _safe_parse(result, "images", lambda: int(header[0].split()[0].strip()))
        _safe_parse(result, "size", lambda: header[2].split()[1].strip())
    
    #parse state information
    states = []    
    for item in data:
        if not len(item): continue
    
        stateinfo = {}
        item = item.split(",", 3)
        _safe_parse(stateinfo, "name", lambda: item[0].split()[1].strip(" \""))
        _safe_parse(stateinfo, "dirs", lambda: int(item[1].split()[0].strip()))
        _safe_parse(stateinfo, "frames", lambda: int(item[2].split()[0].strip()))
        if len(item) > 3:
            stateinfo["misc"] = item[3]
        
        states.append(stateinfo)
    
    result["states"] = states
    return result

def extract_state(input_path, output_path, icon_state, direction=None, frame=None):
    """ Extracts an icon state as a png to a given path.
        If provided direction should be a string, one of S, N, E, W, SE, SW, NE, NW.
        If provided frame should be a frame number or a string of two frame number separated by a dash.
    """
    args = ["extract", input_path, icon_state, output_path]
    if direction is not None: args.extend(("direction" , str(direction)))
    if frame is not None: args.extend(("frame" , str(frame)))
    return _dmitool_call(*args)

def import_state(target_path, input_path, icon_state, replace=False, delays=None, rewind=False, loop=None, ismovement=False, direction=None, frame=None):
    """ Inserts an input png given by the input_path into the target_path.
    """
    args = ["import", target_path, icon_state, input_path]
    
    if replace: args.append("nodup")
    if rewind: args.append("rewind")
    if ismovement: args.append("movement")
    if delays: args.extend(("delays", ",".join(delays)))
    if direction is not None: args.extend(("direction", direction))
    if frame is not None: args.extend(("frame", frame))
    
    if loop in ("inf", "infinity"):
        args.append("loop")
    elif loop:
        args.extend(("loopn", loop))
    
    return _dmitool_call(*args)
