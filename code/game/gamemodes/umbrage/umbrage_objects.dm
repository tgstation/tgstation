//The pass is created with, predictably, Pass. It has a myriad of uses, such as:
// - Pulling yourself to a nearby turf
// - Knocking people down and muting them
// - Prying open depowered airlocks
//It does not do any damage.
/obj/item/weapon/umbrage_pass
	name = "shadowy tendrils"
	desc = "A cluster of black tendrils emitting plumes of smoke."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "umbrage_pass"
	item_state = "umbrage_pass"
	flags = NODROP | CONDUCT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	w_class = 5
	var/mob/living/carbon/human/linked_user


