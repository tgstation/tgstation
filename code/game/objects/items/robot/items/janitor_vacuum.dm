#define MODE_VACUUM (1<<0)
#define MODE_MOP (1<<1)

/**
 * CO-OP Janitorial Borg Vacuum and Mopping which allows you to clean with a friend.
 * It is intended to be a very powerful cleaning option, as the borg can not use it on its own.
 * Sprites done by StrangeWeirdKitten on github.
 */
/obj/item/borg_vacuum
	name = "vacuum apparatus"
	desc = "An operatable vacuum apparatus designed to be used in a co-operative manner"
	icon = 'icons/obj/medical/defib.dmi' // TEMPORARY SPRITES
	icon_state = "defibunit"
	w_class = WEIGHT_CLASS_BULKY
	/// The vacuum hose itself
	var/obj/item/borg_hose/cleaner
	/// The trashbag storage it's connected to
	var/datum/storage/trash = null
	/// Did the borg decide to lock their cleaner?
	var/locked = FALSE
	/// Are we currently active?
	var/on = FALSE

	var/normal_state = "defibunit-paddles"

/obj/item/borg_vacuum/Initialize(mapload)
	. = ..()
	cleaner = make_hose()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/borg_vacuum/proc/make_hose()
	return new /obj/item/borg_hose(src)

/obj/item/borg_vacuum/equipped(mob/user, slot)
	var/mob/living/person = user
	if(trash)
		return NONE
	for(var/obj/item/storage/bag/trash/trash_bag in person.contents) // Get the storage datum of the trashbag
		trash = trash_bag.atom_storage
		message_admins("[trash], [trash_bag], [person]")
	return ..()

/obj/item/borg_vacuum/dropped(mob/user, silent)
	. = ..()
	trash = null

/**
 * Deletion code that handles the removal of both apparatus and hose if the item.
 * remove_hose() is required to ensure that the [borg_hose] follows its connected [borg_vacuum] in deletion
 */
/obj/item/borg_vacuum/Destroy()
	if(!cleaner)
		return
	if(on)
		var/M = get(cleaner, /mob)
		remove_hose(M)
	QDEL_NULL(cleaner)
	return ..()

/obj/item/borg_vacuum/proc/remove_hose(mob/user)
	if(ismob(cleaner.loc))
		var/mob/M = cleaner.loc
		M.dropItemToGround(cleaner, TRUE)
	return NONE

/obj/item/borg_vacuum/update_overlays()
	. = ..()

	if(!on && normal_state)
		. += normal_state

/// Borg can recall its own vacuum
/obj/item/borg_vacuum/attack_self(mob/user, modifiers)
	. = ..()
	if(!cleaner)
		to_chat(user, span_warning("You've somehow lost your hose. Make a bug report!"))
		return NONE
	if(on)
		cleaner.return_to_borg()
		return NONE
	/// Primarily debug code, but makes the vacuum usable as a stand alone item.
	if(issilicon(user))
		return NONE
	if(cleaner.loc != cleaner.home)
		to_chat(user, span_warning("[cleaner.loc == user ? "You are already" : "Someone else is"] holding [cleaner.home]'s hose!"))
		return NONE
	if(!in_range(src, user))
		to_chat(user, span_warning("[cleaner]'s hose is overextended and yanks out of your hand!"))
		return NONE
	user.put_in_hands(cleaner)
	update_appearance(UPDATE_OVERLAYS)

// The inhand vacuum cleaner and mopping tool
/obj/item/borg_hose
	name = "vacuum hose"
	desc = "A duel mode vacuum and scrubber attached to your favorite cleaning buddy!"
	icon = 'icons/obj/items_cyborg.dmi' // TEMPORARY SPRITES
	icon_state = "vacuum"
	w_class = WEIGHT_CLASS_BULKY
	/// Cleaning modes - MODE_VACUUM and MODE_MOP
	var/clean_mode = MODE_VACUUM
	/// The apparatus itself.
	var/obj/item/borg_vacuum/home

/obj/item/borg_hose/Initialize(mapload)
	. = ..()
	home = loc
	AddComponent( \
		/datum/component/transforming, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/borg_hose/Destroy(force)
	home = null
	UnregisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM)
	return ..()

/obj/item/borg_hose/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	clean_mode = (active ? MODE_MOP : MODE_VACUUM)
	if(!user)
		return COMPONENT_NO_DEFAULT_MESSAGE
	balloon_alert(user, "switched to [active ? "mopping" : "vacuuming"]")
	playsound(src, 'sound/weapons/batonextend.ogg', 20, TRUE)
	if(clean_mode == MODE_VACUUM) // Handles the cleaner component. Don't mop if vacuuming
		qdel(GetComponent(/datum/component/cleaner))
	if(clean_mode == MODE_MOP)
		AddComponent( \
			/datum/component/cleaner, \
			base_cleaning_duration = 1 SECONDS, \
		)
	return COMPONENT_NO_DEFAULT_MESSAGE

/// start processing the check_range() proc only when the hose is equipped by the player
/obj/item/borg_hose/equipped(mob/user, slot)
	. = ..()
	if(!home)
		message_admins("equipped failed to apply")
		return NONE
	home.on = TRUE
	message_admins("signal properly applied for COMSIG_MOVABLE_MOVED")
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/borg_hose/proc/return_to_borg()
	if(!home)
		return NONE
	playsound(src, 'sound/machines/click.ogg', 20, FALSE)
	forceMove(home)

/obj/item/borg_hose/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	check_range()

/obj/item/borg_hose/interact_with_atom(obj/thing, mob/living/user, params)
	. = ..()
	var/obj/item/target = thing
	home.trash.collection_mode = COLLECT_ONE

	if(!istype(target, /obj/item)) // Only vacuume actual items
		return NONE
	if(clean_mode == MODE_MOP || !home.trash) // Do we have a trashbag and are we vacuuming?
		return NONE
	for(var/obj/item/obj in get_turf(target.loc)) // Apply animations to all items in the turf
		while(do_after(user, 3 DECISECONDS, obj, NONE, TRUE)) // Fairly quick to give enough time for the animation
			obj.spasm_animation(3)
			home.trash.on_preattack(src, obj, user)
			if(!obj || !in_range(obj, user))
				break

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

/// [COMSIG_MOVABLE_MOVED] Handler to check the range every time Moved() is called
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


#undef MODE_VACUUM
#undef MODE_MOP
