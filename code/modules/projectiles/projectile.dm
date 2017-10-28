
#define MOVES_HITSCAN -1		//Not actually hitscan but close as we get.

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = FALSE
	anchored = TRUE
	flags_1 = ABSTRACT_1
	pass_flags = PASSTABLE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""

	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/suppressed = FALSE	//Attack message
	var/yo = null
	var/xo = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/p_x = 16
	var/p_y = 16			// the pixel location of the tile that the player clicked. Default is the center

	//Fired processing vars
	var/fired = FALSE	//Have we been fired yet
	var/paused = FALSE	//for suspending the projectile midair
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/old_pixel_x = 0
	var/old_pixel_y = 0
	var/pixel_x_increment = 0
	var/pixel_y_increment = 0
	var/pixel_x_offset = 0
	var/pixel_y_offset = 0
	var/new_x = 0
	var/new_y = 0

	var/speed = 0.8			//Amount of deciseconds it takes for projectile to travel
	var/Angle = 0
	var/nondirectional_sprite = FALSE //Set TRUE to prevent projectiles from having their sprites rotated based on firing angle
	var/spread = 0			//amount (in degrees) of projectile spread
	animate_movement = 0	//Use SLIDE_STEPS in conjunction with legacy
	var/ricochets = 0
	var/ricochets_max = 2
	var/ricochet_chance = 30
	var/ignore_source_check = FALSE

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
	var/projectile_type = /obj/item/projectile
	var/range = 50 //This will de-increment every step. When 0, it will delete the projectile.
	var/is_reflectable = FALSE // Can it be reflected or not?
		//Effects
	var/stun = 0
	var/knockdown = 0
	var/unconscious = 0
	var/irradiate = 0
	var/stutter = 0
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 0
	var/jitter = 0
	var/forcedodge = 0 //to pass through everything
	var/dismemberment = 0 //The higher the number, the greater the bonus to dismembering. 0 will not dismember at all.
	var/impact_effect_type //what type of impact effect to show when hitting something
	var/log_override = FALSE //is this type spammed enough to not log? (KAs)

/obj/item/projectile/New()
	permutated = list()
	return ..()

/obj/item/projectile/proc/Range()
	range--
	if(range <= 0 && loc)
		on_range()

/obj/item/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	qdel(src)

//to get the correct limb (if any) for the projectile hit message
/mob/living/proc/check_limb_hit(hit_zone)
	if(has_limbs)
		return hit_zone

/mob/living/carbon/check_limb_hit(hit_zone)
	if(get_bodypart(hit_zone))
		return hit_zone
	else //when a limb is missing the damage is actually passed to the chest
		return "chest"

/obj/item/projectile/proc/prehit(atom/target)
	return TRUE

