
import sys

# .dmm format converter, by RemieRichards
# Version 2.0
# Converts the internal structure of a .dmm file to a syntax
# that git can better handle conflicts-wise, it's also fairly human readable!
# Processes Boxstation (tgstation.2.1.3) almost instantly


def convert_map(map_file):
        #CHECK FOR PREVIOUS CONVERSION
        with open(map_file, "r") as conversion_candidate:
                header = conversion_candidate.readline()
                if header.find("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE") != -1:
                        sys.exit()
                        return


        #ACTUAL CONVERSION
        with open(map_file, "r+") as unconverted_map:
                characters = unconverted_map.read()
                converted_map = "" 
                in_object_block = False #()
                in_variable_block = False #{}
                in_quote_block = False #''
                in_double_quote_block = False #""
                for char in characters:
                        if not in_quote_block: #Checking for things like "Flashbangs (Warning!)" Because we only care about ({'";, that are used as byond syntax, not strings
                                if not in_double_quote_block:
                                        if not in_variable_block:
                                                if char == "(":
                                                        in_object_block = True
                                                        char = char + "\n"
                                                if char == ")":
                                                        in_object_block = False
                                                if char == ",":
                                                        char = char + "\n"
                                                
                                        if char == "{":
                                                in_variable_block = True
                                                if in_object_block:
                                                        char = char + "\n\t"
                                        if char == "}":
                                                in_variable_block = False
                                                if in_object_block:
                                                        char = "\n\t" + char

                                        if char == ";":
                                                char = char + "\n\t"

                                if char == "\"":
                                        if in_double_quote_block:
                                                in_double_quote_block = False
                                        else:
                                                in_double_quote_block = True  

                        if char == "'":
                                if not in_double_quote_block:
                                        if in_quote_block:
                                                in_quote_block = False
                                        else:
                                                in_quote_block = True

                        converted_map = converted_map + char

        #OVERWRITE MAP FILE WITH CONVERTED MAP STRING
        with open(map_file, "r+") as final_converted_map:
                final_converted_map.write("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE \n")
                final_converted_map.write(converted_map)

        sys.exit()


if sys.argv[1]: #Run like dmm2tgm.py "folder/folder/a_map.dmm"
        convert_map(sys.argv[1])
        
