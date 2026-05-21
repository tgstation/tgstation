/datum/religion_rites/banish_nightmare
	name = "Banish Nightmare"
	desc = "Banish the corpse of a Nightmare or its heart back from whence it came, protecting the dreams of \
		the station and earning favor. If a heart is present, you will be rewarded with a special blessing."
	favor_cost = 0
	ritual_length = 20 SECONDS

/datum/religion_rites/banish_nightmare/New()
	. = ..()
	ritual_invocations = list(
		"We have bested a terrible Nightmare that plagued our station!..",
		"With the power of [GLOB.deity], we cast it out!..",
		"This invader of dreams has no place here...",
		"May it trouble our flock no longer.",
	)

/datum/religion_rites/banish_nightmare/perform_rite(mob/living/user, atom/religious_tool)
	var/has_nightmare = FALSE
	for(var/mob/living/carbon/human/nightmare in get_turf(religious_tool))
		if(isnightmare(nightmare))
			has_nightmare = TRUE
			break

	for(var/obj/item/organ/organ in get_turf(religious_tool))
		if(istype(organ, /obj/item/organ/heart/nightmare))
			has_nightmare = TRUE
			break

	if(!has_nightmare)
		to_chat(user, span_warning("There is no corpse or heart of a Nightmare to banish!"))
		return FALSE

	return ..()

/datum/religion_rites/banish_nightmare/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	var/favor = 0
	var/give_heart = FALSE
	for(var/mob/living/carbon/human/nightmare in get_turf(religious_tool))
		if(!isnightmare(nightmare))
			continue

		if(istype(nightmare.get_organ_slot(ORGAN_SLOT_HEART), /obj/item/organ/heart/nightmare))
			give_heart += 1
			favor += 100

		nightmare.dust(just_ash = TRUE, drop_items = TRUE, give_moodlet = FALSE, force =TRUE)
		favor += 200

	for(var/obj/item/organ/organ in get_turf(religious_tool))
		if(!istype(organ, /obj/item/organ/heart/nightmare))
			continue

		qdel(organ)
		favor += 100
		give_heart += 1

	if(favor <= 0)
		CRASH("Banish nightmare rite invoked without finding a nightmare or nightmare heart to banish.")

	GLOB.religious_sect.adjust_favor(favor, user)
	if(give_heart)
		for(var/i in 1 to give_heart)
			new /obj/item/organ/heart/evolved/sacred/dreamer(get_turf(religious_tool))
		playsound(religious_tool, 'sound/effects/pray.ogg', 50, TRUE, frequency = 0.5)
		to_chat(user, span_hypnophrase("[GLOB.deity] blesses you."))
	else
		to_chat(user, span_hypnophrase("[GLOB.deity] smiles upon you."))
	user.add_mood_event("banish_nightmare", /datum/mood_event/banish_nightmare)

/datum/mood_event/banish_nightmare
	mood_change = 4
	description = "I banished a nightmare and protected our dreams!"
	timeout = 10 MINUTES

/obj/item/organ/heart/evolved/sacred/dreamer
	name = "blessed sacred heart"
	desc = "Banish the shadows!"
	maxHealth = STANDARD_ORGAN_THRESHOLD * 1.5
	/// Magic charges we block
	var/charges = 3

/obj/item/organ/heart/evolved/sacred/dreamer/on_life(seconds_per_tick)
	healing_probability = 5
	if(HAS_TRAIT(owner, TRAIT_DREAMING))
		healing_probability += 7.5
	if(owner.stat == UNCONSCIOUS)
		healing_probability += 7.5
	return ..()

/obj/item/organ/heart/evolved/sacred/dreamer/on_blocked()
	charges -= 1
	addtimer(CALLBACK(src, PROC_REF(recharge)), 1 MINUTES)
	playsound(owner, 'sound/effects/health/slowbeat.ogg', 80)

/obj/item/organ/heart/evolved/sacred/dreamer/check_block()
	return charges > 0

/obj/item/organ/heart/evolved/sacred/dreamer/proc/recharge()
	charges += 1
