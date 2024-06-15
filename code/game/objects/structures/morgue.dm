///The cooldown between messages when attempting to break out of a morgue tray.
#define BREAKOUT_COOLDOWN (5 SECONDS)
///The amount of time it takes to break out of a morgue tray.
#define BREAKDOWN_TIME (60 SECONDS)

/obj/item/paper/guides/jobs/medical/morgue
	name = "morgue memo"
	default_raw_text = "<font size='2'>Since this station's medbay never seems to fail to be staffed by the mindless monkeys \
		meant for genetics experiments, I'm leaving a reminder here for anyone handling the pile of cadavers the quacks are sure \
		to leave.</font><BR><BR><font size='4'><font color=red>Red lights mean there's a plain ol' dead body inside.</font><BR><BR>\
		<font color=orange>Yellow lights mean there's non-body objects inside.</font><BR><font size='2'>Probably stuff pried off a \
		corpse someone grabbed, or if you're lucky it's stashed booze.</font><BR><BR><font color=green>Green lights mean the morgue \
		system detects the body may be able to be brought back to life.</font></font><BR><font size='2'>I don't know how that works, \
		but keep it away from the kitchen and go yell at the coroner.</font><BR><BR>- CentCom medical inspector"

/* Morgue stuff
 * Contains:
 * Morgue
 * Morgue tray
 * Crematorium
 * Creamatorium
 * Crematorium tray
 * Crematorium button
 */

/*
 * Bodycontainer
 * Parent class for morgue and crematorium
 * For overriding only
 */
GLOBAL_LIST_EMPTY(bodycontainers) //Let them act as spawnpoints for revenants and other ghosties.

/obj/structure/bodycontainer
	icon = 'icons/obj/structures.dmi'
	icon_state = "morgue1"
	density = TRUE
	anchored = TRUE
	max_integrity = 400
	pass_flags_self = LETPASSTHROW | PASSSTRUCTURE
	dir = SOUTH

	///The morgue tray this container will open/close to put/take things in/out.
	var/obj/structure/tray/connected
	///Boolean on whether we're locked and will not allow the tray to be opened.
	var/locked = FALSE
	///Cooldown between breakout msesages.
	COOLDOWN_DECLARE(breakout_message_cooldown)
	/// Cooldown between being able to slide the tray in or out.
	COOLDOWN_DECLARE(open_close_cd)

/obj/structure/bodycontainer/Initialize(mapload)
	. = ..()
	if(connected)
		connected = new connected(src)
		connected.connected = src
	GLOB.bodycontainers += src
	register_context()

/obj/structure/bodycontainer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!locked)
		context[SCREENTIP_CONTEXT_LMB] = "Open/Close"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bodycontainer/Destroy()
	GLOB.bodycontainers -= src
	open()
	if(connected)
		QDEL_NULL(connected)
	return ..()

/obj/structure/bodycontainer/on_log(login)
	..()
	update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/relaymove(mob/living/user, direction)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(COOLDOWN_FINISHED(src, breakout_message_cooldown))
			COOLDOWN_START(src, breakout_message_cooldown, BREAKOUT_COOLDOWN)
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open()

/obj/structure/bodycontainer/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, span_danger("It's locked."))
		return
	if(!connected)
		to_chat(user, "That doesn't appear to have a tray.")
		return
	if(connected.loc == src)
		open()
	else
		close()
	add_fingerprint(user)

/obj/structure/bodycontainer/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/bodycontainer/attack_robot(mob/user)
	if(!user.Adjacent(src))
		return
	return attack_hand(user)

/obj/structure/bodycontainer/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(loc, 5)

/obj/structure/bodycontainer/container_resist_act(mob/living/user)
	if(!locked)
		open()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(null, \
		span_notice("You lean on the back of [src] and start pushing the tray open... (this will take about [DisplayTimeText(BREAKDOWN_TIME)].)"), \
		span_hear("You hear a metallic creaking from [src]."))
	if(!do_after(user, BREAKDOWN_TIME, target = src))
		return
	if(!user || user.stat != CONSCIOUS || user.loc != src)
		return
	user.visible_message(
		span_warning("[user] successfully broke out of [src]!"),
		span_notice("You successfully break out of [src]!"),
	)
	open()

