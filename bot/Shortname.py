def shortname(name):
  lowname = name.lower()
  numb = 0
  count = 0
  spot = 0
  for letter in name:
    if letter.isupper():
      spot = numb
      count += 1
    numb += 1
  if "_" in name:
    if name.count("_") > 1:
      name = " ".join(name.split("_")[0:name.count("_")])
      if name.lower()[-3:] == "the":
        return name[:-4]
      else:
        return name
    else:
      return name.split("_")[0]
  if count > 1:
    if len(name[0:spot]) > 2:
      return name[0:spot]
  if len(name) < 5:
    return name #Too short to be shortened
  elif "ca" in lowname or "ct" in lowname or "tp" in lowname or "lp" in lowname:
    return name[0:max(map(lambda x: lowname.find(x),["ca","ct","tp","lp"]))+1]
  else:
    return name[0:len(name)/2+len(name)%2]
