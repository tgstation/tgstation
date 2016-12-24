
/obj/item/weapon/gun/energy/beam_rifle
	name = ""
	desc = ""
	icon = 'icons/obj/guns/'
	icon_state = ""
	item_state = ""
	fire_sound = ''
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	origin_tech = ""
	recoil = 5
	zoomable = TRUE
	zoom_amt = 20
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle)
	var/impact_delay = 10
	var/zoom_out_amt = 13
	var/power = 20
	var/maxpower = 20
	var/energy_coeff = 0.20
	var/hipfire_inaccuracy = 7
	var/hipfire_recoil = 20
	var/scoped_inaccuracy = 2
	var/scoped_recoil = 5
	var/scoped = FALSE
	var/noscope = FALSE	//Can you fire this without a scope?
	var/obj/item/weapon/stock_parts/capacitor/cap = new /obj/item/weapon/stock_parts/capacitor
	var/obj/item/weapon/stock_parts/scanning_module/scan = new /obj/item/weapon/stock_parts/scanning_module
	var/obj/item/weapon/stock_parts/manipulator/manip = new /obj/item/weapon/stock_parts/manipulator
	var/obj/item/weapon/stock_parts/micro_laser/laser = new /obj/item/weapon/stock_parts/micro_laser
	var/obj/item/weapon/stock_parts/matter_bin/bin = new /obj/item/weapon/stock_parts/matter_bin
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle
	var/datum/action/item_action/beam_rifle_power/poweraction

/obj/item/weapon/gun/energy/beam_rifle/New()
	..()
	poweraction = new()
	poweraction.gun = src

/obj/item/weapon/gun/energy/beam_rifle/pickup(mob/user)
	if(poweraction)
		poweraction.Grant(user)
	. = ..(user)

/obj/item/weapon/gun/dropped(mob/user)
	if(poweraction)
		poweraction.Remove(user)
	. = ..(user)

/obj/item/weapon/gun/energy/beam_rifle/proc/update_stats()
	maxpower = laser.rating*20
	//ammo cost usage here
	scoped_recoil = 5 - bin.rating
	hipfire_recoil = 20 - bin.rating*2
	scoped_inaccuracy = Clamp((3 - manip.rating), 0, 5)
	hipfire_inaccuacy = Clamp((30 - (manip.rating * 5)), 0, 30)

/obj/item/weapon/gun/energy/beam_rifle/zoom(user, forced_zoom)
	. = ..(user, forced_zoom)
	scope(user, zoomed)

/obj/item/weapon/gun/energy/beam_rifle/proc/scope(mob/user, forced)
	var/scoping
	switch(forced)
		if(TRUE)
			scoping = TRUE
		if(FALSE)
			scoping = FALSE
		else
			scoping = !scoped
	if(scoping)
		spread = scoped_inaccuracy
		recoil = scoped_recoil
		scoped = TRUE
		user << "<span class='boldnotice'>You bring your [src] up and use its scope...</span>"
	else
		spread = hipfire_inaccuracy
		recoil = hipfire_recoil
		scoped = FALSE
		user << "<span class='boldnotice'>You lower your [src].</span>"

/obj/item/weapon/gun/energy/beam_rifle/can_trigger_gun(var/mob/living/user)
	if(!scoped && !noscope)
		user << "<span class='userdanger'>This beam rifle can only be used while scoped!</span>"
		return FALSE
	. = ..(user)

