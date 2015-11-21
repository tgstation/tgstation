/**************************************
Named Colours to HTML Constants Library
             by Jeremy "Spuzzum" Gibson
***************************************

This library converts colour names into HTML
numerical code.  It is used as follows:

var/code = colour2html("white")

This will search through its database and return
"#FFFFFF", which is the matching colour for the
string "white".

You can also use the American spelling, color2html,
if you'd like.  Not that you should. =P

(Note that you don't have to worry about spaces,
either... slate blue and slateblue, for example,
are both equivalent.)


If you want to add colours (doubtful you'd want to
or even need to!), it can be done by using the
HTMLAssociate() proc:

HTMLAssociate("mycolour","ffccdd")

...where the first argument is the name of the
colour and the second is the HTML colour code,
minus the pound (#) symbol.

**************************************/
//AMERICANISATION (AMERICANIZATION)
// Allows you to use your inferior American spellings! ;-)

#define color2html(X) colour2html(X)
#define html_colors html_colours


/*************************************/
//COLOUR2HTML PROC

proc/colour2html(colour)
	var/T
	for(T in html_colours)
		if(ckey(T) == ckey(colour)) break
	if(!T)
		world.log << "Warning!  Could not find matching colour entry for '[colour]'."
		return "#FFFFFF"

	return ("#" + uppertext(html_colours["[colour]"]) )


/*************************************/
//HTMLASSOCIATE PROC

proc/HTMLAssociate(colour, html)
	if(html_colours.Find(colour))
		world.log << "Changing [colour] from [html_colours[colour]] to [html]!"
	html_colours[colour] = html


/*************************************/
//HTML ASSOCIATIONS SAVING/LOADING

world
	New()
		..()
		LoadHTMLAssociations()

	Del()
		SaveHTMLAssociations()
		..()

var/html_colours[0]

