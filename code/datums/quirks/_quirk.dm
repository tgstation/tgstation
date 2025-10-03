//every quirk in this folder should be coded around being applied on spawn
//these are NOT "mob quirks" like GOTTAGOFAST, but exist as a medium to apply them and other different effects
/datum/quirk
	/// The name of the quirk
	var/name = "Test Quirk"
	/// The description of the quirk
	var/desc = "This is a test quirk."
	/// What the quirk is worth in preferences, zero = neutral / free
	var/value = 0
	/// Flags related to this quirk.
	var/quirk_flags = QUIRK_HUMAN_ONLY
	/// Reference to the mob currently tied to this quirk datum. Quirks are not singletons.
	var/mob/living/quirk_holder
	/// Text displayed when this quirk is assigned to a mob (and not transferred)
	var/gain_text
	/// Text displayed when this quirk is removed from a mob (and not transferred)
	var/lose_text
	///This text will appear on medical records for the trait.
	var/medical_record_text
	/// if applicable, apply and remove this mob trait
	var/mob_trait
	/// Amount of points this trait is worth towards the hardcore character mode.
	/// Minus points implies a positive quirk, positive means its hard.
	/// This is used to pick the quirks assigned to a hardcore character.
	//// 0 means its not available to hardcore draws.
	var/hardcore_value = 0
	/// When making an abstract quirk (in OOP terms), don't forget to set this var to the type path for that abstract quirk.
	var/abstract_parent_type = /datum/quirk
	/// The icon to show in the preferences menu.
	/// This references a tgui icon, so it can be FontAwesome or a tgfont (with a tg- prefix).
	var/icon
	/// A lazylist of items people can receive from mail who have this quirk enabled
	/// The base weight for the each quirk's mail goodies list to be selected is 5
	/// then the item selected is determined by pick(selected_quirk.mail_goodies)
	var/list/mail_goodies
	/// max stat below which this quirk can process (if it has QUIRK_PROCESSES) and above which it stops.
	/// If null, then it will process regardless of stat.
	var/maximum_process_stat = HARD_CRIT
	/// A list of additional signals to register with update_process()
	var/list/process_update_signals
	/// A list of traits that should stop this quirk from processing.
	/// Signals for adding and removing this trait will automatically be added to `process_update_signals`.
	var/list/no_process_traits

/datum/quirk/New()
	. = ..()
	for(var/trait in no_process_traits)
		LAZYADD(process_update_signals, list(SIGNAL_ADDTRAIT(trait), SIGNAL_REMOVETRAIT(trait)))

/datum/quirk/Destroy()
	if(quirk_holder)
		remove_from_current_holder()
	return ..()

/// Called when quirk_holder is qdeleting. Simply qdels this datum and lets Destroy() handle the rest.
/datum/quirk/proc/on_holder_qdeleting(mob/living/source, force)
	SIGNAL_HANDLER
	qdel(src)

/**
 * Adds the quirk to a new quirk_holder.
 *
 * Performs logic to make sure new_holder is a valid holder of this quirk.
 * Returns FALSEy if there was some kind of error. Returns TRUE otherwise.
 * Arguments:
 * * new_holder - The mob to add this quirk to.
 * * quirk_transfer - If this is being added to the holder as part of a quirk transfer. Quirks can use this to decide not to spawn new items or apply any other one-time effects.
 */