/obj/structure/bodycontainer/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/structure/bodycontainer/proc/open()
	if(!COOLDOWN_FINISHED(src, open_close_cd))
		return FALSE

	COOLDOWN_START(src, open_close_cd, 0.25 SECONDS)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	playsound(src, 'sound/effects/roll.ogg', 5, TRUE)
	var/turf/dump_turf = get_step(src, dir)
	connected?.setDir(dir)
	for(var/atom/movable/moving in src)
		moving.forceMove(dump_turf)
		animate_slide_out(moving)
	update_appearance()
	return TRUE

/obj/structure/bodycontainer/proc/close()
	if(!COOLDOWN_FINISHED(src, open_close_cd))
		return FALSE

	COOLDOWN_START(src, open_close_cd, 0.5 SECONDS)
	playsound(src, 'sound/effects/roll.ogg', 5, TRUE)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	var/turf/close_loc = connected.loc
	for(var/atom/movable/entering in close_loc)
		if(entering.anchored && entering != connected)
			continue
		if(isliving(entering))
			var/mob/living/living_mob = entering
			if(living_mob.incorporeal_move)
				continue
		else if(istype(entering, /obj/effect/dummy/phased_mob) || isdead(entering))
			continue
		animate_slide_in(entering, close_loc)
		entering.forceMove(src)
	update_appearance()
	return TRUE

#define SLIDE_LENGTH (0.3 SECONDS)

/// Slides the passed object out of the morgue tray.
/obj/structure/bodycontainer/proc/animate_slide_out(atom/movable/animated)
	var/old_layer = animated.layer
	animated.layer = layer - (animated == connected ? 0.03 : 0.01)
	animated.pixel_x = animated.base_pixel_x + (x * 32) - (animated.x * 32)
	animated.pixel_y = animated.base_pixel_y + (y * 32) - (animated.y * 32)
	animate(
		animated,
		pixel_x = animated.base_pixel_x,
		pixel_y = animated.base_pixel_y,
		time = SLIDE_LENGTH,
		easing = CUBIC_EASING|EASE_OUT,
		flags = ANIMATION_PARALLEL,
	)
	addtimer(VARSET_CALLBACK(animated, layer, old_layer), SLIDE_LENGTH)

/// Slides the passed object into the morgue tray from the passed turf.
/obj/structure/bodycontainer/proc/animate_slide_in(atom/movable/animated, turf/from_loc)
	// It's easier to just make a visual for entering than to animate the object itself
	var/obj/effect/temp_visual/morgue_content/visual = new(from_loc, animated)
	visual.layer = layer - (animated == connected ? 0.03 : 0.01)
	animate(
		visual,
		pixel_x = visual.base_pixel_x + (x * 32) - (visual.x * 32),
		pixel_y = visual.base_pixel_y + (y * 32) - (visual.y * 32),
		time = SLIDE_LENGTH,
		easing = CUBIC_EASING|EASE_IN,
		flags = ANIMATION_PARALLEL,
	)

/// Used to mimic the appearance of an object sliding into a morgue tray.
/obj/effect/temp_visual/morgue_content
	duration = SLIDE_LENGTH

/obj/effect/temp_visual/morgue_content/Initialize(mapload, atom/movable/sliding_in)
	. = ..()
	if(isnull(sliding_in))
		return

	appearance = sliding_in.appearance
	dir = sliding_in.dir
	alpha = sliding_in.alpha
	base_pixel_x = sliding_in.base_pixel_x
	base_pixel_y = sliding_in.base_pixel_y

#undef SLIDE_LENGTH

#define MORGUE_EMPTY 1
#define MORGUE_NO_MOBS 2
#define MORGUE_ONLY_BRAINDEAD 3
#define MORGUE_HAS_REVIVABLE 4

