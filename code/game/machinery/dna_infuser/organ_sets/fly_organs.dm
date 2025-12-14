#define FLY_INFUSED_ORGAN_DESC "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."
#define FLY_INFUSED_ORGAN_ICON pick("brain-x-d", "liver-x", "kidneys-x", "spinner-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

///bonus of the fly: you... are a flyperson now. sorry.
/datum/status_effect/organ_set_bonus/fly
	id = "organ_set_bonus_fly"
	organs_needed = 4 //there are actually 7 fly organs that count, but you only need 4 to go full-flyperson. Be careful!
	bonus_activate_text = null
	bonus_deactivate_text = null

/datum/status_effect/organ_set_bonus/fly/enable_bonus(obj/item/organ/inserted_organ)
	. = ..()
	if(!. || !ishuman(owner))
		return
	var/mob/living/carbon/human/new_fly = owner
	if(isflyperson(new_fly))
		return
	// This is ugly as sin, but we're called before the organ finishes inserting into the bodypart
	// so if we swap species directly the bodypart will be replaced and we'll be gone
	// so we need to delay species change until we're fully inserted
	RegisterSignal(inserted_organ, COMSIG_ORGAN_BODYPART_INSERTED, PROC_REF(flyify))

/datum/status_effect/organ_set_bonus/fly/proc/flyify(obj/item/organ/source, obj/item/bodypart/limb, movement_flags)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/new_fly = owner
	// just in case?
	if(isflyperson(new_fly))
		return
	// needs to be done before the species is set
	UnregisterSignal(source, COMSIG_ORGAN_BODYPART_INSERTED)
	// okay you NEED to be a fly
	to_chat(new_fly, span_danger("Too much fly DNA! Your skin begins to discolor into a horrible black as you become more fly than person!"))
	new_fly.set_species(/datum/species/fly)

/obj/item/organ/eyes/fly
	name = "fly eyes"
	desc = "These eyes seem to stare back no matter the direction you look at it from."
	eye_icon_state = "flyeyes"
	icon_state = "eyes_fly"
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	native_fov = NONE //flies can see all around themselves.
	blink_animation = FALSE
	iris_overlay = null

/obj/item/organ/eyes/fly/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/tongue/fly
	name = "proboscis"
	desc = "A freakish looking meat tube that apparently can take in liquids."
	icon = 'icons/obj/medical/organs/fly_organs.dmi'
	say_mod = "buzzes"
	taste_sensitivity = 25 // you eat vomit, this is a mercy
	liked_foodtypes = GROSS | GORE // nasty ass
	disliked_foodtypes = NONE
	toxic_foodtypes = NONE // these fucks eat vomit, i am sure they can handle drinking bleach or whatever too
	modifies_speech = TRUE
	languages_native = list(/datum/language/buzzwords)
	var/static/list/speech_replacements = list(
		new /regex("z+", "g") = "zzz",
		new /regex("Z+", "g") = "ZZZ",
		"s" = "z",
		"S" = "Z",
	)


/obj/item/organ/tongue/fly/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = speech_replacements, should_modify_speech = CALLBACK(src, PROC_REF(should_modify_speech)))
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/tongue/fly/get_possible_languages()
	return ..() + /datum/language/buzzwords

/obj/item/organ/heart/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/heart/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)
	AddElement(/datum/element/update_icon_blocker)

/obj/item/organ/lungs/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/lungs/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/liver/fly
	desc = FLY_INFUSED_ORGAN_DESC
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/stomach/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/stomach/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/stomach/fly/after_eat(edible)
	var/mob/living/carbon/body = owner
	ASSERT(istype(body))
	// we do not lose any nutrition as a fly when vomiting out food
	body.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_FORCE | MOB_VOMIT_HARM), lost_nutrition = 0, distance = 2, purge_ratio = 0.67)
	playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
	body.visible_message(
		span_danger("[body] vomits on the floor!"),
		span_userdanger("You throw up on the floor!"),
	)
	return ..()

/obj/item/organ/appendix/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/appendix/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/fly)

/obj/item/organ/appendix/fly/update_appearance(updates=ALL)
	return ..(updates & ~(UPDATE_NAME|UPDATE_ICON)) //don't set name or icon thank you

//useless organs we throw in just to fuck with surgeons a bit more. they aren't part of a bonus, just the (absolute) state of flies
/obj/item/organ/fly
	desc = FLY_INFUSED_ORGAN_DESC

/obj/item/organ/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = FLY_INFUSED_ORGAN_ICON

/obj/item/organ/fly/groin //appendix is the only groin organ so we gotta have one of these too lol
	zone = BODY_ZONE_PRECISE_GROIN

#undef FLY_INFUSED_ORGAN_DESC
#undef FLY_INFUSED_ORGAN_ICON
