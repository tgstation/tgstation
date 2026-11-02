// Ratwood's locksmithing (rogueitems/keys.dm, structures/mineral_doors.dm, crates_lockers/closets.dm,
// roguejobs/artificer/contraptions.dm): the lock hashes keys turn locks by, lockpicking by skill, custom keys and locks made
// from the artificer's blanks, and the lock imprinter.
//
// A key turns a lock when their lock hashes match. Every lock id gets one hash for the round, picked at random the first time
// the id is seen - by a key or by a lock. A custom key or lock set to a number gets the hash 10000 + the number, past every
// hash of the map's locks, so no number opens the church. Ratwood keeps a custom lock's id empty; here it gets the id
// "custom_<number>", and every copy (tracing a key, aligning a lock, the imprinter, fitting a lock) carries the id with the
// hash, so the checks by lock id that the chests and the merchants' machines still make agree with the hash.

/// Ratwood's ranges of a random lock hash: a key that sees its lock id first picks from the first, a lock from the second.
#define ROCKHILL_KEY_HASH_MIN 100
#define ROCKHILL_KEY_HASH_MAX 999
#define ROCKHILL_LOCK_HASH_MIN 1000
#define ROCKHILL_LOCK_HASH_MAX 9999
/// Random picks of a free hash before the next free number up is taken instead.
#define ROCKHILL_LOCK_HASH_TRIES 100
/// The hash of a custom key or lock is this plus its number (Ratwood customblank attackby()).
#define ROCKHILL_CUSTOM_LOCK_HASH 10000
/// The lock id of a custom key or lock is this and its number.
#define ROCKHILL_CUSTOM_LOCKID "custom_"
/// Highest number a custom key or lock can be set to (the cap of the number input).
#define ROCKHILL_CUSTOM_LOCK_MAX_NUMBER 9999
#define ROCKHILL_PICK_GOOD_SOUNDS list('modular_redtard/rockhill/sound/doors/pickgood1.ogg', 'modular_redtard/rockhill/sound/doors/pickgood2.ogg')
#define ROCKHILL_PICK_BAD_SOUND 'modular_redtard/rockhill/sound/doors/pickbad.ogg'
/// The lock imprinter's modes, which a hammer cycles (Ratwood hammer_action()).
#define ROCKHILL_IMPRINTER_EXAMINER "Examiner"
#define ROCKHILL_IMPRINTER_IMPRINTER "Imprinter"
#define ROCKHILL_IMPRINTER_UNLOCKER "Unlocker"
#define ROCKHILL_IMPRINTER_ON_STATE "imprinter_flick"
#define ROCKHILL_IMPRINTER_OFF_STATE "imprinter_off"
#define ROCKHILL_IMPRINTER_CLANG_SOUNDS list('modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/sheet (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/grille (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/grille (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/onmetal/grille (3).ogg')
#define ROCKHILL_IMPRINTER_THUD_SOUND 'modular_redtard/rockhill/sound/combat/hits/blunt/woodblunt (2).ogg'
#define ROCKHILL_IMPRINTER_CLOCK_SOUND 'modular_redtard/rockhill/sound/misc/clockloop.ogg'
#define ROCKHILL_IMPRINTER_BEEP_SOUND 'modular_redtard/rockhill/sound/misc/beep.ogg'

/// Ratwood GLOB.lockids: the hash of every lock id seen this round.
GLOBAL_LIST_EMPTY(rockhill_lockids)
/// Ratwood GLOB.lockhashes: every hash given out this round, as text keys, so that no two lock ids share one.
GLOBAL_LIST_EMPTY(rockhill_lockhashes)

/obj
	/// Ratwood lockhash: what a key must match to turn this lock, or what this key turns; 0 - none.
	var/lockhash = 0

