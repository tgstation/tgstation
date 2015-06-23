from random import choice as fsample #Yay for added speed!
global responses
responses = ['Yes','Too bad','Will you turn me off if I tell you?','Absolutely',
             "Not at all", "Nope", "It does", "No", "All the time",
             "I don't really know", "Could be","Possibly","You're still here?",# Chaoticag
             "No idea", "Of course", "Would you turn me off if I tell you?",
             "Sweet!","Nah","Certainly","Yeah","Yup","I am quite confident that the answer is Yes",
             "Perhaps", "Yeeeeaah... No.", "Indubitably" ] # Richard
def eightball(data,debug,sender,prefix):
  global responses
  arg = data.lower().replace(prefix+"eightball ","")
  arg = arg.replace(prefix+"8ball ","")
  if debug:
     print sender+":"+prefix+"eightball", arg
  if "answer" in arg and "everything" in arg and "to" in arg:
     if debug:
       print "Responded with",42
     return "42"
  elif arg == "derp":
    if debug:
      print "Responded with herp"
    return("herp")
  elif arg == "herp":
    if debug:
      print "Responded with derp"
    return("derp")
  else:
     #choice = sample(responses,1)[0]
     choice = fsample(responses)
     if debug:
        print "Responded with", choice
     return(choice)
