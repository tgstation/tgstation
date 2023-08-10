
#define MOVES_HITSCAN -1 //Not actually hitscan but close as we get without actual hitscan.
#define MUZZLE_EFFECT_PIXEL_INCREMENT 17 //How many pixels to move the muzzle flash up so your character doesn't look like they're shitting out lasers.

/obj/projectile
	name = "projectile"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	movement_type = FLYING
	wound_bonus = CANT_WOUND // can't wound by default
	generic_canpass = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	layer = MOB_LAYER
	plane = GAME_PLANE_FOV_HIDDEN
	//The sound this plays on impact.
	var/hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""

	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/def_zone = "" //Aiming at
	var/atom/movable/firer = null//Who shot it
	var/datum/fired_from = null // the thing that the projectile was fired from (gun, turret, spell)
	var/suppressed = FALSE //Attack message
	var/yo = null
	var/xo = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	//Fired processing vars
	var/fired = FALSE //Have we been fired yet
	var/paused = FALSE //for suspending the projectile midair
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/datum/point/vector/trajectory
	var/trajectory_ignore_forcemove = FALSE //instructs forceMove to NOT reset our trajectory to the new location!
	/// We already impacted these things, do not impact them again. Used to make sure we can pierce things we want to pierce. Lazylist, typecache style (object = TRUE) for performance.
	var/list/impacted = list()
	/// If TRUE, we can hit our firer.
	var/ignore_source_check = FALSE
	/// We are flagged PHASING temporarily to not stop moving when we Bump something but want to keep going anyways.
	var/temporary_unstoppable_movement = FALSE

	/** PROJECTILE PIERCING
	  * WARNING:
	  * Projectile piercing MUST be done using these variables.
	  * Ordinary passflags will result in can_hit_target being false unless directly clicked on - similar to projectile_phasing but without even going to process_hit.
	  * The two flag variables below both use pass flags.
	  * In the context of LETPASStHROW, it means the projectile will ignore things that are currently "in the air" from a throw.
	  *
	  * Also, projectiles sense hits using Bump(), and then pierce them if necessary.
	  * They simply do not follow conventional movement rules.
	  * NEVER flag a projectile as PHASING movement type.
	  * If you so badly need to make one go through *everything*, override check_pierce() for your projectile to always return PROJECTILE_PIERCE_PHASE/HIT.
	  */
	/// The "usual" flags of pass_flags is used in that can_hit_target ignores these unless they're specifically targeted/clicked on. This behavior entirely bypasses process_hit if triggered, rather than phasing which uses prehit_pierce() to check.
	pass_flags = PASSTABLE
	/// If FALSE, allow us to hit something directly targeted/clicked/whatnot even if we're able to phase through it
	var/phasing_ignore_direct_target = FALSE
	/// Bitflag for things the projectile should just phase through entirely - No hitting unless direct target and [phasing_ignore_direct_target] is FALSE. Uses pass_flags flags.
	var/projectile_phasing = NONE
	/// Bitflag for things the projectile should hit, but pierce through without deleting itself. Defers to projectile_phasing. Uses pass_flags flags.
	var/projectile_piercing = NONE
	/// number of times we've pierced something. Incremented BEFORE bullet_act and on_hit proc!
	var/pierces = 0

	/// If objects are below this layer, we pass through them
	var/hit_threshhold = PROJECTILE_HIT_THRESHHOLD_LAYER

	/// During each fire of SSprojectiles, the number of deciseconds since the last fire of SSprojectiles
	/// is divided by this var, and the result truncated to the next lowest integer is
	/// the number of times the projectile's `pixel_move` proc will be called.
	var/speed = 0.8

	/// This var is multiplied by SSprojectiles.global_pixel_speed to get how many pixels
	/// the projectile moves during each iteration of the movement loop
	///
	/// If you want to make a fast-moving projectile, you should keep this equal to 1 and
	/// reduce the value of `speed`. If you want to make a slow-moving projectile, make
	/// `speed` a modest value like 1 and set this to a low value like 0.2.
	var/pixel_speed_multiplier = 1

	var/Angle = 0
	var/original_angle = 0 //Angle at firing
	var/nondirectional_sprite = FALSE //Set TRUE to prevent projectiles from having their sprites rotated based on firing angle
	var/spread = 0 //amount (in degrees) of projectile spread
	animate_movement = NO_STEPS //Use SLIDE_STEPS in conjunction with legacy
	/// how many times we've ricochet'd so far (instance variable, not a stat)
	var/ricochets = 0
	/// how many times we can ricochet max
	var/ricochets_max = 0
	/// how many times we have to ricochet min (unless we hit an atom we can ricochet off)
	var/min_ricochets = 0
	/// 0-100 (or more, I guess), the base chance of ricocheting, before being modified by the atom we shoot and our chance decay
	var/ricochet_chance = 0
	/// 0-1 (or more, I guess) multiplier, the ricochet_chance is modified by multiplying this after each ricochet
	var/ricochet_decay_chance = 0.7
	/// 0-1 (or more, I guess) multiplier, the projectile's damage is modified by multiplying this after each ricochet
	var/ricochet_decay_damage = 0.7
	/// On ricochet, if nonzero, we consider all mobs within this range of our projectile at the time of ricochet to home in on like Revolver Ocelot, as governed by ricochet_auto_aim_angle
	var/ricochet_auto_aim_range = 0
	/// On ricochet, if ricochet_auto_aim_range is nonzero, we'll consider any mobs within this range of the normal angle of incidence to home in on, higher = more auto aim
	var/ricochet_auto_aim_angle = 30
	/// the angle of impact must be within this many degrees of the struck surface, set to 0 to allow any angle
	var/ricochet_incidence_leeway = 40
	/// Can our ricochet autoaim hit our firer?
	var/ricochet_shoots_firer = TRUE

	///If the object being hit can pass ths damage on to something else, it should not do it for this bullet
	var/force_hit = FALSE

	//Hitscan
	var/hitscan = FALSE //Whether this is hitscan. If it is, speed is basically ignored.
	var/list/beam_segments //assoc list of datum/point or datum/point/vector, start = end. Used for hitscan effect generation.
	/// Last turf an angle was changed in for hitscan projectiles.
	var/turf/last_angle_set_hitscan_store
	var/datum/point/beam_index
	var/turf/hitscan_last //last turf touched during hitscanning.
	var/tracer_type
	var/muzzle_type
	var/impact_type

	//Fancy hitscan lighting effects!
	var/hitscan_light_intensity = 1.5
	var/hitscan_light_range = 0.75
	var/hitscan_light_color_override
	var/muzzle_flash_intensity = 3
	var/muzzle_flash_range = 1.5
	var/muzzle_flash_color_override
	var/impact_light_intensity = 3
	var/impact_light_range = 2
	var/impact_light_color_override

	//Homing
	var/homing = FALSE
	var/atom/homing_target
	var/homing_turn_speed = 10 //Angle per tick.
	var/homing_inaccuracy_min = 0 //in pixels for these. offsets are set once when setting target.
	var/homing_inaccuracy_max = 0
	var/homing_offset_x = 0
	var/homing_offset_y = 0

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here

	///Defines what armor to use when it hits things.  Must be set to bullet, laser, energy, or bomb
	var/armor_flag = BULLET
	///How much armor this projectile pierces.
	var/armour_penetration = 0
	///Whether or not our bullet lacks penetrative power, and is easily stopped by armor.
	var/weak_against_armour = FALSE
	var/projectile_type = /obj/projectile
	var/range = 50 //This will de-increment every step. When 0, it will deletze the projectile.
	var/decayedRange //stores original range
	var/reflect_range_decrease = 5 //amount of original range that falls off when reflecting, so it doesn't go forever
	var/reflectable = NONE // Can it be reflected or not?
	// Status effects applied on hit
	var/stun = 0
	var/knockdown = 0
	var/paralyze = 0
	var/immobilize = 0
	var/unconscious = 0
	var/eyeblur = 0
	/// Drowsiness applied on projectile hit
	var/drowsy = 0 SECONDS
	/// Jittering applied on projectile hit
	var/jitter = 0 SECONDS
	/// Extra stamina damage applied on projectile hit (in addition to the main damage)
	var/stamina = 0
	/// Stuttering applied on projectile hit
	var/stutter = 0 SECONDS
	/// Slurring applied on projectile hit
	var/slur = 0 SECONDS

	var/dismemberment = 0 //The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/catastropic_dismemberment = FALSE //If TRUE, this projectile deals its damage to the chest if it dismembers a limb.
	var/impact_effect_type //what type of impact effect to show when hitting something
	var/log_override = FALSE //is this type spammed enough to not log? (KAs)
	/// We ignore mobs with these factions.
	var/list/ignored_factions

	///If defined, on hit we create an item of this type then call hitby() on the hit target with this, mainly used for embedding items (bullets) in targets
	var/shrapnel_type
	///If we have a shrapnel_type defined, these embedding stats will be passed to the spawned shrapnel type, which will roll for embedding on the target
	var/list/embedding
	///If TRUE, hit mobs even if they're on the floor and not our target
	var/hit_prone_targets = FALSE
	///For what kind of brute wounds we're rolling for, if we're doing such a thing. Lasers obviously don't care since they do burn instead.
	var/sharpness = NONE
	///How much we want to drop both wound_bonus and bare_wound_bonus (to a minimum of 0 for the latter) per tile, for falloff purposes
	var/wound_falloff_tile
	///How much we want to drop the embed_chance value, if we can embed, per tile, for falloff purposes
	var/embed_falloff_tile
	var/static/list/projectile_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_ATTACK_HAND = PROC_REF(attempt_parry),
	)
	/// If true directly targeted turfs can be hit
	var/can_hit_turfs = FALSE
	/// If this projectile has been parried before
	var/parried = FALSE

