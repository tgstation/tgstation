import pickle
def save(filename,data,dnrw=0):
  if dnrw == 1:
    try:
      tiedosto = open(filename,"rb")
    except:
      tiedosto = open(filename,"wb")
    else:
      return False
  else:
    tiedosto = open(filename,"wb")
    
  if "http//" in data:
    data = data.replace("http//","http://")
  pickle.dump(data,tiedosto)
  tiedosto.close()
def load(filename):
  try:
    tiedosto = open(filename,"rb")
  except IOError:
    return "ERROR ERROR ERROR ERR"
  a = pickle.load(tiedosto)
  tiedosto.close()
  return a