/// The lock hash of a lock id: the one it got this round, or a new one picked at random from the range of a key or of a lock,
/// whichever sees the id first. Without an id it is a fresh hash that no key has.
/proc/rockhill_lock_hash(lockid, for_key = FALSE)
	if(lockid && GLOB.rockhill_lockids[lockid])
		return GLOB.rockhill_lockids[lockid]
	var/hash = for_key ? rockhill_free_lock_hash(ROCKHILL_KEY_HASH_MIN, ROCKHILL_KEY_HASH_MAX) : rockhill_free_lock_hash(ROCKHILL_LOCK_HASH_MIN, ROCKHILL_LOCK_HASH_MAX)
	if(lockid)
		GLOB.rockhill_lockids[lockid] = hash
	return hash

/// A hash no lock id has yet, taken for good: random in the range, or past a hundred taken picks the next free number up.
/proc/rockhill_free_lock_hash(low, high)
	var/hash = rand(low, high)
	var/tries = 0
	while(GLOB.rockhill_lockhashes["[hash]"])
		tries++
		hash = tries < ROCKHILL_LOCK_HASH_TRIES ? rand(low, high) : hash + 1
	GLOB.rockhill_lockhashes["[hash]"] = TRUE
	return hash

/// The hash of a custom key or lock set to this number; the number's lock id gets it too.
/proc/rockhill_custom_lock_hash(number)
	var/hash = ROCKHILL_CUSTOM_LOCK_HASH + number
	GLOB.rockhill_lockids["[ROCKHILL_CUSTOM_LOCKID][number]"] = hash
	GLOB.rockhill_lockhashes["[hash]"] = TRUE
	return hash

/// Whether this key - or a key on this ring - turns a lock of this hash (Ratwood trykeylock()): the same hash, or the lord's
/// master key where the master key works.
/proc/rockhill_key_turns(obj/item/key, lockhash, masterkey)
	if(istype(key, /obj/item/roguekey))
		var/obj/item/roguekey/door_key = key
		return (lockhash && door_key.lockhash == lockhash) || (masterkey && door_key.master_key)
	if(istype(key, /obj/item/storage/keyring))
		for(var/obj/item/ring_key in key)
			if(rockhill_key_turns(ring_key, lockhash, masterkey))
				return TRUE
	return FALSE

/// The key or ring in hand, worn, or in something worn that turns a lock of this hash (Ratwood find_key_for_door()).
/proc/rockhill_find_lock_key(mob/user, lockhash, masterkey)
	var/obj/item/held = user.get_active_held_item()
	if(held && rockhill_key_turns(held, lockhash, masterkey))
		return held
	for(var/obj/item/worn in user.get_equipped_items(INCLUDE_POCKETS))
		if(rockhill_key_turns(worn, lockhash, masterkey))
			return worn
		for(var/obj/item/inner in worn)
			if(rockhill_key_turns(inner, lockhash, masterkey))
				return inner
	return null

/// The lock id of this key or lock (Ratwood /obj lockid; here each kind of lock declares its own); null if it has none.
/obj/proc/rockhill_lockid()
	return null

/// Gives this key or lock a lock id and hash, as Ratwood's imprinter and custom locks do; FALSE if it takes no lock.
/obj/proc/rockhill_set_lock(new_lockid, new_lockhash)
	return FALSE

/obj/item/rockhill_lockid()
	return lockid

/obj/item/rockhill_set_lock(new_lockid, new_lockhash)
	lockid = new_lockid
	lockhash = new_lockhash
	return TRUE

/obj/structure/mineral_door/rockhill/rockhill_lockid()
	return lockid

/obj/structure/mineral_door/rockhill/rockhill_set_lock(new_lockid, new_lockhash)
	lockid = new_lockid
	lockhash = new_lockhash
	return TRUE

/obj/structure/closet/crate/wooden/rockhill/rockhill_lockid()
	return lockid

/obj/structure/closet/crate/wooden/rockhill/rockhill_set_lock(new_lockid, new_lockhash)
	lockid = new_lockid
	lockhash = new_lockhash
	return TRUE

