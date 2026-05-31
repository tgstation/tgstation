// Action that toggles flight onto the mob.
/datum/action/item_action/toggle_flight
	name = "Activate Flight Jets"
	desc = "Activates the jet boot's miniturized rocket thrusters, allowing for sustained flight."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/item_action/toggle_flight/Grant(mob/grant_to)
	. = ..()
	grant_to.AddComponent( \
		/datum/component/jetpack, \
		FALSE, \
		1.5 NEWTONS, \
		COMSIG_JETBOOTS_ACTIVE, \
		COMSIG_JETBOOTS_INACTIVE, \
		null, \
		CALLBACK(src, PROC_REF(can_fly)), \
		CALLBACK(src, PROC_REF(can_fly)), \
	)

/datum/action/item_action/toggle_flight/do_effect(trigger_flags)
	if(!ishuman(owner))
		to_chat(owner, span_warning("Your shoes aren't built with you in mind, unfortunately."))
		return FALSE
	if(!target)
		return FALSE
	var/obj/item/target_shoes = target
	var/mob/living/carbon/human/human_owner = owner

	if(!HAS_TRAIT_FROM(human_owner, TRAIT_MOVE_FLOATING, SHOES_TRAIT))
		human_owner.physiology.stun_mod *= 2
		human_owner.add_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY, TRAIT_NOGRAV_ALWAYS_DRIFT), SHOES_TRAIT)
		human_owner.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/shoes)
		human_owner.AddElement(/datum/element/forced_gravity, 0)
		SEND_SIGNAL(human_owner, COMSIG_JETBOOTS_ACTIVE, human_owner)
		passtable_on(human_owner, SHOES_TRAIT)
		to_chat(human_owner, span_notice("You click your jet boots together and begin to hover gently above the ground..."))
		human_owner.set_resting(FALSE, TRUE)
		human_owner.refresh_gravity()
		target_shoes.icon_state = "jetboots_active"
		target_shoes.update_appearance(UPDATE_ICON_STATE)
		return

	human_owner.physiology.stun_mod *= 0.5
	human_owner.remove_traits(list(TRAIT_MOVE_FLOATING, TRAIT_IGNORING_GRAVITY, TRAIT_NOGRAV_ALWAYS_DRIFT), SHOES_TRAIT)
	human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/shoes)
	human_owner.RemoveElement(/datum/element/forced_gravity, 0)
	SEND_SIGNAL(human_owner, COMSIG_JETBOOTS_INACTIVE, human_owner)
	passtable_off(human_owner, SPECIES_FLIGHT_TRAIT)
	to_chat(human_owner, span_notice("You're lowered back onto the ground..."))
	human_owner.refresh_gravity()
	target_shoes.icon_state = "jetboots"
	target_shoes.update_appearance(UPDATE_ICON_STATE)

/// Largely lifted off of wing's can_fly proc, tailored to the jet boots functionality.
/datum/action/item_action/toggle_flight/proc/can_fly()
	var/mob/living/carbon/human/human = owner
	if(human.stat || human.body_position == LYING_DOWN || isnull(human.client))
		return FALSE

	var/turf/location = get_turf(human)
	if(!location)
		return FALSE

	var/datum/gas_mixture/environment = location.return_air()
	if(environment?.return_pressure() < HAZARD_LOW_PRESSURE + 10)
		to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
		return FALSE
	return TRUE