/datum/quirk/proc/add_to_holder(mob/living/new_holder, quirk_transfer = FALSE, client/client_source, unique = TRUE, announce = TRUE)
	if(!new_holder)
		CRASH("Quirk attempted to be added to null mob.")

	if((quirk_flags & QUIRK_HUMAN_ONLY) && !ishuman(new_holder))
		CRASH("Human only quirk attempted to be added to non-human mob.")

	if(new_holder.has_quirk(type))
		CRASH("Quirk attempted to be added to mob which already had this quirk.")

	if(quirk_holder)
		CRASH("Attempted to add quirk to a holder when it already has a holder.")

	quirk_holder = new_holder
	LAZYADD(quirk_holder.quirks, src)
	// If we weren't passed a client source try to use a present one
	client_source ||= quirk_holder.client

	if(mob_trait)
		ADD_TRAIT(quirk_holder, mob_trait, QUIRK_TRAIT)

	add(client_source)

	if(quirk_flags & QUIRK_PROCESSES)
		if(!isnull(maximum_process_stat))
			RegisterSignal(quirk_holder, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))
		if(process_update_signals)
			RegisterSignals(quirk_holder, process_update_signals, PROC_REF(update_process))
		if(should_process())
			START_PROCESSING(SSquirks, src)

	if(!quirk_transfer)
		if(gain_text && announce)
			to_chat(quirk_holder, gain_text)
		if (unique)
			add_unique(client_source)

		if(quirk_holder.client)
			post_add()
		else
			RegisterSignal(quirk_holder, COMSIG_MOB_LOGIN, PROC_REF(on_quirk_holder_first_login))

	RegisterSignal(quirk_holder, COMSIG_QDELETING, PROC_REF(on_holder_qdeleting))

	return TRUE

/// Removes the quirk from the current quirk_holder.
/datum/quirk/proc/remove_from_current_holder(quirk_transfer = FALSE)
	if(!quirk_holder)
		CRASH("Attempted to remove quirk from the current holder when it has no current holder.")

	UnregisterSignal(quirk_holder, list(COMSIG_MOB_STATCHANGE, COMSIG_MOB_LOGIN, COMSIG_QDELETING))
	if(process_update_signals)
		UnregisterSignal(quirk_holder, process_update_signals)

	LAZYREMOVE(quirk_holder.quirks, src)

	if(!quirk_transfer && lose_text)
		to_chat(quirk_holder, lose_text)

	if(mob_trait && !QDELETED(quirk_holder))
		REMOVE_TRAIT(quirk_holder, mob_trait, QUIRK_TRAIT)

	if(quirk_flags & QUIRK_PROCESSES)
		STOP_PROCESSING(SSquirks, src)

	remove()

	quirk_holder = null

/**
 * On client connection set quirk preferences.
 *
 * Run post_add to set the client preferences for the quirk.
 * Clear the attached signal for login.
 * Used when the quirk has been gained and no client is attached to the mob.
 */
/datum/quirk/proc/on_quirk_holder_first_login(mob/living/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOB_LOGIN)
	post_add()

/// Any effect that should be applied every single time the quirk is added to any mob, even when transferred.
/datum/quirk/proc/add(client/client_source)
	return

/// Any effects from the proc that should not be done multiple times if the quirk is transferred between mobs.
/// Put stuff like spawning items in here.
/datum/quirk/proc/add_unique(client/client_source)
	return

/// Removal of any reversible effects added by the quirk.
/datum/quirk/proc/remove()
	return

/// Any special effects or chat messages which should be applied.
/// This proc is guaranteed to run if the mob has a client when the quirk is added.
/// Otherwise, it runs once on the next COMSIG_MOB_LOGIN.
/datum/quirk/proc/post_add()
	return

/// Returns if the quirk holder should process currently or not.
/datum/quirk/proc/should_process()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(QDELETED(quirk_holder))
		return FALSE
	if(!(quirk_flags & QUIRK_PROCESSES))
		return FALSE
	if(!isnull(maximum_process_stat) && quirk_holder.stat >= maximum_process_stat)
		return FALSE
	for(var/trait in no_process_traits)
		if(HAS_TRAIT(quirk_holder, trait))
			return FALSE
	return TRUE

/// Checks to see if the quirk should be processing, and starts/stops it.
/datum/quirk/proc/update_process()
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)
	if(should_process())
		START_PROCESSING(SSquirks, src)
	else
		STOP_PROCESSING(SSquirks, src)

/// Updates processing status whenever the mob's stat changes.
/datum/quirk/proc/on_stat_changed(mob/living/source, new_stat)
	SIGNAL_HANDLER
	update_process()

/// If a quirk is able to be selected for the mob's species
/datum/quirk/proc/is_species_appropriate(datum/species/mob_species)
	if(mob_trait in GLOB.species_prototypes[mob_species].inherent_traits)
		return FALSE
	return TRUE