/obj/projectile/Initialize(mapload)
	. = ..()
	decayedRange = range
	if(embedding)
		updateEmbedding()
	AddElement(/datum/element/connect_loc, projectile_connections)

/obj/projectile/proc/Range()
	range--
	if(wound_bonus != CANT_WOUND)
		wound_bonus += wound_falloff_tile
		bare_wound_bonus = max(0, bare_wound_bonus + wound_falloff_tile)
	if(embedding)
		embedding["embed_chance"] += embed_falloff_tile
	SEND_SIGNAL(src, COMSIG_PROJECTILE_RANGE)
	if(range <= 0 && loc)
		on_range()

/obj/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	SEND_SIGNAL(src, COMSIG_PROJECTILE_RANGE_OUT)
	qdel(src)

//to get the correct limb (if any) for the projectile hit message
/mob/living/proc/check_limb_hit(hit_zone)
	if(has_limbs)
		return hit_zone

/mob/living/carbon/check_limb_hit(hit_zone)
	if(get_bodypart(hit_zone))
		return hit_zone
	else //when a limb is missing the damage is actually passed to the chest
		return BODY_ZONE_CHEST

/**
 * Called when the projectile hits something
 *
 * @params
 * target - thing hit
 * blocked - percentage of hit blocked
 * pierce_hit - are we piercing through or regular hitting
 */
