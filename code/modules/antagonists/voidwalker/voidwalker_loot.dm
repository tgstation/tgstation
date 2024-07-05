/// Gives someone the stable voided trauma and then self destructs
/obj/item/cosmic_skull
	name = "cosmic skull"
	desc = "You can see and feel the surrounding space pulsing through it..."

	icon = /obj/item/clothing/head/helmet/skull::icon
	icon_state = /obj/item/clothing/head/helmet/skull::icon_state

/obj/item/cosmic_skull/Initialize(mapload)
	. = ..()

	var/image/texture = icon(/datum/bodypart_overlay/texture/spacey::texture_icon, /datum/bodypart_overlay/texture/spacey::texture_icon_state)

	add_filter("SPACE_FILTER", 1, layering_filter(icon = texture,blend_mode = BLEND_INSET_OVERLAY))

/obj/item/cosmic_skull/attack_self(mob/user, modifiers)
	. = ..()

	to_chat(user, span_purple("You begin staring into the [name]..."))

	if(!ishuman(user) || !do_after(user, 10 SECONDS, src))
		return

	var/mob/living/carbon/human/starer = user
	starer.gain_trauma(/datum/brain_trauma/voided/stable)
	to_chat(user, span_purple("And a whole world opened up to you."))
	playsound(get_turf(user), 'sound/effects/curse5.ogg', 60)
	qdel(src)
