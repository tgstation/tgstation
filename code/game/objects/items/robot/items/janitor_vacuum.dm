/**
 * CO-OP Janitorial Borg Vacuum and Mopping which allows you to clean with a friend.
 * It is intended to be a very powerful cleaning option, as the borg can not use it on its own.
 * Sprites done by nonsense4you.
 */
/obj/item/borg/borg_vacuum
	name = "vacuum apparatus"
	desc = "An operatable vacuum apparatus designed to be used in a co-operative manner"
	icon = 'icons/obj/medical/defib.dmi' // TEMPORARY SPRITES
	icon_state = "defibunit"
	w_class = WEIGHT_CLASS_BULKY

	var/last_check = 0
	var/check_delay = 10

	/// The vacuum hose itself
	var/mob/living/current_target
	var/mob/living/current_source

	var/obj/item/borg_hose/cleaner
	/// The trashbag storage it's connected to
	var/datum/storage/trash = null
	/// Did the borg decide to lock their cleaner?
	var/locked = FALSE
	/// Are we currently active?
	var/on = FALSE
	var/normal_state = "defibunit-paddles"

	var/datum/beam/borg_hose

/**
 * INITIALIZATION CODE
 * Summons a vacuum hose when an apparatus is created
 */

/obj/item/borg/borg_vacuum/Initialize(mapload)
	. = ..()
	cleaner = make_hose()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/borg/borg_vacuum/proc/make_hose()
	return new /obj/item/borg_hose(src)

/**
 * EXAMINE CODE
 * Tell the player if the device is locked and how to offer it to someone.
 */
/obj/item/borg/borg_vacuum/examine(mob/user)
	. = ..()
	. += span_notice("You can <b>Click</b> another player to offer [cleaner]")
	. += span_notice("<b>Alt-Click</b> to <b>[locked ? "Unlock" : "Lock"]</b> [cleaner].")

/**
 * This gives a verb to the janitor borg that allows crew to take its hose
 * This also handles atom interactions with the borg vacuum apparatus
 *
 * dropped() will unlink the trashbag if a non-silicon drops it for debugging / admin usage
 */
/mob/living/silicon/robot/model/janitor/verb/hose_verb()
	set src in view(1)
	set category = "Object"
	set name = "Take Hose"

	for(var/obj/item/robot_model/janitor/model in src.contents)
		var/obj/item/borg/borg_vacuum/vacuum = locate() in model.basic_modules

		if(!iscarbon(usr))
			return NONE
		if(!usr.can_perform_action(src) || !isturf(loc))
			return NONE
		if(!vacuum)
			return NONE
		if(!vacuum.trash)
			vacuum.locate_trashbag(src)

		return vacuum.summon_hose(usr, src)

/obj/item/borg/borg_vacuum/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/mob/living/target = interacting_with
	if(!iscarbon(target) || !target.stat == CONSCIOUS || !cleaner)
		return ITEM_INTERACT_BLOCKING
	if(on)
		balloon_alert(user, "already deployed!")
	if(!trash)
		locate_trashbag(user)
	summon_hose(target, user)
	return ITEM_INTERACT_BLOCKING

/obj/item/borg/borg_vacuum/dropped(mob/user, silent)
	. = ..()
	if(!issilicon(user))
		trash = null

/**
 * DELETION CODE
 * this handles the removal of both apparatus and hose if the item.
 * remove_hose() is required to ensure that the [borg_hose] follows its connected [borg_vacuum] in deletion
 */

/obj/item/borg/borg_vacuum/Destroy()
	if(!cleaner)
		return
	if(on)
		var/M = get(cleaner, /mob)
		remove_hose(M)
	QDEL_NULL(cleaner)
	return ..()

/obj/item/borg/borg_vacuum/proc/remove_hose(mob/user)
	if(ismob(cleaner.loc))
		var/mob/M = cleaner.loc
		M.dropItemToGround(cleaner, TRUE)
		QDELL_NULL(borg_hose)
	return NONE

/**
 * BASIC OVERLAY CODE
 */

/obj/item/borg/borg_vacuum/update_overlays()
	. = ..()

	if(!on && normal_state)
		. += normal_state

/**
 * HOSE SUMMONING CODE
 * This proc places the physical vacuum hose inside the player's hand.
 */

/obj/item/borg/borg_vacuum/proc/summon_hose(mob/user, mob/source)
	if(source.stat == DEAD)
		to_chat(user, span_warning("The vacuum is completely inoperatable!"))
		return NONE
	if(cleaner.loc != cleaner.home)
		to_chat(user, span_warning("[cleaner.loc == user ? "You are already" : "Someone else is"] holding [cleaner.home]'s hose!"))
		return NONE
	if(!in_range(src, user))
		to_chat(user, span_warning("[cleaner]'s hose is overextended and yanks out of your hand!"))
		return NONE
	if(locked)
		to_chat(user, span_warning("[cleaner]'s hose is locked tight!"))
		to_chat(source, span_warning("[cleaner]'s hose is locked!"))
		return NONE
	START_PROCESSING(SSobj, src)
	playsound(cleaner, 'sound/items/vacuum/hose.ogg', 100, TRUE)
	user.put_in_hands(cleaner)
	create_vacuum_hose(user, source)
	update_appearance(UPDATE_OVERLAYS)

