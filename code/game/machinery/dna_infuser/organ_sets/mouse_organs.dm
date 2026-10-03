#define MOUSE_ORGAN_COLOR "#646464"
#define MOUSE_SCLERA_COLOR "#f0e055"
#define MOUSE_PUPIL_COLOR COLOR_BLACK
#define MOUSE_COLORS MOUSE_ORGAN_COLOR + MOUSE_SCLERA_COLOR + MOUSE_PUPIL_COLOR

///bonus of the mouse: you can ventcrawl!
/datum/status_effect/organ_set_bonus/mouse
	id = "organ_set_bonus_mouse"
	organs_needed = 4
	bonus_activate_text = span_notice("Rodent DNA is deeply infused with you! You've learned how to traverse ventilation!")
	bonus_deactivate_text = span_notice("Your DNA is no longer majority rodent, and so fades your ventilation skills...")
	bonus_traits = list(TRAIT_VENTCRAWLER_NUDE)

///way better night vision, super sensitive. lotta things work like this, huh?
/obj/item/organ/eyes/night_vision/mouse
	name = "mutated mouse-eyes"
	desc = "Mouse DNA infused into what was once a normal pair of eyes."
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	eye_color_left = COLOR_BLACK
	eye_color_right = COLOR_BLACK

	iris_overlay = null
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/organ/eyes/night_vision/mouse"
	post_init_icon_state = "eyes"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = MOUSE_COLORS
	low_light_cutoff = list(16, 11, 0)
	medium_light_cutoff = list(30, 20, 5)
	high_light_cutoff = list(45, 35, 10)

/obj/item/organ/eyes/night_vision/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their eyes have deep black pupils, surrounded by a dark sclera.", BODY_ZONE_PRECISE_EYES)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/mouse)

///increases hunger, disgust recovers quicker, expands what is defined as "food"
/obj/item/organ/stomach/mouse
	name = "mutate mouse-stomach"
	desc = "Mouse DNA infused into what was once a normal stomach."
	disgust_metabolism = 3

	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/organ/stomach/mouse"
	post_init_icon_state = "stomach"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = MOUSE_COLORS
	hunger_modifier = 10

/obj/item/organ/stomach/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/mouse)

/// makes you smaller, walk over tables, and take 1.5x damage
/obj/item/organ/heart/mouse
	name = "mutated mouse-heart"
	desc = "Mouse DNA infused into what was once a normal heart."
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/organ/heart/mouse"
	post_init_icon_state = "heart"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = MOUSE_COLORS
	beat_noise = "a fast-paced high-pitched pit-pat"
	organ_traits = list(TRAIT_DWARF)

/obj/item/organ/heart/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/mouse)
	AddElement(/datum/element/noticable_organ, "%PRONOUN_They have an inwardly posture and %PRONOUN_their movement is jittery and frail.")
	AddElement(/datum/element/update_icon_blocker)

/obj/item/organ/heart/mouse/on_mob_insert(mob/living/carbon/receiver)
	. = ..()
	receiver.damage_resistance -= 50 //but 1.5 damage

/obj/item/organ/heart/mouse/on_mob_remove(mob/living/carbon/heartless, special, movement_flags)
	. = ..()
	heartless.damage_resistance += 50 //revert damage resistance

/// you occasionally squeak, and have some mouse related verbal tics
/obj/item/organ/tongue/mouse
	name = "mutated mouse-tongue"
	desc = "Mouse DNA infused into what was once a normal tongue."
	say_mod = "squeaks"
	modifies_speech = TRUE
	icon = 'icons/map_icons/items/_item.dmi'
	icon_state = "/obj/item/organ/tongue/mouse"
	post_init_icon_state = "tongue"
	greyscale_config = /datum/greyscale_config/mutant_organ
	greyscale_colors = MOUSE_COLORS
	liked_foodtypes = DAIRY //mmm, cheese. doesn't especially like anything else
	disliked_foodtypes = NONE //but a mouse can eat anything without issue
	toxic_foodtypes = NONE

