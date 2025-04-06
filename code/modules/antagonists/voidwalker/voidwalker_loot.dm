/// Gives someone the stable voided trauma and then self destructs
/obj/item/clothing/head/helmet/skull/cosmic
	name = "cosmic skull"
	desc = "You can see and feel the surrounding space pulsing through it..."
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "cosmic_skull_charged"

	light_on = TRUE
	light_color = "#CC00CC"
	light_range = 3
	/// Icon state for when drained
	var/drained_icon_state = "cosmic_skull_drained"
	/// How many uses does it have left?
	var/uses = 1

/obj/item/clothing/head/helmet/skull/cosmic/attack_self(mob/user, modifiers)
	. = ..()

	if(!uses || !ishuman(user))
		return

	var/mob/living/carbon/human/hewmon = user
	if(is_species(hewmon, /datum/species/voidwalker))
		to_chat(user, span_bolddanger("OH GOD NOO!!!! WHYYYYYYYYY!!!!! WHO WOULD DO THIS?!!"))
		return

	to_chat(user, span_purple("You begin staring into \the [src]..."))

	if(!do_after(user, 10 SECONDS, src))
		return

	var/mob/living/carbon/human/starer = user
	starer.cure_trauma_type(/datum/brain_trauma/voided) //this wouldn't make much sense to have anymore

	starer.gain_trauma(/datum/brain_trauma/voided/stable)
	to_chat(user, span_purple("And a whole world opens up to you."))
	playsound(get_turf(user), 'sound/effects/curse/curse5.ogg', 60)

	uses--
	if(uses <= 0)
		icon_state = drained_icon_state
		light_on = FALSE
