from save_load import save
from os import listdir
import CORE_DATA
directory = CORE_DATA.directory
def mkquote(prefix,influx,sender,debug):
  arg = influx[10+len(prefix):]
  if debug:
    print sender+":"+prefix+"makequote "+str(len(arg))+" Characters"
  if len(arg) == 0:
    return("Type something to a quote")
  else:
    files = listdir(directory+"userquotes")
    numb = 0
    while True:
      numb += 1
      if sender.lower()+str(numb) in files:
        pass
      else:
        save(directory+"userquotes/"+sender.lower()+str(numb),[arg,sender.lower()])
        return("Saved as:"+sender.lower()+str(numb))
        break
