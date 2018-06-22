//This is the base type for clockwork melee weapons.
/obj/item/clockwork/weapon
	name = "clockwork weapon"
	desc = "Weaponized brass. Whould've thunk it?"
	clockwork_desc = "This shouldn't exist. Report it to a coder."
	icon = 'icons/obj/clockwork_objects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	var/datum/action/innate/call_weapon/action //Some melee weapons use an action that lets you return and dismiss them

/obj/item/clockwork/weapon/Initialize(mapload, new_action)
	. = ..()
	if(new_action)
		action = new_action
		action.weapon = src