/**
 * LOCATE THE TRASHBAG
 * Used when the hose is deployed to ensure it always tries to find one!
 */

/obj/item/borg/borg_vacuum/proc/locate_trashbag(mob/user)
	var/mob/living/person = user
	if(issilicon(person)) // Get the storage datum of the trashbag
		for(var/obj/item/robot_model/janitor/trash_location in person.contents)
			for(var/obj/item/storage/bag/trash/trash_bag in trash_location.basic_modules)
				trash = trash_bag.atom_storage
				message_admins("[trash], [trash_bag], [person]")
/**
 * INTERACTION CODE
 * Allows the player to recall the hose and toggle the locks with an alt click
 */

/obj/item/borg/borg_vacuum/attack_self(mob/user, modifiers)
	. = ..()
	if(!cleaner)
		return NONE
	if(on)
		cleaner.return_to_borg()
		return NONE
	if(issilicon(user))
		return NONE
	/// Primarily debug code, but makes the vacuum usable as a stand alone item.
	summon_hose(user)

/obj/item/borg/borg_vacuum/click_alt(mob/user)
	balloon_alert(user, "lock toggled [locked ? "off" : "on"].")
	if(on)
		cleaner.return_to_borg(sound = FALSE)
		locked = TRUE
		return CLICK_ACTION_SUCCESS
	locked = !locked // Toggle the lock
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	return CLICK_ACTION_SUCCESS

/**
 *	VACUUM HOSE ITEM
 *
 *  This is the vacuum cleaner itself that is operated by an organic crewmember.
 */

/obj/item/borg_hose
	name = "vacuum hose"
	desc = "A duel mode vacuum and steamer attached to your favorite cleaning buddy!"
	icon = 'icons/obj/service/janitor.dmi'
	icon_state = "vacuum"
	inhand_icon_state = "vacuum"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = INDESTRUCTIBLE // To avoid possible fuckery and a broken borg module
	force = 12
	attack_verb_continuous = list("suck", "vacuum", "smack", "dust off", "beat")
	attack_verb_simple = list("sucks", "vacuums", "smacks", "dusts off", "beats")
	/// Cleaning modes - MODE_VACUUM and MODE_MOP
	var/clean_mode = MODE_VACUUM
	/// The apparatus itself.
	var/obj/item/borg/borg_vacuum/home
/**
 * INITIALIZE AND DESTROY
 */