/obj/projectile/proc/on_hit(atom/target, blocked = FALSE, pierce_hit)
	// i know that this is probably more with wands and gun mods in mind, but it's a bit silly that the projectile on_hit signal doesn't ping the projectile itself.
	// maybe we care what the projectile thinks! See about combining these via args some time when it's not 5AM
	var/obj/item/bodypart/hit_limb
	if(isliving(target))
		var/mob/living/L = target
		hit_limb = L.check_limb_hit(def_zone)
	if(fired_from)
		SEND_SIGNAL(fired_from, COMSIG_PROJECTILE_ON_HIT, firer, target, Angle, hit_limb)
	SEND_SIGNAL(src, COMSIG_PROJECTILE_SELF_ON_HIT, firer, target, Angle, hit_limb)

	if(QDELETED(src)) // in case one of the above signals deleted the projectile for whatever reason
		return
	var/turf/target_loca = get_turf(target)

	var/hitx
	var/hity
	if(target == original)
		hitx = target.pixel_x + p_x - 16
		hity = target.pixel_y + p_y - 16
	else
		hitx = target.pixel_x + rand(-8, 8)
		hity = target.pixel_y + rand(-8, 8)

	if(damage > 0 && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/closed/wall/W = target_loca
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		W.add_dent(WALL_DENT_SHOT, hitx, hity)

		return BULLET_ACT_HIT

	if(!isliving(target))
		if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)
		if(isturf(target) && hitsound_wall)
			var/volume = clamp(vol_by_damage() + 20, 0, 100)
			if(suppressed)
				volume = 5
			playsound(loc, hitsound_wall, volume, TRUE, -1)
		return BULLET_ACT_HIT

	var/mob/living/L = target

	if(blocked != 100) // not completely blocked
		if(damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = dir
			if(starting)
				splatter_dir = get_dir(starting, target_loca)
			if(isalien(L))
				new /obj/effect/temp_visual/dir_setting/bloodsplatter/xenosplatter(target_loca, splatter_dir)
			else
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(target_loca, splatter_dir)
			if(prob(33))
				L.add_splatter_floor(target_loca)
		else if(impact_effect_type && !hitscan)
			new impact_effect_type(target_loca, hitx, hity)

		var/organ_hit_text = ""
		var/limb_hit = hit_limb
		if(limb_hit)
			organ_hit_text = " in \the [parse_zone(limb_hit)]"
		if(suppressed == SUPPRESSED_VERY)
			playsound(loc, hitsound, 5, TRUE, -1)
		else if(suppressed)
			playsound(loc, hitsound, 5, TRUE, -1)
			to_chat(L, span_userdanger("You're shot by \a [src][organ_hit_text]!"))
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(src, hitsound, volume, TRUE, -1)
			L.visible_message(span_danger("[L] is hit by \a [src][organ_hit_text]!"), \
					span_userdanger("You're hit by \a [src][organ_hit_text]!"), null, COMBAT_MESSAGE_RANGE)
			if(L.is_blind())
				to_chat(L, span_userdanger("You feel something hit you[organ_hit_text]!"))
		L.on_hit(src)

	var/reagent_note
	if(reagents?.reagent_list)
		reagent_note = "REAGENTS: [pretty_string_from_reagent_list(reagents.reagent_list)]"

	if(ismob(firer))
		log_combat(firer, L, "shot", src, reagent_note)
		return BULLET_ACT_HIT

	if(isvehicle(firer))
		var/obj/vehicle/firing_vehicle = firer

		var/list/logging_mobs = firing_vehicle.return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)
		if(!LAZYLEN(logging_mobs))
			logging_mobs = firing_vehicle.return_drivers()
		for(var/mob/logged_mob as anything in logging_mobs)
			log_combat(logged_mob, L, "shot", src, "from inside [firing_vehicle][logging_mobs.len > 1 ? " with multiple occupants" : null][reagent_note ? " and contained [reagent_note]" : null]")
		return BULLET_ACT_HIT

	L.log_message("has been shot by [firer] with [src][reagent_note ? " containing [reagent_note]" : null]", LOG_ATTACK, color="orange")
	return BULLET_ACT_HIT

/obj/projectile/proc/vol_by_damage()
	if(src.damage)
		return clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then CLAMP the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/projectile/proc/on_ricochet(atom/A)
	if(!ricochet_auto_aim_angle || !ricochet_auto_aim_range)
		return

	var/mob/living/unlucky_sob
	var/best_angle = ricochet_auto_aim_angle
	if(firer && HAS_TRAIT(firer, TRAIT_NICE_SHOT))
		best_angle += NICE_SHOT_RICOCHET_BONUS
	for(var/mob/living/L in range(ricochet_auto_aim_range, src.loc))
		if(L.stat == DEAD || !is_in_sight(src, L) || (!ricochet_shoots_firer && L == firer))
			continue
		var/our_angle = abs(closer_angle_difference(Angle, get_angle(src.loc, L.loc)))
		if(our_angle < best_angle)
			best_angle = our_angle
			unlucky_sob = L

	if(unlucky_sob)
		set_angle(get_angle(src, unlucky_sob.loc))

/obj/projectile/proc/store_hitscan_collision(datum/point/point_cache)
	beam_segments[beam_index] = point_cache
	beam_index = point_cache
	beam_segments[beam_index] = null

/obj/projectile/Bump(atom/A)
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
	if(!can_hit_target(A, A == original, TRUE, TRUE))
		return
	Impact(A)