/obj/item/projectile/proc/on_hit(atom/target, blocked = FALSE)
	var/turf/target_loca = get_turf(target)
	if(!nodamage && (damage_type == BRUTE || damage_type == BURN) && iswallturf(target_loca) && prob(75))
		var/turf/closed/wall/W = target_loca
		var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "bullet_hole", TURF_DECAL_LAYER)
		if(target == original)
			decal.pixel_x = target.pixel_x + p_x - 16
			decal.pixel_y = target.pixel_y + p_y - 16
		else
			decal.pixel_x = target.pixel_x + rand(2, -2)
			decal.pixel_y = target.pixel_y + rand(2, -2)
		W.add_damage_decal(decal)
	if(!isliving(target))
		if(impact_effect_type)
			new impact_effect_type(target_loca, target, src)
		return 0
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
		else if(impact_effect_type)
			new impact_effect_type(target_loca, target, src)

		var/organ_hit_text = ""
		var/limb_hit = L.check_limb_hit(def_zone)//to get the correct message info.
		if(limb_hit)
			organ_hit_text = " in \the [parse_zone(limb_hit)]"
		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			to_chat(L, "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>")
		else
			if(hitsound)
				var/volume = vol_by_damage()
				playsound(loc, hitsound, volume, 1, -1)
			L.visible_message("<span class='danger'>[L] is hit by \a [src][organ_hit_text]!</span>", \
					"<span class='userdanger'>[L] is hit by \a [src][organ_hit_text]!</span>", null, COMBAT_MESSAGE_RANGE)
		L.on_hit(src)

	var/reagent_note
	if(reagents && reagents.reagent_list)
		reagent_note = " REAGENTS:"
		for(var/datum/reagent/R in reagents.reagent_list)
			reagent_note += R.id + " ("
			reagent_note += num2text(R.volume) + ") "

	add_logs(firer, L, "shot", src, reagent_note)
	return L.apply_effects(stun, knockdown, unconscious, irradiate, slur, stutter, eyeblur, drowsy, blocked, stamina, jitter)

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return Clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/Collide(atom/A)
	if(check_ricochet(A) && check_ricochet_flag(A) && ricochets < ricochets_max)
		ricochets++
		if(A.handle_ricochet(src))
			ignore_source_check = TRUE
			return FALSE
	if(firer && !ignore_source_check)
		if(A == firer || (A == firer.loc && ismecha(A))) //cannot shoot yourself or your mech
			loc = A.loc
			return FALSE

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	if(isturf(A) && hitsound_wall)
		var/volume = Clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	var/turf/target_turf = get_turf(A)

	if(!prehit(A))
		if(forcedodge)
			loc = target_turf
		return FALSE

	var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		loc = target_turf
		if(A)
			permutated.Add(A)
		return FALSE
	else
		var/atom/alt = select_target(A)
		if(alt)
			if(!prehit(alt))
				return FALSE
			alt.bullet_act(src, def_zone)
	qdel(src)
	return TRUE


/obj/item/projectile/proc/select_target(atom/A)				//Selects another target from a wall if we hit a wall.
	if(!A || !A.density || (A.flags_1 & ON_BORDER_1) || ismob(A) || A == original)	//if we hit a dense non-border obj or dense turf then we also hit one of the mobs or machines/structures on that tile.
		return
	var/turf/T = get_turf(A)
	if(original in T)
		return original
	var/list/mob/possible_mobs = typecache_filter_list(T, GLOB.typecache_mob) - A
	var/list/mob/mobs = list()
	for(var/i in possible_mobs)
		var/mob/M = i
		if(M.lying)
			continue
		mobs += M
	var/mob/M = safepick(mobs)
	if(M)
		return M.lowest_buckled_mob()
	var/obj/O = safepick(typecache_filter_list(T, GLOB.typecache_machine_or_structure) - A)
	if(O)
		return O

/obj/item/projectile/proc/check_ricochet()
	if(prob(ricochet_chance))
		return TRUE
	return FALSE

/obj/item/projectile/proc/check_ricochet_flag(atom/A)
	if(A.flags_1 & CHECK_RICOCHET_1)
		return TRUE
	return FALSE

/obj/item/projectile/Process_Spacemove(var/movement_dir = 0)
	return TRUE	//Bullets don't drift in space

/obj/item/projectile/process()
	last_process = world.time
	if(!loc || !fired)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process		//Compensates for pausing, so it doesn't become a hitscan projectile when unpaused from charged up ticks.
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = speed > 0? Floor(elapsed_time_deciseconds / speed) : MOVES_HITSCAN			//Would be better if a 0 speed made hitscan but everyone hates those so I can't make it a universal system :<
	if(required_moves == MOVES_HITSCAN)
		required_moves = SSprojectiles.global_max_tick_moves
	else
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += Modulus(elapsed_time_deciseconds, speed)

	for(var/i in 1 to required_moves)
		pixel_move(required_moves)

