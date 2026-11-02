/// The small fixtures of a Ratwood town (structures/fluff.dm, roguetown/bell.dm, bell_common.dm, rogueitems/bells.dm,
/// roguetown/telescope.dm): clocks that tick and tell the hour and the day of the week, bells to ring, telescopes and globes
/// to look into, signs to carve words on.

#define ROCKHILL_SIGN_MAX_LENGTH 200
#define ROCKHILL_BELL_COMMON_RANGE 8
#define ROCKHILL_BELL_RANGE 5
#define ROCKHILL_CHURCH_BELL_TOLL_VOLUME 35

/// What a clock face tells (Ratwood clock examine()): the hour and the day of the week.
/proc/rockhill_clock_reading()
	var/day = "... actually, WHAT dae is it?"
	if(GLOB.rockhill_days_passed)
		day = "[capitalize(LOWER_TEXT(rockhill_day_name()))]."
	return "Oh no, it's [rockhill_timestamp("hh:mm")] on a [day]"

/// Ratwood clockloop: a quiet tick that walls stop.
/datum/looping_sound/rockhill_clock
	mid_sounds = 'modular_redtard/rockhill/sound/misc/clockloop.ogg'
	mid_length = 2 SECONDS
	volume = 10
	extra_range = -3
	ignore_walls = FALSE

/// A standing clock: ticks, tells the time, and like a statue it is passed only from the sides and the back.
/obj/structure/fluff/clock
	anchored = FALSE
	drag_slowdown = 3
	can_astar_pass = CANASTARPASS_ALWAYS_PROC
	var/datum/looping_sound/rockhill_clock/soundloop
	/// Broken, it is silent and tells nothing.
	var/clock_broken = FALSE

/obj/structure/fluff/clock/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	soundloop = new(src, TRUE)
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/fluff/clock/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/fluff/clock/examine(mob/user)
	. = ..()
	if(!clock_broken)
		. += rockhill_clock_reading()

/obj/structure/fluff/clock/atom_break(damage_flag)
	. = ..()
	clock_broken = TRUE
	soundloop?.stop()
	if(icon_exists(icon, "b[initial(icon_state)]"))
		icon_state = "b[initial(icon_state)]"

/obj/structure/fluff/clock/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir == dir)
		return FALSE

/obj/structure/fluff/clock/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(to_dir == dir)
		return FALSE
	return ..()

/obj/structure/fluff/clock/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving == src || direction != dir)
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/// A wall clock: ticks and tells the time.
/obj/structure/fluff/wallclock
	var/datum/looping_sound/rockhill_clock/soundloop
	var/clock_broken = FALSE

/obj/structure/fluff/wallclock/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	soundloop = new(src, TRUE)

/obj/structure/fluff/wallclock/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/fluff/wallclock/examine(mob/user)
	. = ..()
	if(!clock_broken)
		. += rockhill_clock_reading()

/obj/structure/fluff/wallclock/atom_break(damage_flag)
	. = ..()
	clock_broken = TRUE
	soundloop?.stop()
	if(icon_exists(icon, "b[initial(icon_state)]"))
		icon_state = "b[initial(icon_state)]"

/// A common bell (Ratwood bell_common): rung by hand, heard far even through walls.
/obj/structure/bell_common
	var/last_ring = 0

/obj/structure/bell_common/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(world.time < last_ring + rogue_value("bell_common_cooldown"))
		return TRUE
	user.visible_message(span_info("[user] starts ringing the bell."))
	playsound(src, 'modular_redtard/rockhill/sound/misc/bell_common.ogg', 100, extrarange = ROCKHILL_BELL_COMMON_RANGE, ignore_walls = TRUE)
	flick("bell_commonpressed", src)
	last_ring = world.time
	return TRUE

/// A ship's bell (Ratwood boatbell). Its creaking boat loop is not brought: the ambience sounds are not in the port.
/obj/structure/boatbell
	var/last_ring = 0

/obj/structure/boatbell/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(world.time < last_ring + rogue_value("boatbell_cooldown"))
		return TRUE
	user.visible_message(span_info("[user] rings the bell."))
	playsound(src, 'modular_redtard/rockhill/sound/misc/boatbell.ogg', 100, extrarange = ROCKHILL_BELL_RANGE)
	last_ring = world.time
	return TRUE

