import random
def srtd(data,debug,sender):
  try:
    arg1,arg2 = data.split("d")
  except ValueError, err:
    if str(err) == "need more than 1 value to unpack":
      return("Too small amount of arguments")
    else:
      return("Too many arguments")
  else:
    if debug:
      print sender+":!rtd "+arg1+"d"+arg2
    die = []
    arg1 = arg1.replace(" ","")
    arg2 = arg2.replace(" ","")
    try:
      i_arg1 = int(arg1)
      i_arg2 = int(arg2)
      if abs(i_arg1) == 0 or abs(i_arg2) == 0:
        raise RuntimeError
    except ValueError:
      return("You lied! That's not a number!")
    except RuntimeError:
      return("Too many zeroes!")
    else:
      if abs(i_arg1) > 500:
        return("Too many rolls, I can only do five hundred at max.")
      else:
        for i in xrange(0,abs(i_arg1)):
          if i_arg2 < 0:
            dice = random.randint(i_arg2,0)
          else:
            dice = random.randint(1,i_arg2)
          die.append(dice)
        return(str(reduce(lambda x,y: x+y, die)))