/*
 * Morgue
 */
/obj/structure/bodycontainer/morgue
	name = "morgue"
	desc = "Used to keep bodies in until someone fetches them. Includes a high-tech alert system."
	icon_state = "morgue1"
	base_icon_state = "morgue"
	dir = EAST
	interaction_flags_click = ALLOW_SILICON_REACH|ALLOW_RESTING

	connected = /obj/structure/tray/m_tray

	/// Whether or not this morgue beeps to alert parameds of revivable corpses.
	var/beeper = TRUE
	/// The minimum time between beeps.
	var/beep_cooldown = 1 MINUTES
	/// Whether this morgue tray has revivables or not
	var/morgue_state = MORGUE_EMPTY
	/// The cooldown to prevent this from spamming beeps.
	COOLDOWN_DECLARE(next_beep)

	/// Internal air of this morgue, for cooling purposes.
	var/datum/gas_mixture/internal_air

	/// The rate at which the internal air mixture cools
	var/cooling_rate_per_second = 4
	/// Minimum temperature of the internal air mixture
	var/minimum_temperature = T0C - 60

/obj/structure/bodycontainer/morgue/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bodycontainer/morgue/LateInitialize()
	var/datum/gas_mixture/external_air = loc.return_air()
	if(external_air)
		internal_air = external_air.copy()
	else
		internal_air = new()
	START_PROCESSING(SSobj, src)

/obj/structure/bodycontainer/morgue/return_air()
	return internal_air

/obj/structure/bodycontainer/morgue/process(seconds_per_tick)
	update_morgue_status()
	update_appearance(UPDATE_ICON_STATE)
	if(morgue_state == MORGUE_HAS_REVIVABLE && beeper && COOLDOWN_FINISHED(src, next_beep))
		playsound(src, 'sound/weapons/gun/general/empty_alarm.ogg', 50, FALSE) //Revive them you blind fucks
		COOLDOWN_START(src, next_beep, beep_cooldown)

	if(!connected || connected.loc != src)
		var/datum/gas_mixture/current_exposed_air = loc.return_air()
		if(!current_exposed_air)
			return
		// The internal air won't cool down the external air when the freezer is opened.
		internal_air.temperature = max(current_exposed_air.temperature, internal_air.temperature)
		if(current_exposed_air.equalize(internal_air))
			var/turf/location = get_turf(src)
			location.air_update_turf()
	else
		if(internal_air.temperature <= minimum_temperature)
			return
		var/temperature_decrease_this_tick = min(cooling_rate_per_second * seconds_per_tick, internal_air.temperature - minimum_temperature)
		internal_air.temperature -= temperature_decrease_this_tick

/obj/structure/bodycontainer/morgue/beeper_off
	name = "secure morgue"
	desc = "Used to keep bodies in until someone fetches them. Starts with their beeper off."
	beeper = FALSE

/obj/structure/bodycontainer/morgue/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "[beeper ? "disable beeper" : "enable beeper"]"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/bodycontainer/morgue/proc/update_morgue_status()
	if(length(contents) <= 1)
		morgue_state = MORGUE_EMPTY
		return

	var/list/stored_living = get_all_contents_type(/mob/living) // Search for mobs in all contents.
	if(!length(stored_living))
		morgue_state = MORGUE_NO_MOBS
		return

	if(obj_flags & EMAGGED)
		morgue_state = MORGUE_ONLY_BRAINDEAD
		return

	for(var/mob/living/occupant as anything in stored_living)
		if(occupant.stat == DEAD)
			if(iscarbon(occupant))
				var/mob/living/carbon/carbon_occupant = occupant
				if(!carbon_occupant.can_defib_client())
					continue
			else
				if(HAS_TRAIT(occupant, TRAIT_SUICIDED) || HAS_TRAIT(occupant, TRAIT_BADDNA) || (!occupant.key && !occupant.get_ghost(FALSE, TRUE)))
					continue
		morgue_state = MORGUE_HAS_REVIVABLE
		return
	morgue_state = MORGUE_ONLY_BRAINDEAD