/// A service bell (Ratwood standingbell): after a long ring its chime reaches, however far, those whose service the room is.
/obj/structure/standingbell
	var/on_cooldown = FALSE

/obj/structure/standingbell/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(on_cooldown)
		to_chat(user, span_warning("The bell has already been rung recently."))
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(ring), user)
	return TRUE

/obj/structure/standingbell/proc/ring(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] begins to ring [src]"))
	if(!do_after(user, rogue_value("service_bell_ring_time"), target = src) || on_cooldown)
		return
	on_cooldown = TRUE
	user.visible_message(span_info("[user] rings [src]"))
	playsound(src, 'modular_redtard/rockhill/sound/misc/bell.ogg', 100, extrarange = ROCKHILL_BELL_RANGE)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), rogue_value("service_bell_cooldown"))
	var/area/room = get_area(src)
	var/list/called = called_roles(room?.name)
	if(!length(called))
		return
	for(var/mob/living/carbon/human/servant as anything in GLOB.human_list)
		if(!servant.stat && (servant.mind?.assigned_role?.title in called))
			to_chat(servant, span_big(span_info("I hear the distant sounds of [src] ringing. I'm being called to the [room.name].")))

/obj/structure/standingbell/proc/reset_cooldown()
	visible_message(span_notice("[src] is ready for use again."))
	on_cooldown = FALSE

/// The roles a service bell calls, by the name of the room it stands in (Ratwood's areas and position lists).
/obj/structure/standingbell/proc/called_roles(room_name)
	switch(room_name)
		if("church")
			return list(JOB_ROCKHILL_BISHOP, JOB_ROCKHILL_ACOLYTE, JOB_ROCKHILL_KEEPER, JOB_ROCKHILL_TEMPLAR, JOB_ROCKHILL_DRUID, JOB_ROCKHILL_MARTYR)
		if("Shop")
			return list(JOB_ROCKHILL_MERCHANT, JOB_ROCKHILL_SHOPHAND)
		if("Physician")
			return list(JOB_ROCKHILL_HEAD_PHYSICIAN, JOB_ROCKHILL_APOTHECARY)
		if("The Guild of Craft")
			return list(JOB_ROCKHILL_GUILDMASTER, JOB_ROCKHILL_GUILDSMAN)
		if("Steward")
			return list(JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK)
		if("Baths")
			return list(JOB_ROCKHILL_BATHMASTER, JOB_ROCKHILL_BATHHOUSE_ATTENDANT)
		if("The Inquisition")
			return list(JOB_ROCKHILL_INQUISITOR, JOB_ROCKHILL_ORTHODOXIST, JOB_ROCKHILL_ABSOLVER)
		if("Garrison", "Warden Fort")
			return list(
				JOB_ROCKHILL_CITY_GUARD, JOB_ROCKHILL_ROOKIE, JOB_ROCKHILL_FOREST_WARDEN, JOB_ROCKHILL_SERGEANT, JOB_ROCKHILL_RETAINER,
				JOB_ROCKHILL_VETERAN, JOB_ROCKHILL_MAN_AT_ARMS, JOB_ROCKHILL_SQUIRE, JOB_ROCKHILL_VANGUARD, JOB_ROCKHILL_DUNGEONEER,
				JOB_ROCKHILL_MASTER_WARDEN, JOB_ROCKHILL_WATCH_CAPTAIN,
				JOB_ROCKHILL_GRAND_DUKE, JOB_ROCKHILL_BARON, JOB_ROCKHILL_PRINCE, JOB_ROCKHILL_HAND, JOB_ROCKHILL_KNIGHT_CAPTAIN,
				JOB_ROCKHILL_MARSHAL, JOB_ROCKHILL_COUNCILLOR, JOB_ROCKHILL_STEWARD, JOB_ROCKHILL_CLERK, JOB_ROCKHILL_KNIGHT,
			)
	return list()

/// The church bell (Ratwood stationary_bell): struck with the church's mace it tolls across the town, and everyone in
/// earshot of it hears where.
/obj/structure/stationary_bell
	var/ringing = FALSE

