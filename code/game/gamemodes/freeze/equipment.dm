/obj/item/weapon/proc/chill_target(mob/living/carbon/human/H, temperature_delta = 0)
	if(!istype(H))
		return
	H.temperature = max(H.temperature - temperature_delta, TCMB)

/obj/item/weapon/shield/riot/frosty
	name = "frost shield"
	desc = "A frozen shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/frosty.dmi'
	icon_state = "frost_shield"
	item_state = "frost_shield"
	materials = list()

/obj/item/weapon/shield/riot/frosty/orb
	name = "frost orb"
	desc = "An orb of powerful frost magic. Can protect its wielder from projectiles."
	icon_state = "frost_orb"

/obj/item/weapon/frosty
	icon = 'icons/obj/frosty.dmi'
	damtype = COLD
	var/temperature_delta = 50

/obj/item/weapon/frosty/afterattack(atom/O, mob/user, proximity)
	chill_target(O, temperature_delta)

/obj/item/weapon/frosty/lance
	name = "frost lance"
	desc = "A lance formed of ice."
	icon_state = "frost_lance"

	force = 15
	throw_force = 10

	slot_flags = SLOT_BELT
	w_class = 3

/obj/item/weapon/frosty/sceptre
	name = "frost sceptre"
	desc = "A sceptre capable of wielding powerful frost magic."
	icon_state = "frost_sceptre"

	force = 5
	throw_force = 0
	w_class = 5

	flags = NODROP
