/obj/item/clothing/gloves/ring
	icon = 'modular_skyrat/modules/customization/icons/obj/ring.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/hands.dmi'
	name = "gold ring"
	desc = "A tiny gold ring, sized to wrap around a finger."
	gender = NEUTER
	w_class = WEIGHT_CLASS_TINY
	icon = 'modular_skyrat/modules/customization/icons/obj/ring.dmi'
	icon_state = "ringgold"
	inhand_icon_state = "gring"
	body_parts_covered = 0
	transfer_prints = TRUE
	strip_delay = 40

/obj/item/clothing/gloves/ring/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>\[user] is putting the [src] in [user.p_their()] mouth! It looks like [user] is trying to choke on the [src]!</span>")
	return OXYLOSS


/obj/item/clothing/gloves/ring/diamond
	name = "diamond ring"
	desc = "An expensive ring, studded with a diamond. Cultures have used these rings in courtship for a millenia."
	icon_state = "ringdiamond"
	inhand_icon_state = "dring"

/obj/item/clothing/gloves/ring/diamond/attack_self(mob/user)
	user.visible_message("<span class='warning'>\The [user] gets down on one knee, presenting \the [src].</span>","<span class='warning'>You get down on one knee, presenting \the [src].</span>")

/obj/item/clothing/gloves/ring/silver
	name = "silver ring"
	desc = "A tiny silver ring, sized to wrap around a finger."
	icon_state = "ringsilver"
	inhand_icon_state = "sring"
