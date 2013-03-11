global parta,partb
parta = {"A":"N","B":"O","C":"P","D":"Q","E":"R","F":"S","G":"T","H":"U","I":"V","J":"W","K":"X","L":"Y","M":"Z"}
partb = {'O':'B','N':'A','Q':'D','P':'C','S':'F','R':'E','U':'H','T':'G','W':'J','V':'I','Y':'L','X':'K','Z':'M'}
def rot13(text):
  global parta,partb
  newtext = ""
  for letter in text:
    try:
      if letter.isupper():
        newtext += parta[letter]
      else:
        newtext += parta[letter.upper()].lower()
    except:
      try:
        if letter.isupper():
          newtext += partb[letter]
          pass
        else:
          newtext += partb[letter.upper()].lower()
          pass
      except:
        newtext += letter
  return newtext
