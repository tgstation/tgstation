/datum/quirk/stable_ass
	name = "Stable Rear"
	desc = "Your rear is far more robust than average, falling off less often than usual."
	value = 2
	//All effects are handled directly in butts.dm

/datum/quirk/loud_ass
	name = "Loud Ass"
	desc = "For some ungodly reason, your ass is twice as loud as normal."
	value = 2
	//All effects are handled directly in butts.dm

/datum/quirk/dummy_thick
	name = "Dummy Thicc"
	desc = "Hm...Colonel, I'm trying to sneak around, but I'm dummy thicc and the clap of my ass cheeks keep alerting the guards..."
	value = 3	//Why are we still here? Just to suffer?

/datum/quirk/dummy_thick/post_add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)
	var/obj/item/organ/butt/booty = quirk_holder.getorgan(/obj/item/organ/butt)
	var/matrix/thick = new
	thick.Scale(1.5)
	animate(booty, transform = thick, time = 1)

/datum/quirk/dummy_thick/proc/on_mob_move()
	SIGNAL_HANDLER
	if(prob(33))
		playsound(quirk_holder, "monkestation/sound/misc/clap_short.ogg", 70, TRUE, 5, ignore_walls = TRUE)

/datum/quirk/controlled_prosthetic
	name = "Controlled Prosthetic"
	desc = "You start the round with a Prosthetic Replacement kit, which will allow you to \
	quickly replace a limb you choose with a prosthetic or robotic replacement."
	mob_trait = TRAIT_CONT_PROSTHETIC
	value = 4

/datum/quirk/controlled_prosthetic/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/choice_beacon/prosthetic/B = new(get_turf(H))
	SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_INSERT, B, H, TRUE, TRUE) //insert the item, even if the backpack's full
