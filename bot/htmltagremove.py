def htr(data):
  ignore = False
  if type(data) == list:
    b = []
    for olio in data:
      tempolio = ""
      for letter in olio:
        if letter == "<":
          ignore = True
        else:
          pass
        if ignore != True:
          tempolio += letter
        else:
          pass
        if letter == ">":
          ignore = False
        else:
          pass
      tempolio = tempolio.replace("\t","")
      if len(tempolio) == 0:
        pass
      elif len(tempolio.replace(" ","")) == 0:
        pass
      else:
        b.append(tempolio)
    #Finetuning
    return b
