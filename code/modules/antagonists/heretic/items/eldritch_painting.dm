// The basic eldritch painting
/obj/item/wallframe/painting/eldritch
	name = "The debug and a coder who slept"
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30

/obj/structure/sign/painting/eldritch
	name = "The debug and a coder who slept"
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// Set to false since we don't want this to persist
	persistence_id = FALSE
	/// The trauma the painting applies
	var/applied_trauma = /datum/brain_trauma/severe/pacifism
	/// The text that shows up when you cross the paintings path
	var/text_to_display = "I should not be seeing this..."
	/// The range of the paintings effect
	var/range = 7

/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	. = ..()
	var/static/list/connections = list(COMSIG_ATOM_ENTERED = PROC_REF(apply_trauma))
	AddComponent(/datum/component/connect_range, tracked = src, connections = connections, range = range, works_in_containers = FALSE)

/obj/structure/sign/painting/eldritch/proc/apply_trauma(datum/source, mob/living/carbon/viewer)
	if (!isliving(viewer) || !can_see(viewer, src, range))
		return
	if (!viewer.mind || !viewer.mob_mood || viewer.stat != CONSCIOUS || viewer.is_blind())
		return
	// Certain paintings have no applied trauma, so we shouldnt do further effects if they don't
	if(!applied_trauma)
		return
	if (viewer.has_trauma_type(applied_trauma))
		return
	if(IS_HERETIC(viewer))
		return
	if(viewer.can_block_magic(MAGIC_RESISTANCE))
		return
	to_chat(viewer, span_notice(text_to_display))
	viewer.gain_trauma(applied_trauma, TRAUMA_RESILIENCE_SURGERY)
	viewer.emote("scream")
	to_chat(viewer, span_warning("As you gaze upon the painting your mind rends to its truth!"))

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	if(!user.can_block_magic(MAGIC_RESISTANCE))
		user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
		to_chat(user, span_notice("Laughter echoes through your mind...."))
	qdel(src)

// On examine eldritch paintings give a trait so their effects can not be spammed
/obj/structure/sign/painting/eldritch/examine(mob/living/carbon/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	ADD_TRAIT(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src))
	addtimer(TRAIT_CALLBACK_REMOVE(user, TRAIT_ELDRITCH_PAINTING_EXAMINE, REF(src)), 3 MINUTES)
	examine_effects(user)

/obj/structure/sign/painting/eldritch/proc/examine_effects(mob/living/carbon/examiner)
	if(IS_HERETIC(examiner))
		to_chat(examiner, span_notice("Oh, what arts!"))
	else
		to_chat(examiner, span_notice("Kinda strange painting."))

// The sister and He Who Wept eldritch painting
/obj/item/wallframe/painting/eldritch/weeping
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN."
	icon_state = "eldritch_painting_weeping"
	result_path = /obj/structure/sign/painting/eldritch/weeping

/obj/structure/sign/painting/eldritch/weeping
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN. Destroyable with wirecutters."
	icon_state = "eldritch_painting_weeping"
	applied_trauma = /datum/brain_trauma/severe/weeping
	text_to_display = "Oh what arts! She is so fair, and he...HE WEEPS!!!"

/obj/structure/sign/painting/eldritch/weeping/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		to_chat(examiner, span_notice("Respite, for now...."))
		examiner.mob_mood.mood_events.Remove("eldritch_weeping")
		examiner.add_mood_event("weeping_withdrawl", /datum/mood_event/eldritch_painting/weeping_withdrawl)
		return

	to_chat(examiner, span_notice("Oh, what arts! Just gazing upon it clears your mind."))
	examiner.remove_status_effect(/datum/status_effect/hallucination)
	examiner.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)

// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "The First Desire"
	desc = "A painting depicting a platter of flesh, just looking at it makes your stomach knot and mouth froth."
	icon_state = "eldritch_painting_desire"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/structure/sign/painting/eldritch/desire
	name = "The First Desire"
	desc = "A painting depicting a platter of flesh, just looking at it makes your stomach knot and mouth froth. Destroyable with wirecutters."
	icon_state = "eldritch_painting_desire"
	applied_trauma = /datum/brain_trauma/severe/flesh_desire
	text_to_display = "What an artwork, just looking at it makes me hunger...."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine_effects(mob/living/carbon/examiner)
	if(!IS_HERETIC(examiner))
		// Gives them some nutrition
		examiner.adjust_nutrition(50)
		to_chat(examiner, warning("You feel a searing pain in your stomach!"))
		examiner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		to_chat(examiner, span_notice("You feel less hungry, but more empty somehow?"))
		examiner.add_mood_event("respite_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_examine)
		return

	// A list made of the organs and bodyparts the heretic can get
	var/static/list/random_bodypart_or_organ = list(
		/obj/item/organ/internal/brain,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/ears,
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/appendix,
		/obj/item/bodypart/arm/left,
		/obj/item/bodypart/arm/right,
		/obj/item/bodypart/leg/left,
		/obj/item/bodypart/leg/right
	)
	var/organ_or_bodypart_to_spawn = pick(random_bodypart_or_organ)
	new organ_or_bodypart_to_spawn(drop_location())
	to_chat(examiner, span_notice("A piece of flesh crawls out of the painting and flops onto the floor."))
	// Adds a negative mood event to our heretic
	examiner.add_mood_event("heretic_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_heretic)

// Great chaparral over rolling hills, this one doesn't have the sensor type
/obj/item/wallframe/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "A painting depicting a massive thicket, it seems to be attempting to crawl through the frame."
	icon_state = "eldritch_painting_vines"
	result_path = /obj/structure/sign/painting/eldritch/vines

/obj/structure/sign/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "A painting depicting a massive thicket, it seems to be attempting to crawl through the frame. Destroyable with wirecutters."
	icon_state = "eldritch_painting_vines"
	applied_trauma = null
	// A static list of 5 pretty strong mutations, simple to expand for any admins
	var/list/mutations = list(
		/datum/spacevine_mutation/hardened,
		/datum/spacevine_mutation/toxicity,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/aggressive_spread,
		)
	// Poppy and harebell are used in heretic rituals
	var/list/items_to_spawn = list(
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/harebell,
	)

/obj/structure/sign/painting/eldritch/vines/Initialize(mapload, dir, building)
	. = ..()
	new /datum/spacevine_controller(get_turf(src), mutations, 0, 10)

/obj/structure/sign/painting/eldritch/vines/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!IS_HERETIC(examiner))
		new /datum/spacevine_controller(get_turf(examiner), mutations, 0, 10)
		to_chat(examiner, span_notice("The thicket crawls through the frame, and you suddenly find vines beneath you..."))
		return

	var/item_to_spawn = pick(items_to_spawn)
	to_chat(examiner, span_notice("You picture yourself in the thicket picking flowers.."))
	new item_to_spawn(examiner.drop_location())
	examiner.add_mood_event("heretic_vines", /datum/mood_event/eldritch_painting/heretic_vines)


// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "Lady out of gates"
	desc = "A painting depicting a perfect lady, and I must be perfect like her..."
	icon_state = "eldritch_painting_beauty"
	result_path = /obj/structure/sign/painting/eldritch/beauty

/obj/structure/sign/painting/eldritch/beauty
	name = "Lady out of gates"
	desc = "A painting depicting a perfect lady, and I must be perfect like her. Destroyable with wirecutters."
	icon_state = "eldritch_painting_beauty"
	applied_trauma = /datum/brain_trauma/severe/eldritch_beauty
	text_to_display = "Her flesh glows in the pale light, and mine can too...If it wasnt for these imperfections...."
	// Set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone)

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/beauty/examine_effects(mob/living/carbon/examiner)
	. = ..()
	if(!examiner.has_dna())
		return

	if(!IS_HERETIC(examiner))
		to_chat(examiner, "You feel changed, more perfect....")
		examiner.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
		return

	to_chat(examiner, "Your imperfections shed and you are restored.")
	examiner.reagents.add_reagent(reagents_to_add, 5)

// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "Climb over the rusted mountain"
	desc = "A painting depicting something climbing a mountain of rust, it gives you an eerie feeling."
	icon_state = "eldritch_painting_rust"
	result_path = /obj/structure/sign/painting/eldritch/rust

/obj/structure/sign/painting/eldritch/rust
	name = "Climb over the rusted mountain"
	desc = "A painting depicting something climbing a mountain of rust, it gives you an eerie feeling. Destroyable with wirecutters."
	icon_state = "eldritch_painting_rust"
	applied_trauma = /datum/brain_trauma/severe/rusting
	text_to_display = "It climbs, and I will aid it...The rust calls and I shall answer..."

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine_effects(mob/living/carbon/examiner)
	. = ..()

	if(!IS_HERETIC(examiner))
		to_chat(examiner, "It can wait...")
		examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_examine)
		return

	to_chat(examiner, "You see the climber, and are inspired by it!")
	examiner.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_heretic_examine)