/// Signal proc for when a mob attempts to attack this projectile or the turf it's on with an empty hand.
/obj/projectile/proc/attempt_parry(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER

	if(parried)
		return FALSE

	if(SEND_SIGNAL(user, COMSIG_LIVING_PROJECTILE_PARRYING, src) & ALLOW_PARRY)
		on_parry(user, modifiers)
		return TRUE

	return FALSE


/// Called when a mob with PARRY_TRAIT clicks on this projectile or the tile its on, reflecting the projectile within 7 degrees and increasing the bullet's stats.
/obj/projectile/proc/on_parry(mob/user, list/modifiers)
	if(SEND_SIGNAL(user, COMSIG_LIVING_PROJECTILE_PARRIED, src) & INTERCEPT_PARRY_EFFECTS)
		return

	parried = TRUE
	set_angle(dir2angle(user.dir) + rand(-3, 3))
	firer = user
	speed *= 0.8 // Go 20% faster when parried
	damage *= 1.15 // And do 15% more damage
	add_atom_colour(COLOR_RED_LIGHT, TEMPORARY_COLOUR_PRIORITY)


/**
 * Called when the projectile hits something
 * This can either be from it bumping something,
 * or it passing over a turf/being crossed and scanning that there is infact
 * a valid target it needs to hit.
 * This target isn't however necessarily WHAT it hits
 * that is determined by process_hit and select_target.
 *
 * Furthermore, this proc shouldn't check can_hit_target - this should only be called if can hit target is already checked.
 * Also, we select_target to find what to process_hit first.
 */
/obj/projectile/proc/Impact(atom/A)
	if(!trajectory)
		qdel(src)
		return FALSE
	if(impacted[A]) // NEVER doublehit
		return FALSE
	var/datum/point/point_cache = trajectory.copy_to()
	var/turf/T = get_turf(A)
	if(ricochets < ricochets_max && check_ricochet_flag(A) && check_ricochet(A))
		ricochets++
		if(A.handle_ricochet(src))
			on_ricochet(A)
			impacted = list() // Shoot a x-ray laser at a pair of mirrors I dare you
			ignore_source_check = TRUE // Firer is no longer immune
			decayedRange = max(0, decayedRange - reflect_range_decrease)
			ricochet_chance *= ricochet_decay_chance
			damage *= ricochet_decay_damage
			stamina *= ricochet_decay_damage
			range = decayedRange
			if(hitscan)
				store_hitscan_collision(point_cache)
			return TRUE

	if(!HAS_TRAIT(src, TRAIT_ALWAYS_HIT_ZONE))
		var/distance = get_dist(T, starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
		def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	return process_hit(T, select_target(T, A, A), A) // SELECT TARGET FIRST!

/**
 * The primary workhorse proc of projectile impacts.
 * This is a RECURSIVE call - process_hit is called on the first selected target, and then repeatedly called if the projectile still hasn't been deleted.
 *
 * Order of operations:
 * 1. Checks if we are deleted, or if we're somehow trying to hit a null, in which case, bail out
 * 2. Adds the thing we're hitting to impacted so we can make sure we don't doublehit
 * 3. Checks piercing - stores this.
 * Afterwards:
 * Hit and delete, hit without deleting and pass through, pass through without hitting, or delete without hitting depending on result
 * If we're going through without hitting, find something else to hit if possible and recurse, set unstoppable movement to true
 * If we're deleting without hitting, delete and return
 * Otherwise, send signal of COMSIG_PROJECTILE_PREHIT to target
 * Then, hit, deleting ourselves if necessary.
 * @params
 * T - Turf we're on/supposedly hitting
 * target - target we're hitting
 * bumped - target we originally bumped. it's here to ensure that if something blocks our projectile by means of Cross() failure, we hit it
 * even if it is not dense.
 * hit_something - only should be set by recursive calling by this proc - tracks if we hit something already
 *
 * Returns if we hit something.
 */
/obj/projectile/proc/process_hit(turf/T, atom/target, atom/bumped, hit_something = FALSE)
	// 1.
	if(QDELETED(src) || !T || !target)
		return
	// 2.
	impacted[target] = TRUE //hash lookup > in for performance in hit-checking
	// 3.
	var/mode = prehit_pierce(target)
	if(mode == PROJECTILE_DELETE_WITHOUT_HITTING)
		qdel(src)
		return hit_something
	else if(mode == PROJECTILE_PIERCE_PHASE)
		if(!(movement_type & PHASING))
			temporary_unstoppable_movement = TRUE
			movement_type |= PHASING
		return process_hit(T, select_target(T, target, bumped), bumped, hit_something) // try to hit something else
	// at this point we are going to hit the thing
	// in which case send signal to it
	if (SEND_SIGNAL(target, COMSIG_PROJECTILE_PREHIT, args, src) & PROJECTILE_INTERRUPT_HIT)
		qdel(src)
		return BULLET_ACT_BLOCK
	if(mode == PROJECTILE_PIERCE_HIT)
		++pierces
	hit_something = TRUE
	var/result = target.bullet_act(src, def_zone, mode == PROJECTILE_PIERCE_HIT)
	if((result == BULLET_ACT_FORCE_PIERCE) || (mode == PROJECTILE_PIERCE_HIT))
		if(!(movement_type & PHASING))
			temporary_unstoppable_movement = TRUE
			movement_type |= PHASING
		return process_hit(T, select_target(T, target, bumped), bumped, TRUE)
	qdel(src)
	return hit_something

/**
 * Selects a target to hit from a turf
 *
 * @params
 * T - The turf
 * target - The "preferred" atom to hit, usually what we Bumped() first.
 * bumped - used to track if something is the reason we impacted in the first place.
 *    If set, this atom is always treated as dense by can_hit_target.
 *
 * Priority:
 * 0. Anything that is already in impacted is ignored no matter what. Furthermore, in any bracket, if the target atom parameter is in it, that's hit first.
 * Furthermore, can_hit_target is always checked. This (entire proc) is PERFORMANCE OVERHEAD!! But, it shouldn't be ""too"" bad and I frankly don't have a better *generic non snowflakey* way that I can think of right now at 3 AM.
 * FURTHERMORE, mobs/objs have a density check from can_hit_target - to hit non dense objects over a turf, you must click on them, same for mobs that usually wouldn't get hit.
 * 1. Special check on what we bumped to see if it's a border object that intercepts hitting anything behind it
 * 2. The thing originally aimed at/clicked on
 * 3. Mobs - picks lowest buckled mob to prevent scarp piggybacking memes
 * 4. Objs
 * 5. Turf
 * 6. Nothing
 */
/obj/projectile/proc/select_target(turf/our_turf, atom/target, atom/bumped)
	// 1. special bumped border object check
	if((bumped?.flags_1 & ON_BORDER_1) && can_hit_target(bumped, original == bumped, FALSE, TRUE))
		return bumped
	// 2. original
	if(can_hit_target(original, TRUE, FALSE, original == bumped))
		return original
	var/list/atom/considering = list()  // let's define this ONCE
	// 3. mobs
	for(var/mob/living/iter_possible_target in our_turf)
		if(can_hit_target(iter_possible_target, iter_possible_target == original, TRUE, iter_possible_target == bumped))
			considering |= iter_possible_target
	if(length(considering))
		return pick(considering)
	// 4. objs and other dense things
	for(var/i in our_turf)
		if(can_hit_target(i, i == original, TRUE, i == bumped))
			considering += i
	if(length(considering))
		return pick(considering)
	// 5. turf
	if(can_hit_target(our_turf, our_turf == original, TRUE, our_turf == bumped))
		return our_turf
	// 6. nothing
		// (returns null)

//Returns true if the target atom is on our current turf and above the right layer
//If direct target is true it's the originally clicked target.
/obj/projectile/proc/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(QDELETED(target) || impacted[target])
		return FALSE
	if(!ignore_loc && (loc != target.loc) && !(can_hit_turfs && direct_target && loc == target))
		return FALSE
	// if pass_flags match, pass through entirely - unless direct target is set.
	if((target.pass_flags_self & pass_flags) && !direct_target)
		return FALSE
	if(!ignore_source_check && firer)
		var/mob/M = firer
		if((target == firer) || ((target == firer.loc) && ismecha(firer.loc)) || (target in firer.buckled_mobs) || (istype(M) && (M.buckled == target)))
			return FALSE
	if(ignored_factions?.len && ismob(target) && !direct_target)
		var/mob/target_mob = target
		if(faction_check(target_mob.faction, ignored_factions))
			return FALSE
	if(target.density || cross_failed) //This thing blocks projectiles, hit it regardless of layer/mob stuns/etc.
		return TRUE
	if(!isliving(target))
		if(isturf(target)) // non dense turfs
			return can_hit_turfs && direct_target
		if(target.layer < hit_threshhold)
			return FALSE
		else if(!direct_target) // non dense objects do not get hit unless specifically clicked
			return FALSE
	else
		var/mob/living/living_target = target
		if(direct_target)
			return TRUE
		if(living_target.stat == DEAD)
			return FALSE
		if(HAS_TRAIT(living_target, TRAIT_IMMOBILIZED) && HAS_TRAIT(living_target, TRAIT_FLOORED) && HAS_TRAIT(living_target, TRAIT_HANDS_BLOCKED))
			return FALSE
		if(!hit_prone_targets)
			var/mob/living/buckled_to = living_target.lowest_buckled_mob()
			if(!buckled_to.density) // Will just be us if we're not buckled to another mob
				return FALSE
			if(living_target.body_position != LYING_DOWN)
				return TRUE
	return TRUE

/**
 * Scan if we should hit something and hit it if we need to
 * The difference between this and handling in Impact is
 * In this we strictly check if we need to Impact() something in specific
 * If we do, we do
 * We don't even check if it got hit already - Impact() does that
 * In impact there's more code for selecting WHAT to hit
 * So this proc is more of checking if we should hit something at all BY having an atom cross us.
 */
/obj/projectile/proc/scan_crossed_hit(atom/movable/A)
	if(can_hit_target(A, direct_target = (A == original)))
		Impact(A)

/**
 * Scans if we should hit something on the turf we just moved to if we haven't already
 *
 * This proc is a little high in overhead but allows us to not snowflake CanPass in living and other things.
 */
/obj/projectile/proc/scan_moved_turf()
	// Optimally, we scan: mobs --> objs --> turf for impact
	// but, overhead is a thing and 2 for loops every time it moves is a no-go.
	// realistically, since we already do select_target in impact, we can not do that
	// and hope projectiles get refactored again in the future to have a less stupid impact detection system
	// that hopefully won't also involve a ton of overhead
	if(can_hit_target(original, TRUE, FALSE))
		Impact(original) // try to hit thing clicked on
	// else, try to hit mobs
	else // because if we impacted original and pierced we'll already have select target'd and hit everything else we should be hitting
		for(var/mob/M in loc) // so I guess we're STILL doing a for loop of mobs because living movement would otherwise have snowflake code for projectile CanPass
			// so the snowflake vs performance is pretty arguable here
			if(can_hit_target(M, M == original, TRUE))
				Impact(M)
				break

/**
 * Projectile crossed: When something enters a projectile's tile, make sure the projectile hits it if it should be hitting it.
 */
/obj/projectile/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	scan_crossed_hit(AM)

/**
 * Projectile can pass through
 * Used to not even attempt to Bump() or fail to Cross() anything we already hit.
 */
/obj/projectile/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	return impacted[blocker] ? TRUE : ..()

/**
 * Projectile moved:
 *
 * If not fired yet, do not do anything. Else,
 *
 * If temporary unstoppable movement used for piercing through things we already hit (impacted list) is set, unset it.
 * Scan turf we're now in for anything we can/should hit. This is useful for hitting non dense objects the user
 * directly clicks on, as well as for PHASING projectiles to be able to hit things at all as they don't ever Bump().
 */
/obj/projectile/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!fired)
		return
	if(temporary_unstoppable_movement)
		temporary_unstoppable_movement = FALSE
		movement_type &= ~PHASING
	scan_moved_turf() //mostly used for making sure we can hit a non-dense object the user directly clicked on, and for penetrating projectiles that don't bump

/**
 * Checks if we should pierce something.
 *
 * NOT meant to be a pure proc, since this replaces prehit() which was used to do things.
 * Return PROJECTILE_DELETE_WITHOUT_HITTING to delete projectile without hitting at all!
 */
/obj/projectile/proc/prehit_pierce(atom/A)
	if((projectile_phasing & A.pass_flags_self) && (phasing_ignore_direct_target || original != A))
		return PROJECTILE_PIERCE_PHASE
	if(projectile_piercing & A.pass_flags_self)
		return PROJECTILE_PIERCE_HIT
	if(ismovable(A))
		var/atom/movable/AM = A
		if(AM.throwing)
			return (projectile_phasing & LETPASSTHROW)? PROJECTILE_PIERCE_PHASE : ((projectile_piercing & LETPASSTHROW)? PROJECTILE_PIERCE_HIT : PROJECTILE_PIERCE_NONE)
	return PROJECTILE_PIERCE_NONE

/obj/projectile/proc/check_ricochet(atom/A)
	var/chance = ricochet_chance * A.receive_ricochet_chance_mod
	if(firer && HAS_TRAIT(firer, TRAIT_NICE_SHOT))
		chance += NICE_SHOT_RICOCHET_BONUS
	if(ricochets < min_ricochets || prob(chance))
		return TRUE
	return FALSE

/obj/projectile/proc/check_ricochet_flag(atom/A)
	if((armor_flag in list(ENERGY, LASER)) && (A.flags_ricochet & RICOCHET_SHINY))
		return TRUE

	if((armor_flag in list(BOMB, BULLET)) && (A.flags_ricochet & RICOCHET_HARD))
		return TRUE

	return FALSE

/obj/projectile/proc/return_predicted_turf_after_moves(moves, forced_angle) //I say predicted because there's no telling that the projectile won't change direction/location in flight.
	if(!trajectory && isnull(forced_angle) && isnull(Angle))
		return FALSE
	var/datum/point/vector/current = trajectory
	if(!current)
		var/turf/T = get_turf(src)
		current = new(T.x, T.y, T.z, pixel_x, pixel_y, isnull(forced_angle)? Angle : forced_angle, SSprojectiles.global_pixel_speed)
	var/datum/point/vector/v = current.return_vector_after_increments(moves * SSprojectiles.global_iterations_per_move)
	return v.return_turf()

/obj/projectile/proc/return_pathing_turfs_in_moves(moves, forced_angle)
	var/turf/current = get_turf(src)
	var/turf/ending = return_predicted_turf_after_moves(moves, forced_angle)
	return get_line(current, ending)

/obj/projectile/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE //Bullets don't drift in space

/obj/projectile/process()
	last_process = world.time
	if(!loc || !fired || !trajectory)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process //Compensates for pausing, so it doesn't become a hitscan projectile when unpaused from charged up ticks.
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = speed > 0? FLOOR(elapsed_time_deciseconds / speed, 1) : MOVES_HITSCAN //Would be better if a 0 speed made hitscan but everyone hates those so I can't make it a universal system :<
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	else
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += MODULUS(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(pixel_speed_multiplier, FALSE)

/obj/projectile/proc/fire(angle, atom/direct_target)
	LAZYINITLIST(impacted)
	if(fired_from)
		SEND_SIGNAL(fired_from, COMSIG_PROJECTILE_BEFORE_FIRE, src, original)
	if(firer)
		SEND_SIGNAL(firer, COMSIG_PROJECTILE_FIRER_BEFORE_FIRE, src, fired_from, original)
	//If no angle needs to resolve it from xo/yo!
	if(shrapnel_type && LAZYLEN(embedding))
		AddElement(/datum/element/embed, projectile_payload = shrapnel_type)
	if(!log_override && firer && original)
		log_combat(firer, original, "fired at", src, "from [get_area_name(src, TRUE)]")
			//note: mecha projectile logging is handled in /obj/item/mecha_parts/mecha_equipment/weapon/action(). try to keep these messages roughly the sameish just for consistency's sake.
	if(direct_target && (get_dist(direct_target, get_turf(src)) <= 1)) // point blank shots
		process_hit(get_turf(direct_target), direct_target)
		if(QDELETED(src))
			return
	if(isnum(angle))
		set_angle(angle)
	if(spread)
		set_angle(Angle + ((rand() - 0.5) * spread))
	var/turf/starting = get_turf(src)
	if(isnull(Angle)) //Try to resolve through offsets if there's no angle set.
		if(isnull(xo) || isnull(yo))
			stack_trace("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			qdel(src)
			return
		var/turf/target = locate(clamp(starting + xo, 1, world.maxx), clamp(starting + yo, 1, world.maxy), starting.z)
		set_angle(get_angle(src, target))
	original_angle = Angle
	if(!nondirectional_sprite)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		transform = matrix
	trajectory_ignore_forcemove = TRUE
	forceMove(starting)
	trajectory_ignore_forcemove = FALSE
	trajectory = new(starting.x, starting.y, starting.z, pixel_x, pixel_y, Angle, SSprojectiles.global_pixel_speed)
	last_projectile_move = world.time
	fired = TRUE
	play_fov_effect(starting, 6, "gunfire", dir = NORTH, angle = Angle)
	SEND_SIGNAL(src, COMSIG_PROJECTILE_FIRE)
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attempt_parry))
	if(hitscan)
		process_hitscan()
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSprojectiles, src)
	pixel_move(pixel_speed_multiplier, FALSE) //move it now!