/obj/item/weapon/gun/energy/beam_rifle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/S = I
		if(istype(S, /obj/item/weapon/stock_parts/manipulator))
			if((!manip) || (manip.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Accuracy increased.</span>"
				if(user.unEquip(I))
					I.loc = src
					manip = I
		if(istype(S, /obj/item/weapon/stock_parts/scanning_module))
			if((!scan) || (scan.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems.</span>"
				if(user.unEquip(I))
					I.loc = src
					scan = I
		if(istype(S, /obj/item/weapon/stock_parts/micro_laser))
			if((!laser) || (laser.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Power output increased.</span>"
				if(user.unEquip(I))
					I.loc = src
					laser = I
		if(istype(S, /obj/item/weapon/stock_parts/matter_bin))
			if((!bin) || (bin.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Recoil compensators upgraded.</span>"
				if(user.unEquip(I))
					I.loc = src
					bin = I
		if(istype(S, /obj/item/weapon/stock_parts/capacitor))
			if((!cap) || (cap.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Power efficiency upgraded.</span>"
				if(user.unEquip(I))
					I.loc = src
					cap = I
	. = (I, user, params)

/obj/item/weapon/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()
	return	//Energy drain handled by its cell.

/obj/item/weapon/gun/energy/beam_rifle/proc/select_power(mob/user)
	var/powerpercent = 50
	powerpercent = round(input("Set [src] to percentage power","Adjust power output", null) as num|null)
	if(powerpercent)
		power = ((100/maxpower) * powerpercent)
		user << "<span class='boldnotice'>[src] set to [powerpercent]% power.</span>"

/datum/action/item_action/beam_rifle_power
	name = "Adjust Power Output"
	var/obj/item/weapon/gun/energy/beam_rifle/gun
	button_icon_state = "
	background_icon_state = "

/datum/action/item_action/beam_rifle_power/Trigger()
	gun.select_power(owner)
	. = ..()

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	projectile_type = /obj/item/projectile/energy/beam_rifle
	e_cost = 2000
	var/base_energy_multiplier = 100
	var/hitscan_delay = 10
	fire_sound = 'sound/'
	firing_effect_type =

/obj/item/projectile/energy/beam_rifle
	name = "particle beam"
	icon = '
	icon_state = "
	hitsound = '
	hitsound_wall = "
	damage = 20
	damage_type = BURN
	flag = energy
	range = 150
	jitter = 10
	impact_effect_type =


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
	return

/obj/item/projectile/proc/on_hit(atom/target, blocked = 0)
	var/turf/target_loca = get_turf(target)
	if(!isliving(target))
		if(impact_effect_type)
			PoolOrNew(impact_effect_type, list(target_loca, target, src))
		return 0
	var/mob/living/L = target
	if(blocked != 100) // not completely blocked
		if(damage && L.blood_volume && damage_type == BRUTE)
			var/splatter_dir = dir
			if(starting)
				splatter_dir = get_dir(starting, target_loca)
			if(isalien(L))
				PoolOrNew(/obj/effect/overlay/temp/dir_setting/bloodsplatter/xenosplatter, list(target_loca, splatter_dir))
			else
				PoolOrNew(/obj/effect/overlay/temp/dir_setting/bloodsplatter, list(target_loca, splatter_dir))
			if(prob(33))
				L.add_splatter_floor(target_loca)
		else if(impact_effect_type)
			PoolOrNew(impact_effect_type, list(target_loca, target, src))

		var/organ_hit_text = ""
		var/limb_hit = L.check_limb_hit(def_zone)//to get the correct message info.
		if(limb_hit)
			organ_hit_text = " in \the [parse_zone(limb_hit)]"
		if(suppressed)
			playsound(loc, hitsound, 5, 1, -1)
			L << "<span class='userdanger'>You're shot by \a [src][organ_hit_text]!</span>"
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
	return L.apply_effects(stun, weaken, paralyze, irradiate, slur, stutter, eyeblur, drowsy, blocked, stamina, jitter)

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return Clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then clamp the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume

/obj/item/projectile/Bump(atom/A, yes)
	if(!yes) //prevents double bumps.
		return
	if(firer)
		if(A == firer || (A == firer.loc && istype(A, /obj/mecha))) //cannot shoot yourself or your mech
			loc = A.loc
			return 0

	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.

	if(isturf(A) && hitsound_wall)
		var/volume = Clamp(vol_by_damage() + 20, 0, 100)
		if(suppressed)
			volume = 5
		playsound(loc, hitsound_wall, volume, 1, -1)

	var/turf/target_turf = get_turf(A)

	prehit(A)
	var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null
	if(permutation == -1 || forcedodge)// the bullet passes through a dense object!
		loc = target_turf
		if(A)
			permutated.Add(A)
		return 0
	else
		if(A && A.density && !ismob(A) && !(A.flags & ON_BORDER)) //if we hit a dense non-border obj or dense turf then we also hit one of the mobs on that tile.
			var/list/mobs_list = list()
			for(var/mob/living/L in target_turf)
				mobs_list += L
			if(mobs_list.len)
				var/mob/living/picked_mob = pick(mobs_list)
				prehit(picked_mob)
				picked_mob.bullet_act(src, def_zone)
	qdel(src)

/obj/item/projectile/proc/fire(setAngle, atom/direct_target)
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(direct_target)
		prehit(direct_target)
		direct_target.bullet_act(src, def_zone)
		qdel(src)
		return
	if(setAngle)
		Angle = setAngle
	if(!legacy) //new projectiles
		set waitfor = 0
		var/next_run = world.time
		while(loc)
			if(paused)
				next_run = world.time
				sleep(1)
				continue

			if((!( current ) || loc == current))
				current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)

			if(!Angle)
				Angle=round(Get_Angle(src,current))
			if(spread)
				Angle += (rand() - 0.5) * spread
			var/matrix/M = new
			M.Turn(Angle)
			transform = M

			var/Pixel_x=round(sin(Angle)+16*sin(Angle)*2)
			var/Pixel_y=round(cos(Angle)+16*cos(Angle)*2)
			var/pixel_x_offset = pixel_x + Pixel_x
			var/pixel_y_offset = pixel_y + Pixel_y
			var/new_x = x
			var/new_y = y

			while(pixel_x_offset > 16)
				pixel_x_offset -= 32
				pixel_x -= 32
				new_x++// x++
			while(pixel_x_offset < -16)
				pixel_x_offset += 32
				pixel_x += 32
				new_x--

			while(pixel_y_offset > 16)
				pixel_y_offset -= 32
				pixel_y -= 32
				new_y++
			while(pixel_y_offset < -16)
				pixel_y_offset += 32
				pixel_y += 32
				new_y--

			step_towards(src, locate(new_x, new_y, z))
			next_run += max(world.tick_lag, speed)
			var/delay = next_run - world.time
			if(delay <= world.tick_lag*2)
				pixel_x = pixel_x_offset
				pixel_y = pixel_y_offset
			else
				animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (delay <= 3 ? delay - 1 : delay)), flags = ANIMATION_END_NOW)

			if(original && (original.layer>=2.75) || ismob(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original, 1)
			Range()
			if (delay > 0)
				sleep(delay)

	else //old projectile system
		set waitfor = 0
		while(loc)
			if(!paused)
				if((!( current ) || loc == current))
					current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
				step_towards(src, current)
				if(original && (original.layer>=2.75) || ismob(original))
					if(loc == get_turf(original))
						if(!(original in permutated))
							Bump(original, 1)
				Range()
			sleep(config.run_speed * 0.9)