/// Sets a custom key or lock to a number (Ratwood customblank and customlock attackby() with a hammer).
/obj/item/proc/rockhill_set_custom_lock(number)
	rockhill_set_lock("[ROCKHILL_CUSTOM_LOCKID][number]", rockhill_custom_lock_hash(number))

/// Asks for the number of a custom key or lock while its maker holds the hammer.
/obj/item/proc/rockhill_ask_lock_number(mob/living/user, obj/item/hammer, what)
	var/number = tgui_input_number(user, "What would you like to set the [what] ID to?", "[capitalize(what)] ID", 0, ROCKHILL_CUSTOM_LOCK_MAX_NUMBER, 0)
	if(isnull(number) || QDELETED(src) || QDELETED(hammer) || !user.is_holding(hammer) || !user.can_perform_action(src))
		return
	rockhill_set_custom_lock(number)
	to_chat(user, span_notice("I set the [what] ID to [number]."))

// --- Keys and chests

/obj/item/roguekey
	/// A custom key finished from a blank (Ratwood /obj/item/roguekey/custom, which the porter has not brought): a hammer
	/// renames it.
	var/rockhill_custom = FALSE

/// Ratwood roguekey Initialize(): a key of a lock id turns every lock of that id.
/obj/item/roguekey/Initialize(mapload)
	. = ..()
	if(lockid && !lockhash)
		lockhash = rockhill_lock_hash(lockid, TRUE)

/// Ratwood roguekey/custom attackby(): a hammer renames a custom key.
/obj/item/roguekey/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rockhill_custom || !istype(tool, /obj/item/rogueweapon/hammer))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rename_custom), user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/roguekey/proc/rename_custom(mob/living/user, obj/item/hammer)
	var/new_name = tgui_input_text(user, "What would you name this key?", "Key", max_length = MAX_NAME_LEN)
	if(!new_name || QDELETED(src) || QDELETED(hammer) || !user.is_holding(hammer) || !user.can_perform_action(src))
		return
	name = "[new_name] key"
	to_chat(user, span_notice("I rename the key to [name]."))

/// Ratwood closet Initialize(): a chest with a lock gets the hash of its lock id.
/obj/structure/closet/crate/wooden/rockhill/Initialize(mapload)
	. = ..()
	if(keylock && !lockhash)
		lockhash = rockhill_lock_hash(lockid)

// --- Lockpicking

/// Deciseconds of one try at a lock (Ratwood trypicklock() picktime): 70, 10 less a rank of Lockpicking, at least 10; a hard
/// lock adds 10 a level of its difficulty.
/proc/rockhill_pick_time(mob/living/user, lockdifficulty)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/misc/lockpicking)
	var/pick_time = clamp(rogue_value("lockpick_time") - rank * rogue_value("lockpick_time_per_rank"), rogue_value("lockpick_time_min"), rogue_value("lockpick_time"))
	if(lockdifficulty > 1)
		pick_time += lockdifficulty * rogue_value("lockpick_difficulty_time")
	return pick_time

/// Percent chance of one try to move the pins (Ratwood pickchance): 35, 10 a rank, a fifth of perception, all times the
/// pick's level, at most 95; a hard lock divides it by three quarters of its difficulty.
/proc/rockhill_pick_chance(mob/living/user, obj/item/lockpick, lockdifficulty)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/misc/lockpicking)
	var/chance = rogue_value("lockpick_chance") + rank * rogue_value("lockpick_chance_per_rank") + user.rogue_stat(ROGUE_STAT_PERCEPTION) / rogue_value("lockpick_perception_divisor")
	chance = clamp(chance * lockpick.picklvl, 1, rogue_value("lockpick_chance_max"))
	if(lockdifficulty > 1)
		chance /= lockdifficulty * rogue_value("lockpick_difficulty_chance_factor")
	return chance