/obj/projectile/proc/set_angle(new_angle) //wrapper for overrides.
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		transform = matrix
	if(trajectory)
		trajectory.set_angle(new_angle)
	if(fired && hitscan && isloc(loc) && (loc != last_angle_set_hitscan_store))
		last_angle_set_hitscan_store = loc
		var/datum/point/point_cache = new (src)
		point_cache = trajectory.copy_to()
		store_hitscan_collision(point_cache)
	return TRUE

/// Same as set_angle, but the reflection continues from the center of the object that reflects it instead of the side
/obj/projectile/proc/set_angle_centered(new_angle)
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		transform = matrix
	if(trajectory)
		trajectory.set_angle(new_angle)

	var/list/coordinates = trajectory.return_coordinates()
	trajectory.set_location(coordinates[1], coordinates[2], coordinates[3]) // Sets the trajectory to the center of the tile it bounced at

	if(fired && hitscan && isloc(loc) && (loc != last_angle_set_hitscan_store)) // Handles hitscan projectiles
		last_angle_set_hitscan_store = loc
		var/datum/point/point_cache = new (src)
		point_cache.initialize_location(coordinates[1], coordinates[2], coordinates[3]) // Take the center of the hitscan collision tile
		store_hitscan_collision(point_cache)
	return TRUE



