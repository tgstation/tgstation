/datum/status_effect/freon
	id = "frozen"
	duration = 100
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/freon
	var/icon/cube
	var/can_melt = TRUE

/atom/movable/screen/alert/status_effect/freon
	name = "Frozen Solid"
	desc = "You're frozen inside an ice cube, and cannot move! You can still do stuff, like shooting. Resist out of the cube!"
	icon_state = "frozen"

/datum/status_effect/freon/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_LIVING_RESIST, PROC_REF(owner_resist))
	if(!owner.stat)
		to_chat(owner, span_userdanger("You become frozen in a cube!"))
	cube = icon('icons/effects/freeze.dmi', "ice_cube")
	owner.add_overlay(cube)


/datum/status_effect/freon/tick(seconds_between_ticks)
	if(can_melt && owner.bodytemperature >= owner.get_body_temp_normal())
		qdel(src)

/datum/status_effect/freon/proc/owner_resist()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_resist))

/datum/status_effect/freon/proc/do_resist()
	to_chat(owner, span_notice("You start breaking out of the ice cube..."))
	if(do_after(owner, 4 SECONDS, target = owner))
		to_chat(owner, span_notice("You break out of the ice cube!"))
		qdel(src)

/datum/status_effect/freon/on_remove()
	if(!owner.stat)
		to_chat(owner, span_notice("The cube melts!"))
	owner.cut_overlay(cube)
	owner.adjust_bodytemperature(100)
	UnregisterSignal(owner, COMSIG_LIVING_RESIST)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/freon/watcher
	duration = 8
	can_melt = FALSE

/datum/status_effect/freon/watcher/extended
	duration = 5 SECONDS

/datum/status_effect/freon/lasting
	id = "lasting_frozen"
	duration = STATUS_EFFECT_PERMANENT

/datum/status_effect/hypernob_protection
	id = "hypernob_protection"
	duration = 10 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/hypernob_protection

/datum/status_effect/hypernob_protection/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/atom/movable/screen/alert/status_effect/hypernob_protection
	name = "Hyper-Noblium Protection"
	desc = "The Hyper-Noblium around your body is protecting it from self-combustion and fires, but you feel sluggish..."
	icon_state = "hypernob_protection"

/datum/status_effect/hypernob_protection/on_apply()
	if(!ishuman(owner))
		CRASH("[type] status effect added to non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.add_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium) //small slowdown as a tradeoff
	ADD_TRAIT(human_owner, TRAIT_NOFIRE, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/hypernob_protection/on_remove()
	if(!ishuman(owner))
		stack_trace("[type] status effect being removed from non-human owner: [owner ? owner.type : "null owner"]")
	var/mob/living/carbon/human/human_owner = owner
	human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hypernoblium)
	REMOVE_TRAIT(human_owner, TRAIT_NOFIRE, TRAIT_STATUS_EFFECT(id))
