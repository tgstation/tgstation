/// Gives someone the stable voided trauma and then self destructs
/obj/item/cosmic_skull
	name = "cosmic skull"
	desc = "You can see and feel the surrounding space pulsing through it..."

	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "cosmic_skull_charged"

/obj/item/cosmic_skull/attack_self(mob/user, modifiers)
	. = ..()

	to_chat(user, span_purple("You begin staring into the [name]..."))

	if(!ishuman(user) || !do_after(user, 10 SECONDS, src))
		return

	var/mob/living/carbon/human/starer = user
	starer.cure_trauma_type(/datum/brain_trauma/voided) //this wouldn't make much sense to have anymore

	starer.gain_trauma(/datum/brain_trauma/voided/stable)
	to_chat(user, span_purple("And a whole world opened up to you."))
	playsound(get_turf(user), 'sound/effects/curse5.ogg', 60)
	qdel(src)
