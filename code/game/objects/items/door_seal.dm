/obj/item/door_seal
	name = "pneumatic seal"
	desc = "A brace used to seal and reinforce an airlock. Useful for making areas inaccessible to those without opposable thumbs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "pneumatic_seal"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=2000)
	attack_verb = list("clonked", "whacked", "bashed", "thunked", "battered", "bludgeoned")
	var/seal_time = 30
	var/unseal_time = 20

/obj/item/door_seal/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is sealing [user.p_them()]self off from the world with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(src, 'sound/items/jaws_pry.ogg', 30, TRUE)
	return(BRUTELOSS)

