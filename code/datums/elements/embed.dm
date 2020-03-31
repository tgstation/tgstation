/*
	The presence of this element allows an item (or a projectile carrying an item) to embed itself in a human or turf when it is thrown into a target (whether by hand, gun, or explosive wave) with either
	at least 4 throwspeed (EMBED_THROWSPEED_THRESHOLD) or ignore_throwspeed_threshold set to TRUE. Items meant to be used as shrapnel for projectiles should have ignore_throwspeed_threshold set to true.

	Whether we're dealing with a direct /obj/item (throwing a knife at someone) or an /obj/projectile with a shrapnel_type, how we handle things plays out the same, with one extra step separating them.
	Items simply make their COMSIG_MOVABLE_IMPACT or COMSIG_MOVABLE_IMPACT_ZONE check (against a closed turf or a carbon, respectively), while projectiles check on COMSIG_PROJECTILE_SELF_ON_HIT.
	Upon a projectile hitting a valid target, it spawns whatever type of payload it has defined, then has that try to embed itself in the target on its own.

	Otherwise non-embeddable or stickable items can be made embeddable/stickable through wizard events/sticky tape/admin memes.
*/

#define STANDARD_WALL_HARDNESS 40

/datum/element/embed
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/initialized = FALSE /// whether we can skip assigning all the vars (since these are bespoke elements, we don't have to reset the vars every time we attach to something, we already know what we are!)

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
	var/payload_type
	var/embed_chance_turf_mod

/datum/element/embed/Attach(datum/target, embed_chance, fall_chance, pain_chance, pain_mult, remove_pain_mult, impact_pain_mult, rip_time, ignore_throwspeed_threshold, jostle_chance, jostle_pain_mult, pain_stam_pct, embed_chance_turf_mod, projectile_payload=/obj/item/shard)
	. = ..()

	if(!isitem(target) && !isprojectile(target))
		return ELEMENT_INCOMPATIBLE

	if(isitem(target))
		RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, .proc/checkEmbedMob)
		RegisterSignal(target, COMSIG_MOVABLE_IMPACT, .proc/checkEmbedOther)
		RegisterSignal(target, COMSIG_ELEMENT_ATTACH, .proc/severancePackage)
		RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/examined)
		RegisterSignal(target, COMSIG_EMBED_TRY_FORCE, .proc/tryForceEmbed)
		RegisterSignal(target, COMSIG_ITEM_DISABLE_EMBED, .proc/detachFromWeapon)
		if(!initialized)
			src.embed_chance = embed_chance
			src.fall_chance = fall_chance
			src.pain_chance = pain_chance
			src.pain_mult = pain_mult
			src.remove_pain_mult = remove_pain_mult
			src.rip_time = rip_time
			src.impact_pain_mult = impact_pain_mult
			src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
			src.jostle_chance = jostle_chance
			src.jostle_pain_mult = jostle_pain_mult
			src.pain_stam_pct = pain_stam_pct
			src.embed_chance_turf_mod = embed_chance_turf_mod
			initialized = TRUE
	else
		payload_type = projectile_payload
		RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/checkEmbedProjectile)


/datum/element/embed/Detach(obj/target)
	. = ..()
	if(isitem(target))
		UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_ELEMENT_ATTACH, COMSIG_MOVABLE_IMPACT, COMSIG_PARENT_EXAMINE, COMSIG_EMBED_TRY_FORCE, COMSIG_ITEM_DISABLE_EMBED))
	else
		UnregisterSignal(target, list(COMSIG_PROJECTILE_SELF_ON_HIT))