proc/LoadHTMLAssociations()
	var/savefile/F = new ("s_html.sav")
	F["html_colours"] >> html_colours
	if(!html_colours) html_colours = list()

	if(!html_colours.len)
		HTMLAssociate("aliceblue",        "f0f8ff")
		HTMLAssociate("antiquewhite",     "faebd7")
		HTMLAssociate("aqua",             "00ffff")
		HTMLAssociate("aquamarine",       "7fffd4")
		HTMLAssociate("azure",            "f0ffff")
		HTMLAssociate("beige",            "f5f5dc")
		HTMLAssociate("bisque",           "ffe4c4")
		HTMLAssociate("black",            "000000")
		HTMLAssociate("blanchedalmond",   "ffebcd")
		HTMLAssociate("blue",             "0000ff")
		HTMLAssociate("blueviolet",       "8a2be2")
		HTMLAssociate("brown",            "a52a2a")
		HTMLAssociate("burlywood",        "deb887")
		HTMLAssociate("cadetblue",        "5f9ea0")
		HTMLAssociate("chartreuse",       "7fff00")
		HTMLAssociate("chocolate",        "d2691e")
		HTMLAssociate("coral",            "ff7f50")
		HTMLAssociate("cornflowerblue",   "6495ed")
		HTMLAssociate("cornsilk",         "fff8dc")
		HTMLAssociate("crimson",          "dc143c")
		HTMLAssociate("cyan",             "00ffff")
		HTMLAssociate("darkblue",         "00008b")
		HTMLAssociate("darkcyan",         "008b8b")
		HTMLAssociate("darkgoldenrod",    "b8b60b")
		HTMLAssociate("darkgrey",         "a9a9a9")
		HTMLAssociate("darkgray",         "a9a9a9")
		HTMLAssociate("darkgreen",        "006400")
		HTMLAssociate("darkkhaki",        "bdb76b")
		HTMLAssociate("darkmagenta",      "8b008b")
		HTMLAssociate("darkolivegreen",   "556b2f")
		HTMLAssociate("darkorange",       "ff8c00")
		HTMLAssociate("darkorchid",       "9932cc")
		HTMLAssociate("darkred",          "8b0000")
		HTMLAssociate("darksalmon",       "e9967a")
		HTMLAssociate("darkseagreen",     "8fbc8f")
		HTMLAssociate("darkslateblue",    "483d8b")
		HTMLAssociate("darkslategrey",    "2f4f4f")
		HTMLAssociate("darkslategray",    "2f4f4f")
		HTMLAssociate("darkturquoise",    "00ced1")
		HTMLAssociate("darkviolet",       "9400d3")
		HTMLAssociate("deeppink",         "ff1493")
		HTMLAssociate("deepskyblue",      "00bfff")
		HTMLAssociate("dimgrey",          "696969")
		HTMLAssociate("dimgray",          "696969")
		HTMLAssociate("dodgerblue",       "1e90ff")
		HTMLAssociate("firebrick",        "b22222")
		HTMLAssociate("floralwhite",      "fffaf0")
		HTMLAssociate("forestgreen",      "228b22")
		HTMLAssociate("fuchsia",          "ff00ff")
		HTMLAssociate("gainsboro",        "dcdcdc")
		HTMLAssociate("ghostwhite",       "f8f8ff")
		HTMLAssociate("gold",             "ffd700")
		HTMLAssociate("goldenrod",        "daa520")
		HTMLAssociate("grey",             "808080")
		HTMLAssociate("gray",             "808080")
		HTMLAssociate("green",            "008000")
		HTMLAssociate("greenyellow",      "adff2f")
		HTMLAssociate("honeydew",         "f0fff0")
		HTMLAssociate("hotpink",          "ff69b4")
		HTMLAssociate("indianred",        "cd5c5c")
		HTMLAssociate("indigo",           "4b0082")
		HTMLAssociate("ivory",            "fffff0")
		HTMLAssociate("khaki",            "f0e68c")
		HTMLAssociate("lavender",         "e6e6fa")
		HTMLAssociate("lavenderblush",    "fff0f5")
		HTMLAssociate("lawngreen",        "7cfc00")
		HTMLAssociate("lemonchiffon",     "fffacd")
		HTMLAssociate("lightblue",        "add8e6")
		HTMLAssociate("lightcoral",       "f08080")
		HTMLAssociate("lightcyan",        "e0ffff")
		HTMLAssociate("lightgoldenrod",   "fafad2")
		HTMLAssociate("lightgreen",       "90ee90")
		HTMLAssociate("lightgrey",        "d3d3d3")
		HTMLAssociate("lightgray",        "d3d3d3")
		HTMLAssociate("lightpink",        "ffb6c1")
		HTMLAssociate("lightsalmon",      "ffa07a")
		HTMLAssociate("lightseagreen",    "20b2aa")
		HTMLAssociate("lightskyblue",     "87cefa")
		HTMLAssociate("lightslategrey",   "778899")
		HTMLAssociate("lightslategray",   "778899")
		HTMLAssociate("lightsteelblue",   "b0c4de")
		HTMLAssociate("lightyellow",      "ffffe0")
		HTMLAssociate("lime",             "00ff00")
		HTMLAssociate("limegreen",        "32cd32")
		HTMLAssociate("linen",            "faf0e6")
		HTMLAssociate("magenta",          "ff00ff")
		HTMLAssociate("maroon",           "800000")
		HTMLAssociate("mediumaquamarine", "66cdaa")
		HTMLAssociate("mediumblue",       "0000cd")
		HTMLAssociate("mediumorchid",     "ba55d3")
		HTMLAssociate("mediumpurple",     "9370db")
		HTMLAssociate("mediumseagreen",   "3cb371")
		HTMLAssociate("mediumslateblue",  "7b68ee")
		HTMLAssociate("mediumspringgreen","00fa9a")
		HTMLAssociate("mediumturquoise",  "48d1cc")
		HTMLAssociate("mediumvioletred",  "c71585")
		HTMLAssociate("midnightblue",     "191970")
		HTMLAssociate("mintcream",        "f5fffa")
		HTMLAssociate("mistyrose",        "ffe4e1")
		HTMLAssociate("moccasin",         "ffe4b5")
		HTMLAssociate("navajowhite",      "ffdead")
		HTMLAssociate("navy",             "000080")
		HTMLAssociate("oldlace",          "fdf5e6")
		HTMLAssociate("olive",            "808000")
		HTMLAssociate("olivedrab",        "6b8e23")
		HTMLAssociate("orange",           "ffa500")
		HTMLAssociate("orangered",        "ff4500")
		HTMLAssociate("orchid",           "da70d6")
		HTMLAssociate("palegoldenrod",    "eee8aa")
		HTMLAssociate("palegreen",        "98fb98")
		HTMLAssociate("paleturquoise",    "afeeee")
		HTMLAssociate("palevioletred",    "db7093")
		HTMLAssociate("papayawhip",       "ffefd5")
		HTMLAssociate("peachpuff",        "ffdab9")
		HTMLAssociate("peru",             "cd853f")
		HTMLAssociate("pink",             "ffc0cd")
		HTMLAssociate("plum",             "dda0dd")
		HTMLAssociate("powderblue",       "b0e0e6")
		HTMLAssociate("purple",           "800080")
		HTMLAssociate("red",              "ff0000")
		HTMLAssociate("rosybrown",        "bc8f8f")
		HTMLAssociate("royalblue",        "4169e1")
		HTMLAssociate("saddlebrown",      "8b4513")
		HTMLAssociate("salmon",           "fa8072")
		HTMLAssociate("sandybrown",       "f4a460")
		HTMLAssociate("seagreen",         "2e8b57")
		HTMLAssociate("seashell",         "fff5ee")
		HTMLAssociate("sienna",           "a0522d")
		HTMLAssociate("silver",           "c0c0c0")
		HTMLAssociate("skyblue",          "87ceed")
		HTMLAssociate("slateblue",        "6a5acd")
		HTMLAssociate("slategrey",        "708090")
		HTMLAssociate("slategray",        "708090")
		HTMLAssociate("snow",             "fffafa")
		HTMLAssociate("springgreen",      "00ff7f")
		HTMLAssociate("steelblue",        "4682b4")
		HTMLAssociate("tan",              "d2b48c")
		HTMLAssociate("teal",             "008080")
		HTMLAssociate("thistle",          "d8bfd8")
		HTMLAssociate("tomato",           "ff6347")
		HTMLAssociate("turquoise",        "40e0d0")
		HTMLAssociate("violet",           "ee82ee")
		HTMLAssociate("wheat",            "f5deb3")
		HTMLAssociate("white",            "ffffff")
		HTMLAssociate("whitesmoke",       "f5f5f5")
		HTMLAssociate("yellow",           "ffff00")
		HTMLAssociate("yellowgreen",      "a9cd32")


proc/SaveHTMLAssociations()
	var/savefile/F = new ("s_html.sav")
	F["html_colours"] << html_colours