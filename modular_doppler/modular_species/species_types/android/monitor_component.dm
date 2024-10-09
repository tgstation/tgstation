GLOBAL_LIST_INIT(monitor_head_displays, list(
	"Disabled" = "none",
	"Blank" = "blank",
	"Blank (White)" = "blankwhite",
	"Blue" = "blue",
	"Blue Screen of Death" = "bsod",
	"Breakout" = "breakout",
	"Cigarette" = "smoking",
	"Console" = "console",
	"Cubic Wave" = "squarewave",
	"Cyclops" = "eye",
	"Database" = "database",
	"ECG Wave" = "ecgwave",
	"Eight" = "eight",
	"Eyes" = "eyes",
	"Goggles" = "goggles",
	"Gol Glider" = "golglider",
	"Green" = "green",
	"Heart" = "heart",
	"Heartrate Monitor" = "heartrate",
	"Luminous Eyes" = "lumi_eyes",
	"Mono Eye" = "mono_eye",
	"Music" = "music",
	"Nature" = "nature",
	"Pink" = "pink",
	"Purple" = "purple",
	"Rainbow" = "rainbow",
	"Red Text" = "redtext",
	"Red" = "red",
	"RGB" = "rgb",
	"Scroll" = "scroll",
	"Shower" = "shower",
	"Sine Wave" = "sinewave",
	"Smiley" = "yellow",
	"Stars" = "stars",
	"Sunburst" = "sunburst",
	"Test Screen" = "test",
	"Text Drop" = "textdrop",
	"TV Static" = "static",
	"TV Static (Color)" = "static3",
	"TV Static (Slow)" = "static2",
	"Waiting..." = "waiting",
	))

/datum/component/monitor_head
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/action/innate/monitor_head/display_action

/datum/component/monitor_head/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	display_action = new
	display_action.Grant(parent)

/datum/component/monitor_head/Destroy(force)
	if(display_action)
		display_action.Remove(parent)
	return ..()

/datum/action/innate/monitor_head
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"
	background_icon_state = "bg_default"
	var/datum/bodypart_overlay/simple/monitor_head/display_overlay

/datum/action/innate/monitor_head/Activate()
	var/new_display = tgui_input_list(usr, "Choose your character's screen:", "Monitor Display", GLOB.monitor_head_displays)
	if(!new_display)
		return

	var/mob/living/carbon/human/wearer = owner
	var/obj/item/bodypart/head/monitor_head = wearer.get_bodypart(BODY_ZONE_HEAD)

	if(!display_overlay)
		display_overlay = new /datum/bodypart_overlay/simple/monitor_head

	display_overlay.icon_state = "[GLOB.monitor_head_displays[new_display]]"
	monitor_head.add_bodypart_overlay(display_overlay)
	wearer.update_body_parts()

/datum/action/innate/monitor_head/Remove(mob/remove_from)
	if(remove_from && display_overlay)
		var/mob/living/carbon/human/wearer = remove_from
		var/obj/item/bodypart/head/monitor_head = wearer.get_bodypart(BODY_ZONE_HEAD)
		monitor_head.remove_bodypart_overlay(display_overlay)
		wearer.update_body_parts()
	return ..()

/datum/bodypart_overlay/simple/monitor_head
	icon = 'modular_doppler/modular_customization/accessories/icons/cybernetic/synth_screens.dmi'
	icon_state = "none"
	layers = EXTERNAL_ADJACENT
