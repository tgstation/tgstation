/**
 * # Nuclear Bomb Operator
 *
 * Component applied to handless non-carbon mobs to allow them to perform the function of a nuclear operative.
 * Effectively this means they need to be able to:
 * * Strip people
 * * Pick up the nuke disc, without having hands
 * * Place the nuke disc into the nuke
 * * Activate the nuke
 *
 * Human mobs do not need this component because they can already do all of those things.
 */
/datum/component/nuclear_bomb_operator
	/// A weak reference to a held nuclear disk, in place of holding it in our inventory, because we don't have one
	var/datum/weakref/disky
	/// Something to call when we collect the disk
	var/datum/callback/on_disk_collected
	/// Should return some overlays to display on the mob to show they're carrying a disk
	var/datum/callback/add_disk_overlays

/datum/component/nuclear_bomb_operator/Initialize(datum/callback/on_disk_collected, datum/callback/add_disk_overlays)
	if (!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if (iscarbon(parent)) // Redundant
		return COMPONENT_INCOMPATIBLE

	src.on_disk_collected = on_disk_collected
	src.add_disk_overlays = add_disk_overlays

/datum/component/nuclear_bomb_operator/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignals(parent, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(owner_attacked_atom)) // This only works for players, but I am not sure this should have AI anyway
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(atom_exited_owner))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	ADD_TRAIT(parent, TRAIT_DISK_VERIFIER, NUKE_OP_MINION_TRAIT) // Can identify the real disk
	ADD_TRAIT(parent, TRAIT_CAN_STRIP, NUKE_OP_MINION_TRAIT) // Can take the disk off people
	ADD_TRAIT(parent, TRAIT_CAN_USE_NUKE, NUKE_OP_MINION_TRAIT) // Can put the disk into the bomb

/datum/component/nuclear_bomb_operator/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_LIVING_DEATH,
		COMSIG_PARENT_QDELETING,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_UPDATE_OVERLAYS,
	))
	REMOVE_TRAIT(parent, TRAIT_DISK_VERIFIER, NUKE_OP_MINION_TRAIT)
	REMOVE_TRAIT(parent, TRAIT_CAN_STRIP, NUKE_OP_MINION_TRAIT)
	REMOVE_TRAIT(parent, TRAIT_CAN_USE_NUKE, NUKE_OP_MINION_TRAIT)

/datum/component/nuclear_bomb_operator/Destroy(force, silent)
	QDEL_NULL(disky)
	return ..()

/// Drop the disk on the floor, if we have it
/datum/component/nuclear_bomb_operator/proc/drop_disky()
	var/obj/item/disk/nuclear/held_disk = disky?.resolve()
	if (!held_disk)
		return
	var/mob/mob_parent = parent
	held_disk.forceMove(mob_parent.drop_location())
	mob_parent.visible_message(span_danger("[mob_parent] drops [held_disk] onto the ground!"))
	disky = null
	mob_parent.update_appearance(updates = UPDATE_ICON)

/// Add details about carrying the nuke disc to examination.
/datum/component/nuclear_bomb_operator/proc/on_examine(atom/parent_atom, mob/examiner, list/examine_list)
	SIGNAL_HANDLER
	var/obj/item/disk/nuclear/held_disk = disky?.resolve()
	if (!held_disk)
		return
	var/mob/mob_parent = parent
	examine_list += span_notice("Wait... [mob_parent.p_are()] [mob_parent.p_they()] holding [held_disk]?")

/// Drop the disk when we are killed
/datum/component/nuclear_bomb_operator/proc/on_death(atom/parent_atom)
	SIGNAL_HANDLER
	drop_disky()

/// Try to pick up the disk, put it down, or open the nuke panel
/datum/component/nuclear_bomb_operator/proc/owner_attacked_atom(atom/parent_atom, atom/attacked_target, proximity, modifiers)
	SIGNAL_HANDLER
	if (!proximity)
		return
	if (!LAZYACCESS(modifiers, LEFT_CLICK))
		return
	var/obj/item/disk/nuclear/held_disk = disky?.resolve()
	if (held_disk)
		return try_put_down_disk(held_disk, attacked_target)

	if (istype(attacked_target, /obj/item/disk/nuclear))
		return try_pick_up_disk(attacked_target)

	if (istype(attacked_target, /obj/machinery/nuclearbomb))
		attacked_target.ui_interact(parent)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/// Picks up the nuke disk, if it can be picked up
/datum/component/nuclear_bomb_operator/proc/try_pick_up_disk(obj/item/disk/nuclear/potential_disky)
	if(potential_disky.anchored)
		return
	var/mob/mob_parent = parent
	potential_disky.forceMove(mob_parent)
	disky = WEAKREF(potential_disky)
	mob_parent.update_appearance(updates = UPDATE_ICON)
	mob_parent.balloon_alert(mob_parent, "disk secured!")
	on_disk_collected?.InvokeAsync(potential_disky)

/// Uses the disk on clicked atom, or places it on the ground
/datum/component/nuclear_bomb_operator/proc/try_put_down_disk(obj/item/disk/nuclear/held_disk, atom/attacked_target)
	var/mob/mob_parent = parent
	if(!isopenturf(attacked_target))
		INVOKE_ASYNC(held_disk, TYPE_PROC_REF(/obj/item, melee_attack_chain), mob_parent, attacked_target)
		mob_parent.do_item_attack_animation(attacked_target, used_item = held_disk)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	held_disk.forceMove(attacked_target)
	disky = null
	mob_parent.balloon_alert(mob_parent, "disk dropped!")
	mob_parent.update_appearance(updates = UPDATE_ICON)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Don't hold onto the reference if we lose the disk somehow
/datum/component/nuclear_bomb_operator/proc/atom_exited_owner(atom/parent_atom, atom/movable/gone)
	SIGNAL_HANDLER
	var/obj/item/disk/nuclear/held_disk = disky?.resolve()
	if (held_disk != gone)
		return
	disky = null
	var/mob/mob_parent = parent
	mob_parent.update_appearance(updates = UPDATE_ICON)

/// Display any disk-related overlays which need displaying
/datum/component/nuclear_bomb_operator/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER
	if (!disky?.resolve())
		return
	var/mob/mob_parent = parent
	if (!istype(mob_parent) || mob_parent.stat == DEAD)
		return
	add_disk_overlays?.InvokeAsync(overlays)