/obj/structure/stationary_bell/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(attacking_item, /obj/item/rogueweapon/mace/church))
		return ..()
	if(ringing)
		return TRUE
	ringing = TRUE
	addtimer(VARSET_CALLBACK(src, ringing, FALSE), rogue_value("church_bell_cooldown"))
	playsound(loc, 'modular_redtard/rockhill/sound/misc/bell.ogg', 50, TRUE)
	toll()
	toll_message("The [src] rings, echoing solemnly")
	visible_message(span_notice("[user] uses the [attacking_item] to ring the [src]."))
	return TRUE

/// Ratwood ring_bell(): the bell heard far away, by everyone alive on the same stack of levels beyond those who hear it up close.
/obj/structure/stationary_bell/proc/toll()
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	var/list/levels = SSmapping.get_connected_levels(origin) || list(origin.z)
	var/near = rogue_value("church_bell_near_range")
	var/range = rogue_value("church_bell_range")
	for(var/mob/living/listener as anything in GLOB.player_list)
		if(!isliving(listener) || listener.stat == DEAD || isbrain(listener) || !(listener.z in levels))
			continue
		var/distance = get_dist(listener, origin)
		if(distance > near && distance <= range)
			listener.playsound_local(get_turf(listener), 'modular_redtard/rockhill/sound/misc/bell.ogg', ROCKHILL_CHURCH_BELL_TOLL_VOLUME, FALSE, pressure_affected = FALSE)

/// Ratwood loud_message(): who hears the bell is told where it rang from, those out of sight within its range too; one far off
/// and dull of perception hears only that it was somewhere.
/obj/structure/stationary_bell/proc/toll_message(message)
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	var/range = rogue_value("church_bell_range")
	var/list/levels = SSmapping.get_connected_levels(origin) || list(origin.z)
	var/list/listening = get_hearers_in_view(range, origin)
	for(var/mob/listener as anything in GLOB.player_list)
		if(!isliving(listener) || !listener.client || (listener in listening) || !(listener.z in levels) || get_dist(listener, origin) > range)
			continue
		var/mob/living/far_listener = listener
		if(far_listener.rogue_stat(ROGUE_STAT_PERCEPTION) <= rogue_value("loud_message_perception"))
			to_chat(far_listener, span_warning("You hear something... somewhere!"))
			continue
		listening += far_listener
	for(var/mob/living/hearer in listening)
		var/where_z
		if(hearer.z > origin.z)
			where_z = hearer.z - origin.z == 1 ? "below" : "far below"
		else if(hearer.z < origin.z)
			where_z = origin.z - hearer.z == 1 ? "above" : "far above"
		var/where_dir = dir2text(get_dir(hearer, origin))
		to_chat(hearer, span_warning("[message] from [where_z ? "<b>[where_z]</b>" : ""][where_dir ? "[where_z ? " and " : ""]<b>[where_dir]</b>" : ""]."))

/// Ratwood's telescope: a look at the sky; Astrata's light burns the eye, Noc's clears the mind.
/obj/structure/telescope
	anchored = FALSE

/obj/structure/telescope/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !ishuman(user))
		return
	var/sight = pick("You can see Noc rotating!", "Looking at Astrata blinds you!", "The stars smile at you.", "Nepolx is red today.", "Blessed yellow strife.", "You see a star!")
	to_chat(user, span_notice(sight))
	switch(sight)
		if("Looking at Astrata blinds you!")
			INVOKE_ASYNC(src, PROC_REF(gaze_at_astrata), user)
		if("You can see Noc rotating!")
			INVOKE_ASYNC(src, PROC_REF(gaze_at_noc), user)
	return TRUE

/obj/structure/telescope/proc/gaze_at_astrata(mob/living/carbon/human/stargazer)
	if(!do_after(stargazer, rogue_value("telescope_gaze_time"), target = src))
		return
	to_chat(stargazer, span_warning("The blinding light causes you intense pain!"))
	stargazer.apply_damage(rogue_value("telescope_astrata_burn"), BURN, BODY_ZONE_HEAD)