/// Subtype quirk that has some bonus logic to spawn items for the player.
/datum/quirk/item_quirk
	/// Lazylist of strings describing where all the quirk items have been spawned.
	var/list/where_items_spawned
	/// If true, the backpack automatically opens on post_add(). Usually set to TRUE when an item is equipped inside the player's backpack.
	var/open_backpack = FALSE
	abstract_parent_type = /datum/quirk/item_quirk

/**
 * Handles inserting an item in any of the valid slots provided, then allows for post_add notification.
 *
 * If no valid slot is available for an item, the item is left at the mob's feet.
 * Arguments:
 * * quirk_item - The item to give to the quirk holder. If the item is a path, the item will be spawned in first on the player's turf.
 * * valid_slots - List of LOCATION_X that is fed into [/mob/living/carbon/proc/equip_in_one_of_slots].
 * * flavour_text - Optional flavour text to append to the where_items_spawned string after the item's location.
 * * default_location - If the item isn't possible to equip in a valid slot, this is a description of where the item was spawned.
 * * notify_player - If TRUE, adds strings to where_items_spawned list to be output to the player in [/datum/quirk/item_quirk/post_add()]
 */
/datum/quirk/item_quirk/proc/give_item_to_holder(obj/item/quirk_item, list/valid_slots, flavour_text = null, default_location = "at your feet", notify_player = FALSE)
	if(ispath(quirk_item))
		quirk_item = new quirk_item(get_turf(quirk_holder))

	var/mob/living/carbon/human/human_holder = quirk_holder

	var/where = human_holder.equip_in_one_of_slots(quirk_item, valid_slots, qdel_on_fail = FALSE, indirect_action = TRUE) || default_location

	if(where == LOCATION_BACKPACK)
		open_backpack = TRUE

	if(notify_player)
		LAZYADD(where_items_spawned, span_boldnotice("You have \a [quirk_item] [where]. [flavour_text]"))

/datum/quirk/item_quirk/post_add()
	if(open_backpack)
		var/mob/living/carbon/human/human_holder = quirk_holder
		// post_add() can be called via delayed callback. Check they still have a backpack equipped before trying to open it.
		if(human_holder.back)
			human_holder.back.atom_storage.show_contents(human_holder)

	for(var/chat_string in where_items_spawned)
		to_chat(quirk_holder, chat_string)

	where_items_spawned = null

/**
 * get_quirk_string() is used to get a printable string of all the quirk traits someone has for certain criteria
 *
 * Arguments:
 * * Medical- If we want the long, fancy descriptions that show up in medical records, or if not, just the name
 * * Category- Which types of quirks we want to print out. Defaults to everything
 * * from_scan- If the source of this call is like a health analyzer or HUD, in which case QUIRK_HIDE_FROM_MEDICAL hides the quirk.
 */
/mob/living/proc/get_quirk_string(medical = FALSE, category = CAT_QUIRK_ALL, from_scan = FALSE)
	var/list/dat = list()
	for(var/datum/quirk/candidate as anything in quirks)
		if(from_scan && (candidate.quirk_flags & QUIRK_HIDE_FROM_SCAN))
			continue
		switch(category)
			if(CAT_QUIRK_MAJOR_DISABILITY)
				if(candidate.value >= -4)
					continue
			if(CAT_QUIRK_MINOR_DISABILITY)
				if(!ISINRANGE(candidate.value, -4, -1))
					continue
			if(CAT_QUIRK_NOTES)
				if(candidate.value < 0)
					continue
		dat += medical ? candidate.medical_record_text : candidate.name

	if(!length(dat))
		return medical ? "No issues have been declared." : "None"
	return medical ?  dat.Join("<br>") : dat.Join(", ")

/mob/living/proc/cleanse_quirk_datums() //removes all trait datums
	QDEL_LAZYLIST(quirks)

/mob/living/proc/transfer_quirk_datums(mob/living/to_mob)
	// We could be done before the client was moved or after the client was moved
	var/datum/preferences/to_pass = client || to_mob.client

	for(var/datum/quirk/quirk as anything in quirks)
		quirk.remove_from_current_holder(quirk_transfer = TRUE)
		quirk.add_to_holder(to_mob, quirk_transfer = TRUE, client_source = to_pass)
