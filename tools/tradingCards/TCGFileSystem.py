import sys

def main():
    args = sys.argv
    leg = len(args)
    if leg >= 3 and (args[1].strip().lower() == "extract" or args[1].strip().lower() == "ex"): 
        from_file(args[2], args[3])
    elif leg >= 3 and (args[1].strip().lower() == "insert" or args[1].strip().lower() == "is"): 
        to_file(args[3], args[2])
    else:    
        print("Invalid Input")
master = {
    "template" : -1,
    "name" :  0,
    "desc" :  1,
    "icon" :  2,
    "icon_state" :  3,
    "id" :  4,
    "power" :  5,
    "resolve" :  6,
    "tags" :  7,
    "cardtype" : 8
    }

#Extract all the compressed data into uncompressed format. Place it into the specified file
def from_file(file, toWrite):
    f = open(file, 'r')
    open(toWrite, 'w').write(convert_from(f.read()))

#Compress all the uncompressed data into compressed format. Place it into the specified file
def to_file(file, toWrite):
    f = open(file, 'r')
    open(toWrite, 'w').write(convert_to(f.read()))

#Converts the contents of a uncompressed file into an compressed file
#We assume text is a string
def convert_to(text):
    inpt = list(text.split('\n'))
    output = ""
    toInsert = dict()

    #Extract the values
    for x in inpt:
        if len(x.strip()) and x[0] == ':':
            x = x.split('=')
            toInsert[x[0].strip()] = x[1].strip()
        else:
            if len(toInsert) != 0:
                output += convert_line_to(toInsert) + '\n'
                toInsert = dict()
    return output

#Converts a string into an entry
def convert_line_to(outdatedJoke):
    toReturn = ""
    for key, value in outdatedJoke.items():
        state = master.get(key.strip(':'))
        if state == -1:
            toReturn = value + toReturn
        else:
            toReturn += "|" + str(state) + "," + value
    return toReturn + "|"

#Converts the contents of a compressed file into an uncompressed file
#We assume text is a string
def convert_from(text):
    inpt = text.split('\n')
    output = ""

    #Extract the values
    for x in inpt:
        output += convert_line_from(x)
    return output.strip('\n') + '\n'


#Converts an entry into a string
def convert_line_from(outdatedJoke):
    toReturn = ""
    toOp = outdatedJoke.split('|')
    if toOp[0] != '':
        toReturn += ':' + list(master.keys())[0] + ' = ' + toOp[0] + '\n'
    for x in range(1, len(toOp)):
        temp = toOp[x].split(',')
        toReturn += ':' + list(master.keys())[int(temp[0]) + 1] + ' = ' + temp[1].replace('|', '') + '\n'
    return toReturn + '\n'

if __name__ == "__main__":
    main()














                