/obj/structure/telescope/proc/gaze_at_noc(mob/living/carbon/human/stargazer)
	if(!do_after(stargazer, rogue_value("telescope_gaze_time"), target = src))
		return
	to_chat(stargazer, span_warning("Noc's glow seems to help clear your thoughts."))
	stargazer.apply_status_effect(/datum/status_effect/rockhill_noc_blessing)

/// Ratwood nocblessing: a little more intelligence for a while after gazing at Noc.
/datum/status_effect/rockhill_noc_blessing
	id = "rockhill_noc_blessing"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/rockhill_noc_blessing

/datum/status_effect/rockhill_noc_blessing/on_creation(mob/living/new_owner, ...)
	duration = rogue_value("noc_blessing_time")
	return ..()

/datum/status_effect/rockhill_noc_blessing/refresh(effect, ...)
	duration = rogue_value("noc_blessing_time")

/datum/status_effect/rockhill_noc_blessing/on_apply()
	var/list/stats = list()
	stats[ROGUE_STAT_INTELLIGENCE] = rogue_value("noc_blessing_intelligence")
	owner.attributes?.set_variable_attribute_modifier(id, stats)
	return TRUE

/datum/status_effect/rockhill_noc_blessing/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	return ..()

/atom/movable/screen/alert/status_effect/rockhill_noc_blessing
	name = "Noc's blessing"
	desc = "Gazing Noc helps me think."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "buff"

/// Ratwood's globe: a spin, and a finger lands on some land of the world.
/obj/structure/globe
	anchored = FALSE

/obj/structure/globe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !ishuman(user))
		return
	to_chat(user, span_notice(pick("you spin the globe!", "You land on Rotwood Vale!", "You land on Rockhill!", "You land on Al-Ashur!", "You land on Avar!", "You land on Zybantium!", "You land on port Ice cube!.", "You land on port Thornvale!", "You land on Grenzelhoft!", "You land on Gronn!", "You land on Otava!", "You land on Giza!", "You land on Hammerhold!", "You land on Kingsfield!", "You land on Fablefield!", "You land on Avar!", "You land on Etrusca!", "You land on Kazengun! You think? Probably.")))
	return TRUE

/// Ratwood's custom sign: one who can write carves words on it with a short point (a knife's stab, a thorn, a feather, coal),
/// once; the literate read them. The map's own words are its wrotesign.
/obj/structure/fluff/customsign
	var/wrotesign

/obj/structure/fluff/customsign/examine(mob/user)
	. = ..()
	if(wrotesign)
		. += user.is_literate() ? "It says \"[wrotesign]\"." : "I have no idea what it says."

/obj/structure/fluff/customsign/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(!user.is_literate())
		to_chat(user, span_warning("I do not know how to write."))
		return ITEM_INTERACT_BLOCKING
	if(!can_carve_with(user, tool))
		to_chat(user, span_warning("Alas, this will not work. I could carve words, if I stabbed at this with something posessing a short, sharp point. A knife, thorn, feather or even coal comes to mind."))
		return ITEM_INTERACT_BLOCKING
	if(wrotesign)
		to_chat(user, span_warning("Something is already carved here."))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(carve), user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/fluff/customsign/proc/can_carve_with(mob/living/user, obj/item/tool)
	if(istype(tool, /obj/item/natural/thorn) || istype(tool, /obj/item/natural/feather) || istype(tool, /obj/item/rogueore/coal))
		return TRUE
	var/datum/intent/intent = user.rogue_active_intent()
	return intent?.blade_class == BCLASS_STAB && tool.wlength == WLENGTH_SHORT

/obj/structure/fluff/customsign/proc/carve(mob/living/user)
	var/words = tgui_input_text(user, "What would you like to carve here?", name, max_length = ROCKHILL_SIGN_MAX_LENGTH)
	if(!words || wrotesign || QDELETED(src) || !user.Adjacent(src))
		return
	wrotesign = words
	icon_state = "signwrote"
	user.log_message("carved \"[words]\" into [src].", LOG_GAME)

#undef ROCKHILL_SIGN_MAX_LENGTH
#undef ROCKHILL_BELL_COMMON_RANGE
#undef ROCKHILL_BELL_RANGE
#undef ROCKHILL_CHURCH_BELL_TOLL_VOLUME
