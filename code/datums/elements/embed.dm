/*
	The presence of this element allows an item (or a projectile carrying an item) to embed itself in a carbon when it is thrown into a target (whether by hand, gun, or explosive wave) with either
	at least 4 throwspeed (EMBED_THROWSPEED_THRESHOLD) or ignore_throwspeed_threshold set to TRUE. Items meant to be used as shrapnel for projectiles should have ignore_throwspeed_threshold set to true.

	Whether we're dealing with a direct /obj/item (throwing a knife at someone) or an /obj/projectile with a shrapnel_type, how we handle things plays out the same, with one extra step separating them.
	Items simply make their COMSIG_MOVABLE_IMPACT_ZONE check, while projectiles check on COMSIG_PROJECTILE_SELF_ON_HIT.
	Upon a projectile hitting a valid target, it spawns whatever type of payload it has defined, then has that try to embed itself in the target on its own.

	Otherwise non-embeddable or stickable items can be made embeddable/stickable through wizard events/sticky tape/admin memes.
*/

/datum/element/embed

/datum/element/embed/Attach(datum/target)
	. = ..()

	if(!isitem(target) && !isprojectile(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ELEMENT_ATTACH, PROC_REF(sever_element))
	if(isprojectile(target))
		RegisterSignal(target, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(check_embed_projectile))
		return

	RegisterSignal(target, COMSIG_MOVABLE_IMPACT_ZONE, PROC_REF(check_embed))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_TAGS, PROC_REF(examined_tags))
	RegisterSignal(target, COMSIG_EMBED_TRY_FORCE, PROC_REF(try_force_embed))
	RegisterSignal(target, COMSIG_ITEM_DISABLE_EMBED, PROC_REF(detach_from_weapon))

/datum/element/embed/Detach(obj/target)
	. = ..()
	if(isprojectile(target))
		UnregisterSignal(target, list(COMSIG_PROJECTILE_SELF_ON_HIT, COMSIG_ELEMENT_ATTACH))
		return

	UnregisterSignal(target, list(COMSIG_MOVABLE_IMPACT_ZONE, COMSIG_ELEMENT_ATTACH, COMSIG_MOVABLE_IMPACT, COMSIG_ATOM_EXAMINE, COMSIG_EMBED_TRY_FORCE, COMSIG_ITEM_DISABLE_EMBED))

