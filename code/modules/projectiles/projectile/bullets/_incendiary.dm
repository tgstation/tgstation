/obj/projectile/bullet/incendiary
	damage = 20
	var/fire_stacks = 4

/obj/projectile/bullet/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()

/obj/projectile/bullet/incendiary/Move()
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/// Used in [the backblast element][/datum/element/backblast]
/obj/projectile/bullet/incendiary/backblast
	damage = 15
	range = 10 // actually overwritten in the backblast element
	alpha = 0
	pass_flags = PASSTABLE | PASSMOB
	sharpness = NONE
	shrapnel_type = null
	embedding = null
	ricochet_chance = 10000
	ricochets_max = 4
	ricochet_incidence_leeway = 0
	suppressed = SUPPRESSED_VERY
	damage_type = BURN
	flag = BOMB
	speed = 1.2
	wound_bonus = 30
	bare_wound_bonus = 30
	wound_falloff_tile = -4
	fire_stacks = 3

	/// Lazy attempt at knockback, any items this plume hits will be knocked back this far. Decrements with each tile passed.
	var/knockback_range = 7
	/// A lazylist of all the items we've already knocked back, so we don't do it again
	var/list/launched_items

/// we only try to knock back the first 6 items per tile
#define BACKBLAST_MAX_ITEM_KNOCKBACK	6

/obj/projectile/bullet/incendiary/backblast/Move()
	. = ..()
	if(knockback_range <= 0)
		return
	knockback_range--
	var/turf/current_turf = get_turf(src)
	var/turf/throw_at_turf = get_turf_in_angle(Angle, current_turf, 7)
	var/thrown_items = 0

	for(var/iter in current_turf.contents)
		if(thrown_items > BACKBLAST_MAX_ITEM_KNOCKBACK)
			break
		if(isitem(iter))
			var/obj/item/iter_item = iter
			if(iter_item.anchored || LAZYFIND(launched_items, iter_item) || iter_item.throwing)
				continue
			thrown_items++
			iter_item.throw_at(throw_at_turf, knockback_range, knockback_range)
			LAZYADD(launched_items, iter_item)
		else if(isliving(iter))
			var/mob/living/incineratee = iter
			incineratee.take_bodypart_damage(0, damage, wound_bonus=wound_bonus, bare_wound_bonus=bare_wound_bonus)
			incineratee.adjust_fire_stacks(fire_stacks)

#undef BACKBLAST_MAX_ITEM_KNOCKBACK
