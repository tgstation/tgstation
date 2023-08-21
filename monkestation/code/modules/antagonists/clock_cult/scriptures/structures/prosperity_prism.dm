//==================================//
// !      Prosperity Prism     ! //
//==================================//
/datum/scripture/create_structure/prosperity_prism
	name = "Prosperity Prism"
	desc = "Creates a prism that will remove all forms of damage from nearby servants over time, along with purging poisons. Requires power from a sigil of transmission."
	tip = "Create a prosperity prism to heal servants while defending your base."
	button_icon_state = "Prolonging Prism"
	power_cost = 300
	invocation_time = 8 SECONDS
	invocation_text = list("Your light shall heal the wounds beneath my skin.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES


/datum/scripture/create_structure/prosperity_prism/check_special_requirements(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(locate(/obj/structure/destructible/clockwork/gear_base/powered/prosperity_prism) in range(3)) // No stacking heals for you
		user.balloon_alert(user, "too close to another prism!")
		return FALSE

	return TRUE