/obj/item/borg_hose/Initialize(mapload)
	. = ..()
	home = loc
	AddComponent( \
		/datum/component/transforming, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
		hitsound_on = hitsound, \
		attack_verb_continuous_on = list("wash", "mops", "scrub", "whack"), \
		attack_verb_simple_on = list("washes", "mops", "scrubs", "whacks"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/borg_hose/Destroy()
	home = null
	UnregisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM)
	if(home.on)
		QDELL_NULL(home.borg_hose)
	return ..()

/**
 * EXAMINE INFORMATION
 */
/obj/item/borg_hose/examine(mob/user)
	. = ..()
	if(clean_mode == MODE_VACUUM)
		. += span_notice("The switch is set to <b>VACUUMING</b>.")
	if(clean_mode == MODE_MOP)
		. += span_notice("The switch is set to <b>MOPPING</b>.")

/**
 * MAIN VACUUMING AND CLEANING FUNCTIONALITY
 *
 * on_transform() handles the switch between both modes.
 */

/obj/item/borg_hose/interact_with_atom(obj/thing, mob/living/user, params)
	. = ..()
	var/obj/item/target = thing

	if(!istype(target, /obj/item)) // Only vacuume actual items
		return NONE
	if(!home.trash || clean_mode == MODE_MOP) // Do we have a trashbag and are we vacuuming?
		return NONE
	if(target.anchored || target.w_class >= WEIGHT_CLASS_BULKY)
		return NONE
	for(var/obj/item/I in get_turf(target))
		I.spasm_animation(3)
	playsound(src, 'sound/items/vacuum/vacuum_use.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(vacuum_items), target, user), 0.2 SECONDS)

/obj/item/borg_hose/proc/vacuum_items(obj/thing, mob/living/user)
	home.trash.collection_mode = COLLECT_SAME
	home.trash.collect_on_turf(thing, user)

/obj/item/borg_hose/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	clean_mode = (active ? MODE_MOP : MODE_VACUUM)
	if(!user)
		return COMPONENT_NO_DEFAULT_MESSAGE
	playsound(src, 'sound/items/vacuum/clack.ogg', 50, TRUE)
	if(clean_mode == MODE_VACUUM) // Handles the cleaner component. Don't mop if vacuuming
		qdel(GetComponent(/datum/component/cleaner))
	if(clean_mode == MODE_MOP)
		AddComponent( \
			/datum/component/cleaner, \
			base_cleaning_duration = 1 SECONDS, \
			pre_clean_callback = CALLBACK(src, PROC_REF(steam_sound)), \
		)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/borg_hose/proc/steam_sound()
	playsound(src, 'sound/items/vacuum/steam.ogg', 10, TRUE)

/**
 * This handles registering unregistering [COMSIG_MOVABLE_MOVED]
 * This also handles returning the hose back to its home
 */

/obj/item/borg_hose/equipped(mob/user, slot)
	. = ..()
	if(!home)
		message_admins("equipped failed to apply")
		return NONE
	home.on = TRUE
	message_admins("signal properly applied for COMSIG_MOVABLE_MOVED")
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/borg_hose/dropped(mob/user, silent = TRUE)
	. = ..()
	if(!home)
		return NONE
	if(user)
		home.on = FALSE
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	to_chat(user, span_notice("The vacuum hose retracts back into [home]"))
	return_to_borg()
	home.update_appearance(UPDATE_OVERLAYS)

/obj/item/borg_hose/proc/return_to_borg(sound = TRUE)
	if(!home)
		return NONE
	if(home.borg_hose)
		QDEL_NULL(home.borg_hose)
	if(sound)
		playsound(src, 'sound/items/vacuum/ploop.ogg', 50, TRUE)
	STOP_PROCESSING(SSobj, home)
	forceMove(home)

/**
 * [COMSIG_MOVABLE_MOVED] Handler to check the range every time Moved() is called
 */

/obj/item/borg_hose/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	check_range()
/*
/obj/item/borg/borg_vacuum/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	cleaner.check_range()
*/
/obj/item/borg_hose/proc/check_range()
	SIGNAL_HANDLER

	if(!home)
		return
	if(!IN_GIVEN_RANGE(src, home, 5)) // Allows you to clean everything in the same room
		if(isliving(loc))
			var/mob/living/user = loc
			to_chat(user, span_warning("[home]'s hose extends too much and springs out of your hands!"))
		else
			visible_message(span_notice("[src] snaps back into [home]."))
		return_to_borg()

/**
 * VISUAL SPRITE BEAM EFFECTS
 * Creates a visual line between the vacuum cleaner hose and the object it's connected to.
 */

/obj/item/borg/borg_vacuum/proc/create_vacuum_hose(mob/living/target, mob/living/source)
	if(!on)
		return
	current_target = target
	current_source = source
	borg_hose = source.Beam(current_target, icon_state = "zipline_hook", maxdistance = 5)
	RegisterSignal(borg_hose, COMSIG_QDELETING, PROC_REF(hose_lost))
	//var/datum/beam/borg_hose

/obj/item/borg/borg_vacuum/proc/hose_lost()
	SIGNAL_HANDLER
	borg_hose = null
	if(on)
		cleaner.return_to_borg()
	current_target = null
	current_source = null

/obj/item/borg/borg_vacuum/process()
	if(!on)
		QDEL_NULL(borg_hose)
		return
	if(!current_target || !current_source)
		cleaner.return_to_borg()
		return
	if(current_source.stat == DEAD)
		cleaner.return_to_borg()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(!los_check(current_source, current_target))
		cleaner.return_to_borg()
		return

/// Update the beam and interrupt it if passed through turfs

/obj/item/borg/borg_vacuum/proc/los_check(mob/living/user, mob/living/target)
	var/turf/user_turf = user.loc
	if(!istype(user_turf))
		return FALSE
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSITEM|PASSMOB
	var/turf/previous_step = user_turf
	var/first_step = TRUE
	for(var/turf/next_step as anything in (get_line(user_turf, target) - user_turf))
		if(first_step)
			for(var/obj/blocker in user_turf)
				if(!blocker.density || !(blocker.flags_1 & ON_BORDER_1))
					continue
				if(blocker.CanPass(dummy, get_dir(user_turf, next_step)))
					continue
				return FALSE
			first_step = FALSE
		if(next_step.density)
			qdel(dummy)
			return FALSE
		for(var/atom/movable/movable as anything in next_step)
			if(!movable.CanPass(dummy, get_dir(next_step, previous_step)))
				qdel(dummy)
				return FALSE
	qdel(dummy)
	return TRUE

/*
/obj/item/borg/borg_vacuum/process()
	if(!on)
		hose_lost()
		return
	if(!current_target)
		hose_lost()
		return
*/

