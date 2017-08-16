//Melee-based clockwork weapons.

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

/obj/item/clockwork/weapon/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = "A powerful spear of Ratvarian making. It's more effective against enemy cultists and silicons."
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 15 //Extra damage is dealt to targets in attack()
	throwforce = 25
	armour_penetration = 10
	sharpness = IS_SHARP_ACCURATE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY


