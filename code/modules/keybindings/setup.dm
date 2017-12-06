/client
	var/list/keys_held = list() // A list of any keys held currently
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done

// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	return

// Keys used for movement
GLOBAL_LIST_INIT(movement_keys, list(
	"W" = NORTH, "A" = WEST, "S" = SOUTH, "D" = EAST,														// WASD
	"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST,											// Arrow keys & Numpad
	))

/*
A horrific battle against shitcode was fought here to find out some use details of winset
Aparently you need to wrap the entire proc + args in quotes if you intend on using args
But you don't need the quote wrappings to just call on a proc with no args
ex. winset(src, "default-Any", "command=keyDown \[\[*\]\]") 		fail: command = keyDown
ex. winset(src, "default-Any", "command=keyDown \"\[\[*\]\]\"") 	fail: same
ex. winset(src, "default-T", "command=say") 						works fine
ex. winset(src, "default-Any", "command=\"keyDown \[\[*\]\]\"")		works fine
Thanks for the useful errors lummox ~ninjanomnom
*/
GLOBAL_LIST_INIT(default_macros, list(
	"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=#F0F0F0:input.focus=true input.background-color=#D3B5B5\\\"\"",
	"O" = "ooc",
	"T" = "say",
	"M" = "me",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"", // This makes it so backspace can remove default inputs
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	))

/client/proc/set_macros()
	set waitfor = FALSE

	winset(src, null, "reset=true")
	winset(src, null, "mainwindow.macro=default")
	var/list/default = params2list(winget(src, "default.*", "command"))
	for(var/i in 1 to length(default))
		var/id = default[i]
		winset(src, id, "parent=none")

	var/list/default_macros = GLOB.default_macros
	for(var/i in 1 to length(default_macros))
		var/input = default_macros[i]
		var/output = default_macros[input]
		winset(src, "default-[input]", "parent=default;name=[input];command=[output]")

	if(prefs.hotkeys)
		winset(src, null, "mapwindow.map.focus=true input.background-color=#e0e0e0")
	else
		winset(src, null, "input.focus=true input.background-color=#d3b5b5")