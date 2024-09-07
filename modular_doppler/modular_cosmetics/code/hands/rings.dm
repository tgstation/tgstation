/obj/item/clothing/gloves/ring
	icon = 'modular_doppler/modular_cosmetics/icons/obj/hands/rings.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/hands/rings.dmi'
	lefthand_file = 'modular_doppler/modular_cosmetics/icons/mob/inhands/rings_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_cosmetics/icons/mob/inhands/rings_righthand.dmi'
	name = "gold ring"
	desc = "A tiny gold ring, sized to wrap around a finger."
	gender = NEUTER
	w_class = WEIGHT_CLASS_TINY
	icon_state = "ringgold"
	inhand_icon_state = "ringgold"
	worn_icon_state = "gring"
	body_parts_covered = 0
	strip_delay = 4 SECONDS
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/ring/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("\[user] is putting the [src] in [user.p_their()] mouth! It looks like [user] is trying to choke on the [src]!"))
	return OXYLOSS


/obj/item/clothing/gloves/ring/diamond
	name = "diamond ring"
	desc = "An expensive ring, studded with a diamond. Cultures have used these rings in courtship for a millenia."
	icon_state = "ringdiamond"
	inhand_icon_state = "ringdiamond"
	worn_icon_state = "dring"

/obj/item/clothing/gloves/ring/diamond/attack_self(mob/user)
	user.visible_message(span_warning("\The [user] gets down on one knee, presenting \the [src]."),span_warning("You get down on one knee, presenting \the [src]."))

/obj/item/clothing/gloves/ring/silver
	name = "silver ring"
	desc = "A tiny silver ring, sized to wrap around a finger."
	icon_state = "ringsilver"
	inhand_icon_state = "ringsilver"
	worn_icon_state = "sring"
