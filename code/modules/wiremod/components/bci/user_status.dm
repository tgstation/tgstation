/**
 * # User State
 *
 * Returns true when state matches user.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/compare/user_status
	display_name = "User Status"
	desc = "A component that compares the user's status to known values, and returns true or false."
	category = "BCI"

	required_shells = list(/obj/item/organ/internal/cyberimp/bci)

	/// Compare state option
	var/datum/port/input/option/state_option

	var/obj/item/organ/internal/cyberimp/bci/bci

/obj/item/circuit_component/compare/user_status/populate_options()
	var/static/component_options = list(
		"Alive",
		"Asleep",
		"Critical",
		"Unconscious",
		"Deceased",
	)
	state_option = add_option_port("Comparison Option", component_options)

/obj/item/circuit_component/compare/user_status/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/internal/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/compare/user_status/unregister_shell(atom/movable/shell)
	. = ..()
	bci = null

/obj/item/circuit_component/compare/user_status/do_comparisons()
	if(!bci?.owner)
		return FALSE

	var/current_option = state_option.value
	var/mob/living/carbon/owner = bci.owner
	var/state = owner.stat
	switch(current_option)
		if("Alive")
			return state != DEAD
		if("Asleep")
			return !!owner.IsSleeping() && !owner.IsUnconscious()
		if("Critical")
			return state == SOFT_CRIT || state == HARD_CRIT
		if("Unconscious")
			return state == UNCONSCIOUS || state == HARD_CRIT || !!owner.IsUnconscious()
		if("Deceased")
			return state == DEAD
	//Unknown state, something fucked up really bad - just return false
	return FALSE
