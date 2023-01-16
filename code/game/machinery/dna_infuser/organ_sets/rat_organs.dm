
#define RAT_ORGAN_COLOR "#646464"
#define RAT_SCLERA_COLOR "#f0e055"
#define RAT_PUPIL_COLOR "#000000"

#define RAT_COLORS RAT_ORGAN_COLOR + RAT_SCLERA_COLOR + RAT_PUPIL_COLOR

///bonus of the rat: you can ventcrawl!
/datum/status_effect/organ_set_bonus/rat
	organs_needed = 4
	bonus_activate_text = span_notice("Rodent DNA is deeply infused with you! You've learned how to traverse ventilation!")
	bonus_deactivate_text = span_notice("Your DNA is no longer majority rat, and so fades your ventilation skills...")

/datum/status_effect/organ_set_bonus/rat/enable_bonus()
	. = ..()
	ADD_TRAIT(owner, TRAIT_VENTCRAWLER_NUDE, REF(src))

/datum/status_effect/organ_set_bonus/rat/disable_bonus()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_VENTCRAWLER_NUDE, REF(src))



///way better night vision, super sensitive. lotta things work like this, huh?
/obj/item/organ/internal/eyes/night_vision/rat
	name = "mutated rat-eyes"
	desc = "Rat DNA infused into what was once a normal pair of eyes."
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	eye_color_left = "#000000"
	eye_color_right = "#000000"

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "eyes"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = RAT_COLORS

/obj/item/organ/internal/eyes/night_vision/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "eyes have deep, shifty black pupils, surrounded by a sickening yellow sclera.", BODY_ZONE_PRECISE_EYES)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)



///increases hunger, disgust recovers quicker, expands what is defined as "food"
/obj/item/organ/internal/stomach/rat
	name = "mutated rat-stomach"
	desc = "Rat DNA infused into what was once a normal stomach."
	disgust_metabolism = 3

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "stomach"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = RAT_COLORS

/obj/item/organ/internal/stomach/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)

/obj/item/organ/internal/stomach/rat/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	AddElement(/datum/element/noticable_organ, "salivate[reciever.p_s()] excessively.", BODY_ZONE_HEAD)
	return ..()

/obj/item/organ/internal/stomach/rat/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!ishuman(reciever))
		return
	var/mob/living/carbon/human/human_holder = reciever
	var/datum/species/species = human_holder.dna.species
	//mmm, cheese. doesn't especially like anything else
	species.liked_food = DAIRY
	//but a rat can eat anything without issue
	species.disliked_food = NONE
	species.toxic_food = NONE
	human_holder.physiology.hunger_mod *= 10
	RegisterSignal(human_holder, COMSIG_SPECIES_GAIN, PROC_REF(on_species_gain))

/obj/item/organ/internal/stomach/rat/proc/on_species_gain(datum/source, datum/species/new_species, datum/species/old_species)
	SIGNAL_HANDLER
	new_species.liked_food = DAIRY
	new_species.disliked_food = NONE
	new_species.toxic_food = NONE

/obj/item/organ/internal/stomach/rat/Remove(mob/living/carbon/stomach_owner, special)
	. = ..()
	if(!ishuman(stomach_owner))
		return
	var/mob/living/carbon/human/human_holder = stomach_owner
	var/datum/species/species = human_holder.dna.species
	species.liked_food = initial(species.liked_food)
	species.disliked_food = initial(species.disliked_food)
	species.toxic_food = initial(species.toxic_food)
	human_holder.physiology.hunger_mod /= 10
	UnregisterSignal(stomach_owner, COMSIG_SPECIES_GAIN)



/// makes you smaller, walk over tables, and take 1.5x damage
/obj/item/organ/internal/heart/rat
	name = "mutated rat-heart"
	desc = "Rat DNA infused into what was once a normal heart."

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = RAT_COLORS

/obj/item/organ/internal/heart/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)

/obj/item/organ/internal/heart/rat/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	AddElement(/datum/element/noticable_organ, "hunch[owner.p_es()] over unnaturally!")
	return ..()

/obj/item/organ/internal/heart/rat/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(!ishuman(reciever))
		return
	var/mob/living/carbon/human/human_reciever = reciever
	human_reciever.dna.add_mutation(/datum/mutation/human/dwarfism)
	//but 1.5 damage
	human_reciever.physiology.damage_resistance -= 50

/obj/item/organ/internal/heart/rat/Remove(mob/living/carbon/heartless, special)
	. = ..()
	if(!ishuman(heartless))
		return
	var/mob/living/carbon/human/human_heartless = heartless
	human_heartless.dna.remove_mutation(/datum/mutation/human/dwarfism)
	human_heartless.physiology.damage_resistance += 50



/// you occasionally squeak, and have some rat related verbal tics
/obj/item/organ/internal/tongue/rat
	name = "mutated rat-tongue"
	desc = "Rat DNA infused into what was once a normal tongue."
	say_mod = "squeaks"
	modifies_speech = TRUE

	icon = 'icons/obj/medical/organs/infuser_organs.dmi'
	icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = RAT_COLORS

/obj/item/organ/internal/tongue/rat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "teeth are oddly shaped and yellowing", BODY_ZONE_HEAD)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/rat)

/obj/item/organ/internal/tongue/rat/modify_speech(datum/source, list/speech_args)
	. = ..()
	var/message = lowertext(speech_args[SPEECH_MESSAGE])
	if(message == "hi" || message == "hi.")
		speech_args[SPEECH_MESSAGE] = "Cheesed to meet you!"
	if(message == "hi?")
		speech_args[SPEECH_MESSAGE] = "Um... cheesed to meet you?"

/obj/item/organ/internal/tongue/rat/Insert(mob/living/carbon/tongue_owner, special, drop_if_replaced)
	. = ..()
	RegisterSignal(tongue_owner, COMSIG_CARBON_ITEM_GIVEN, PROC_REF(its_on_the_mouse))

/obj/item/organ/internal/tongue/rat/Remove(mob/living/carbon/tongue_owner, special)
	. = ..()
	UnregisterSignal(tongue_owner, COMSIG_CARBON_ITEM_GIVEN)

/obj/item/organ/internal/tongue/rat/proc/on_item_given(mob/living/carbon/offerer, mob/living/taker, obj/item/given)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(its_on_the_mouse), offerer, taker)

/obj/item/organ/internal/tongue/rat/proc/its_on_the_mouse(mob/living/carbon/offerer, mob/living/taker)
	offerer.say("For you, it's on the mouse.")
	taker.add_mood_event("it_was_on_the_mouse", /datum/mood_event/it_was_on_the_mouse)

/obj/item/organ/internal/tongue/rat/on_life(delta_time, times_fired)
	. = ..()
	if(prob(5))
		owner.emote("squeaks")
		playsound(owner, 'sound/effects/mousesqueek.ogg', 100)

#undef RAT_ORGAN_COLOR
#undef RAT_SCLERA_COLOR
#undef RAT_PUPIL_COLOR

#undef RAT_COLORS