/obj/item/projectile/proc/fire(angle, atom/direct_target)
	//If no angle needs to resolve it from xo/yo!
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(direct_target)
		if(prehit(direct_target))
			direct_target.bullet_act(src, def_zone)
			qdel(src)
			return
	if(isnum(angle))
		setAngle(angle)
	if(spread)
		setAngle(Angle + ((rand() - 0.5) * spread))
	if(isnull(Angle))	//Try to resolve through offsets if there's no angle set.
		var/turf/starting = get_turf(src)
		var/turf/target = locate(Clamp(starting + xo, 1, world.maxx), Clamp(starting + yo, 1, world.maxy), starting.z)
		setAngle(Get_Angle(src, target))
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	old_pixel_x = pixel_x
	old_pixel_y = pixel_y
	last_projectile_move = world.time
	fired = TRUE
	if(!isprocessing)
		START_PROCESSING(SSprojectiles, src)

/obj/item/projectile/proc/setAngle(new_angle)	//wrapper for overrides.
	Angle = new_angle
	return TRUE

/obj/item/projectile/proc/pixel_move(moves)
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M

	pixel_x_increment=round((sin(Angle)+16*sin(Angle)*2), 1)	//round() is a floor operation when only one argument is supplied, we don't want that here
	pixel_y_increment=round((cos(Angle)+16*cos(Angle)*2), 1)
	pixel_x_offset = old_pixel_x + pixel_x_increment
	pixel_y_offset = old_pixel_y + pixel_y_increment
	new_x = x
	new_y = y

	while(pixel_x_offset > 16)
		pixel_x_offset -= 32
		old_pixel_x -= 32
		new_x++// x++
	while(pixel_x_offset < -16)
		pixel_x_offset += 32
		old_pixel_x += 32
		new_x--
	while(pixel_y_offset > 16)
		pixel_y_offset -= 32
		old_pixel_y -= 32
		new_y++
	while(pixel_y_offset < -16)
		pixel_y_offset += 32
		old_pixel_y += 32
		new_y--

	step_towards(src, locate(new_x, new_y, z))
	pixel_x = old_pixel_x
	pixel_y = old_pixel_y
	//var/animation_time = ((SSprojectiles.flags & SS_TICKER? (SSprojectiles.wait * world.tick_lag) : SSprojectiles.wait) / moves)
	animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = 1, flags = ANIMATION_END_NOW)
	old_pixel_x = pixel_x_offset
	old_pixel_y = pixel_y_offset
	if(can_hit_target(original, permutated))
		Collide(original)
	Range()
	last_projectile_move = world.time

//Returns true if the target atom is on our current turf and above the right layer
/obj/item/projectile/proc/can_hit_target(atom/target, var/list/passthrough)
	if(target && (target.layer >= PROJECTILE_HIT_THRESHHOLD_LAYER) || ismob(target))
		if(loc == get_turf(target))
			if(!(target in passthrough))
				return TRUE
	return FALSE

/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, params, spread = 0)
	var/turf/curloc = get_turf(source)
	var/turf/targloc = get_turf(target)
	forceMove(get_turf(source))
	starting = get_turf(source)
	original = target
	yo = targloc.y - curloc.y
	xo = targloc.x - curloc.x

	if(isliving(source) && params)
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(source, params)
		p_x = calculated[2]
		p_y = calculated[3]

		if(spread)
			setAngle(calculated[1] + spread)
		else
			setAngle(calculated[1])
	else
		setAngle(Get_Angle(src, targloc))

/proc/calculate_projectile_angle_and_pixel_offsets(mob/user, params)
	var/list/mouse_control = params2list(params)
	var/p_x = 0
	var/p_y = 0
	var/angle = 0
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])
	if(mouse_control["screen-loc"])
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")

		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")

		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
		var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32

		//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
		var/screenview = (user.client.view * 2 + 1) * world.icon_size //Refer to http://www.byond.com/docs/ref/info.html#/client/var/view for mad maths

		var/ox = round(screenview/2) - user.client.pixel_x //"origin" x
		var/oy = round(screenview/2) - user.client.pixel_y //"origin" y
		angle = Atan2(y - oy, x - ox)
	return list(angle, p_x, p_y)

/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && (AM.density || AM == original) && !checkpass(PASSMOB))
		Collide(AM)

/obj/item/projectile/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	return ..()

/obj/item/projectile/experience_pressure_difference()
	return
