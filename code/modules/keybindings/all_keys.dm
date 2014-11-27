// This file contains a listing of every key and some other helpful key-related definitions

#define NUMPAD "west","east","north","south","northeast","southeast","northwest","southwest","center","numpad0","numpad1","numpad2","numpad3","numpad4","numpad5","numpad6","numpad7","numpad8","numpad9","divide","multiply","subtract","add","decimal"
#define EXTENDED "space","shift","ctrl","alt","escape","return","tab","back","delete","insert"
#define PUNCTUATION "`","-","=","\[","]",";","'",",",".","/","\\"
#define FUNCTION "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"
#define LETTERS "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"
#define NUMBERS "0","1","2","3","4","5","6","7","8","9"

// Technically speaking these other defines aren't truly needed, but it makes the list organized
// The fact this works is borderline a bug
#define ALL_KEYS NUMPAD,EXTENDED,FUNCTION,LETTERS,NUMBERS,PUNCTUATION

var/list/all_keys = list(ALL_KEYS)

// Keys used for movement
var/list/movement_keys = list(\
	"w" = NORTH, "a" = WEST, "s" = SOUTH, "d" = EAST, \
	"north" = NORTH, "west" = WEST, "south" = SOUTH, "east" = EAST, \
	"numpad8" = NORTH, "numpad4" = WEST, "numpad2" = SOUTH, "numpad6" = EAST)

// var/list/numpad_mappings = list("numpad0" = "0", "numpad1" = "1", "numpad2" = "2", "numpad3" = "3", "numpad4" = "4", "numpad5" = "5", "numpad6" = "6", "numpad7" = "7", "numpad8" = "8", "numpad9" = "9", "divide" = "/", "multiply" = "*", "subtract" = "-", "add" = "+", "decimal" = ".")
// It may be useful to turn numpad input to regular input. If so uncomment the above line and just do
//	if(numpad_mappings[key])
//		key = numpad_mappings[key]