/obj/item/organ/tongue/mouse/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/noticable_organ, "%PRONOUN_Their teeth are particularly bucktoothed!", BODY_ZONE_PRECISE_MOUTH)
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/mouse)

/obj/item/organ/tongue/mouse/proc/whimsy_check(mob/living/checking)
	if(check_holidays(APRIL_FOOLS))
		return TRUE
	if(HAS_PERSONALITY(checking, /datum/personality/whimsical))
		return TRUE
	if(prob(1))
		return TRUE
	return FALSE

/obj/item/organ/tongue/mouse/modify_speech(datum/source, list/speech_args)
	. = ..()
	if(!whimsy_check(source))
		return
	var/message = LOWER_TEXT(speech_args[SPEECH_MESSAGE])
	if(message == "hi" || message == "hi.")
		speech_args[SPEECH_MESSAGE] = "Cheesed to meet you!"
	if(message == "hi?")
		speech_args[SPEECH_MESSAGE] = "Um... cheesed to meet you?"

/obj/item/organ/tongue/mouse/on_mob_insert(mob/living/carbon/tongue_owner, special, movement_flags)
	. = ..()
	RegisterSignal(tongue_owner, COMSIG_LIVING_ITEM_GIVEN, PROC_REF(its_on_the_mouse))

/obj/item/organ/tongue/mouse/on_mob_remove(mob/living/carbon/tongue_owner)
	. = ..()
	UnregisterSignal(tongue_owner, COMSIG_LIVING_ITEM_GIVEN)

/obj/item/organ/tongue/mouse/proc/on_item_given(mob/living/carbon/offerer, mob/living/taker, obj/item/given)
	SIGNAL_HANDLER
	if(!whimsy_check(offerer))
		return
	INVOKE_ASYNC(src, PROC_REF(its_on_the_mouse), offerer, taker)

/obj/item/organ/tongue/mouse/proc/its_on_the_mouse(mob/living/carbon/offerer, mob/living/taker)
	offerer.say("For you, it's on the mouse.")
	taker.add_mood_event("it_was_on_the_mouse", /datum/mood_event/it_was_on_the_mouse)

/obj/item/organ/tongue/mouse/on_life(seconds_per_tick)
	. = ..()
	if(prob(5))
		owner.emote("squeaks")
		playsound(owner, 'sound/mobs/non-humanoids/mouse/mousesqueek.ogg', 100)

/obj/item/organ/ears/mouse
	name = "mouse ears"
	desc = "Ears round as a satellite dish, with only a short fuzz on the inside."
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2

	dna_block = /datum/dna_block/feature/accessory/ears
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears/mouse_ears
	sprite_accessory_override = /datum/sprite_accessory/ears/mouse

/datum/bodypart_overlay/mutant/cat_ears/mouse_ears
	layers = list(
		EXTERNAL_FRONT = BODY_FRONT_LAYER,
		EXTERNAL_ADJACENT = BODY_ADJ_LAYER
	)
	inner_layer = list(EXTERNAL_FRONT, EXTERNAL_ADJACENT)

/obj/item/organ/tail/mouse
	name = "mouse tail"
	desc = "A long, dextrous and furless appendage."

	dna_block = null
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/mouse

	wag_flags = WAG_ABLE
	restyle_flags = EXTERNAL_RESTYLE_FLESH

/datum/bodypart_overlay/mutant/tail/mouse
	color_source = NONE
	feature_key = FEATURE_TAIL_MOUSE
	draw_on_husks = HUSK_OVERLAY_GRAYSCALE
	imprint_on_next_insertion = FALSE
	offset_location = LOWER_BODY

/datum/bodypart_overlay/mutant/tail/mouse/New()
	. = ..()
	set_appearance_from_name(/datum/sprite_accessory/tails/mouse/default::name) //only one mouse tail

/datum/bodypart_overlay/mutant/tail/mouse/randomize_appearance()
	set_appearance_from_name(/datum/sprite_accessory/tails/mouse/default::name)

#undef MOUSE_ORGAN_COLOR
#undef MOUSE_SCLERA_COLOR
#undef MOUSE_PUPIL_COLOR
#undef MOUSE_COLORS
