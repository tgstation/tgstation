// Honker

/obj/projectile/bullet/honker
	name = "banana"
	damage = 0
	movement_type = FLYING
	projectile_piercing = ALL
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/service/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/honker/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/bullet/honker/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/M = target
	if(istype(M))
		if(M.can_block_magic())
			return BULLET_ACT_BLOCK
		else
			M.slip(100, M.loc, GALOSHES_DONT_HELP|SLIDE, 0, FALSE)

// Mime

/obj/projectile/bullet/mime
	damage = 40

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/living_target = target
	living_target.set_silence_if_lower(20 SECONDS)


// Marksman Revolver + Ricochet Coin

/// Marksman Shot
/obj/projectile/bullet/marksman
	name = "marksman nanoshot"
	hitscan = TRUE
	damage = 30
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/bullet
	impact_type = /obj/effect/projectile/impact/sniper
	/// How many ricochets deep this is, for tracer size
	var/ricoshot_level = 0

/obj/projectile/bullet/marksman/Initialize(mapload, obj/item/ammo_casing/casing, incoming_ricoshot_level)
	. = ..()
	if(isnum(incoming_ricoshot_level))
		ricoshot_level = incoming_ricoshot_level

	switch(ricoshot_level)
		if(0)
			tracer_type = /obj/effect/projectile/tracer/solar/thinnest
		if(1)
			tracer_type = /obj/effect/projectile/tracer/solar/thin
		if(2 to INFINITY)
			tracer_type = /obj/effect/projectile/tracer/solar

/obj/projectile/bullet/marksman/scan_moved_turf()
	var/turf/cur_turf = get_turf(src) // check to see if we're passing over a turf with a coin on it
	var/obj/projectile/bullet/coin/coin_check = cur_turf ? locate(/obj/projectile/bullet/coin) in cur_turf.contents : null

	if(!coin_check || (ricoshot_level == 0 && get_dist(coin_check.target_turf, coin_check) >= 1) || coin_check.used) // no coin, keep trucking
		return ..()

	coin_check.check_splitshot(firer, src)
	Impact(coin_check)

/// Marksman Coin
/obj/projectile/bullet/coin
	name = "marksman coin"
	icon_state = "coinshot"
	pixel_speed_multiplier = 0.333
	speed = 1
	damage = 5
	color = "#dbdd4c"

	/// Save the turf we're aiming for for future use
	var/turf/target_turf
	/// Coins are valid while within a tile of their target tile, and can only be directly ricoshot during this time.
	var/valid = FALSE
	/// When a coin has been activated, is is marked as used, so that it is taken out of consideration for any further ricochets
	var/used = FALSE
	/// When this coin is targeted with a valid splitshot, it creates this many child splitshots
	var/num_of_splitshots = 2
	/// The crosshair icon put on the targeted turf for the user- so we can remove it from their images when done
	var/image/crosshair_indicator
	/// The mob who originally flipped this coin, as a matter of convenience, may be able tto be removed
	var/mob/original_firer

/obj/projectile/bullet/coin/Initialize(mapload, turf/the_target, mob/original_firer)
	src.original_firer = original_firer
	target_turf = the_target
	range = (get_dist(original_firer, target_turf) + 3) * 3 // 3 tiles past the origin (the *3 is because Range() ticks 3 times a tile because of the slower speed)

	. = ..()

	if(!istype(original_firer) || !original_firer.client)
		return

	var/client/firing_client = original_firer.client
	crosshair_indicator = image('icons/obj/supplypods_32x32.dmi', target_turf, "LZ")
	firing_client.images += crosshair_indicator

/obj/projectile/bullet/coin/Destroy()
	remove_crosshair_indicator()
	return ..()

// the coin must be on the target turf to be directly targetable
/obj/projectile/bullet/coin/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!valid && get_dist(loc, target_turf) < 1)
		original_firer?.playsound_local(src, 'sound/machines/ping.ogg', 30)
		valid = TRUE
	else if(valid && get_dist(loc, target_turf) > 1)
		valid = FALSE
		remove_crosshair_indicator()