/obj/projectile/forceMove(atom/target)
	if(!isloc(target) || !isloc(loc) || !z)
		return ..()
	var/zc = target.z != z
	var/old = loc
	if(zc)
		before_z_change(old, target)
	. = ..()
	if(QDELETED(src)) // we coulda bumped something
		return
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		if(hitscan)
			finalize_hitscan_and_generate_tracers(FALSE)
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)
		if(hitscan)
			record_hitscan_start(RETURN_PRECISE_POINT(src))
	if(zc)
		after_z_change(old, target)

/obj/projectile/proc/after_z_change(atom/olcloc, atom/newloc)

/obj/projectile/proc/before_z_change(atom/oldloc, atom/newloc)

/obj/projectile/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, Angle))
			set_angle(var_value)
			return TRUE
		else
			return ..()

/obj/projectile/proc/set_pixel_speed(new_speed)
	if(trajectory)
		trajectory.set_speed(new_speed)
		return TRUE
	return FALSE

/obj/projectile/proc/record_hitscan_start(datum/point/point_cache)
	if(point_cache)
		beam_segments = list()
		beam_index = point_cache
		beam_segments[beam_index] = null //record start.

/obj/projectile/proc/process_hitscan()
	var/safety = range * 10
	record_hitscan_start(RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1))
	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue
		if(safety-- <= 0)
			if(loc)
				Bump(loc)
			if(!QDELETED(src))
				qdel(src)
			return //Kill!
		pixel_move(1, TRUE)

