/datum/quirk/stable_ass
	name = "Stable Rear"
	desc = "Your rear is far more robust than average, falling off less often than usual."
	value = 2
	icon = FA_ICON_FACE_SAD_CRY
	//All effects are handled directly in butts.dm

/datum/quirk/loud_ass
	name = "Loud Ass"
	desc = "For some ungodly reason, your ass is twice as loud as normal."
	value = 2
	icon = FA_ICON_VOLUME_HIGH
	//All effects are handled directly in butts.dm

/datum/quirk/dummy_thick
	name = "Dummy Thicc"
	desc = "Hm...Colonel, I'm trying to sneak around, but I'm dummy thicc and the clap of my ass cheeks keep alerting the guards..."
	value = 3	//Why are we still here? Just to suffer?
	icon = FA_ICON_VOLUME_UP

/datum/quirk/dummy_thick/post_add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	var/obj/item/organ/internal/butt/booty = quirk_holder.get_organ_by_type(/obj/item/organ/internal/butt)
	var/matrix/thick = new
	thick.Scale(1.5)
	animate(booty, transform = thick, time = 1)

/datum/quirk/dummy_thick/proc/on_mob_move()
	SIGNAL_HANDLER
	if(prob(33))
		playsound(quirk_holder, "monkestation/sound/misc/clap_short.ogg", 70, TRUE, 5, ignore_walls = TRUE)

/datum/quirk/gourmand
	name = "Gourmand"
	desc = "You enjoy the finer things in life. You are able to have one more food buff applied at once."
	value = 2
	icon = FA_ICON_COOKIE_BITE
	mob_trait = TRAIT_GOURMAND
	gain_text = "<span class='notice'>You start to enjoy fine cuisine.</span>"
	lose_text = "<span class='danger'>Those Space Twinkies are starting to look mighty fine.</span>"

/datum/quirk/gourmand/add()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs ++

/datum/quirk/gourmand/remove()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs --

/datum/quirk/fluffy_tongue
	name = "Fluffy Tongue"
	desc = "After spending too much time watching anime you have developed a horrible speech impediment."
	value = 5
	icon = FA_ICON_CAT

/datum/quirk/fluffy_tongue/add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/quirk/fluffy_tongue/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_MOB_SAY)

/datum/quirk/fluffy_tongue/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]

	if(message[1] != "*")
		message = replacetext(message, "ne", "nye")
		message = replacetext(message, "nu", "nyu")
		message = replacetext(message, "na", "nya")
		message = replacetext(message, "no", "nyo")
		message = replacetext(message, "ove", "uv")
		message = replacetext(message, "r", "w")
		message = replacetext(message, "l", "w")
	speech_args[SPEECH_MESSAGE] = message

/datum/quirk/dwarfism
	name = "Dwarfism"
	desc = "Your cells take up less space than others', giving you a smaller appearance. You also find it easier to climb tables. Rock and Stone!"
	value = 4
	icon = FA_ICON_CHEVRON_CIRCLE_DOWN
	quirk_flags = QUIRK_CHANGES_APPEARANCE

/datum/quirk/dwarfism/add()
	. = ..()
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/godzuki = quirk_holder
		if(godzuki.dna)
			godzuki.dna.add_mutation(/datum/mutation/human/dwarfism)

/datum/quirk/dwarfism/remove()
	. = ..()
	if (ishuman(quirk_holder))
		var/mob/living/carbon/human/godzuki = quirk_holder
		if(godzuki.dna)
			godzuki.dna.remove_mutation(/datum/mutation/human/dwarfism)

/datum/quirk/voracious
	name = "Voracious"
	desc = "Nothing gets between you and your food. You eat faster and can binge on junk food! Being fat suits you just fine. Also allows you to have an additional food buff."
	icon = FA_ICON_DRUMSTICK_BITE
	value = 6
	mob_trait = TRAIT_VORACIOUS
	gain_text = span_notice("You feel HONGRY.")
	lose_text = span_danger("You no longer feel HONGRY.")
	mail_goodies = list(/obj/effect/spawner/random/food_or_drink/dinner)


/datum/quirk/voracious/add()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs ++

/datum/quirk/voracious/remove()
	var/mob/living/carbon/human/holder = quirk_holder
	holder.max_food_buffs --
