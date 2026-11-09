// Datums describing an icon that is overlaid on a pAI card, to make its screen show something. The
// player can select between any of these at any time. These are usually faces, but can
// realistically be anything (similar to an AI's display).

/datum/pai_screen_image
	// The name to show in the radial menu.
	var/name
	// The icon and icon state that is applied to the pAI device when this screen image is selected.
	var/icon/icon = 'icons/obj/aicards.dmi'
	var/icon_state
	// The FontAwesome icon to use next to the "Display" button in the pAI's tgui interface window.
	var/interface_icon

/datum/pai_screen_image/angry
	name = "Angry"
	icon_state = "pai-angry"
	interface_icon = "angry"

/datum/pai_screen_image/cat
	name = "Cat"
	icon_state = "pai-cat"
	interface_icon = "cat"

/datum/pai_screen_image/extremely_happy
	name = "Extremely Happy"
	icon_state = "pai-extremely-happy"
	interface_icon = "grin-beam"

/datum/pai_screen_image/face
	name = "Face"
	icon_state = "pai-face"
	interface_icon = "grin-alt"

/datum/pai_screen_image/happy
	name = "Happy"
	icon_state = "pai-happy"
	interface_icon = "smile"

/datum/pai_screen_image/laugh
	name = "Laugh"
	icon_state = "pai-laugh"
	interface_icon = "grin-tears"

/datum/pai_screen_image/neutral
	name = "Neutral"
	icon_state = "pai-null"
	interface_icon = "meh"

/datum/pai_screen_image/off
	name = "None"
	icon_state = "pai-off"
	interface_icon = "meh-blank"

/datum/pai_screen_image/sad
	name = "Sad"
	icon_state = "pai-sad"
	interface_icon = "sad-cry"

/datum/pai_screen_image/sunglasses
	name = "Sunglasses"
	icon_state = "pai-sunglasses"
	interface_icon = "sun"

/datum/pai_screen_image/what
	name = "What"
	icon_state = "pai-what"
	interface_icon = "frown-open"