/obj/structure/bodycontainer/morgue/proc/handle_bodybag_enter(obj/structure/closet/body_bag/arrived_bag)
	if(!arrived_bag.tag_name)
		return
	name = "[initial(name)] - ([arrived_bag.tag_name])"
	update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/morgue/proc/handle_bodybag_exit(obj/structure/closet/body_bag/exited_bag)
	name = initial(name)
	update_appearance(UPDATE_ICON)

/obj/structure/bodycontainer/morgue/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/structure/closet/body_bag))
		return handle_bodybag_enter(arrived)

/obj/structure/bodycontainer/morgue/close()
	. = ..()
	update_morgue_status()
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/bodycontainer/morgue/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/structure/closet/body_bag))
		return handle_bodybag_exit(gone)

/obj/structure/bodycontainer/morgue/open()
	. = ..()
	update_morgue_status()
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/bodycontainer/morgue/examine(mob/user)
	. = ..()
	. += span_notice("The speaker is [beeper ? "enabled" : "disabled"]. Alt-click to toggle it.")

/obj/structure/bodycontainer/morgue/click_alt(mob/user)
	beeper = !beeper
	to_chat(user, span_notice("You turn the speaker function [beeper ? "on" : "off"]."))
	return CLICK_ACTION_SUCCESS

/obj/structure/bodycontainer/morgue/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	balloon_alert(user, "alert system overloaded")
	obj_flags |= EMAGGED
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/bodycontainer/morgue/update_icon_state()
	if(!connected || connected.loc != src) // Open or tray is gone.
		icon_state = "morgue0"
		return ..()

	if(morgue_state == MORGUE_EMPTY)  // Empty
		icon_state = "morgue1"
		return ..()

	if(morgue_state == MORGUE_NO_MOBS) // No mobs?
		icon_state = "morgue3"
		return ..()

	if(morgue_state == MORGUE_HAS_REVIVABLE)
		icon_state = "morgue4" // Revivable
		return ..()

	if(morgue_state == MORGUE_ONLY_BRAINDEAD)
		icon_state = "morgue2" // Dead, brainded mob.
	return ..()

/obj/structure/bodycontainer/morgue/update_overlays()
	. = ..()
	underlays.Cut()

	if(name != initial(name))
		. += "[base_icon_state]_label"

#undef MORGUE_EMPTY
#undef MORGUE_NO_MOBS
#undef MORGUE_ONLY_BRAINDEAD
#undef MORGUE_HAS_REVIVABLE

/*
 * Crematorium
 */
GLOBAL_LIST_EMPTY(crematoriums)
/obj/structure/bodycontainer/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbecue nights."
	icon = 'icons/obj/machines/crematorium.dmi'
	icon_state = "crema1"
	base_icon_state = "crema"
	dir = SOUTH

	connected = /obj/structure/tray/c_tray

	var/id = 1

/obj/structure/bodycontainer/crematorium/Initialize(mapload)
	. = ..()
	GLOB.crematoriums += src

/obj/structure/bodycontainer/crematorium/Destroy()
	GLOB.crematoriums -= src
	return ..()

/obj/structure/bodycontainer/crematorium/attack_robot(mob/user) //Borgs can't use crematoriums without help
	to_chat(user, span_warning("[src] is locked against you."))
	return

/obj/structure/bodycontainer/crematorium/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

/obj/structure/bodycontainer/crematorium/update_icon_state()
	if(!connected || connected.loc != src)
		icon_state = "[base_icon_state]0"
		return ..()
	if(locked)
		icon_state = "[base_icon_state]_active"
		return ..()
	icon_state = "[base_icon_state][(contents.len > 1) ? 2 : 1]"
	return ..()

