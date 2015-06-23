### EXPERIMENTAL PROTOTYPE ###
# e = 2.7182818284590452353602874713526624977572
# pi = math.pi
from __future__ import division #PYTHON Y U NO TELL ME THIS BEFORE
import math
import random
import re
e = "2.7182818284590452353602874713526624977572"
pi = str(math.pi)
global pre
pre = len("maths ")
def maths(influx,prefix="!",sender="NaN",debug=True,method="n"):
  global pre
  influx = influx.lower()
  influx = influx[len(prefix)+pre:]
  influx = influx.replace("pie",pi+"*"+e)
  influx = influx.replace("e*",e+"*")
  influx = influx.replace("*e","*"+e)
  influx = influx.replace("pi",pi)
  if debug:
    print sender+":"+prefix+"maths"
  if influx.count("**") == 0 and influx.count('"') == 0 and influx.count("'") == 0 and influx.count(";") == 0 and influx.count(":") == 0:
    influx_low = influx.lower()
    influx_hi = influx.upper()
    if "0b" in influx_low:
      influx_low = re.sub("0b[0-1]*","",influx_low)
      influx_hi = re.sub("0B[0-1]*","",influx_hi)
    if "0x" in influx_low:
      influx_low = re.sub("0x[a-f0-9]*","",influx_low)
      influx_hi = re.sub("0X[A-F0-9]*","",influx_hi)
    if "rand" in influx_low:
      influx_low = re.sub("rand","",influx_low)
      influx_hi = re.sub("RAND","",influx_hi)
    if influx_low == influx_hi:
      influx = re.sub("rand","random.random()",influx)
      try:
        result = eval(influx.lower())
      except ZeroDivisionError:
        return "Divide by zero detected."
      except SyntaxError:
        return "Syntax Error detected."
      except TypeError:
        return "Type Error detected."
      except:
        return "Unknown Error detected."
      else:
        if method == "n": #Normal
          return result
        elif method == "i": #Forced Int
          return int(result)
        elif method == "h": #Hex
          try:
            if "L" in hex(result)[2:]:
              return hex(result)[2:-1]
            else:
              return hex(result)[2:].upper()
          except TypeError:
            return "That value (%s) cannot be interpreted properly using !hmaths" %(str(result))
        elif method == "b": #Binary
          try:
            return bin(result)[2:].upper()
          except TypeError:
            return "That value (%s) cannot be interpreted properly using !bmaths" %(str(result))
        else:
          return result
    else:
      return "What are you trying to make me do again?"
  else:
    return "Those are likely to make me hang"
  