/// How far one good try moves the lock (Ratwood moveup): 10, 3 more a rank, at most 30.
/proc/rockhill_pick_step(mob/living/user)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/misc/lockpicking)
	return clamp(rogue_value("lockpick_progress") + rank * rogue_value("lockpick_progress_per_rank"), rogue_value("lockpick_progress"), rogue_value("lockpick_progress_max"))

/// Ratwood trypicklock() of doors and chests: tries at the lock, a do_after each, until its strength is worked through or the
/// picker stops. Each good try teaches Lockpicking by intelligence, a failed one teaches half as much and wears the pick; too
/// poor a pick cannot work a hard lock at all. TRUE when the lock gives.
/proc/rockhill_try_pick(mob/living/user, obj/item/lockpick, atom/lock_holder, lockdifficulty, lock_strength)
	if(lockdifficulty > 2 && lockpick.picklvl < 1)
		to_chat(user, span_warning("My lockpick is too poor to handle this lock."))
		playsound(lock_holder, ROCKHILL_PICK_BAD_SOUND, 40, TRUE)
		lockpick.take_damage(1, BRUTE, MELEE)
		to_chat(user, span_warning("Clack."))
		return FALSE
	var/pick_time = rockhill_pick_time(user, lockdifficulty)
	var/chance = rockhill_pick_chance(user, lockpick, lockdifficulty)
	var/pick_step = rockhill_pick_step(user)
	var/progress = 0
	user.log_message("started picking the lock of [lock_holder].", LOG_ATTACK)
	while(progress < lock_strength)
		if(!do_after(user, pick_time, lock_holder) || QDELETED(lockpick) || !user.is_holding(lockpick))
			user.log_message("stopped picking the lock of [lock_holder].", LOG_ATTACK)
			return FALSE
		if(prob(chance))
			progress += pick_step
			playsound(lock_holder, pick(ROCKHILL_PICK_GOOD_SOUNDS), 5, TRUE)
			to_chat(user, span_warning("Click..."))
			user.rogue_craft_experience(/datum/attribute/skill/misc/lockpicking, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * rogue_value("lockpick_click_xp"))
			continue
		playsound(lock_holder, ROCKHILL_PICK_BAD_SOUND, 40, TRUE)
		to_chat(user, span_warning("Clack."))
		user.rogue_craft_experience(/datum/attribute/skill/misc/lockpicking, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * rogue_value("lockpick_clack_xp"))
		lockpick.take_damage(1, BRUTE, MELEE)
	to_chat(user, span_notice("The locking mechanism gives."))
	user.log_message("lockpicked [lock_holder].", LOG_ATTACK)
	return TRUE

// --- Custom keys and locks

/// Ratwood customblank attackby(): a hammer sets the number of the key's teeth.
/obj/item/customblank/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/rogueweapon/hammer))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rockhill_ask_lock_number), user, tool, "key")
	return ITEM_INTERACT_SUCCESS

/// Ratwood customblank attack_right(): the teeth of a key held in the other hand are traced onto the blank, or the blank is
/// fine-tuned to a lock held; a hammer then finishes it into a key.
/obj/item/customblank/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/roguekey))
		rockhill_set_lock(tool.lockid, tool.lockhash)
		to_chat(user, span_notice("I trace the teeth from [tool] to [src]."))
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/customlock))
		rockhill_set_lock(tool.lockid, tool.lockhash)
		to_chat(user, span_notice("I fine-tune [src] to the lock's internals."))
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/rogueweapon/hammer))
		return NONE
	if(!lockhash)
		to_chat(user, span_warning("[src] has no teeth to finish yet."))
		return ITEM_INTERACT_BLOCKING
	finish_key(user)
	return ITEM_INTERACT_SUCCESS

/// The blank becomes a custom key of its teeth (Ratwood /obj/item/roguekey/custom: until the porter brings that type, a plain
/// key with the custom key's name and look).
/obj/item/customblank/proc/finish_key(mob/living/user)
	var/obj/item/roguekey/key = new(drop_location())
	key.name = "custom key"
	key.desc = "A custom key designed by a blacksmith."
	key.icon_state = "brownkey"
	key.rockhill_custom = TRUE
	key.rockhill_set_lock(lockid, lockhash)
	var/held = user.is_holding(src)
	to_chat(user, span_notice("I finish [key]."))
	qdel(src)
	if(held)
		user.put_in_hands(key)
	return key