/obj/structure/bodycontainer/crematorium/proc/cremate(mob/user)
	if(locked)
		return //don't let you cremate something twice or w/e
	// Make sure we don't delete the actual morgue and its tray
	var/list/conts = get_all_contents() - src - connected

	if(!conts.len)
		audible_message(span_hear("You hear a hollow crackle."))
		return

	else
		audible_message(span_hear("You hear a roar as the crematorium activates."))

		locked = TRUE
		update_appearance()

		for(var/mob/living/M in conts)
			if(M.incorporeal_move) //can't cook revenants!
				continue
			if (M.stat != DEAD)
				M.emote("scream")
			if(user)
				log_combat(user, M, "cremated")
			else
				M.log_message("was cremated", LOG_ATTACK)

			if(user.stat != DEAD)
				user.investigate_log("has died from being cremated.", INVESTIGATE_DEATHS)
			M.death(TRUE)
			if(M) //some animals get automatically deleted on death.
				M.ghostize()
				qdel(M)

		for(var/obj/O in conts) //conts defined above, ignores crematorium and tray
			if(istype(O, /obj/effect/dummy/phased_mob)) //they're not physical, don't burn em.
				continue
			qdel(O)

		if(!locate(/obj/effect/decal/cleanable/ash) in get_step(src, dir))//prevent pile-up
			new/obj/effect/decal/cleanable/ash(src)

		sleep(3 SECONDS)

		if(!QDELETED(src))
			locked = FALSE
			update_appearance()
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE) //you horrible people

/obj/structure/bodycontainer/crematorium/creamatorium
	name = "creamatorium"
	desc = "A human incinerator. Works well during ice cream socials."

/obj/structure/bodycontainer/crematorium/creamatorium/cremate(mob/user)
	var/list/icecreams = list()
	for(var/mob/living/i_scream as anything in get_all_contents_type(/mob/living))
		icecreams += new /obj/item/food/icecream(null, list(ICE_CREAM_MOB = list(null, i_scream.name)))
	. = ..()
	for(var/obj/ice_cream as anything in icecreams)
		ice_cream.forceMove(src)

/*
 * Generic Tray
 * Parent class for morguetray and crematoriumtray
 * For overriding only
 */
/obj/structure/tray
	icon = 'icons/obj/machines/crematorium.dmi'
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW

	max_integrity = 350

	///The bodycontainer we are a tray to.
	var/obj/structure/bodycontainer/connected

/obj/structure/tray/Destroy()
	if(connected)
		connected.connected = null
		connected.update_appearance()
		connected = null
	return ..()

/obj/structure/tray/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron (loc, 2)

/obj/structure/tray/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/tray/attack_robot(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/tray/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if (connected)
		connected.close()
	else
		to_chat(user, span_warning("That's not connected to anything!"))
	add_fingerprint(user)

/obj/structure/tray/attackby(obj/P, mob/user, params)
	if(!istype(P, /obj/item/riding_offhand))
		return ..()

	var/obj/item/riding_offhand/riding_item = P
	var/mob/living/carried_mob = riding_item.rider
	if(carried_mob == user) //Piggyback user.
		return
	user.unbuckle_mob(carried_mob)
	mouse_drop_receive(carried_mob, user)

/obj/structure/tray/mouse_drop_receive(atom/movable/O as mob|obj, mob/user, params)
	if(!ismovable(O) || O.anchored || O.loc == user)
		return
	if(!ismob(O))
		if(!istype(O, /obj/structure/closet/body_bag))
			return
	else
		var/mob/M = O
		if(M.buckled)
			return
	O.forceMove(src.loc)
	if (user != O)
		visible_message(span_warning("[user] stuffs [O] into [src]."))

/*
 * Crematorium tray
 */
/obj/structure/tray/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon_state = "cremat"
	layer = /obj/structure/bodycontainer/crematorium::layer - 0.03

/*
 * Morgue tray
 */
/obj/structure/tray/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/structures.dmi'
	icon_state = "morguet"
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = /obj/structure/bodycontainer/morgue::layer - 0.03

/obj/structure/tray/m_tray/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

#undef BREAKOUT_COOLDOWN
#undef BREAKDOWN_TIME