/// Remove the crosshair indicator from the original firer if it exists
/obj/projectile/bullet/coin/proc/remove_crosshair_indicator()
	if(original_firer?.client && crosshair_indicator)
		original_firer.client.images -= crosshair_indicator
	QDEL_NULL(crosshair_indicator)

/// We've been shot by a marksman revolver shot, or the ricochet off another coin, check if we can actually ricochet. The forced var being TRUE means it's a ricochet from another coin
/obj/projectile/bullet/coin/proc/check_splitshot(mob/living/shooter, obj/projectile/bullet/marksman/incoming_shot, forced = FALSE)
	if(!forced && get_dist(src, target_turf) > 1)
		return FALSE

	used = TRUE
	var/turf/cur_tur = get_turf(src)
	cur_tur.visible_message(span_nicegreen("[incoming_shot] impacts [src] and splits!"))
	iterate_splitshots(shooter, incoming_shot)
	QDEL_IN(src, 0.25 SECONDS) // may not be needed

/// Now we actually create all the splitshots, loop through however many splits we'll create and fire them
/obj/projectile/bullet/coin/proc/iterate_splitshots(mob/living/shooter, obj/projectile/incoming_shot)
	for(var/i in 1 to num_of_splitshots)
		fire_splitshot(incoming_shot)

/// Shoot an individual splitshot at a new target
/obj/projectile/bullet/coin/proc/fire_splitshot(obj/projectile/bullet/marksman/incoming_shot)
	var/atom/next_target = find_next_target()

	ADD_TRAIT(next_target, TRAIT_RECENTLY_COINED, "[type]")
	addtimer(TRAIT_CALLBACK_REMOVE(next_target, TRAIT_RECENTLY_COINED, "[type]"), 0.5 SECONDS)
	var/outgoing_ricoshot_level = incoming_shot.ricoshot_level + 1
	var/obj/projectile/bullet/marksman/new_splitshot = new /obj/projectile/bullet/marksman(get_turf(src), null, outgoing_ricoshot_level)
	//Shooting Code:
	new_splitshot.original = next_target
	new_splitshot.fired_from = incoming_shot.fired_from
	new_splitshot.firer = incoming_shot.firer
	new_splitshot.damage = 2 * incoming_shot.damage

	var/current_turf = get_turf(src)
	var/target_turf = get_turf(next_target)

	if(Adjacent(current_turf, target_turf))
		new_splitshot.fire(get_angle(current_turf, target_turf), direct_target = next_target)
	else
		new_splitshot.preparePixelProjectile(next_target, get_turf(src))
		new_splitshot.fire()

	if(istype(next_target, /obj/projectile/bullet/coin)) // handle further splitshot checks
		var/obj/projectile/bullet/coin/our_coin = next_target
		our_coin.check_splitshot(incoming_shot.firer, new_splitshot, forced = TRUE)

/// Find what the splitshots will want to target next, with the order roughly based off the UK coin
/obj/projectile/bullet/coin/proc/find_next_target()
	var/list/valid_targets = shuffle(oview(4, loc))
	valid_targets -= firer

	for(var/obj/projectile/bullet/coin/iter_coin in valid_targets)
		if(!iter_coin.used) // this will prevent shooting itself as well
			return iter_coin

	var/list/possible_victims = list()

	for(var/mob/living/iter_living in valid_targets)
		if(HAS_TRAIT(iter_living, TRAIT_RECENTLY_COINED) || iter_living.stat != CONSCIOUS)
			continue

		if(get_dist(src, iter_living) <= 2) // prioritize close mobs
			return iter_living
		possible_victims += iter_living

	if(possible_victims.len)
		return pick(possible_victims)

	var/list/static/prioritized_targets = list(/obj/structure/reagent_dispensers, /obj/item/grenade, /obj/structure/window)
	for(var/iter_type in prioritized_targets)
		for(var/already_coined_tries in 1 to 3)
			var/atom/iter_type_check = locate(iter_type) in valid_targets
			if(iter_type_check)
				if(HAS_TRAIT(iter_type_check, TRAIT_RECENTLY_COINED))
					valid_targets -= iter_type_check
					continue
				else
					return iter_type_check

	for(var/atom/last_ditch in valid_targets)
		if(!HAS_TRAIT(last_ditch, TRAIT_RECENTLY_COINED))
			return last_ditch