/obj/item/customlock
	/// Ratwood /obj/item/customlock/finished, which the porter has not brought: a finished lock fits a door or a chest.
	var/rockhill_finished = FALSE
	/// Ratwood holdname: the label a hammer marks a finished lock with, which the door or chest it is fitted to takes on.
	var/rockhill_label

/// Ratwood customlock attackby(): a hammer sets the number of the lock's pins, or labels a finished lock; a key or a blank tried
/// in it twists cleanly or jams.
/obj/item/customlock/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/rogueweapon/hammer))
		if(rockhill_finished)
			INVOKE_ASYNC(src, PROC_REF(ask_label), user, tool)
		else
			INVOKE_ASYNC(src, PROC_REF(rockhill_ask_lock_number), user, tool, "lock")
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/roguekey) && !istype(tool, /obj/item/customblank))
		return ..()
	if(tool.lockhash == lockhash)
		to_chat(user, span_notice("[tool] twists cleanly in [src]."))
	else
		to_chat(user, span_warning("[tool] jams in [src]."))
	return ITEM_INTERACT_SUCCESS

/// Ratwood customlock attack_right(): an unfinished lock's pins are aligned to a key or blank held in the other hand; a hammer
/// then finishes it. A finished lock does nothing.
/obj/item/customlock/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(rockhill_finished)
		return NONE
	if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/customblank))
		rockhill_set_lock(tool.lockid, tool.lockhash)
		to_chat(user, span_notice("I align the lock's internals to [tool]."))
		return ITEM_INTERACT_SUCCESS
	if(!istype(tool, /obj/item/rogueweapon/hammer))
		return NONE
	if(!lockhash)
		to_chat(user, span_warning("[src] has no pins set to finish yet."))
		return ITEM_INTERACT_BLOCKING
	finish_lock(user)
	return ITEM_INTERACT_SUCCESS

/obj/item/customlock/proc/finish_lock(mob/living/user)
	rockhill_finished = TRUE
	name = "lock"
	desc = "A customized iron lock that is used by keys."
	to_chat(user, span_notice("I finish [src]."))

/obj/item/customlock/proc/ask_label(mob/living/user, obj/item/hammer)
	var/label = tgui_input_text(user, "What would you like to name this?", "Lock", max_length = MAX_NAME_LEN)
	if(!label || QDELETED(src) || QDELETED(hammer) || !user.is_holding(hammer) || !user.can_perform_action(src))
		return
	rockhill_label = label
	to_chat(user, span_notice("I label [src] with [label]."))

/// Ratwood customlock/finished attack_obj(): a finished lock is fitted to a door or a chest without a lock, which then opens to
/// the keys of its pins and takes its label.
/obj/item/customlock/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!rockhill_finished || !(istype(interacting_with, /obj/structure/mineral_door/rockhill) || istype(interacting_with, /obj/structure/closet/crate/wooden/rockhill)))
		return NONE
	fit_to(user, interacting_with)
	return ITEM_INTERACT_SUCCESS

/obj/item/customlock/proc/fit_to(mob/living/user, obj/structure/target)
	if(istype(target, /obj/structure/mineral_door/rockhill))
		var/obj/structure/mineral_door/rockhill/door = target
		if(door.keylock)
			to_chat(user, span_warning("[door] already has a lock."))
			return FALSE
		door.keylock = TRUE
		door.lock_strength = rogue_value("custom_lock_strength")
		if(rockhill_label)
			door.name = rockhill_label
	else if(istype(target, /obj/structure/closet/crate/wooden/rockhill))
		var/obj/structure/closet/crate/wooden/rockhill/chest = target
		if(chest.keylock)
			to_chat(user, span_warning("[chest] already has a lock."))
			return FALSE
		chest.keylock = TRUE
		chest.lock_strength = rogue_value("custom_lock_strength")
		if(rockhill_label)
			chest.name = "[rockhill_label] [chest.name]"
	else
		return FALSE
	target.rockhill_set_lock(lockid, lockhash)
	to_chat(user, span_notice("I add [src] to [target]."))
	user.log_message("fitted a custom lock ([lockid]) to [target].", LOG_GAME)
	qdel(src)
	return TRUE