/obj/projectile/proc/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	if(!loc || !trajectory)
		return
	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		transform = matrix
	if(homing)
		process_homing()
	var/forcemoved = FALSE
	for(var/i in 1 to SSprojectiles.global_iterations_per_move)
		if(QDELETED(src))
			return
		trajectory.increment(trajectory_multiplier)
		var/turf/T = trajectory.return_turf()
		if(!istype(T))
			qdel(src)
			return
		if(T.z != loc.z)
			var/old = loc
			before_z_change(loc, T)
			trajectory_ignore_forcemove = TRUE
			forceMove(T)
			trajectory_ignore_forcemove = FALSE
			after_z_change(old, loc)
			if(!hitscanning)
				pixel_x = trajectory.return_px()
				pixel_y = trajectory.return_py()
			forcemoved = TRUE
			hitscan_last = loc
		else if(T != loc)
			step_towards(src, T)
			hitscan_last = loc
	if(QDELETED(src)) //deleted on last move
		return
	if(!hitscanning && !forcemoved)
		pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier * SSprojectiles.global_iterations_per_move
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	Range()

/obj/projectile/proc/process_homing() //may need speeding up in the future performance wise.
	if(!homing_target)
		return FALSE
	var/datum/point/PT = RETURN_PRECISE_POINT(homing_target)
	PT.x += clamp(homing_offset_x, 1, world.maxx)
	PT.y += clamp(homing_offset_y, 1, world.maxy)
	var/angle = closer_angle_difference(Angle, angle_between_points(RETURN_PRECISE_POINT(src), PT))
	set_angle(Angle + clamp(angle, -homing_turn_speed, homing_turn_speed))

/obj/projectile/proc/set_homing_target(atom/A)
	if(!A || (!isturf(A) && !isturf(A.loc)))
		return FALSE
	homing = TRUE
	homing_target = A
	homing_offset_x = rand(homing_inaccuracy_min, homing_inaccuracy_max)
	homing_offset_y = rand(homing_inaccuracy_min, homing_inaccuracy_max)
	if(prob(50))
		homing_offset_x = -homing_offset_x
	if(prob(50))
		homing_offset_y = -homing_offset_y

/**
 * Aims the projectile at a target.
 *
 * Must be passed at least one of a target or a list of click parameters.
 * If only passed the click modifiers the source atom must be a mob with a client.
 *
 * Arguments:
 * - [target][/atom]: (Optional) The thing that the projectile will be aimed at.
 * - [source][/atom]: The initial location of the projectile or the thing firing it.
 * - [modifiers][/list]: (Optional) A list of click parameters to apply to this operation.
 * - deviation: (Optional) How the trajectory should deviate from the target in degrees.
 *   - //Spread is FORCED!
 */
/obj/projectile/proc/preparePixelProjectile(atom/target, atom/source, list/modifiers = null, deviation = 0)
	if(!(isnull(modifiers) || islist(modifiers)))
		stack_trace("WARNING: Projectile [type] fired with non-list modifiers, likely was passed click params.")
		modifiers = null

	var/turf/source_loc = get_turf(source)
	var/turf/target_loc = get_turf(target)
	if(isnull(source_loc))
		stack_trace("WARNING: Projectile [type] fired from nullspace.")
		qdel(src)
		return FALSE

	trajectory_ignore_forcemove = TRUE
	forceMove(source_loc)
	trajectory_ignore_forcemove = FALSE

	starting = source_loc
	pixel_x = source.pixel_x
	pixel_y = source.pixel_y
	original = target
	if(length(modifiers))
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, target_loc && target, modifiers)

		p_x = calculated[2]
		p_y = calculated[3]
		set_angle(calculated[1] + deviation)
		return TRUE

	if(target_loc)
		yo = target_loc.y - source_loc.y
		xo = target_loc.x - source_loc.x
		set_angle(get_angle(src, target_loc) + deviation)
		return TRUE

	stack_trace("WARNING: Projectile [type] fired without a target or mouse parameters to aim with.")
	qdel(src)
	return FALSE

/**
 * Calculates the pixel offsets and angle that a projectile should be launched at.
 *
 * Arguments:
 * - [source][/atom]: The thing that the projectile is being shot from.
 * - [target][/atom]: (Optional) The thing that the projectile is being shot at.
 *   - If this is not provided the  source atom must be a mob with a client.
 * - [modifiers][/list]: A list of click parameters used to modify the shot angle.
 */
