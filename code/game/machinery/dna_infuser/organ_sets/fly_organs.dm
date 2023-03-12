#define FLY_INFUSED_ORGAN_DESC "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."
#define FLY_INFUSED_ORGAN_ICON pick("brain-x-d", "liver-x", "kidneys-x", "spinner-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

///bonus of the fly: you... are a flyperson now. sorry.
/datum/status_effect/organ_set_bonus/fly
	id = "organ_set_bonus_fly"
	organs_needed = 4 //there are actually 7 fly organs that count, but you only need 4 to go full-flyperson. Be careful!
	bonus_activate_text = null
	bonus_deactivate_text = null

/datum/status_effect/organ_set_bonus/fly/enable_bonus()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/new_fly = owner
	if(isflyperson(new_fly))
		return
	//okay you NEED to be a fly
	to_chat(new_fly, span_danger("Too much fly DNA! Your skin begins to discolor into a horrible black as you become more fly than person!"))
	new_fly.set_species(/datum/species/fly)

/obj/item/organ/internal/eyes/fly
	name = "fly eyes"
	desc = "These eyes seem to stare back no matter the direction you look at it from."
	eye_icon_state = "flyeyes"
	icon_state = "eyeballs-fly"
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	native_fov = NONE //flies can see all around themselves.

/obj/item/organ/internal/eyes/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon = 'icons/obj/medical/organs/fly_organs.dmi'
	say_mod = "buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	modifies_speech = TRUE
	languages_native = list(/datum/language/buzzwords)

/obj/item/organ/internal/tongue/fly/modify_speech(datum/source, list/speech_args)
	var/static/regex/fly_buzz = new("z+", "g")
	var/static/regex/fly_buZZ = new("Z+", "g")
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = fly_buzz.Replace(message, "zzz")
		message = fly_buZZ.Replace(message, "ZZZ")
		message = replacetext(message, "s", "z")
		message = replacetext(message, "S", "Z")
	speech_args[SPEECH_MESSAGE] = message

/obj/item/organ/internal/tongue/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/tongue/fly/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/internal/heart/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/internal/heart/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/heart/fly/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return //don't set icon thank you

/obj/item/organ/internal/lungs/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/internal/lungs/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/liver/fly
	desc = FLY_INFUSED_ORGAN_DESC
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/internal/liver/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/stomach/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/internal/stomach/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/stomach/fly/after_eat(edible)
	var/mob/living/carbon/body = owner
	ASSERT(istype(body))
	// we do not lose any nutrition as a fly when vomiting out food
	body.vomit(lost_nutrition = 0, stun = FALSE, distance = 2, force = TRUE, purge_ratio = 0.67)
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	body.visible_message(
		span_danger("[body] vomits on the floor!"),
		span_userdanger("You throw up on the floor!"),
	)
	return ..()

/obj/item/organ/internal/appendix/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/internal/appendix/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/internal/appendix/fly/update_appearance(updates=ALL)
	return ..(updates & ~(UPDATE_NAME|UPDATE_ICON)) //don't set name or icon thank you

//useless organs we throw in just to fuck with surgeons a bit more. they aren't part of a bonus, just the (absolute) state of flies
/obj/item/organ/internal/fly
	desc = FLY_INFUSED_ORGAN_DESC
	visual = FALSE

/obj/item/organ/internal/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON

/obj/item/organ/internal/fly/groin //appendix is the only groin organ so we gotta have one of these too lol
	zone = BODY_ZONE_PRECISE_GROIN

#undef FLY_INFUSED_ORGAN_DESC
#undef FLY_INFUSED_ORGAN_ICON