// --- The lock imprinter

/obj/item/contraption
	/// Ratwood current_charge: uses left from the power source put in the contraption.
	var/current_charge = 0

/// Ratwood's lock imprinter (contraptions.dm): an unfinished lock put in powers it for four uses. A key put in gives it the
/// key's lock; a hammer turns it between Examiner (reads a lock's id), Imprinter (gives a door or chest the stored lock, which
/// teaches engineering) and Unlocker (turns a lock without its key). Ratwood also lets it work the steward's and merchants'
/// machines; here it works doors and chests.
/obj/item/contraption/lock_imprinter
	/// Ratwood stored_lock_id and stored_lock_hash: the lock it imprints, from the last key put in it.
	var/stored_lockid = "artificer"
	var/stored_lockhash = 0
	var/mode = ROCKHILL_IMPRINTER_EXAMINER

/obj/item/contraption/lock_imprinter/Initialize(mapload)
	. = ..()
	stored_lockhash = rockhill_lock_hash(stored_lockid)

/obj/item/contraption/lock_imprinter/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/viewer = user
	if(current_charge)
		. += span_warning("The contraption has [current_charge] charges left.")
	else
		. += span_warning("This contraption requires a new unfinished lock to function.")
	var/rank = viewer.rogue_skill_rank(/datum/attribute/skill/craft/engineering)
	if(rank < rogue_value("imprinter_mode_rank"))
		return
	. += span_warning("[src] is currently in [mode] mode.")
	if(rank < rogue_value("imprinter_lockid_rank"))
		. += span_warning("I cannot yet fully understand this contraption.")
		return
	. += span_warning(stored_lockid ? "The current stored lock ID is [stored_lockid]." : "There is no stored lock ID.")

/obj/item/contraption/lock_imprinter/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/customlock))
		insert_power(user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/roguekey))
		store_key(user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/rogueweapon/hammer))
		cycle_mode(user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/contraption/lock_imprinter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isstructure(interacting_with))
		return NONE
	if(!current_charge)
		flick(ROCKHILL_IMPRINTER_OFF_STATE, src)
		to_chat(user, span_info("The contraption beeps! It requires an unfinished lock!"))
		playsound(src, ROCKHILL_IMPRINTER_BEEP_SOUND, 100, TRUE)
		return ITEM_INTERACT_BLOCKING
	var/obj/structure/target = interacting_with
	if(!istype(target, /obj/structure/mineral_door/rockhill) && !istype(target, /obj/structure/closet/crate/wooden/rockhill))
		to_chat(user, span_info("[src] refuses to function."))
		playsound(user, 'modular_redtard/rockhill/sound/items/flint.ogg', 100, FALSE)
		flick(ROCKHILL_IMPRINTER_OFF_STATE, src)
		do_sparks(1, TRUE, get_turf(target))
		return ITEM_INTERACT_BLOCKING
	switch(mode)
		if(ROCKHILL_IMPRINTER_EXAMINER)
			examine_lock(user, target)
		if(ROCKHILL_IMPRINTER_IMPRINTER)
			imprint_lock(user, target)
		if(ROCKHILL_IMPRINTER_UNLOCKER)
			turn_lock(user, target)
	return ITEM_INTERACT_SUCCESS

