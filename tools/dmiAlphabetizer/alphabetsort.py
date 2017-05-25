#NINX3's dank .dmi file sorter.
import PIL #pep install pillow
from PIL import Image # YOU CANT HAVE PIL OR YOU DIE IN A FIRE
def pngsave(im, file):
    #Credit for this function:
    # public domain, Nick Galbreath
    # http://blog.modp.com/2007/08/python-pil-and-png-metadata-take-2.html

    # these can be automatically added to Image.info dict
    # they are not user-added metadata
    reserved = ('interlace', 'gamma', 'dpi', 'transparency', 'aspect')

    # undocumented class
    from PIL import PngImagePlugin
    meta = PngImagePlugin.PngInfo()

    # copy metadata into new object
    for k in im.info:
        if k in reserved:
            continue
        meta.add_text(k, im.info[k], 1)

    # and save
    im.save(file, "PNG", pnginfo=meta)
def is_sorted(lst, key=lambda x: x):
    for i, el in enumerate(lst[1:]):
        if key(el) < key(lst[i]): # i is the index of the previous element
            return False
    return True
#this is the sorting key, you can do what you wish
def atoz(key):
    return key[0].lower()

def sortAZ(im_str):
    try:
        img = Image.open(im_str)
    except OSError:
        print("error at: " + im_str + ", File failed to open, wrong string or v3 dmi?")
        return
    if img.mode == "RGB":
        print("WARNING: RGB")
    ztxt = img.info["Description"]
    new_data = [] #Last time this is going to look nice
    ztxt = ztxt.split('\n') #UNFUCKED
    pos = 4 # we start at 4 cuz the first few are hardcoded
    width = 0
    height = 0
    force = 0
    if ztxt[1].split()[2] != "4.0":
        print("WARNING: VERSION CHANGE DETECTED")
        print("Shit could be fucked.")
    if ztxt[2].split()[0] != "width":
        print("error old file detected, updating meta data and assuming 32x32")
        force = 1
        width = 32
        height = 32
        pos -=2
    else:
        width = int(ztxt[2].split()[2])
        height = int(ztxt[3].split()[2]) #if this stuff aint in the right place
    #Files fucked anyway
    cell = []
    while pos < len(ztxt):
        txt = ztxt[pos].split()
        if txt[0] == '#':
            print(im_str + "  --empty file?")
            return 0
        #cell.append(txt[2:]) #Can you have spaces?
        if len(txt) > 2:
            assblastusa = txt[2]
            for num in range(3,len(txt)):
                assblastusa += " "+ txt[num]
        cell.append(assblastusa)
        pos += 1
        cell.append(int(ztxt[pos].split()[2]))
        pos += 1
        cell.append(int(ztxt[pos].split()[2]))#We end up with cell having name, dirs, frames
        pos += 1
        cell.append("")#extra data
        cell.append([])#picture data

        txt = ztxt[pos].split()
        while txt[0] != "state" and txt[0] != '#':
            cell[3] += ztxt[pos]+"\n"
            pos += 1
            txt = ztxt[pos].split()
        new_data += [cell]
        if txt[0] == '#':
            break
        cell = []
    #So now we have the meta data happily extracted. Now we need to get the icons
    giticons(new_data,img,width,height)
    #now we need to sort it.
    if not force and is_sorted(new_data,key=atoz):
        #file is sorted, and we dont want to save it cuz that fucks stuff
        return 0
    new_data.sort(key=atoz)
    new_ztxt = gitmetadata(new_data,width,height)
    img.info["Description"] = new_ztxt
    createimage(new_data,img,width,height)
    pngsave(img,im_str)
    return 1

def createimage(data,new_image,width,height):
    pos = 0
    imwidth = new_image.size[0]/width #if this aint round fuck us all
    imheight = new_image.size[1]/height #who the fuck cares?
    for cell in data:
        for icon in cell[4]:
            target = (int(pos%imwidth*width),int(pos//imwidth*height),int((pos+1)%imwidth*width),int((pos+1)//imwidth*height+height))
            if not (pos+1)%imwidth:
                target = (int(pos%imwidth*width),int(pos//imwidth*height),int(imwidth*width),int((pos)//imwidth*height+height))

            new_image.paste(icon,target)
            pos+=1








def gitmetadata(data,w,h):
    ztxt = "# BEGIN DMI\nversion = 4.0\n" #technically not compressed but like whatever I like it more than itxt
    #I could extract the width and height from the first cell but meh
    ztxt += "\twidth = "+ str(w)
    ztxt += "\n\theight = " + str(h) + "\n"
    for cell in data:
        ztxt += "state = "+ str(cell[0]) + "\n\tdirs = " + str(cell[1])
        ztxt += "\n\tframes = " + str(cell[2]) + "\n"
        for line in cell[3]:
            ztxt += line
    ztxt += "# END DMI\n"
    return ztxt
#fucking python bullshit right here
def giticons(new_data,oldimg,width,height):
    imwidth = oldimg.size[0]/width #if this aint round fuck us all
    imheight = oldimg.size[1]/height #who the fuck cares?
    pos = 0
    for cell in new_data:
        take_chunks = cell[1]*cell[2]
        imgs = []
        while take_chunks:
            target = ((pos%imwidth*width),(pos//imwidth*height),((pos+1)%imwidth*width),((pos+1)//imwidth*height+height))
            if not (pos+1)%imwidth:
                target = ((pos%imwidth*width),(pos//imwidth*height),(imwidth*width),((pos)//imwidth*height+height))
            icon = oldimg.crop(target) # left upper right lower
            icon.load()
            pos+=1
            take_chunks-=1
            imgs.append(icon) #This lists in lists of lists busness is out of hand
        cell[4] = imgs

def recurser(directory):
    #sorts everything in its directory, and calls itself on any directorys inside it
    for root, dirs, files in os.walk(cwd):#this doesnt work how I thought it did
        for thing in files: # file is a keyword. fml
            if len(thing) >=3 and thing[-3:] == "dmi":
                if sortAZ(root+"\\"+thing):
                    print(root+"\\"+thing)


import argparse
parser = argparse.ArgumentParser(description='Sort ALL the things!\
                                sorts dmi files alphabetically\
                                Easily modifiable to do other stuff.\
                                WARNING: You should probably resave the files\
                                using dream maker, although you dont have to.\
                                It makes the files smaller. Could cause problems later.')
parser.add_argument('-f', metavar='file', type=str,default=None,dest="file",
                    help=' a single file to alphabetize, or directory to recurse through.')
parser.add_argument('-r', dest='recurse', default=0,
                    action='store_true',help='recurse over all files in dir and below, or specified directory using -f.\
                     You can use ..\ to get up a directory. no ending \ afaik. Millage may vary.')


args = parser.parse_args()
if not args.recurse: #this is literally stupid. Im cancer.
    if args.file != None: #too late now though
        sortAZ(args.file)
elif args.recurse:
    import os
    if args.file:
        cwd = args.file
    else:
        cwd = os.getcwd()
    recurser(cwd)
print("Finished.")
