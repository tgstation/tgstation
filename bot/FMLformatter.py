from htmltagremove import htr
def formatter(data):
  newdata = []
  data = htr(data)
  bad = ["Your nick : Categories : ","\r","Advanced search - last",
         "FMyLife","Get the guts to spill the beans","FML: Your random funny stories",
         "Woman","Man","Choose","Health","Intimacy","Miscellaneous","Man or woman? ",
         "Money","Kids","Work","Love","Email notification?",
         "Moderate the FMLs","Submit your FML story",
         "- If your story isn't published on the website, don't feel offended, and thank you nevertheless&#33;",
         "Pick a country","See all","Your account","Team's blog",
         "Meet the FMLHello readers! Did you meet someone new this...The whole blog",
         "Amazon","Borders","IndieBound","Personalized book","Terms of use",
         "FML t-shirts -","Love - Money - Kids - Work - Health - Intimacy - Miscellaneous - Members",
         "Follow the FML Follow the FML blog Follow the FML comments ",
         "_qoptions={",
         "};","})();","Categories","Sign up - Password? ", " Net Avenir : gestion publicitaire",
         "FMyLife, the book","Available NOW on:","Barnes &amp; Noble"]
         
  for checkable in data:
    if checkable in bad:
      pass
    elif "_gaq.push" in checkable:
      pass
    elif "ga.src" in checkable:
      pass
    elif "var _gaq" in checkable:
      pass
    elif "var s =" in checkable:
      pass
    elif "var ga" in checkable:
      pass
    elif "function()" in checkable:
      pass
    elif "siteanalytics" in checkable:
      pass
    elif "qacct:" in checkable:
      pass
    elif "\r" in checkable:
      pass
    elif "ic_" in checkable:
      pass
    elif "Please note that spam and nonsensical stories" in checkable:
      pass
    elif "Refresh this page" in checkable:
      pass
    elif "You...The whole blo" in checkable:
      pass
    elif "Net Avenir : gestion publicitair" in checkable:
      pass
    else:
      if "Net Avenir : gestion publicitaireClose the advertisement" in checkable:
        checkable = checkable.replace("Net Avenir : gestion publicitaireClose the advertisement","")
      newdata.append(checkable)
  return newdata
