//This is the base type for chumbiswork melee weapons.
/obj/item/chumbiswork/weapon
	name = "chumbiswork weapon"
	desc = "Weaponized brass. Whould've thunk it?"
	chumbiswork_desc = "This shouldn't exist. Report it to a coder."
	icon = 'icons/obj/chumbiswork_objects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/chumbiswork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/chumbiswork_righthand.dmi'
	var/datum/action/innate/call_weapon/action //Some melee weapons use an action that lets you return and dismiss them

/obj/item/chumbiswork/weapon/Initialize(mapload, new_action)
	. = ..()
	if(new_action)
		action = new_action
		action.weapon = src
