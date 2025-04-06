/**
 * Common behaviour shared by things which are minions to a blob
 */
/datum/component/blob_minion
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Overmind who is our boss
	var/mob/eye/blob/overmind
	/// Callback to run if overmind strain changes
	var/datum/callback/on_strain_changed

/datum/component/blob_minion/Initialize(mob/eye/blob/overmind, datum/callback/on_strain_changed)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.on_strain_changed = on_strain_changed
	register_overlord(overmind)

/datum/component/blob_minion/InheritComponent(datum/component/new_comp, i_am_original, mob/eye/blob/overmind, datum/callback/on_strain_changed)
	if (!isnull(on_strain_changed))
		src.on_strain_changed = on_strain_changed
	register_overlord(overmind)

/datum/component/blob_minion/proc/register_overlord(mob/eye/blob/overmind)
	if (isnull(overmind))
		return
	src.overmind = overmind
	overmind.register_new_minion(parent)
	RegisterSignal(overmind, COMSIG_QDELETING, PROC_REF(overmind_deleted))
	RegisterSignal(overmind, COMSIG_BLOB_SELECTED_STRAIN, PROC_REF(overmind_properties_changed))
	overmind_properties_changed(overmind, overmind.blobstrain)

/// Our overmind is gone, uh oh!
/datum/component/blob_minion/proc/overmind_deleted()
	SIGNAL_HANDLER
	overmind = null
	overmind_properties_changed()

/// Our overmind has changed colour and properties
/datum/component/blob_minion/proc/overmind_properties_changed(mob/eye/blob/overmind, datum/blobstrain/new_strain)
	SIGNAL_HANDLER
	var/mob/living/living_parent = parent
	living_parent.update_appearance(UPDATE_ICON)
	on_strain_changed?.Invoke(overmind, new_strain)

/datum/component/blob_minion/RegisterWithParent()
	var/mob/living/living_parent = parent
	living_parent.pass_flags |= PASSBLOB
	living_parent.faction |= ROLE_BLOB
	ADD_TRAIT(parent, TRAIT_BLOB_ALLY, REF(src))
	remove_verb(parent, /mob/living/verb/pulled) // No dragging people into the blob
	RegisterSignal(parent, COMSIG_MOB_MIND_INITIALIZED, PROC_REF(on_mind_init))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(on_update_appearance))
	RegisterSignal(parent, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(on_update_status_tab))
	RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, PROC_REF(on_blob_touched))
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, PROC_REF(on_burned))
	RegisterSignal(parent, COMSIG_ATOM_TRIED_PASS, PROC_REF(on_attempted_pass))
	RegisterSignal(parent, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(on_space_move))
	RegisterSignal(parent, COMSIG_MOB_TRY_SPEECH, PROC_REF(on_try_speech))
	RegisterSignal(parent, COMSIG_MOB_CHANGED_TYPE, PROC_REF(on_transformed))
	living_parent.update_appearance(UPDATE_ICON)
	GLOB.blob_telepathy_mobs |= parent

/datum/component/blob_minion/UnregisterFromParent()
	if (!isnull(overmind))
		overmind.blob_mobs -= parent
	var/mob/living/living_parent = parent
	living_parent.pass_flags &= ~PASSBLOB
	living_parent.faction -= ROLE_BLOB
	REMOVE_TRAIT(parent, TRAIT_BLOB_ALLY, REF(src))
	add_verb(parent, /mob/living/verb/pulled)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_ATOM_TRIED_PASS,
		COMSIG_ATOM_UPDATE_ICON,
		COMSIG_MOB_TRY_SPEECH,
		COMSIG_MOB_CHANGED_TYPE,
		COMSIG_MOB_GET_STATUS_TAB_ITEMS,
		COMSIG_MOB_MIND_INITIALIZED,
		COMSIG_MOVABLE_SPACEMOVE,
	))
	GLOB.blob_telepathy_mobs -= parent

/// Become blobpilled when we gain a mind
/datum/component/blob_minion/proc/on_mind_init(mob/living/minion, datum/mind/new_mind)
	SIGNAL_HANDLER
	if (isnull(overmind))
		return
	var/datum/antagonist/blob_minion/minion_motive = new(overmind)
	new_mind.add_antag_datum(minion_motive)

/// When our icon is updated, update our colour too
/datum/component/blob_minion/proc/on_update_appearance(mob/living/minion)
	SIGNAL_HANDLER
	if(isnull(overmind))
		minion.remove_atom_colour(FIXED_COLOUR_PRIORITY)
		return
	minion.add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)

/// When our icon is updated, update our colour too
/datum/component/blob_minion/proc/on_update_status_tab(mob/living/minion, list/status_items)
	SIGNAL_HANDLER
	if (isnull(overmind))
		return
	status_items += "Blobs to Win: [length(overmind.blobs_legit)]/[overmind.blobwincount]"

/// If we feel the gentle caress of a blob, we feel better
/datum/component/blob_minion/proc/on_blob_touched(mob/living/minion)
	SIGNAL_HANDLER
	if(minion.stat == DEAD || minion.health >= minion.maxHealth)
		return COMPONENT_CANCEL_BLOB_ACT // Don't hurt us in order to heal us
	for(var/i in 1 to 2)
		var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(parent)) // hello yes you are being healed
		heal_effect.color = isnull(overmind) ? COLOR_BLACK : overmind.blobstrain.complementary_color
	minion.heal_overall_damage(minion.maxHealth * BLOBMOB_HEALING_MULTIPLIER)
	return COMPONENT_CANCEL_BLOB_ACT

/// If we feel the fearsome bite of open flame, we feel worse
/datum/component/blob_minion/proc/on_burned(mob/living/minion, exposed_temperature, exposed_volume)
	SIGNAL_HANDLER
	if(isnull(exposed_temperature))
		minion.adjustFireLoss(5)
		return
	minion.adjustFireLoss(clamp(0.01 * exposed_temperature, 1, 5))

/// Someone is attempting to move through us, allow it if it is a blob tile
/datum/component/blob_minion/proc/on_attempted_pass(mob/living/minion, atom/movable/incoming)
	SIGNAL_HANDLER
	if(istype(incoming, /obj/structure/blob))
		return COMSIG_COMPONENT_PERMIT_PASSAGE

/// If we're near a blob, stop drifting
/datum/component/blob_minion/proc/on_space_move(mob/living/minion)
	SIGNAL_HANDLER
	var/obj/structure/blob/blob_handhold = locate() in range(1, parent)
	if (!isnull(blob_handhold))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/// We only speak telepathically to blobs
/datum/component/blob_minion/proc/on_try_speech(mob/living/minion, message, ignore_spam, forced)
	SIGNAL_HANDLER
	minion.log_talk(message, LOG_SAY, tag = "blob hivemind telepathy")
	var/spanned_message = minion.say_quote(message)
	var/rendered = span_blob("<b>\[Blob Telepathy\] [minion.real_name]</b> [spanned_message]")
	relay_to_list_and_observers(rendered, GLOB.blob_telepathy_mobs, minion)
	return COMPONENT_CANNOT_SPEAK

/// Called when a blob minion is transformed into something else, hopefully a spore into a zombie
/datum/component/blob_minion/proc/on_transformed(mob/living/minion, mob/living/replacement)
	SIGNAL_HANDLER
	overmind?.assume_direct_control(replacement)

/datum/component/blob_minion/PostTransfer(datum/new_parent)
	if(!isliving(new_parent))
		return COMPONENT_INCOMPATIBLE