/// Ratwood attackby() with the power source: an unfinished lock gives the imprinter its uses, if none is in it yet.
/obj/item/contraption/lock_imprinter/proc/insert_power(mob/living/user, obj/item/customlock/lock)
	user.changeNext_move(CLICK_CD_MELEE)
	do_sparks(1, TRUE, get_turf(src))
	playsound(src, ROCKHILL_IMPRINTER_THUD_SOUND, 100, TRUE)
	if(current_charge)
		to_chat(user, span_info("I try to insert [lock] but there's already an unfinished lock inside!"))
		shake_camera(user, 1, 1)
		return FALSE
	to_chat(user, span_info("I insert [lock] and [src] starts ticking."))
	current_charge = rogue_value("imprinter_charges")
	qdel(lock)
	addtimer(CALLBACK(src, PROC_REF(tick_sound)), 0.5 SECONDS)
	return TRUE

/// Ratwood attackby() with a key: the imprinter takes in the key's lock.
/obj/item/contraption/lock_imprinter/proc/store_key(mob/living/user, obj/item/roguekey/key)
	user.changeNext_move(CLICK_CD_MELEE)
	flick(ROCKHILL_IMPRINTER_OFF_STATE, src)
	playsound(user, 'modular_redtard/rockhill/sound/doors/unlock.ogg', 100, TRUE)
	do_sparks(1, TRUE, get_turf(src))
	stored_lockid = key.lockid
	stored_lockhash = key.lockhash
	user.visible_message(span_notice("[user] inserts [key] into [src] and it starts ticking..."))
	addtimer(CALLBACK(src, PROC_REF(tick_sound)), 0.5 SECONDS)

