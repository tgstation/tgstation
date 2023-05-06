#define OCULAR_WARDEN_PLACE_RANGE 3

/datum/scripture/create_structure/ocular_warden
	name = "Ocular Warden"
	desc = "An eye turret that will fire upon nearby targets."
	tip = "Place these around to prevent crew from rushing past your defenses."
	button_icon_state = "Ocular Warden"
	power_cost = 400
	invocation_time = 5 SECONDS
	invocation_text = list("Summon thee to defend our temple")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/powered/ocular_warden
	cogs_required = 3
	category = SPELLTYPE_STRUCTURES

/datum/scripture/create_structure/ocular_warden/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(locate(/obj/structure/destructible/clockwork/gear_base/powered/ocular_warden) in range(OCULAR_WARDEN_PLACE_RANGE))
		user.balloon_alert(user, "too close to another warden!")
		return FALSE

	return TRUE

#undef OCULAR_WARDEN_PLACE_RANGE
