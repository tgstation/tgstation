// Honker

/obj/projectile/bullet/honker
	name = "banana"
	damage = 0
	movement_type = FLYING
	projectile_piercing = ALL
	nodamage = TRUE
	hitsound = 'sound/items/bikehorn.ogg'
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "banana"
	range = 200
	embedding = null
	shrapnel_type = null

/obj/projectile/bullet/honker/Initialize(mapload)
	. = ..()
	SpinAnimation()

/obj/projectile/bullet/honker/on_hit(atom/target, blocked = FALSE)
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

/obj/projectile/bullet/mime/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.silent = max(M.silent, 10)

// Marksman Revolver + Ricochet Coin

// marksman
/obj/projectile/bullet/marksman
	name = "nanoshot"
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/bullet
	impact_type = /obj/effect/projectile/impact/sniper

/obj/projectile/bullet/marksman/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	var/turf/cur_turf = get_turf(src) // check to see if we're passing over a turf with a coin on it
	var/obj/projectile/bullet/coin/coin_check = cur_turf ? locate(/obj/projectile/bullet/coin) in cur_turf.contents : null

	if(!coin_check || coin_check.used) // no coin, keep trucking
		return

	coin_check.check_splitshot(firer, src)
	Impact(coin_check)

// coin
/obj/projectile/bullet/coin
	name = "marksman coin"
	pixel_speed_multiplier = 0.333
	speed = 1
	damage = 5

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
	. = ..()
	src.original_firer = original_firer
	target_turf = the_target
	range = get_dist(get_turf(original_firer), target_turf) + 1

	if(!istype(original_firer) || !original_firer.client)
		return

	var/client/firing_client = original_firer.client
	crosshair_indicator = image('icons/obj/supplypods_32x32.dmi', target_turf, "LZ")
	firing_client.images += crosshair_indicator

/obj/projectile/bullet/coin/Destroy()
	if(original_firer?.client && crosshair_indicator)
		original_firer.client.images -= crosshair_indicator
	QDEL_NULL(crosshair_indicator)
	return ..()

// the coin must be within 1 tile of the target turf to be directly targetable
/obj/projectile/bullet/coin/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!valid && get_dist(loc, target_turf) <= 1)
		original_firer?.playsound_local(src, 'sound/machines/ping.ogg', 30)
		valid = TRUE
		if(crosshair_indicator)
			crosshair_indicator.color = COLOR_YELLOW

/// We've been shot by a marksman revolver shot, or the ricochet off another coin, check if we can actually ricochet. The forced var being TRUE means it's a ricochet from another coin
/obj/projectile/bullet/coin/proc/check_splitshot(mob/living/shooter, obj/projectile/incoming_shot, forced = FALSE)
	if(!forced && get_dist(src, target_turf) > 1)
		return FALSE

	used = TRUE
	var/turf/cur_tur = get_turf(src)
	cur_tur.visible_message(span_nicegreen("[incoming_shot] impacts [src]!"))
	initiate_splitshots(shooter, incoming_shot)
	QDEL_IN(src, 0.25 SECONDS) // may not be needed

/// Now we actually create all the splitshots, loop through however many splits we'll create and find them targets
/obj/projectile/bullet/coin/proc/initiate_splitshots(mob/living/shooter, obj/projectile/incoming_shot)
	for(var/i in 1 to num_of_splitshots)
		var/atom/next_target = find_next_target()
		fire_splitshot(next_target, incoming_shot)

/// Minor convenience function for creating each shrapnel piece with circle explosions, mostly stolen from the MIRV component
/obj/projectile/bullet/coin/proc/fire_splitshot(atom/target, obj/projectile/incoming_shot)
	if(!istype(target))
		return

	ADD_TRAIT(target, TRAIT_RECENTLY_COINED, ABSTRACT_ITEM_TRAIT)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_RECENTLY_COINED, ABSTRACT_ITEM_TRAIT), 0.5 SECONDS)
	var/projectile_type = incoming_shot.type
	var/obj/projectile/new_splitshot = new projectile_type(get_turf(src))

	//Shooting Code:
	new_splitshot.original = target
	new_splitshot.fired_from = incoming_shot.fired_from
	new_splitshot.firer = incoming_shot.firer
	new_splitshot.preparePixelProjectile(target, src)
	new_splitshot.fire()
	new_splitshot.damage *= 1.5

	if(istype(target, /obj/projectile/bullet/coin)) // handle further splitshot checks
		var/obj/projectile/bullet/coin/our_coin = target
		our_coin.check_splitshot(incoming_shot.firer, new_splitshot, forced = TRUE)

/// Find what the splitshots will want to target next, with the order roughly based off the UK coin
/obj/projectile/bullet/coin/proc/find_next_target()
	var/list/valid_targets = (oview(4, src.loc))
	valid_targets -= firer

	for(var/obj/projectile/bullet/coin/iter_coin in valid_targets)
		if(!iter_coin.used) // this will prevent shooting itself as well
			return iter_coin

	var/list/possible_victims = list()

	for(var/mob/living/iter_living in valid_targets)
		if(!HAS_TRAIT(iter_living, TRAIT_RECENTLY_COINED))
			if(get_dist(src, iter_living) <= 2) // prioritize close mobs
				return iter_living
			possible_victims += iter_living

	if(possible_victims.len)
		return pick(possible_victims)

	// TODO: add a few new classes- fuel tanks, windows, etc
	for(var/atom/last_ditch in valid_targets)
		if(!HAS_TRAIT(last_ditch, TRAIT_RECENTLY_COINED))
			return last_ditch
