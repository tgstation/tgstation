
// The sister and He Who Wept eldritch painting
// All eldritch paintings are based on this one, with some light changes
/obj/item/wallframe/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN."
	icon = 'icons/obj/signs.dmi'
	resistance_flags = FLAMMABLE
	flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch
	pixel_shift = 30

/obj/structure/sign/painting/eldritch
	name = "The sister and He Who Wept"
	desc = "A beautiful artwork depicting a fair lady and HIM, HE WEEPS, I WILL SEE HIM AGAIN. Destroyable with wirecutters."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	buildable_sign = FALSE
	// The list of canvas types accepted by this frame, set to zero here
	accepted_canvas_types = list()
	// This stops people hiding their sneaky posters behind signs
	layer = CORGI_ASS_PIN_LAYER
	// A basic proximity sensor
	var/datum/proximity_monitor/painting_proximity_sensor
	// For changing sensor types on subtypes
	var/sensor_type = /datum/proximity_monitor/advanced/eldritch_painting
	// Set to false since we don't want this to persist
	persistence_id = FALSE

// Mood applied for ripping the painting
// These moods are here to check hallucinations and provide easier user feedback
/datum/mood_event/eldritch_painting
	description = "YOU, I SHOULD NOT HAVE DONE THAT!!!"
	mood_change = -6
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/weeping
	description = "HE IS HERE, AND HE WEEPS!"
	mood_change = -3
	timeout = 10 SECONDS

/datum/mood_event/eldritch_painting/weeping_heretic
	description = "Oh such arts! They truly inspire me!"
	mood_change = 5
	timeout = 5 MINUTES

/datum/mood_event/eldritch_painting/weeping_withdrawl
	description = "My mind is clear from his influence."
	mood_change = 1
	timeout = 5 MINUTES

/obj/structure/sign/painting/eldritch/Initialize(mapload, dir, building)
	if(sensor_type)
		painting_proximity_sensor = new sensor_type(_host = src, range = 7, _ignore_if_not_on_turf = TRUE)
	return ..()

/obj/structure/sign/painting/eldritch/wirecutter_act(mob/living/user, obj/item/I)
	user.add_mood_event("ripped_eldritch_painting", /datum/mood_event/eldritch_painting)
	to_chat(user, span_notice("laughter echoes through your mind"))
	QDEL_NULL(painting_proximity_sensor)
	qdel(src)

/obj/structure/sign/painting/eldritch/examine(mob/living/carbon/user)
	if(IS_HERETIC(user))
		// If they already have the positive moodlet return
		if("heretic_eldritch_painting" in user.mob_mood.mood_events)
			return
		to_chat(user, span_notice("Oh, what arts! Just gazing upon it clears your mind."))
		// Adjusts every hallucination by -300, thus removing them if we have any
		user.adjust_hallucinations(-300 SECONDS)
		// Adds a very good mood event to the heretic
		user.add_mood_event("heretic_eldritch_painting", /datum/mood_event/eldritch_painting/weeping_heretic)
	// Do they have the mood event added with the hallucination?
	if("eldritch_weeping" in user.mob_mood.mood_events)
		to_chat(user, span_notice("Respite, for now...."))
		// Remove the mood event associated with the hallucinations
		user.mob_mood.mood_events.Remove("eldritch_weeping")
		// Add a mood event that causes the hallucinations to not trigger anymore
		user.add_mood_event("weeping_withdrawl", /datum/mood_event/eldritch_painting/weeping_withdrawl)

// Applies an affect on view
/datum/proximity_monitor/advanced/eldritch_painting
	var/applied_trauma = /datum/brain_trauma/severe/weeping
	var/text_to_display = "Oh what arts! She is so fair, and he...HE WEEPS!!!"

/datum/proximity_monitor/advanced/eldritch_painting/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	. = ..()

