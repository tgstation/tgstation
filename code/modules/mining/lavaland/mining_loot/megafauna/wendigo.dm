// Wendigo blood

/obj/item/wendigo_blood
	name = "bottle of wendigo blood"
	desc = "A bottle of viscous red liquid... You're not actually going to drink this, are you?"
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "vial"

/obj/item/wendigo_blood/attack_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(!human_user.mind)
		return
	to_chat(human_user, span_danger("Power courses through you! You can now shift your form at will."))
	var/datum/action/cooldown/spell/shapeshift/polar_bear/transformation_spell = new(user.mind || user)
	transformation_spell.Grant(user)
	playsound(human_user.loc, 'sound/items/drink.ogg', rand(10,50), TRUE)
	qdel(src)

// Wendigo skull

/obj/item/wendigo_skull
	name = "wendigo skull"
	desc = "A bloody skull torn from a murderous beast, the soulless eye sockets seem to constantly track your movement."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "wendigo_skull"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
