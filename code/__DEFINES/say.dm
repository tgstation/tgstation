/*
	Defines for use in saycode and text formatting.
	Currently contains speech spans and message modes
*/

//Message modes. Each one defines a radio channel, more or less.
#define MODE_HEADSET "headset"
#define MODE_ROBOT "robot"
#define MODE_R_HAND "right hand"
#define MODE_L_HAND "left hand"
#define MODE_INTERCOM "intercom"
#define MODE_BINARY "binary"
#define MODE_WHISPER "whisper"
#define MODE_DEPARTMENT "department"
#define MODE_ALIEN "alientalk"
#define MODE_HOLOPAD "holopad"
#define MODE_CHANGELING "changeling"
#define MODE_VOCALCORDS "cords"

//Spans. Robot speech, italics, etc. Applied in compose_message().
#define SPAN_ROBOT "robot"
#define SPAN_YELL "yell"
#define SPAN_ITALICS "italics"
#define SPAN_SANS "sans"
#define SPAN_PAPYRUS "papyrus"
#define SPAN_REALLYBIG "reallybig"
#define SPAN_COMMAND "command_headset"
#define SPAN_CLOWN "clown"

//bitflag #defines for return value of the radio() proc.
#define ITALICS 1
#define REDUCE_RANGE 2
#define NOPASS 4

// A link given to ghost alice to follow bob
#define FOLLOW_LINK(alice, bob) "<a href=?src=\ref[alice];follow=\ref[bob]>(F)</a>"