/// Checking to see if we're gonna embed into a human
/datum/element/embed/proc/checkEmbedMob(obj/item/weapon, mob/living/carbon/victim, hit_zone, datum/thrownthing/throwingdatum, forced=FALSE)
	if(!istype(victim) || HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return

	var/actual_chance = embed_chance

	if(!weapon.isEmbedHarmless()) // all the armor in the world won't save you from a kick me sign
		var/armor = max(victim.run_armor_check(hit_zone, "bullet", silent=TRUE), victim.run_armor_check(hit_zone, "bomb", silent=TRUE)) // we'll be nice and take the better of bullet and bomb armor

		if(armor) // we only care about armor penetration if there's actually armor to penetrate
			var/pen_mod = -armor + weapon.armour_penetration // even a little bit of armor can make a big difference for shrapnel with large negative armor pen
			actual_chance += pen_mod // doing the armor pen as a separate calc just in case this ever gets expanded on
			if(actual_chance <= 0)
				victim.visible_message("<span class='danger'>[weapon] bounces off [victim]'s armor!</span>", "<span class='notice'>[weapon] bounces off your armor!</span>", vision_distance = COMBAT_MESSAGE_RANGE)
				return

	var/roll_embed = prob(actual_chance)
	var/pass = forced || ((((throwingdatum ? throwingdatum.speed : weapon.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || ignore_throwspeed_threshold) && roll_embed)
	if(!pass)
		return

	var/obj/item/bodypart/limb = victim.get_bodypart(hit_zone) || pick(victim.bodyparts)
	victim.AddComponent(/datum/component/embedded,\
		weapon,\
		throwingdatum,\
		part = limb,\
		embed_chance = embed_chance,\
		fall_chance = fall_chance,\
		pain_chance = pain_chance,\
		pain_mult = pain_mult,\
		remove_pain_mult = remove_pain_mult,\
		rip_time = rip_time,\
		ignore_throwspeed_threshold = ignore_throwspeed_threshold,\
		jostle_chance = jostle_chance,\
		jostle_pain_mult = jostle_pain_mult,\
		pain_stam_pct = pain_stam_pct,\
		embed_chance_turf_mod = embed_chance_turf_mod)

	return TRUE

/// We need the hit_zone if we're embedding into a human, so this proc only handles if we're embedding into a turf
/datum/element/embed/proc/checkEmbedOther(obj/item/weapon, turf/closed/hit, datum/thrownthing/throwingdatum, forced=FALSE)
	if(!istype(hit))
		return

	var/chance = embed_chance + embed_chance_turf_mod
	if(iswallturf(hit))
		var/turf/closed/wall/W = hit
		chance += 2 * (W.hardness - STANDARD_WALL_HARDNESS)

	if(!forced && chance <= 0 || embed_chance_turf_mod <= -100)
		return

	var/pass = ((((throwingdatum ? throwingdatum.speed : weapon.throw_speed) >= EMBED_THROWSPEED_THRESHOLD) || ignore_throwspeed_threshold) && prob(chance))
	if(!pass)
		return

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
		pain_stam_pct = pain_stam_pct,\
		embed_chance_turf_mod = embed_chance_turf_mod)

	return TRUE

///A different embed element has been attached, so we'll detach and let them handle things
/datum/element/embed/proc/severancePackage(obj/item/weapon, datum/element/E)
	if(istype(E, /datum/element/embed))
		Detach(weapon)

///If we don't want to be embeddable anymore (deactivating an e-dagger for instance)
/datum/element/embed/proc/detachFromWeapon(obj/weapon)
	Detach(weapon)

///Someone inspected our embeddable item
/datum/element/embed/proc/examined(obj/item/I, mob/user, list/examine_list)
	if(I.isEmbedHarmless())
		examine_list += "[I] feels sticky, and could probably get stuck to someone if thrown properly!"
	else
		examine_list += "[I] has a fine point, and could probably embed in someone if thrown properly!"

/**
  * checkEmbedProjectile() is what we get when a projectile with a defined shrapnel_type impacts a target.
  *
  * If we hit a valid target (carbon or closed turf), we create the shrapnel_type object and immediately call tryEmbed() on it, targeting what we impacted. That will lead
  *	it to call tryForceEmbed() on its own embed element (it's out of our hands here, our projectile is done), where it will run through all the checks it needs to.
  */
/datum/element/embed/proc/checkEmbedProjectile(obj/projectile/P, atom/movable/firer, atom/hit)
	if(!iscarbon(hit) && !isclosedturf(hit))
		Detach(P)
		return // we don't care

	var/obj/item/payload = new payload_type(get_turf(hit))
	var/did_embed
	if(iscarbon(hit))
		var/mob/living/carbon/C = hit
		var/obj/item/bodypart/limb = C.get_bodypart(C.check_limb_hit(P.def_zone))
		did_embed = payload.tryEmbed(limb)
	else
		did_embed = payload.tryEmbed(hit)

	if(!did_embed)
		payload.failedEmbed()
	Detach(P)

/**
  * tryForceEmbed() is called here when we fire COMSIG_EMBED_TRY_FORCE from [/obj/item/proc/tryEmbed]. Mostly, this means we're a piece of shrapnel from a projectile that just impacted something, and we're trying to embed in it.
  *
  * The reason for this extra mucking about is avoiding having to do an extra hitby(), and annoying the target by impacting them once with the projectile, then again with the shrapnel (which likely represents said bullet), and possibly
  * AGAIN if we actually embed. This way, we save on at least one message. Runs the standard embed checks on the mob/turf.
  *
  * Arguments:
  * * I- what we're trying to embed, obviously
  * * target- what we're trying to shish-kabob, either a bodypart, a carbon, or a closed turf
  * * hit_zone- if our target is a carbon, try to hit them in this zone, if we don't have one, pick a random one. If our target is a bodypart, we already know where we're hitting.
  * * forced- if we want this to succeed 100%
  */
/datum/element/embed/proc/tryForceEmbed(obj/item/I, atom/target, hit_zone, forced=FALSE)
	var/obj/item/bodypart/limb
	var/mob/living/carbon/C
	var/turf/closed/T

	if(!forced && !prob(embed_chance))
		return

	if(iscarbon(target))
		C = target
		if(!hit_zone)
			limb = pick(C.bodyparts)
			hit_zone = limb.body_zone
	else if(isbodypart(target))
		limb = target
		C = limb.owner
	else if(isclosedturf(target))
		T = target

	if(C)
		return checkEmbedMob(I, C, hit_zone, forced=TRUE)
	else if(T)
		return checkEmbedOther(I, T, forced=TRUE)
