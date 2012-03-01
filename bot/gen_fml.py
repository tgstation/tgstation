from FMLformatter import formatter
from urllib2 import urlopen
try:
  from hashlib import md5
except:
  from md5 import md5
from save_load import save,load
import CORE_DATA
directory = CORE_DATA.directory
FML = urlopen("http://www.fmylife.com/random")
formatted = formatter(FML.read().split("\n"))
for Quote in formatted:
  exact = Quote[:Quote.find("#")]
#  print exact
  save(directory+"fmlquotes/"+md5(exact).hexdigest()+".txt",exact)
