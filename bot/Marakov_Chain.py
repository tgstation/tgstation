import pickle
import random
import os
import sys
import time
import CORE_DATA
def merge(d1, d2, merger=lambda x,y:x+y):
  #http://stackoverflow.com/questions/38987/how-can-i-merge-two-python-dictionaries-as-a-single-expression
  result = dict(d1)
  for k,v in d2.iteritems():
    if k in result:
      result[k] = merger(result[k], v)
    else:
      result[k] = v
  return result
full_data = {}
imported_data = {}
try:
  tiedostot = os.listdir("Marakov")
except:
  os.mkdir("Marakov")
  tiedostot = os.listdir("Marakov")
else:
  pass
  
listaus = []
for i in tiedostot:
  if "marakov." not in i.lower():
    pass
  else:
    listaus.append(i)
for i in listaus:
  tiedosto = open("Marakov/"+i,"r")
  old_size = len(full_data.keys())
  if i != "Marakov.Cache":
    imported_data = merge(imported_data,pickle.load(tiedosto))
    print "Added contents of "+i+" (Import)"
    print "Entries: "+str(len(imported_data))
  else:
    full_data = merge(full_data,pickle.load(tiedosto))
    new_size = len(full_data.keys())
    print "Added contents of "+i
    print "Entries: "+str(new_size-old_size)
  time.sleep(0.1)

def give_data(data):
  state = False
  for a,b in zip(data.split(" "),data.split(" ")[1:]):
    a = a.lower().replace(",","").replace(".","").replace("?","").replace("!","").replace("(","").replace(")","").replace("[","").replace("]","").replace('"',"").replace("'","")
    b = b.lower().replace(",","").replace(".","").replace("?","").replace("!","").replace("(","").replace(")","").replace("[","").replace("]","").replace('"',"").replace("'","")
    if a not in [CORE_DATA.prefix+"marakov"]+CORE_DATA.SName:
      state = True
      if a[:7] == "http://" or a[:7] == "http:\\\\" or a[:4] == "www.":
        pass
      else:
        try:
          if b not in full_data[a]:
            full_data[a].append(b)
        except:
          try:
            if b not in imported_data[a]:
              pass
          except:
            full_data[a] = []
            full_data[a].append(b)
  if state == True:
    tiedosto = open("Marakov/Marakov.Cache","w")
    pickle.dump(full_data,tiedosto)
    tiedosto.close()
def form_sentence(argument=None):
  length = 0
  attempts = 0
  while attempts < 20:
    sentence = []
    if argument != None:
      a = argument
    else:
      try:
        a = random.choice(full_data.keys())
      except IndexError:
        try:
          b = random.choice(imported_data.keys())
        except IndexError:
          attempts = 999
          return "No sentences formable at all"
    sentence.append(a)
    length = 0
    attempts += 1
    while length < 12 or sentence[-1].lower() in ["but","who","gets","im","most","is","it","if","then","after","over","every","of","on","or","as","the","wheather","whether","a","to","and","for"] and length < 24:
      try:
        b = random.choice(full_data[a])
      except:
        try:
          b = random.choice(imported_data[a])
        except IndexError:
          break
        except KeyError:
          break
        else:
          sentence.append(b)
          length += 1
          a = b
      else:
        sentence.append(b)
        length += 1
        a = b
    if len(sentence) > 5:
      argument = None
      return sentence
    else:
      pass
  argument = None
  return sentence
def remdata(arg):
  try:
    del(full_data[arg])
  except:
    print "There is no such data"
  else:
    tiedosto = open("Marakov/Marakov.Cache","w")
    pickle.dump(full_data,tiedosto)
    tiedosto.close()
def remobject(arg1,arg2):
  try:
    del(full_data[arg1][full_data[arg1].index(arg2)])
  except ValueError:
    print "No such object"
  except KeyError:
    print "No such data"
  else:
    tiedosto = open("Marakov/Marakov.Cache","w")
    pickle.dump(full_data,tiedosto)
    tiedosto.close()
def convert(filename_from,filename_to):
  try:
    tiedosto = open(filename_from,"r")
    data = pickle.load(tiedosto)
    tiedosto.close()
  except:
    try:
      tiedosto.close()
    except:
      pass
    print "Error!"
  else:
    for lista in data.keys():
      try:
        a = lista[-1]
      except IndexError:
        pass
      else:
        if lista[-1] in """",.?!'()[]{}""" and not lista.islower():
          if lista[:-1].lower() in data.keys():
            data[lista[:-1].lower()] += data[lista]
            print "Added "+str(len(data[lista]))+" Objects from "+lista+" To "+lista[:-1].lower()
            del(data[lista])
          else:
            data[lista[:-1].lower()] = data[lista]
            print lista+" Is now "+lista[:-1].lower()
            del(data[lista])
        elif lista[-1] in """",.?!'()[]{}""" and lista.islower():
          if lista[:-1] in data.keys():
            data[lista[:-1]] += data[lista]
            print "Added "+str(len(data[lista]))+" Objects from "+lista+" To "+lista[:-1]
            del(data[lista])
          else:
            data[lista[:-1]] = data[lista]
            print lista+" Is now "+lista[:-1]
            del(data[lista])
        elif not lista.islower():
          if lista.lower() in data.keys():
            data[lista.lower()] += data[lista]
            print "Added "+str(len(data[lista]))+" Objects from "+lista+" To "+lista.lower()
            del(data[lista])
          else:
            data[lista.lower()] = data[lista]
            print lista+" Is now "+lista.lower()
            del(data[lista])
        
        
    for a in data.keys():
      for b in data[a]:
        if b.lower()[:7] == "http://" or b.lower()[:7] == "http:\\\\" or b.lower()[:4] == "www.":
          data[a].pop(b)
        else:
          try:
            if b[-1] in """",.?!'()[]{}""" and not b.islower() and not b.isdigit():
              data[a].pop(data[a].index(b))
              data[a].append(b[:-1].lower())
              print a+" | "+b +" -> "+b[:-1].lower()
            elif b[-1] in """",.?!'()[]{}""" and b.islower():
              data[a].pop(data[a].index(b))
              data[a].append(b[:-1].lower())
              print a+" | "+b +" -> "+b[:-1]
            elif not b.islower() and not b.isdigit():
              data[a].pop(data[a].index(b))
              data[a].append(b.lower())
              print a+" | "+b +" -> "+b.lower()
          except IndexError: #If it has no letters.. well.. yeah.
            data[a].pop(data[a].index(b))
            print "Removed a NULL object"
    tiedosto = open(filename_to,"w")
    pickle.dump(data,tiedosto)
