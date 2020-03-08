/*
	The presence of this element allows an item to embed itself in a human or turf when it is thrown into a target (whether by hand, gun, or explosive wave)
	with either at least 4 throwspeed (EMBED_THROWSPEED_THRESHOLD) or ignore_throwspeed_threshold set to TRUE.

	This element is granted primarily to any /obj/item that has something in its /embedding var, which should be formatted as a list. If you wish to be able to
	grant/rescind the ability for an item to embed (say, when activating and deactivating an edagger), you can do so in two ways:

		1. Drop the throw_speed var below EMBED_THROWSPEED_THRESHOLD (object will still be able to otherwise embed if thrown at high speed by something else like a blast)
		2. Add/Remove the embed element as needed (won't be able to embed at all)

	Otherwise non-embeddable or stickable items can be made embeddable/stickable through wizard events/sticky tape/admin memes.

*/

#define STANDARD_WALL_HARDNESS 40

/datum/element/embed
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance
	var/fall_chance
	var/pain_chance
	var/pain_mult
	var/remove_pain_mult
	var/impact_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct

/datum/element/embed/Attach(datum/target, list/embedArgs)
	. = ..()
	parseArgs(arglist(embedArgs))

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, .proc/checkEmbedMob)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/checkEmbedOther)
	RegisterSignal(target, COMSIG_ELEMENT_ATTACH, .proc/severancePackage)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/examined)


/datum/element/embed/Detach(obj/item/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_ELEMENT_ATTACH, COMSIG_MOVABLE_IMPACT, COMSIG_PARENT_EXAMINE))


/// Checking to see if we're gonna embed into a human
/datum/element/embed/proc/checkEmbedMob(obj/item/weapon, mob/living/carbon/human/victim, hit_zone, datum/thrownthing/throwingdatum)
	if(!istype(victim))
		return

	if((((throwingdatum ? throwingdatum.speed : weapon.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || ignore_throwspeed_threshold) && prob(embed_chance) && !HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		victim.AddComponent(/datum/component/embedded,\
			weapon,\
			throwingdatum,\
			embed_chance = embed_chance,\
			fall_chance = fall_chance,\
			pain_chance = pain_chance,\
			pain_mult = pain_mult,\
			remove_pain_mult = remove_pain_mult,\
			rip_time = rip_time,\
			ignore_throwspeed_threshold = ignore_throwspeed_threshold,\
			jostle_chance = jostle_chance,\
			jostle_pain_mult = jostle_pain_mult,\
			pain_stam_pct = pain_stam_pct)


/// We need the hit_zone if we're embedding into a human, so this proc only handled if we're embedding into a turf
/datum/element/embed/proc/checkEmbedOther(obj/item/weapon, turf/closed/hit, datum/thrownthing/throwingdatum)
	if(!istype(hit))
		return

	var/chance = embed_chance
	if(iswallturf(hit))
		var/turf/closed/wall/W = hit
		chance += 2 * (W.hardness - STANDARD_WALL_HARDNESS)

	if((((throwingdatum ? throwingdatum.speed : weapon.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || ignore_throwspeed_threshold) && prob(chance))
		hit.AddComponent(/datum/component/embedded,\
			weapon,\
			throwingdatum,\
			embed_chance = embed_chance,\
			fall_chance = fall_chance,\
			pain_chance = pain_chance,\
			pain_mult = pain_mult,\
			remove_pain_mult = remove_pain_mult,\
			rip_time = rip_time,\
			ignore_throwspeed_threshold = ignore_throwspeed_threshold,\
			jostle_chance = jostle_chance,\
			jostle_pain_mult = jostle_pain_mult,\
			pain_stam_pct = pain_stam_pct)

/datum/element/embed/proc/parseArgs(embed_chance = EMBED_CHANCE,
		fall_chance = EMBEDDED_ITEM_FALLOUT,
		pain_chance = EMBEDDED_PAIN_CHANCE,
		pain_mult = EMBEDDED_PAIN_MULTIPLIER,
		remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
		rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
		impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
		ignore_throwspeed_threshold = FALSE,
		jostle_chance = EMBEDDED_JOSTLE_CHANCE,
		jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
		pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)

	src.embed_chance = embed_chance
	src.fall_chance = fall_chance
	src.pain_chance = pain_chance
	src.pain_mult = pain_mult
	src.remove_pain_mult = remove_pain_mult
	src.impact_pain_mult = impact_pain_mult
	src.rip_time = rip_time
	src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	src.jostle_chance = jostle_chance
	src.jostle_pain_mult = jostle_pain_mult
	src.pain_stam_pct = pain_stam_pct

///A different embed element has been attached, so we'll detach and let them handle things
/datum/element/embed/proc/severancePackage(obj/item/weapon, datum/element/E)
	if(istype(E, /datum/element/embed))
		Detach(weapon)

/datum/element/embed/proc/examined(obj/item/I, mob/user, list/examine_list)
	if(!pain_mult && !jostle_pain_mult)
		examine_list += "[I] feels sticky, and could probably get stuck to someone if thrown properly!"
	else
		examine_list += "[I] has a fine point, and could probably embed in someone if thrown properly!"
