GLOBAL_VAR(legion_summoner)

/obj/structure/legion_summoner
	name = "strange device"
	desc = "You have no idea what this could possibly do."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "nexus"
	density = TRUE
	anchored = TRUE
	color = COLOR_VERY_LIGHT_GRAY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_range = 20
	light_power = 1
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	var/runes_activated = 0
	var/legion_spawned = FALSE

/obj/structure/legion_summoner/Initialize(mapload)
	. = ..()
	// Check if there is already a summoner
	if(GLOB.legion_summoner)
		qdel(src)
		return
	GLOB.legion_summoner = src

/obj/structure/legion_summoner/attack_hand(mob/user, list/modifiers)
	if(runes_activated < 4 || legion_spawned)
		return
	var/safety = tgui_alert(user, "You think this might be a bad idea...", "Activate the device?", list("Proceed", "Abort"))
	if(safety != "Proceed" || !in_range(src, user) || !src || user.incapacitated())
		return
	if(legion_spawned)
		return
	legion_spawned = TRUE
	user.visible_message(span_warning("[user] presses a button on [src]..."), span_boldannounce("You press a button on [src]..."))
	sleep(5 SECONDS)
	// Stuff originally from the necropolis legion gate which was removed from the map
	visible_message(span_userdanger("Something horrible emerges from the Device!"))
	var/sound/legion_sound = sound('sound/creatures/legion_spawn.ogg')
	var/turf/T = get_turf(src)
	for(var/mob/M in GLOB.player_list)
		// Check if on the same z level as legion
		if(is_valid_z_level(get_turf(M), T))
			to_chat(M, span_userdanger("Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has been released."))
			M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, sound_to_use = legion_sound)
			flash_color(M, flash_color = "#FF0000", flash_time = 50)
	var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
	notify_ghosts("Legion has been released in the [get_area(src)]!", source = src, alert_overlay = release_overlay, action = NOTIFY_JUMP, flashwindow = FALSE)
	new /mob/living/basic/boss/legion(T)


/obj/structure/legion_summoner/proc/add_crystal(obj/item/W)
	// Blend the colors of the crystal and main object together
	var/list/color_list = rgb2num(color)
	var/list/crystal_color_list = rgb2num(W.color)
	var/list/blended_color_list = list(0, 0, 0)
	for(var/i in 1 to 3)
		blended_color_list[i] = (color_list[i] + crystal_color_list[i]) / 2
	color = rgb(blended_color_list[1], blended_color_list[2], blended_color_list[3])
	light_color = color
	runes_activated++
	playsound(get_turf(src), 'sound/magic/swap.ogg', 50, 1)
	if(runes_activated == 4)
		visible_message(span_userdanger("The device seems to be fully powered."))
	else
		visible_message(span_userdanger("A part of the strange device lights up."))


/obj/effect/legion_rune
	name = "summoning rune"
	desc = "An odd collection of symbols, there seems to be a spot for a crystal shaped object."
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER

/obj/effect/legion_rune/shadow
	icon_state = "4"
	color = COLOR_DARK_PURPLE

/obj/effect/legion_rune/shadow/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/shadow_crystal))
		var/obj/structure/legion_summoner/S = GLOB.legion_summoner
		S.add_crystal(W)
		qdel(W)
		return
	. = ..()

/obj/effect/legion_rune/blood
	icon_state = "6"
	color = COLOR_DARK_RED

/obj/effect/legion_rune/blood/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/blood_crystal))
		var/obj/structure/legion_summoner/S = GLOB.legion_summoner
		S.add_crystal(W)
		qdel(W)
		return
	. = ..()

/obj/effect/legion_rune/ice
	icon_state = "3"
	color = COLOR_CYAN

/obj/effect/legion_rune/ice/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/ice_crystal))
		var/obj/structure/legion_summoner/S = GLOB.legion_summoner
		S.add_crystal(W)
		qdel(W)
		return
	. = ..()

/obj/effect/legion_rune/smoke
	icon_state = "7"
	color = COLOR_GRAY

/obj/effect/legion_rune/smoke/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/smoke_crystal))
		var/obj/structure/legion_summoner/S = GLOB.legion_summoner
		S.add_crystal(W)
		qdel(W)
		return
	. = ..()

/obj/item/shadow_crystal
	name = "shadow crystal"
	desc = "This should probably be used on something."
	icon = 'icons/obj/objects.dmi'
	icon_state = "crystal"
	color = COLOR_DARK_PURPLE

/obj/item/blood_crystal
	name = "blood crystal"
	desc = "This should probably be used on something."
	icon = 'icons/obj/objects.dmi'
	icon_state = "crystal"
	color = COLOR_DARK_RED

/obj/item/ice_crystal
	name = "ice crystal"
	desc = "This should probably be used on something."
	icon = 'icons/obj/objects.dmi'
	icon_state = "crystal"
	color = COLOR_CYAN

/obj/item/smoke_crystal
	name = "smoke crystal"
	desc = "This should probably be used on something."
	icon = 'icons/obj/objects.dmi'
	icon_state = "crystal"
	color = COLOR_GRAY