/// Ratwood hammer_action(): a blow of a hammer turns it to its next mode.
/obj/item/contraption/lock_imprinter/proc/cycle_mode(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	flick(ROCKHILL_IMPRINTER_OFF_STATE, src)
	user.visible_message(span_info("[user] beats [src] into submission!"))
	playsound(src, pick(ROCKHILL_IMPRINTER_CLANG_SOUNDS), 100, TRUE)
	shake_camera(user, 1, 1)
	do_sparks(1, TRUE, get_turf(src))
	switch(mode)
		if(ROCKHILL_IMPRINTER_EXAMINER)
			mode = ROCKHILL_IMPRINTER_IMPRINTER
		if(ROCKHILL_IMPRINTER_IMPRINTER)
			mode = ROCKHILL_IMPRINTER_UNLOCKER
		else
			mode = ROCKHILL_IMPRINTER_EXAMINER

/obj/item/contraption/lock_imprinter/proc/examine_lock(mob/living/user, obj/structure/target)
	var/target_lockid = target.rockhill_lockid()
	if(target_lockid)
		to_chat(user, span_warning("[src] identifies this lock's ID as [target_lockid]."))
	else
		to_chat(user, span_warning("[src] identifies an absence of a lock or lock ID."))
	playsound(src, ROCKHILL_IMPRINTER_BEEP_SOUND, 50, TRUE)
	flick(ROCKHILL_IMPRINTER_OFF_STATE, src)

/// Gives the door or chest the stored lock - its id and hash, not a keyhole it lacks (Ratwood leaves keylock as it is).
/obj/item/contraption/lock_imprinter/proc/imprint_lock(mob/living/user, obj/structure/target)
	target.rockhill_set_lock(stored_lockid, stored_lockhash)
	flick(ROCKHILL_IMPRINTER_ON_STATE, src)
	shake_camera(user, 1, 1)
	user.visible_message(span_notice("[user] holds [src] up to [target], causing sparks to fly!"))
	playsound(src, pick(ROCKHILL_IMPRINTER_CLANG_SOUNDS), 100, TRUE)
	do_sparks(1, TRUE, get_turf(target))
	spend_charge(user)
	user.rogue_craft_experience(/datum/attribute/skill/craft/engineering, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * rogue_value("imprinter_xp"))
	user.log_message("imprinted the lock of [target] with [stored_lockid || "no lock ID"] at [AREACOORD(target)].", LOG_GAME)

/// Locks or unlocks the door or chest without its key; a door or chest must be shut for it.
/obj/item/contraption/lock_imprinter/proc/turn_lock(mob/living/user, obj/structure/target)
	var/now_locked
	if(istype(target, /obj/structure/mineral_door/rockhill))
		var/obj/structure/mineral_door/rockhill/door = target
		if(door.door_opened || door.isSwitchingStates)
			to_chat(user, span_warning("[door] must be shut first."))
			return
		door.locked = !door.locked
		door.relock = FALSE
		now_locked = door.locked
	else
		var/obj/structure/closet/crate/wooden/rockhill/chest = target
		if(chest.opened)
			to_chat(user, span_warning("[chest] must be shut first."))
			return
		chest.locked = !chest.locked
		chest.update_appearance()
		now_locked = chest.locked
	playsound(user, now_locked ? 'modular_redtard/rockhill/sound/doors/lock.ogg' : 'modular_redtard/rockhill/sound/doors/unlock.ogg', 100, TRUE)
	playsound(user, 'modular_redtard/rockhill/sound/doors/lockrattlemetal.ogg', 100, TRUE)
	user.visible_message(span_notice("[user] holds [src] up to [target], causing sparks to fly!"))
	do_sparks(1, TRUE, get_turf(target))
	var/start_x = target.pixel_x
	animate(target, pixel_x = start_x + 1, time = 0.5)
	animate(pixel_x = start_x - 1, time = 0.5)
	animate(pixel_x = start_x, time = 0.5)
	flick(ROCKHILL_IMPRINTER_ON_STATE, src)
	spend_charge(user)
	user.log_message("[now_locked ? "locked" : "unlocked"] [target] with [src] at [AREACOORD(target)].", LOG_GAME)

/// Ratwood charge_deduction(): a use is spent; the last one wastes the lock inside away.
/obj/item/contraption/lock_imprinter/proc/spend_charge(mob/living/user)
	current_charge = max(current_charge - 1, 0)
	if(!current_charge)
		addtimer(CALLBACK(src, PROC_REF(power_spent), user), 0.5 SECONDS)

/// Ratwood battery_collapse().
/obj/item/contraption/lock_imprinter/proc/power_spent(mob/living/user)
	if(!QDELETED(user))
		to_chat(user, span_info("The unfinished lock wastes away into nothing."))
		shake_camera(user, 1, 1)
	playsound(src, pick(ROCKHILL_IMPRINTER_CLANG_SOUNDS), 100, FALSE)
	do_sparks(1, TRUE, get_turf(src))

/obj/item/contraption/lock_imprinter/proc/tick_sound()
	playsound(src, ROCKHILL_IMPRINTER_CLOCK_SOUND, 25, TRUE)

#undef ROCKHILL_KEY_HASH_MIN
#undef ROCKHILL_KEY_HASH_MAX
#undef ROCKHILL_LOCK_HASH_MIN
#undef ROCKHILL_LOCK_HASH_MAX
#undef ROCKHILL_LOCK_HASH_TRIES
#undef ROCKHILL_CUSTOM_LOCK_HASH
#undef ROCKHILL_CUSTOM_LOCKID
#undef ROCKHILL_CUSTOM_LOCK_MAX_NUMBER
#undef ROCKHILL_PICK_GOOD_SOUNDS
#undef ROCKHILL_PICK_BAD_SOUND
#undef ROCKHILL_IMPRINTER_EXAMINER
#undef ROCKHILL_IMPRINTER_IMPRINTER
#undef ROCKHILL_IMPRINTER_UNLOCKER
#undef ROCKHILL_IMPRINTER_ON_STATE
#undef ROCKHILL_IMPRINTER_OFF_STATE
#undef ROCKHILL_IMPRINTER_CLANG_SOUNDS
#undef ROCKHILL_IMPRINTER_THUD_SOUND
#undef ROCKHILL_IMPRINTER_CLOCK_SOUND
#undef ROCKHILL_IMPRINTER_BEEP_SOUND