/// Checking to see if we're gonna embed into a human
/datum/element/embed/proc/check_embed(obj/item/weapon, mob/living/carbon/victim, hit_zone, blocked, datum/thrownthing/throwingdatum, forced=FALSE)
	SIGNAL_HANDLER

	if(forced)
		embed_object(weapon, victim, hit_zone, throwingdatum)
		return TRUE

	if(blocked || !istype(victim) || HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
		return FALSE

	if(HAS_TRAIT(victim, TRAIT_GODMODE))
		return FALSE

	var/flying_speed = throwingdatum?.speed || weapon.throw_speed

	if(flying_speed < EMBED_THROWSPEED_THRESHOLD && !weapon.get_embed().ignore_throwspeed_threshold)
		return FALSE

	if(!roll_embed_chance(weapon, victim, hit_zone, throwingdatum))
		return FALSE

	embed_object(weapon, victim, hit_zone, throwingdatum)
	return TRUE

/// Actually sticks the object to a victim
/datum/element/embed/proc/embed_object(obj/item/weapon, mob/living/carbon/victim, hit_zone, datum/thrownthing/throwingdatum)
	var/obj/item/bodypart/limb = victim.get_bodypart(hit_zone) || pick(victim.bodyparts)
	victim.AddComponent(/datum/component/embedded,\
		weapon,\
		throwingdatum,\
		part = limb)

///A different embed element has been attached, so we'll detach and let them handle things
/datum/element/embed/proc/sever_element(obj/weapon, datum/element/E)
	SIGNAL_HANDLER

	if(istype(E, /datum/element/embed))
		Detach(weapon)

///If we don't want to be embeddable anymore (deactivating an e-dagger for instance)
/datum/element/embed/proc/detach_from_weapon(obj/weapon)
	SIGNAL_HANDLER

	Detach(weapon)

///Someone inspected our embeddable item
/datum/element/embed/proc/examined_tags(obj/item/I, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(I.is_embed_harmless())
		examine_list["sticky"] = "[I] feels sticky, and could probably get stuck to someone if thrown properly!"
	else
		examine_list["embeddable"] = "[I] has a fine point, and could probably embed in someone if thrown properly!"

/**
 * check_embed_projectile() is what we get when a projectile with a defined shrapnel_type impacts a target.
 *
 * If we hit a valid target, we create the shrapnel_type object and then forcefully try to embed it on its
 * behalf. DO NOT EVER add an embed element to the payload and let it do the rest.
 * That's awful, and it'll limit us to drop-deletable shrapnels in the worry of stuff like
 * arrows and harpoons being embeddable even when not let loose by their weapons.
 */
/datum/element/embed/proc/check_embed_projectile(obj/projectile/source, atom/movable/firer, atom/hit, angle, hit_zone, blocked)
	SIGNAL_HANDLER

	if(!source.can_embed_into(hit) || blocked)
		Detach(source)
		return // we don't care
	var/payload_type = source.shrapnel_type
	var/obj/item/payload = new payload_type(get_turf(hit))
	payload.set_embed(source.get_embed())
	if(istype(payload, /obj/item/shrapnel/bullet))
		payload.name = source.name
	SEND_SIGNAL(source, COMSIG_PROJECTILE_ON_SPAWN_EMBEDDED, payload)
	var/mob/living/carbon/C = hit
	var/obj/item/bodypart/limb = C.get_bodypart(hit_zone)
	if(!limb)
		limb = C.get_bodypart()

	if(!try_force_embed(payload, limb))
		payload.failedEmbed()
	else
		SEND_SIGNAL(source, COMSIG_PROJECTILE_ON_EMBEDDED, payload, hit)
	Detach(source)

/**
 * try_force_embed() is called here when we fire COMSIG_EMBED_TRY_FORCE from [/obj/item/proc/tryEmbed]. Mostly, this means we're a piece of shrapnel from a projectile that just impacted something, and we're trying to embed in it.
 *
 * The reason for this extra mucking about is avoiding having to do an extra hitby(), and annoying the target by impacting them once with the projectile, then again with the shrapnel, and possibly
 * AGAIN if we actually embed. This way, we save on at least one message.
 *
 * Arguments:
 * * embedding_item- the item we're trying to insert into the target
 * * target- what we're trying to shish-kabob, either a bodypart or a carbon
 * * hit_zone- if our target is a carbon, try to hit them in this zone, if we don't have one, pick a random one. If our target is a bodypart, we already know where we're hitting.
 * * forced- if we want this to succeed 100%
 */
/datum/element/embed/proc/try_force_embed(obj/item/embedding_item, atom/target, hit_zone, forced=FALSE)
	SIGNAL_HANDLER

	var/obj/item/bodypart/limb
	var/mob/living/carbon/victim

	if(iscarbon(target))
		victim = target
		if(!hit_zone)
			limb = pick(victim.bodyparts)
			hit_zone = limb.body_zone
	else if(isbodypart(target))
		limb = target
		hit_zone = limb.body_zone
		victim = limb.owner

	if(!forced && !roll_embed_chance(embedding_item, victim, hit_zone))
		return

	return check_embed(embedding_item, victim, hit_zone, forced=TRUE) // Don't repeat the embed roll, we already did it

/// Calculates the actual chance to embed based on armour penetration and throwing speed, then returns true if we pass that probability check
/datum/element/embed/proc/roll_embed_chance(obj/item/embedding_item, mob/living/victim, hit_zone, datum/thrownthing/throwingdatum)
	var/actual_chance = embedding_item.get_embed().embed_chance

	if(throwingdatum?.speed > embedding_item.throw_speed)
		actual_chance += (throwingdatum.speed - embedding_item.throw_speed) * EMBED_CHANCE_SPEED_BONUS

	if(embedding_item.is_embed_harmless()) // all the armor in the world won't save you from a kick me sign
		return prob(actual_chance)

	var/armor = max(victim.run_armor_check(hit_zone, BULLET, silent=TRUE), victim.run_armor_check(hit_zone, BOMB, silent=TRUE)) * 0.5 // we'll be nice and take the better of bullet and bomb armor, halved
	if(!armor) // we only care about armor penetration if there's actually armor to penetrate
		return prob(actual_chance)

	//Keep this above 1, as it is a multiplier for the pen_mod for determining actual embed chance.
	var/penetrative_behaviour = embedding_item.weak_against_armour ? ARMOR_WEAKENED_MULTIPLIER : 1
	var/pen_mod = -(armor * penetrative_behaviour) // if our shrapnel is weak into armor, then we restore our armor to the full value.
	actual_chance += pen_mod // doing the armor pen as a separate calc just in case this ever gets expanded on
	if(actual_chance <= 0)
		victim.visible_message(span_danger("[embedding_item] bounces off [victim]'s armor, unable to embed!"), span_notice("[embedding_item] bounces off your armor, unable to embed!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return FALSE

	return prob(actual_chance)
