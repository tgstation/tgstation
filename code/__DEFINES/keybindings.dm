GLOBAL_LIST_INIT(keybinding_validkeys, list(
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"Insert",
	"Delete",
	"Northwest",
	"Southwest",
	"Northeast",
	"Southeast",
	"F1",
	"F2",
	"F3",
	"F4",
	"F5",
	"F6",
	"F7",
	"F8",
	"F9",
	"F10",
	"F11",
	"F12",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"Numpad1",
	"Numpad2",
	"Numpad3",
	"Numpad4",
	"Numpad5",
	"Numpad6",
	"Numpad7",
	"Numpad8",
	"Numpad9",
	",",
	".",
	"&",
	"é",
	"\"",
	"'",
	"(",
	"§",
	"è",
	"!",
	"ç",
	"à",
	")",
	"-",
	"Unbound",
))


// Movement
#define ACTION_MOVENORTH "Move North"
#define ACTION_MOVEWEST "Move West"
#define ACTION_MOVESOUTH "Move South"
#define ACTION_MOVEEAST "Move East"

// Client
#define ACTION_OOC "OOC"
#define ACTION_AHELP "Adminhelp"
#define ACTION_SCREENSHOT "Screenshot"
#define ACTION_MINHUD "Min Hud"

// Mob
#define ACTION_SAY "Say"
#define ACTION_ME "Me"

#define ACTION_STOPPULLING "Stop Pulling"
#define ACTION_INTENTRIGHT "Intent Right"
#define ACTION_INTENTLEFT "Intent Left"
#define ACTION_SWAPHAND "Swap Hand"
#define ACTION_USESELF "Use Self"
#define ACTION_DROP "Drop"
#define ACTION_EQUIP "Equip"

#define ACTION_TARGETHEAD "Target Head"
#define ACTION_TARGETRARM "Target RArm"
#define ACTION_TARGETCHEST "Target Chest"
#define ACTION_TARGETLARM "Target LArm"
#define ACTION_TARGETRLEG "Target RLeg"
#define ACTION_TARGETGROIN "Target Groin"
#define ACTION_TARGETLLEG "Target LLeg"

#define ACTION_RESIST "Resist"
#define ACTION_TOGGLETHROW "Toggle Throw"
#define ACTION_INTENTHELP "Intent Help"
#define ACTION_INTENTDISARM "Intent Disarm"
#define ACTION_INTENTGRAB "Intent Grab"
#define ACTION_INTENTHARM "Intent Harm"

// Admin
#define ACTION_ASAY "Adminchat"
#define ACTION_AGHOST "Admin Ghost"
#define ACTION_PLAYERPANEL "Player Panel"
#define ACTION_BUILDMODE "Build Mode"
#define ACTION_STEALTHMIN "Stealthmin"
#define ACTION_DSAY "Deadchat"


GLOBAL_LIST_INIT(keybinding_default, list(
	ACTION_MOVENORTH = "W",
	ACTION_MOVEWEST = "A",
	ACTION_MOVESOUTH = "S",
	ACTION_MOVEEAST = "D",
	ACTION_OOC = "O",
	ACTION_AHELP = "F1",
	ACTION_SCREENSHOT = "F2",
	ACTION_MINHUD = "F12",


	ACTION_SAY = "T",
	ACTION_ME = "M",
	ACTION_STOPPULLING = "Delete",
	ACTION_INTENTRIGHT = "G",
	ACTION_INTENTLEFT = "H",
	ACTION_SWAPHAND = "X",
	ACTION_USESELF = "Z",
	ACTION_DROP = "Q",
	ACTION_EQUIP = "E",

	ACTION_TARGETHEAD = "Numpad8",
	ACTION_TARGETRARM = "Numpad4",
	ACTION_TARGETCHEST = "Numpad5",
	ACTION_TARGETLARM = "Numpad6",
	ACTION_TARGETRLEG = "Numpad1",
	ACTION_TARGETGROIN = "Numpad2",
	ACTION_TARGETLLEG = "Numpad3",
	ACTION_RESIST = "B",
	ACTION_TOGGLETHROW = "R",
	ACTION_INTENTHELP = "1",
	ACTION_INTENTDISARM = "2",
	ACTION_INTENTGRAB = "3",
	ACTION_INTENTHARM = "4",


	ACTION_ASAY = "F3",
	ACTION_AGHOST = "F5",
	ACTION_PLAYERPANEL = "F6",
	ACTION_BUILDMODE = "F7",
	ACTION_STEALTHMIN = "F8",
	ACTION_DSAY = "F10",
))


#define BUTTON_KEY_MOVEMENT(name, action, dir) \
	button = bindings.get_action_key(action); \
	button_bound = TRUE; \
	if(!button || button == "" || button == "Unbound") \
		button_bound = FALSE; \
	dat += "<b>[name]:</b> <a href='?_src_=prefs;keybinding=[action];dir=[dir];task=input' [button_bound ? "" : "style='color:red'"]>[button_bound ? button : "Unbound"]</a><br>"; \

#define BUTTON_KEY(name, action) \
	BUTTON_KEY_MOVEMENT(name, action, 0);
