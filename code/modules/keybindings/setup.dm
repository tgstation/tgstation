/client
	var/list/keys_held = list() // A list of any keys held currently
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done

// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/keyDown(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/keyUp(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	return

// Keys used for movement
var/list/movement_keys = list(
	"w" = NORTH, "a" = WEST, "s" = SOUTH, "d" = EAST,
	"north" = NORTH, "west" = WEST, "south" = SOUTH, "east" = EAST,
	"numpad8" = NORTH, "numpad4" = WEST, "numpad2" = SOUTH, "numpad6" = EAST)

// This was in the library I based this off of and I'm leaving it here in case someone cares
// var/list/numpad_mappings = list("numpad0" = "0", "numpad1" = "1", "numpad2" = "2", "numpad3" = "3", "numpad4" = "4", "numpad5" = "5", "numpad6" = "6", "numpad7" = "7", "numpad8" = "8", "numpad9" = "9", "divide" = "/", "multiply" = "*", "subtract" = "-", "add" = "+", "decimal" = ".")
// It may be useful to turn numpad input to regular input. If so uncomment the above line and just do
//	if(numpad_mappings[key])
//		key = numpad_mappings[key]