import pickle
def save(filename,data,dnrw=0):
  if dnrw == 1:
    try:
      tiedosto = open(filename,"r")
    except:
      tiedosto = open(filename,"w")
    else:
      return False
  else:
    tiedosto = open(filename,"w")
    
  if "http//" in data:
    data = data.replace("http//","http://")
  pickle.dump(data,tiedosto)
  tiedosto.close()
def load(filename):
  try:
    tiedosto = open(filename,"r")
  except IOError:
    return "ERROR ERROR ERROR ERR"
  a = pickle.load(tiedosto)
  tiedosto.close()
  return a
