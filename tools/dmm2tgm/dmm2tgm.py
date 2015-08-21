
import sys

# .dmm format converter, by RemieRichards
# Version 2.0
# Converts the internal structure of a .dmm file to a syntax
# that git can better handle conflicts-wise, it's also fairly human readable!
# Processes Boxstation (tgstation.2.1.3) almost instantly

#TWEAKABLE VARIABLES                  
map_file = "tgstation.2.1.3.dmm" #Map file, .dmm or .txt
output_file = ""  #Output file, .dmm or .txt, leave blank to overwrite map_file


#CHECK FOR PREVIOUS CONVERSION
with open(map_file, "r") as conversion_candidate:
        header = conversion_candidate.readline()
        if header.find("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE") != -1:
                sys.exit("This map has already been converted, cancelling...")


#ACTUAL CONVERSION
with open(map_file, "r+") as unconverted_map:
        characters = unconverted_map.read()
        converted_map = "" 
        in_object_block = False #()
        in_variable_block = False #{}
        in_quote_block = False #''
        in_double_quote_block = False #""
        for char in characters:
                if char == "(" :
                        if not in_object_block:
                                if not in_quote_block:
                                        if not in_double_quote_block:
                                                if not in_variable_block:
                                                        in_object_block = True
                                                        char = char + "\n"
                if char == ")":
                        if in_object_block:
                                if not in_quote_block:
                                        if not in_double_quote_block:
                                                if not in_variable_block:
                                                        in_object_block = False
                if char == "{":
                        in_variable_block = True
                        if in_object_block: 
                                char = char + "\n\t"
                if char == "}":
                        in_variable_block = False
                        if in_object_block:
                                char = "\n\t"+char
                if char == ",":
                        if not in_variable_block:
                                char = char + "\n"
                if char == "'":
                        if in_quote_block:
                                in_quote_block = False
                        else:
                                in_quote_block = True
                if char == "\"":
                        if in_double_quote_block:
                                in_double_quote_block = False
                        else:
                                in_double_quote_block = True
                if char == ";":
                        if not in_quote_block:
                                if not in_double_quote_block:
                                        char = char + "\n\t"

                converted_map = converted_map + char

if output_file == "":
        output_file = map_file
with open(output_file, "r+") as final_converted_map:
        final_converted_map.write("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE \n")
        final_converted_map.write(converted_map)
                        

        