/datum/proximity_monitor/advanced/eldritch_painting/field_turf_crossed(atom/movable/crossed, turf/location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_seen(crossed)

/datum/proximity_monitor/advanced/eldritch_painting/proc/on_seen(mob/living/carbon/human/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	if (viewer.has_trauma_type(applied_trauma))
		return
	if(IS_HERETIC(viewer))
		return
	to_chat(viewer, span_notice(text_to_display))
	viewer.gain_trauma(applied_trauma, TRAUMA_RESILIENCE_ABSOLUTE)

/*
 * A brain trauma that this eldritch paintings apply
 * This one is for "The Sister and He Who Wept" or /obj/structure/sign/painting/eldritch
 */
/datum/brain_trauma/severe/weeping
	name = "The Weeping"
	desc = "Patient hallucinates everyone as a figure called He Who Wept"
	scan_desc = "H_E##%%%WEEP6%11S!!,)()"
	gain_text = span_warning("HE WEEPS AND I WILL SEE HIM ONCE MORE")
	lose_text = span_notice("You feel the tendrils of something slip from your mind.")

/datum/brain_trauma/severe/weeping/on_life(seconds_per_tick, times_fired)
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	// If they have the weeping withdrawl mood event return
	if("weeping_withdrawl" in owner.mob_mood.mood_events)
		return
	// If they already have the weeping mood event return, its duration is the same as the hallucination so this is done to prevent large amounts of lag
	if("eldritch_weeping" in owner.mob_mood.mood_events)
		return
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	..()

/datum/brain_trauma/severe/weeping/on_gain()
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping brain trauma")
	..()



// The First Desire painting, using a lot of the painting/eldritch framework
/obj/item/wallframe/painting/eldritch/desire
	name = "The First Desire"
	desc = "A painting depicting a platter of flesh, just looking at it makes your stomach knot and mouth froth."
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch/desire

/obj/structure/sign/painting/eldritch/desire
	name = "The First Desire"
	desc = "A painting depicting a platter of flesh, just looking at it makes your stomach knot and mouth froth. Destroyable with wirecutters."
	icon_state = "frame-empty"
	sensor_type = /datum/proximity_monitor/advanced/eldritch_painting/desire

// Moodlets used to track hunger and provide feedback
/datum/mood_event/eldritch_painting/desire_heretic
	description = "A part gained, the manus takes and gives. What did it take from me?"
	mood_change = -2
	timeout = 1 MINUTES

/datum/mood_event/eldritch_painting/desire_examine
	description = "A hunger kept at bay..."
	mood_change = 3
	timeout = 1 MINUTES

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/desire/examine(mob/living/carbon/user)
	if(IS_HERETIC(user))
		// If they already have the negative moodlet return
		if("heretic_eldritch_hunger" in user.mob_mood.mood_events)
			return
		// A list made of the organs and bodyparts the heretic possess
		var/list/random_bodypart_or_organ = list(
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
		new organ_or_bodypart_to_spawn(src.loc)
		to_chat(user, span_notice("A piece of flesh crawls out of the painting and flops onto the floor."))
		// Adds a negative mood event to our heretic
		user.add_mood_event("heretic_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_heretic)

	// Do they have the mood event added on examine, if so return
	if ("respite_eldritch_hunger" in user.mob_mood.mood_events)
		to_chat(user, span_notice("You are still full from your last viewing!"))
		return

	if (user.has_trauma_type(/datum/brain_trauma/severe/flesh_desire))
		// Gives them some nutrition
		user.adjust_nutrition(50)
		to_chat(user, warning("You feel a searing pain in your stomach!"))
		user.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		to_chat(user, span_notice("You feel less hungry, but more empty somehow?"))
		user.add_mood_event("respite_eldritch_hunger", /datum/mood_event/eldritch_painting/desire_examine)


// Specific proximity monitor for The First Desire or /obj/item/wallframe/painting/eldritch/desire
/datum/proximity_monitor/advanced/eldritch_painting/desire
	applied_trauma = /datum/brain_trauma/severe/flesh_desire
	text_to_display = "What an artwork, just looking at it makes me hunger...."

/*
 * A brain trauma that this eldritch paintings apply
 * This one is for "The First Desire" or /obj/structure/sign/painting/eldritch/desire
 */
/datum/brain_trauma/severe/flesh_desire
	name = "The Desire for Flesh"
	desc = "Patient seems to only be able to eat organs or raw flesh for nutrients, also seems to become hungrier at a faster rate"
	scan_desc = "H_(82882)G3E:__))9R"
	gain_text = span_warning("I feel a hunger, only organs and flesh will feed it...")
	lose_text = span_notice("Your stomach no longer craves flesh, and your tongue feels duller.")
	/// How much faster we loose hunger
	var/hunger_rate = 15

/datum/brain_trauma/severe/flesh_desire/on_gain()
	// Allows them to eat faster, mainly for flavor
	owner.add_traits(TRAIT_VORACIOUS)
	// We don't want this to be bypassed by Aguesia so if they have it, remove it
	if(HAS_TRAIT(owner, TRAIT_AGEUSIA))
		owner.remove_traits(TRAIT_AGEUSIA)
	// If they have a tongue, make it crave meat
	var/obj/item/organ/internal/tongue/tongue = owner.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_foodtypes = GORE | MEAT
	..()

/datum/brain_trauma/severe/flesh_desire/on_life(seconds_per_tick, times_fired)
	// Causes them to need to eat at 10x the normal rate
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(prob(2))
		to_chat(owner, span_notice("You feel a ravenous hunger for flesh..."))
	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

/datum/brain_trauma/severe/flesh_desire/on_lose()
	owner.remove_traits(TRAIT_VORACIOUS)
	// After loosing this trauma you also loose the ability to taste, sad!
	owner.add_traits(TRAIT_AGEUSIA)
	..()



// Great chaparral over rolling hills, this one doesn't have the sensor type
/obj/item/wallframe/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "A painting depicting a massive thicket, it seems to be attempting to crawl through the frame."
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch/vines

/obj/structure/sign/painting/eldritch/vines
	name = "Great chaparral over rolling hills"
	desc = "A painting depicting a massive thicket, it seems to be attempting to crawl through the frame. Destroyable with wirecutters."
	icon_state = "frame-empty"
	sensor_type = null
	// A static list of 5 pretty strong mutations, simple to expand for any admins
	var/list/mutations = list(
		/datum/spacevine_mutation/hardened,
		/datum/spacevine_mutation/toxicity,
		/datum/spacevine_mutation/thorns,
		/datum/spacevine_mutation/fire_proof,
		/datum/spacevine_mutation/aggressive_spread,
		)
	// Items to pick from to spawn on examine
	var/list/items_to_spawn = list(
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/harebell,
	)

// Moodlets used to prevent rust
/datum/mood_event/eldritch_painting/heretic_vines
	description = "Oh what a lovely flower!"
	mood_change = 3
	timeout = 1 MINUTES

/obj/structure/sign/painting/eldritch/vines/Initialize(mapload, dir, building)
	new /datum/spacevine_controller(get_turf(src), mutations, 0, 10)
	return ..()

/obj/structure/sign/painting/eldritch/vines/examine(mob/living/carbon/user)
	if("heretic_vines" in user.mob_mood.mood_events)
		return

	if(IS_HERETIC(user))
		var/item_to_spawn = pick(items_to_spawn)
		to_chat(user, span_notice("You picture yourself in the thicket picking flowers.."))
		// Spawns one of two flowers that often are used by heretics
		new item_to_spawn(user.loc)
		user.add_mood_event("heretic_vines", /datum/mood_event/eldritch_painting/heretic_vines)
	else
		new /datum/spacevine_controller(get_turf(user), mutations, 0, 10)
		to_chat(user, span_notice("The thicket crawls through the frame, and you suddenly find vines beneath you..."))



// Lady out of gates, gives a brain trauma causing the person to scratch themselves
/obj/item/wallframe/painting/eldritch/beauty
	name = "Lady out of gates"
	desc = "A painting depicting a perfect lady, and I must be perfect like her..."
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch/beauty

/obj/structure/sign/painting/eldritch/beauty
	name = "Lady out of gates"
	desc = "A painting depicting a perfect lady, and I must be perfect like her. Destroyable with wirecutters."
	icon_state = "frame-empty"
	sensor_type = /datum/proximity_monitor/advanced/eldritch_painting/beauty
	// Set to mutadone by default to remove mutations
	var/list/reagents_to_add = list(/datum/reagent/medicine/mutadone)

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/beauty/examine(mob/living/carbon/human/user)
	if(IS_HERETIC(user))
		to_chat(user, "Your imperfections shed and you are restored.")
		user.reagents.add_reagent(reagents_to_add, 5)
	if(!user.has_dna())
		return
	if(user.has_trauma_type(/datum/brain_trauma/severe/eldritch_beauty))
		to_chat(user, "You feel changed, more perfect....")
		user.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)


// Specific proximity monitor for Lady out of gates or /obj/item/wallframe/painting/eldritch/beauty
/datum/proximity_monitor/advanced/eldritch_painting/beauty
	applied_trauma = /datum/brain_trauma/severe/eldritch_beauty
	text_to_display = "Her flesh glows in the pale light, and mine can too...If it wasnt for these imperfections...."

/datum/brain_trauma/severe/eldritch_beauty
	name = "The Pursuit of perfection"
	desc = "Patient seems to furiously scratch at their body, the only way to make them cease is for them to remove their jumpsuit."
	scan_desc = "I_)8(P_E##R&&F(E)C__T)"
	gain_text = span_warning("I WILL RID MY FLESH FROM IMPERFECTION!! I WILL BE PERFECT WITHOUT MY SUITS!!")
	lose_text = span_notice("You feel the influence of something slip your mind, and you feel content as you are.")
	/// How much damage we deal with each scratch
	var/scratch_damage = 0.5

/datum/brain_trauma/severe/eldritch_beauty/on_life(seconds_per_tick, times_fired)
	// If they don't have a jumpsuit, return. They are encouraged to remove their jumpsuit to avoid damage.
	if(!owner.get_item_by_slot(ITEM_SLOT_ICLOTHING))
		return

	// Scratching code
	var/obj/item/bodypart/bodypart = owner.get_bodypart(owner.get_random_valid_zone(even_weights = TRUE))
	if(bodypart && IS_ORGANIC_LIMB(bodypart) && !(bodypart.bodypart_flags & BODYPART_PSEUDOPART))
		if(!owner.incapacitated())
			bodypart.receive_damage(scratch_damage)
			if(prob(2))
				to_chat(owner, span_notice("You scratch furiously at [bodypart] to rid its imperfections!"))



// Climb over the rusted mountain, gives a brain trauma causing the person to randomly rust tiles beneath them
/obj/item/wallframe/painting/eldritch/rust
	name = "Climb over the rusted mountain"
	desc = "A painting depicting something climbing a mountain of rust, it gives you an eerie feeling."
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting/eldritch/rust

/obj/structure/sign/painting/eldritch/rust
	name = "Climb over the rusted mountain"
	desc = "A painting depicting something climbing a mountain of rust, it gives you an eerie feeling. Destroyable with wirecutters."
	icon_state = "frame-empty"
	sensor_type = /datum/proximity_monitor/advanced/eldritch_painting/rust
	// This item is popped up on examine by a heretic
	var/list/item_on_examine = list(/obj/item/ammo_box/strilka310/lionhunter)

// Moodlets used to prevent rust and give a positive moodlet for heretics
/datum/mood_event/eldritch_painting/rust_examine
	description = "The rusted climb can wait..."
	mood_change = -2
	timeout = 3 MINUTES

/datum/mood_event/eldritch_painting/rust_heretic_examine
	description = "I must hurry the rusted climb!"
	mood_change = 4
	timeout = 5 MINUTES

// The special examine interaction for this painting
/obj/structure/sign/painting/eldritch/rust/examine(mob/living/carbon/human/user)
	if("rusted_examine" in user.mob_mood.mood_events)
		return

	if(IS_HERETIC(user))
		to_chat(user, "You see the climber reach and drop something.")
		user.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_heretic_examine)
		new item_on_examine(user.loc)

	if(user.has_trauma_type(/datum/brain_trauma/severe/rusting))
		to_chat(user, "It can wait...")
		user.add_mood_event("rusted_examine", /datum/mood_event/eldritch_painting/rust_examine)


// Specific proximity monitor for Climb over the rusted mountain or /obj/item/wallframe/painting/eldritch/rust
/datum/proximity_monitor/advanced/eldritch_painting/rust
	applied_trauma = /datum/brain_trauma/severe/rusting
	text_to_display = "It climbs, and I will aid it...The rust calls and I shall answer..."

/*
 * A brain trauma that this eldritch paintings apply
 * This one is for "Climb over the rusted mountain" or /obj/structure/sign/painting/eldritch/rust
 */
/datum/brain_trauma/severe/rusting
	name = "The Rusted Climb"
	desc = "Patient seems to oxidise things around them at random, and seem to believe they are aiding a creature in climbing a mountin."
	scan_desc = "C_)L(#_I_##M;B"
	gain_text = span_warning("The rusted climb shall finish at the peak")
	lose_text = span_notice("The rusted climb? Whats that? An odd dream to be sure.")

/datum/brain_trauma/severe/rusting/on_life(seconds_per_tick, times_fired)
	var/atom/tile = get_turf(owner)
	// If they have the special mood event for rusted climb they don't start rusting tiles beneath them
	if("rusted_examine" in owner.mob_mood.mood_events)
		return

	if(prob(2))
		to_chat(owner, span_notice("You feel eldritch energies pulse from your body!"))
		tile.rust_heretic_act()
