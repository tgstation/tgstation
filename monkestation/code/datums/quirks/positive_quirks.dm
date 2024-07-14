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


/datum/quirk/hardened_soles
	name = "Hardened Soles"
	desc = "You're used to walking barefoot, and won't receive the negative effects of doing so."
	value = 2
	mob_trait = TRAIT_HARD_SOLES
	gain_text = span_notice("The ground doesn't feel so rough on your feet anymore.")
	lose_text = span_danger("You start feeling the ridges and imperfections on the ground.")
	medical_record_text = "Patient's feet are more resilient against traction."
	icon = FA_ICON_LINES_LEANING

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


/datum/quirk/bright_eyes
	name = "Bright Eyes"
	desc = "You've got bright, cybernetic eyes!"
	icon = FA_ICON_SUN
	value = 3
	medical_record_text = "Patient has acquired and been installed with high luminosity eyes."
	// hardcore_value = 0
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	gain_text = span_notice("Your eyes feel extra shiny.")
	lose_text = span_danger("You can't feel your eyes anymore.")

/datum/quirk/bright_eyes/add()
	var/obj/item/organ/internal/eyes/old_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	var/obj/item/organ/internal/eyes/robotic/glow/new_eyes = new

	qdel(old_eyes)
	new_eyes.Insert(quirk_holder)

/datum/quirk/bright_eyes/remove()
	var/obj/item/organ/internal/eyes/old_eyes = quirk_holder.get_organ_slot(ORGAN_SLOT_EYES)
	var/mob/living/carbon/human/quirk_mob = quirk_holder

	if(!old_eyes || /obj/item/organ/internal/eyes/robotic/glow)
		return

	var/species_eyes = /obj/item/organ/internal/eyes
	if(quirk_mob.dna.species && quirk_mob.dna.species.mutanteyes)
		species_eyes = quirk_mob.dna.species.mutanteyes
	var/obj/item/organ/internal/eyes/new_eyes = new species_eyes()

	qdel(old_eyes)
	new_eyes.Insert(quirk_holder)

/datum/quirk/neuralink
	name = "Neuralinked"
	desc = "You've been installed with an NT 1.0 cyberlink!"
	icon = FA_ICON_PLUG
	value = 3
	medical_record_text = "Patient has acquired and been installed with a NT 1.0 Cyberlink."
	// hardcore_value = 0
	gain_text = span_notice("You feel robotic.")
	lose_text = span_danger("You feel fleshy again.")

/datum/quirk/neuralink/add()
	var/obj/item/organ/internal/cyberimp/cyberlink/nt_low/neuralink = new

	neuralink.Insert(quirk_holder)

/datum/quirk/neuralink/remove()
	var/obj/item/organ/internal/cyberimp/cyberlink/nt_low/neuralink = new
	var/obj/item/organ/internal/cyberimp/cyberlink/current_link = quirk_holder.get_organ_slot(ORGAN_SLOT_LINK)

	if(!neuralink)
		return
	qdel(current_link)

/datum/quirk/hosed
	name = "Hosed"
	desc = "You've got a cybernetic breathing tube implant!"
	icon = FA_ICON_LUNGS
	value = 3
	medical_record_text = "Patient has been installed with a breathing tube implant."
	// hardcore_value = 0
	gain_text = span_notice("You can breathe easier!")
	lose_text = span_notice("Breathing feels normal again.")

/datum/quirk/hosed/add()
	var/obj/item/organ/internal/cyberimp/mouth/breathing_tube/hose = new

	hose.Insert(quirk_holder)

/datum/quirk/hosed/remove()
	var/obj/item/organ/internal/cyberimp/mouth/breathing_tube/hose = new
	var/obj/item/organ/internal/cyberimp/cyberlink/current_hose = quirk_holder.get_organ_slot(ORGAN_SLOT_BREATHING_TUBE)

	//should work even if we get more implants of this type in the future. maybe. might have issues mentioned in previous comment
	if(!hose)
		return
	qdel(current_hose)
