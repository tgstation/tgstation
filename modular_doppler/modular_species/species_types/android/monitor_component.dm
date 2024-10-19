#define MONITOR_HEAD (1<<0)
#define MONITOR_HEAD_LIZARD (1<<1)

GLOBAL_LIST_INIT(monitor_displays, list(
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

GLOBAL_LIST_INIT(monitor_lizard_displays, list(
	"Disabled" = "none",
	"Eyes" = "liz_eyes",
	"Question" = "liz_question",
	"Exclaim" = "liz_exclaim",
	))

// the overlay
/datum/bodypart_overlay/simple/monitor_head
	icon = 'modular_doppler/modular_customization/accessories/icons/cybernetic/synth_screens.dmi'
	icon_state = "none"
	layers = EXTERNAL_ADJACENT
	blocks_emissive = EMISSIVE_BLOCK_NONE

// the component
/datum/component/monitor_head
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/action/innate/monitor_head/display_action

/datum/component/monitor_head/lizard

/datum/component/monitor_head/Initialize(...)
	. = ..()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(src, /datum/component/monitor_head/lizard))
		display_action = new /datum/action/innate/monitor_head/lizard
	else
		display_action = new

	display_action.Grant(parent)

/datum/component/monitor_head/Destroy(force)
	if(display_action)
		display_action.Remove(parent)
	return ..()

// the action
/datum/action/innate/monitor_head
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"
	background_icon_state = "bg_default"
	/// the var that should be changed when a different screen list should be used
	var/head_type = MONITOR_HEAD
	/// the overlay we use
	var/datum/bodypart_overlay/simple/monitor_head/display_overlay

/datum/action/innate/monitor_head/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_MOB_EMOTE, PROC_REF(check_emote))

/datum/action/innate/monitor_head/Remove(mob/remove_from)
	. = ..()
	UnregisterSignal(remove_from, COMSIG_MOB_EMOTE)

/datum/action/innate/monitor_head/Activate()
	var/mob/living/carbon/human/wearer = owner
	var/new_display = tgui_input_list(usr, "Choose your character's screen:", "Monitor Display", head_type & MONITOR_HEAD ? GLOB.monitor_displays : GLOB.monitor_lizard_displays)
	if(!new_display)
		return

	if(!display_overlay)
		create_screen(wearer)

	change_screen(wearer, "[head_type & MONITOR_HEAD ? GLOB.monitor_displays[new_display] : GLOB.monitor_lizard_displays[new_display]]")

/datum/action/innate/monitor_head/proc/check_emote(mob/living/carbon/wearer, datum/emote/emote)
	SIGNAL_HANDLER
	/// a list of the 'key' variable of emotes that have a screen update effect
	var/static/list/screen_emotes = list(
		"tunesing",
		"exclaim",
		"question",
	)
	// early return
	if(!(emote.key in screen_emotes))
		return

	if(!display_overlay)
		create_screen(wearer)

	var/old_screen = display_overlay.icon_state

	if(head_type & MONITOR_HEAD)
		switch(emote.key)
			if("tunesing")
				change_screen(wearer, "music")

	if(head_type & MONITOR_HEAD_LIZARD)
		switch(emote.key)
			if("exclaim")
				change_screen(wearer, "liz_exclaim")
			if("question")
				change_screen(wearer, "liz_question")
	// this timer is 5 seconds just like the emote overlays, so they are synchronized
	addtimer(CALLBACK(src, PROC_REF(change_screen), wearer, old_screen), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/action/innate/monitor_head/update_status_on_signal(mob/living/carbon/wearer, new_stat, old_stat)
	. = ..()

	if(!display_overlay)
		create_screen(wearer)

	if(head_type & MONITOR_HEAD)
		switch(new_stat)
			if(SOFT_CRIT)
				change_screen(wearer, "bsod")
			if(HARD_CRIT)
				change_screen(wearer, "static3")
			if(UNCONSCIOUS)
				change_screen(wearer, "none")
			if(DEAD)
				change_screen(wearer, "none")

	if(head_type & MONITOR_HEAD_LIZARD)
		switch(new_stat)
			if(UNCONSCIOUS)
				change_screen(wearer, "none")
			if(DEAD)
				change_screen(wearer, "none")

/datum/action/innate/monitor_head/proc/create_screen(mob/living/carbon/wearer)
	var/obj/item/bodypart/head/monitor_head = wearer.get_bodypart(BODY_ZONE_HEAD)
	display_overlay = new /datum/bodypart_overlay/simple/monitor_head

	if(head_type & MONITOR_HEAD_LIZARD)
		var/mob/living/carbon/human/human_wearer = wearer
		display_overlay.draw_color = human_wearer.eye_color_left

	monitor_head.add_bodypart_overlay(display_overlay)

/datum/action/innate/monitor_head/proc/change_screen(mob/living/carbon/wearer, screen)
	var/obj/item/bodypart/head/robot/android/monitor_head = wearer.get_bodypart(BODY_ZONE_HEAD)

	display_overlay.icon_state = screen
	monitor_head.monitor_state = screen

	playsound(wearer, 'modular_doppler/modular_sounds/sound/mobs/humanoids/android/monitor_switch.ogg', 100, TRUE)
	wearer.update_body_parts()

/datum/action/innate/monitor_head/Remove(mob/remove_from)
	if(remove_from && display_overlay)
		var/mob/living/carbon/human/wearer = remove_from
		var/obj/item/bodypart/head/monitor_head = wearer.get_bodypart(BODY_ZONE_HEAD)
		monitor_head.remove_bodypart_overlay(display_overlay)
		wearer.update_body_parts()
	return ..()

/datum/action/innate/monitor_head/lizard
	head_type = MONITOR_HEAD_LIZARD


#undef MONITOR_HEAD
#undef MONITOR_HEAD_LIZARD
