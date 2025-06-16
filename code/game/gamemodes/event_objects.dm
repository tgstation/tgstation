/datum/armor/obj_structure/relic
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 100
	fire = 100
	acid = 100
	bio = 100

/obj/structure/cursed_thing
	name = "strange relic"
	desc = "A strange relic of the past. It seems to be made of some kind of metal, and is covered in strange runes. \
		It radiates a dark aura."
	icon = 'icons/obj/devices/artefacts.dmi'
	icon_state = "necrotech1"
	max_integrity = 1000
	armor_type = /datum/armor/obj_structure/relic
	drag_slowdown = 2
	var/list/past_examiners = list()
	var/list/past_touchers = list()

/obj/structure/cursed_thing/Initialize(mapload)
	. = ..()
	transform = transform.Scale(2, 2)
	add_filter("curse_moment", 1, outline_filter(2, COLOR_DARK_PURPLE))
	var/curse_filter = get_filter("curse_moment")
	animate(curse_filter, 2 SECONDS, alpha = 0, loop = -1)
	animate(2 SECONDS, alpha = 255, loop = -1, flags = ANIMATION_PARALLEL)
	RegisterSignal(src, COMSIG_MOVABLE_BUMP_PUSHED, PROC_REF(block_bump))

/obj/structure/cursed_thing/Destroy()
	past_examiners.Cut()
	past_touchers.Cut()
	return ..()

/obj/structure/cursed_thing/proc/block_bump(...)
	SIGNAL_HANDLER
	return COMPONENT_NO_PUSH

/obj/structure/cursed_thing/examine(mob/user)
	. = ..()
	if(!ishuman(user) || isnull(user.mind))
		return
	var/mob/living/carbon/human/examiner = user
	if(examiner.has_trauma_type(/datum/brain_trauma/hypnosis))
		return

	if(past_examiners[user.mind])
		var/datum/brain_trauma/hypnosis/curse/hypnotize = new("Touch the relic.")
		hypnotize.resilience = TRAUMA_RESILIENCE_MAGIC
		hypnotize.snap_out = FALSE
		examiner.gain_trauma(hypnotize)

	else
		past_examiners[user.mind] = TRUE
		. += span_hypnophrase("You feel a strange compulsion to touch the relic, as if it is calling out to you. \
			Have you seen it before? You could swear you have...")
		. += span_warning("Maybe you should get out of here...")

/obj/structure/cursed_thing/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) || isnull(user.mind))
		return
	if(!is_mining_level(z) && !past_touchers[user.mind])
		past_touchers[user.mind] = TRUE
		to_chat(user, span_warning("As you reach out to touch the relic, a strange feeling washes over you. \
			Yanking your hand back, you feel as if you probably shouldn't touch it again."))
		return

	var/mob/living/carbon/human/examiner = user
	var/datum/brain_trauma/hypnosis/hypnotize = examiner.has_trauma_type(__IMPLIED_TYPE__)
	if(istype(hypnotize, /datum/brain_trauma/hypnosis/curse))
		qdel(hypnotize)
	else if(hypnotize)
		return
	var/new_hypnosis = "Get more members of the crew to touch the relic."
	if(is_mining_level(z))
		new_hypnosis = "Bring the relic back to the ship. Get more members of the crew to touch it."

	hypnotize = new /datum/brain_trauma/hypnosis/curse(new_hypnosis)
	hypnotize.resilience = TRAUMA_RESILIENCE_MAGIC
	examiner.gain_trauma(hypnotize)

/datum/brain_trauma/hypnosis/curse

/datum/brain_trauma/hypnosis/curse/on_life(seconds_per_tick, times_fired)
	. = ..()
	owner.adjust_hallucinations_up_to(5 SECONDS * seconds_per_tick, 5 MINUTES)
	owner.mob_mood?.adjust_sanity(-2.5 * seconds_per_tick, minimum = SANITY_CRAZY, override = TRUE)
