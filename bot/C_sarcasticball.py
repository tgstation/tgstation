from random import choice as fsample
sarcastic_responses = ["Yeah right","What do I look like to you?","Are you kidding me?",#UsF
                       "As much as you","You don't believe that yourself","When pigs fly",#UsF
                       "Like your grandma","You would like to know, wouldn't you?", #UsF
                       "Like your mom", #Spectre
                       "Totally","Not at all", #Spectre
                       "AHAHAHahahaha, No.", #Strumpetplaya
                       "Not as much as USER","As much as USER",
                       "Really, you expect me to tell you that?",
                       "Right, and you've been building NOUNs for those USERs in the LOCATION, haven't you?" ] #Richard
locations = ["woods","baystation","ditch"]
nouns = ["bomb","toilet","robot","cyborg",
         "garbage can","gun","cake",
         "missile"]
def sarcasticball(data,debug,sender,users,prefix):
  arg = data.lower().replace(prefix+"sarcasticball ","")
  arg = arg.replace(prefix+"sball ","")
  if debug:
    print sender+":"+prefix+"sarcasticball", arg
  choice = fsample(sarcastic_responses)
  if "USER" in choice:
    choice = choice.replace("USER",fsample(users),1)
    choice = choice.replace("USER",fsample(users),1)
  if "NOUN" in choice:
    choice = choice.replace("NOUN",fsample(nouns),1)
  if "LOCATION" in choice:
    choice = choice.replace("LOCATION",fsample(locations),1)
  if debug:
     print "Responded with", choice
  return(choice)
