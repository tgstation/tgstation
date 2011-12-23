import os
directory = ""
raw = os.listdir(directory)
extract = []
for i in raw:
    if i[-3:] == ".py":
        extract.append(i)
toc = 0
toc3 = 0
toc2 = 0
print len(extract),"Files"
lista = []
for ob in extract:
    count3 = 0
    if directory == "":
        tiedosto = open(ob,"r")
        tiedosto2 = open(ob,"r")
        count3 += os.path.getsize(ob)
        toc3 += count3
    else:
        tiedosto = open(directory+"/"+ob,"r")
        tiedosto2 = open(directory+"/"+ob,"r")
        count3 += os.path.getsize(directory+"/"+ob)
        toc3 += count3
    count = 0
    count2 = 0
    line = tiedosto.readline()
    while line != "":
        count += 1
        toc += 1
        line = tiedosto.readline()
    count2 += len(tiedosto2.read())
    toc2 += count2
    lista.append([count,count2,ob,count3])
    tiedosto.close()
    tiedosto2.close()
print toc,"Lines in total"
print toc2,"Letters in total"
print toc3,"Bytes in total"

for linecount, lettercount, filename, bytecount in lista:
    print str(linecount)+" Lines (%s%%) || "%(str(round((float(linecount)/toc)*100,1))),str(lettercount)+" Letters (%s%%)  in file " %(str(round((float(lettercount)/toc2)*100,1)))+filename
    print str(bytecount) + " Bytes (%s%%) "%(str(round((float(bytecount)/toc3)*100,1)))
