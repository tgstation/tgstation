/obj/item/melee/blinkknife
	name = "Blink Dagger"
	desc = "You feel the power of god and anime course through you holding this blade."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rainbowknife"
	item_state = "rainbowknife"
	force = 20
	damtype = BRUTE
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	hitsound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 50
	sharpness = IS_SHARP
	attack_verb = list("detroyed", "annihilated")

/obj/item/melee/blinkknife/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS)