/proc/calculate_projectile_angle_and_pixel_offsets(atom/source, atom/target, modifiers)
	var/angle = 0
	var/p_x = LAZYACCESS(modifiers, ICON_X) ? text2num(LAZYACCESS(modifiers, ICON_X)) : world.icon_size / 2 // ICON_(X|Y) are measured from the bottom left corner of the icon.
	var/p_y = LAZYACCESS(modifiers, ICON_Y) ? text2num(LAZYACCESS(modifiers, ICON_Y)) : world.icon_size / 2 // This centers the target if modifiers aren't passed.

	if(target)
		var/turf/source_loc = get_turf(source)
		var/turf/target_loc = get_turf(target)
		var/dx = ((target_loc.x - source_loc.x) * world.icon_size) + (target.pixel_x - source.pixel_x) + (p_x - (world.icon_size / 2))
		var/dy = ((target_loc.y - source_loc.y) * world.icon_size) + (target.pixel_y - source.pixel_y) + (p_y - (world.icon_size / 2))

		angle = ATAN2(dy, dx)
		return list(angle, p_x, p_y)

	if(!ismob(source) || !LAZYACCESS(modifiers, SCREEN_LOC))
		CRASH("Can't make trajectory calculations without a target or click modifiers and a client.")

	var/mob/user = source
	if(!user.client)
		CRASH("Can't make trajectory calculations without a target or click modifiers and a client.")

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")

	var/tx = (text2num(screen_loc_X[1]) - 1) * world.icon_size + text2num(screen_loc_X[2])
	var/ty = (text2num(screen_loc_Y[1]) - 1) * world.icon_size + text2num(screen_loc_Y[2])

	//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
	var/list/screenview = view_to_pixels(user.client.view)

	var/ox = round(screenview[1] / 2) - user.client.pixel_x //"origin" x
	var/oy = round(screenview[2] / 2) - user.client.pixel_y //"origin" y
	angle = ATAN2(tx - oy, ty - ox)
	return list(angle, p_x, p_y)

/obj/projectile/Destroy()
	if(hitscan)
		finalize_hitscan_and_generate_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	cleanup_beam_segments()
	if(trajectory)
		QDEL_NULL(trajectory)
	return ..()

/obj/projectile/proc/cleanup_beam_segments()
	QDEL_LIST_ASSOC(beam_segments)
	beam_segments = list()
	QDEL_NULL(beam_index)

/obj/projectile/proc/finalize_hitscan_and_generate_tracers(impacting = TRUE)
	if(trajectory && beam_index)
		var/datum/point/point_cache = trajectory.copy_to()
		beam_segments[beam_index] = point_cache
	generate_hitscan_tracers(null, null, impacting)

/obj/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 3, impacting = TRUE)
	if(!length(beam_segments))
		return
	if(tracer_type)
		var/tempref = REF(src)
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration, hitscan_light_range, hitscan_light_color_override, hitscan_light_intensity, tempref)
	if(muzzle_type && duration > 0)
		var/datum/point/p = beam_segments[1]
		var/atom/movable/thing = new muzzle_type
		p.move_atom_to_src(thing)
		var/matrix/matrix = new
		matrix.Turn(original_angle)
		thing.transform = matrix
		thing.color = color
		thing.set_light(muzzle_flash_range, muzzle_flash_intensity, muzzle_flash_color_override? muzzle_flash_color_override : color)
		QDEL_IN(thing, duration)
	if(impacting && impact_type && duration > 0)
		var/datum/point/p = beam_segments[beam_segments[beam_segments.len]]
		var/atom/movable/thing = new impact_type
		p.move_atom_to_src(thing)
		var/matrix/matrix = new
		matrix.Turn(Angle)
		thing.transform = matrix
		thing.color = color
		thing.set_light(impact_light_range, impact_light_intensity, impact_light_color_override? impact_light_color_override : color)
		QDEL_IN(thing, duration)
	if(cleanup)
		cleanup_beam_segments()

/obj/projectile/experience_pressure_difference()
	return

///Like [/obj/item/proc/updateEmbedding] but for projectiles instead, call this when you want to add embedding or update the stats on the embedding element
/obj/projectile/proc/updateEmbedding()
	if(!shrapnel_type || !LAZYLEN(embedding))
		return

	AddElement(/datum/element/embed,\
		embed_chance = (!isnull(embedding["embed_chance"]) ? embedding["embed_chance"] : EMBED_CHANCE),\
		fall_chance = (!isnull(embedding["fall_chance"]) ? embedding["fall_chance"] : EMBEDDED_ITEM_FALLOUT),\
		pain_chance = (!isnull(embedding["pain_chance"]) ? embedding["pain_chance"] : EMBEDDED_PAIN_CHANCE),\
		pain_mult = (!isnull(embedding["pain_mult"]) ? embedding["pain_mult"] : EMBEDDED_PAIN_MULTIPLIER),\
		remove_pain_mult = (!isnull(embedding["remove_pain_mult"]) ? embedding["remove_pain_mult"] : EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER),\
		rip_time = (!isnull(embedding["rip_time"]) ? embedding["rip_time"] : EMBEDDED_UNSAFE_REMOVAL_TIME),\
		ignore_throwspeed_threshold = (!isnull(embedding["ignore_throwspeed_threshold"]) ? embedding["ignore_throwspeed_threshold"] : FALSE),\
		impact_pain_mult = (!isnull(embedding["impact_pain_mult"]) ? embedding["impact_pain_mult"] : EMBEDDED_IMPACT_PAIN_MULTIPLIER),\
		jostle_chance = (!isnull(embedding["jostle_chance"]) ? embedding["jostle_chance"] : EMBEDDED_JOSTLE_CHANCE),\
		jostle_pain_mult = (!isnull(embedding["jostle_pain_mult"]) ? embedding["jostle_pain_mult"] : EMBEDDED_JOSTLE_PAIN_MULTIPLIER),\
		pain_stam_pct = (!isnull(embedding["pain_stam_pct"]) ? embedding["pain_stam_pct"] : EMBEDDED_PAIN_STAM_PCT),\
		projectile_payload = shrapnel_type)
	return TRUE

/**
 * Is this projectile considered "hostile"?
 *
 * By default all projectiles which deal damage or impart crowd control effects (including stamina) are hostile
 *
 * This is NOT used for pacifist checks, that's handled by [/obj/item/ammo_casing/var/harmful]
 * This is used in places such as AI responses to determine if they're being threatened or not (among other places)
 */
/obj/projectile/proc/is_hostile_projectile()
	if(damage > 0 || stamina > 0)
		return TRUE

	if(paralyze + stun + immobilize + knockdown > 0 SECONDS)
		return TRUE

	return FALSE

#undef MOVES_HITSCAN
#undef MUZZLE_EFFECT_PIXEL_INCREMENT
