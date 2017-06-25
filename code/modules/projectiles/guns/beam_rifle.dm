
/obj/item/weapon/gun/energy/beam_rifle
	name = "particle acceleration rifle"
	desc = "An energy-based anti material marksman rifle that uses highly charged particle beams moving at extreme velocities to decimate whatever is unfortunate enough to be targetted by one. \
		<span class='boldnotice'>Hold down left click while scoped to aim, when weapon is fully aimed (Tracer goes from red to green as it charges), release to fire. Moving while aiming or \
		changing where you're pointing at while aiming will delay the aiming process depending on how much you changed.</span>"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "esniper"
	item_state = "esniper"
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	origin_tech = ""
	recoil = 5
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	zoomable = TRUE
	zoom_amt = 17
	zoom_out_amt = 20
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan)
	var/hipfire_inaccuracy = 2
	var/hipfire_recoil = 10
	var/scoped_inaccuracy = 0
	var/scoped_recoil = 3
	var/scoped = FALSE
	var/noscope = FALSE	//Can you fire this without a scope?
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle
	canMouseDown = TRUE
	pin = null
	var/aiming = FALSE
	var/aiming_time = 7
	var/aiming_time_fire_threshold = 2
	var/aiming_time_left = 7
	var/aiming_time_increase_user_movement = 3
	var/scoped_slow = 1
	var/aiming_time_increase_angle_multiplier = 0.6

	var/lastangle = 0
	var/mob/current_user = null
	var/list/obj/effect/temp_visual/current_tracers = list()

	var/structure_piercing = 2				//This doesn't always work!
	var/structure_bleed_coeff = 0.7
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 50
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 40
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 30
	var/impact_structure_damage = 60
	var/projectile_damage = 30
	var/projectile_stun = 0
	var/projectile_setting_pierce = TRUE
	var/delay = 65
	var/lastfire = 0

	var/static/image/charged_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_charged")
	var/static/image/drained_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_empty")

/obj/item/weapon/gun/energy/beam_rifle/debug
	delay = 0
	cell_type = /obj/item/weapon/stock_parts/cell/infinite
	aiming_time = 0
	recoil = 0
	scoped_recoil = 0
	hipfire_recoil = 0
	hipfire_inaccuracy = 0
	scoped_inaccuracy = 0
	noscope = 1

/obj/item/weapon/gun/energy/beam_rifle/update_icon()
	cut_overlays()
	var/obj/item/ammo_casing/energy/primary_ammo = ammo_type[1]
	if(cell.charge > primary_ammo.e_cost)
		add_overlay(charged_overlay)
	else
		add_overlay(drained_overlay)

/obj/item/weapon/gun/energy/beam_rifle/attack_self(mob/user)
	projectile_setting_pierce = !projectile_setting_pierce
	to_chat(user, "<span class='boldnotice'>You set \the [src] to [projectile_setting_pierce? "pierce":"impact"] mode.</span>")

/obj/item/weapon/gun/energy/beam_rifle/proc/update_slowdown()
	if(scoped)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/weapon/gun/energy/beam_rifle/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/weapon/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/obj/item/weapon/gun/energy/beam_rifle/zoom(user, forced_zoom)
	. = ..()
	scope(user, .)

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
	update_slowdown()

/obj/item/weapon/gun/energy/beam_rifle/can_trigger_gun(var/mob/living/user)
	if(!scoped && !noscope)
		user << "<span class='userdanger'>This beam rifle can only be used while scoped!</span>"
		return FALSE
	. = ..(user)

/obj/item/weapon/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()

/obj/item/weapon/gun/energy/beam_rifle/proc/aiming_beam()
	var/atom/A = current_user.client.mouseObject
	if(!istype(A) || !A.loc)
		return
	var/turf/T = get_turf(current_user.client.mouseObject)
	if(!istype(T))
		return
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.gun = src
	P.wall_pierce_amount = wall_pierce_amount
	P.structure_pierce_amount = structure_piercing
	P.do_pierce = projectile_setting_pierce
	P.preparePixelProjectile(current_user.client.mouseObject, T, current_user, current_user.client.mouseParams, 0)
	if(aiming_time)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * ((100 - percent) / 100),0)
	else
		P.color = rgb(0, 255, 0)
	clear_tracers()
	P.fire()

/obj/item/weapon/gun/energy/beam_rifle/proc/clear_tracers()
	for(var/I in current_tracers)
		current_tracers -= I
		var/obj/effect/temp_visual/projectile_beam/PB = I
		qdel(PB)

/obj/item/weapon/gun/energy/beam_rifle/proc/terminate_aiming()
	stop_aiming()
	clear_tracers()

/obj/item/weapon/gun/energy/beam_rifle/process()
	if(!aiming)
		return
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		terminate_aiming()
		return
	if(aiming_time_left > 0)
		aiming_time_left--
	aiming_beam()
	process_aim()

/obj/item/weapon/gun/energy/beam_rifle/proc/process_aim()
	if(current_user.client.mouseParams)
		var/list/mouse_control = params2list(current_user.client.mouseParams)
		if(isturf(current_user.client.mouseLocation))
			current_user.face_atom(current_user.client.mouseLocation)
		if(mouse_control["screen-loc"])
			var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")
			var/list/screen_loc_X = splittext(screen_loc_params[1],":")
			var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
			var/x = (text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32)
			var/y = (text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32)
			var/screenview = (current_user.client.view * 2 + 1) * world.icon_size //Refer to http://www.byond.com/docs/ref/info.html#/client/var/view for mad maths
			var/ox = round(screenview/2) - current_user.client.pixel_x //"origin" x
			var/oy = round(screenview/2) - current_user.client.pixel_y //"origin" y
			var/angle = NORM_ROT(Atan2(y - oy, x - ox))
			var/difference = abs(lastangle - angle)
			delay_penalty(difference * aiming_time_increase_angle_multiplier)
			lastangle = angle

/obj/item/weapon/gun/energy/beam_rifle/on_mob_move()
	delay_penalty(aiming_time_increase_user_movement)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_aiming()
	aiming_time_left = aiming_time
	aiming = FALSE

/obj/item/weapon/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	current_user = mob

/obj/item/weapon/gun/energy/beam_rifle/onMouseDown(object, location, params, mob)
	start_aiming()
	current_user = mob

/obj/item/weapon/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold)
		sync_ammo()
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	clear_tracers()

/obj/item/weapon/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/proc/sync_ammo()
	for(var/obj/item/ammo_casing/energy/beam_rifle/AC in contents)
		AC.sync_stats()

/obj/item/weapon/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = Clamp(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 30
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 66
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 20
	var/impact_structure_damage = 50
	var/projectile_damage = 40
	var/projectile_stun = 0
	var/structure_piercing = 2
	var/structure_bleed_coeff = 0.7
	var/do_pierce = TRUE
	var/obj/item/weapon/gun/energy/beam_rifle/host

/obj/item/ammo_casing/energy/beam_rifle/proc/sync_stats()
	var/obj/item/weapon/gun/energy/beam_rifle/BR = loc
	if(!istype(BR))
		stack_trace("Beam rifle syncing error")
	host = BR
	do_pierce = BR.projectile_setting_pierce
	wall_pierce_amount = BR.wall_pierce_amount
	wall_devastate = BR.wall_devastate
	aoe_structure_range = BR.aoe_structure_range
	aoe_structure_damage = BR.aoe_structure_damage
	aoe_fire_range = BR.aoe_fire_range
	aoe_fire_chance = BR.aoe_fire_chance
	aoe_mob_range = BR.aoe_mob_range
	aoe_mob_damage = BR.aoe_mob_damage
	impact_structure_damage = BR.impact_structure_damage
	projectile_damage = BR.projectile_damage
	projectile_stun = BR.projectile_stun
	delay = BR.delay
	structure_piercing = BR.structure_piercing
	structure_bleed_coeff = BR.structure_bleed_coeff

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	. = ..(target, user, quiet, zone_override)
	var/obj/item/projectile/beam/beam_rifle/hitscan/HS_BB = BB
	if(!istype(HS_BB))
		return
	HS_BB.impact_direct_damage = projectile_damage
	HS_BB.stun = projectile_stun
	HS_BB.impact_structure_damage = impact_structure_damage
	HS_BB.aoe_mob_damage = aoe_mob_damage
	HS_BB.aoe_mob_range = Clamp(aoe_mob_range, 0, 15)				//Badmin safety lock
	HS_BB.aoe_fire_chance = aoe_fire_chance
	HS_BB.aoe_fire_range = aoe_fire_range
	HS_BB.aoe_structure_damage = aoe_structure_damage
	HS_BB.aoe_structure_range = Clamp(aoe_structure_range, 0, 15)	//Badmin safety lock
	HS_BB.wall_devastate = wall_devastate
	HS_BB.wall_pierce_amount = wall_pierce_amount
	HS_BB.structure_pierce_amount = structure_piercing
	HS_BB.structure_bleed_coeff = structure_bleed_coeff
	HS_BB.do_pierce = do_pierce
	HS_BB.gun = host

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "beam"
	e_cost = 5000
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = ""
	hitsound = 'sound/effects/explosion3.ogg'
	damage = 0				//Handled manually.
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	var/obj/item/weapon/gun/energy/beam_rifle/gun
	var/structure_pierce_amount = 0				//All set to 0 so the gun can manually set them during firing.
	var/structure_bleed_coeff = 0
	var/structure_pierce = 0
	var/do_pierce = TRUE
	var/wall_pierce_amount = 0
	var/wall_pierce = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 0
	var/aoe_structure_damage = 0
	var/aoe_fire_range = 0
	var/aoe_fire_chance = 0
	var/aoe_mob_range = 0
	var/aoe_mob_damage = 0
	var/impact_structure_damage = 0
	var/impact_direct_damage = 0
	var/turf/cached

/obj/item/projectile/beam/beam_rifle/proc/AOE(turf/epicenter)
	set waitfor = FALSE
	if(!epicenter)
		return
	new /obj/effect/temp_visual/explosion/fast(epicenter)
	for(var/mob/living/L in range(aoe_mob_range, epicenter))		//handle aoe mob damage
		L.adjustFireLoss(aoe_mob_damage)
		to_chat(L, "<span class='userdanger'>\The [src] sears you!</span>")
	for(var/turf/T in range(aoe_fire_range, epicenter))		//handle aoe fire
		if(prob(aoe_fire_chance))
			new /obj/effect/hotspot(T)
	for(var/obj/O in range(aoe_structure_range, epicenter))
		if(!isitem(O))
			if(O.level == 1)	//Please don't break underfloor items!
				continue
			O.take_damage(aoe_structure_damage * get_damage_coeff(O), BURN, "laser", FALSE)

/obj/item/projectile/beam/beam_rifle/proc/check_pierce(atom/target)
	if(!do_pierce)
		return FALSE
	if(isclosedturf(target))
		if(wall_pierce++ < wall_pierce_amount)
			loc = target
			if(prob(wall_devastate))
				target.ex_act(2)
			return TRUE
	if(ismovableatom(target))
		var/atom/movable/AM = target
		if(AM.density && !AM.CanPass(src, get_turf(target)) && !ismob(AM))
			if(structure_pierce++ < structure_pierce_amount)
				if(isobj(AM))
					var/obj/O = AM
					O.take_damage((impact_structure_damage + aoe_structure_damage) * structure_bleed_coeff * get_damage_coeff(AM), BURN, "energy", FALSE)
				loc = get_turf(AM)
				return TRUE
	return FALSE

/obj/item/projectile/beam/beam_rifle/proc/get_damage_coeff(atom/target)
	if(istype(target, /obj/machinery/door))
		return 0.4
	if(istype(target, /obj/structure/window))
		return 0.5
	return 1

/obj/item/projectile/beam/beam_rifle/proc/handle_impact(atom/target)
	if(isobj(target))
		var/obj/O = target
		O.take_damage(impact_structure_damage * get_damage_coeff(target), BURN, "laser", FALSE)
	if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(impact_direct_damage)
		L.emote("scream")

/obj/item/projectile/beam/beam_rifle/proc/handle_hit(atom/target)
	set waitfor = FALSE
	if(!cached && !QDELETED(target))
		cached = get_turf(target)
	if(nodamage)
		return FALSE
	playsound(cached, 'sound/effects/explosion3.ogg', 100, 1)
	AOE(cached)
	if(!QDELETED(target))
		handle_impact(target)

/obj/item/projectile/beam/beam_rifle/Bump(atom/target, yes)
	if(check_pierce(target))
		permutated += target
		return FALSE
	if(!QDELETED(target))
		cached = get_turf(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = 0)
	if(!QDELETED(target))
		cached = get_turf(target)
	handle_hit(target)
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	var/tracer_type = /obj/effect/temp_visual/projectile_beam/tracer

/obj/item/projectile/beam/beam_rifle/hitscan/fire(setAngle, atom/direct_target)	//oranges didn't let me make this a var the first time around so copypasta time
	set waitfor = 0
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(setAngle)
		Angle = setAngle
	var/next_run = world.time
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
	var/safety = 0	//The code works fine, but... just in case...
	while(loc)
		if(++safety > (range * 3))	//If it's looping for way, way too long...
			return	//Kill!
		if((!( current ) || loc == current))
			current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
		if(!Angle)
			Angle=round(Get_Angle(src,current))
		if(spread)
			Angle += (rand() - 0.5) * spread
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
		var/Pixel_x=sin(Angle)+16*sin(Angle)*2
		var/Pixel_y=cos(Angle)+16*cos(Angle)*2
		var/pixel_x_offset = old_pixel_x + Pixel_x
		var/pixel_y_offset = old_pixel_y + Pixel_y
		var/new_x = x
		var/new_y = y
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
		pixel_x = old_pixel_x
		pixel_y = old_pixel_y
		step_towards(src, locate(new_x, new_y, z))
		next_run += max(world.tick_lag, speed)
		var/delay = next_run - world.time
		if(delay <= world.tick_lag*2)
			pixel_x = pixel_x_offset
			pixel_y = pixel_y_offset
		else
			animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (delay <= 3 ? delay - 1 : delay)), flags = ANIMATION_END_NOW)
		old_pixel_x = pixel_x_offset
		old_pixel_y = pixel_y_offset
		if(original && (original.layer>=2.75) || ismob(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original, 1)
		Range()

/obj/item/projectile/beam/beam_rifle/hitscan/Range()
	spawn_tracer_effect()
	if(!QDELETED(src) && loc)
		cached = get_turf(src)

/obj/item/projectile/beam/beam_rifle/hitscan/proc/spawn_tracer_effect()
	QDEL_IN((new tracer_type(loc, time = 5, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)), 5)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/temp_visual/projectile_beam/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/spawn_tracer_effect()
	var/obj/effect/temp_visual/projectile_beam/T = new tracer_type(loc, time = 5, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)
	if(istype(gun) && istype(T))
		gun.current_tracers[T] = TRUE

/obj/effect/temp_visual/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = 1
	duration = 5
	randomdir = FALSE
	light_power = 1
	light_range = 2
	light_color = "#00ffff"

/obj/effect/temp_visual/projectile_beam/New(time = 5, angle_override, p_x, p_y, color_override)
	duration = time
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	var/matrix/M = new
	M.Turn(angle_override)
	look.transform = M
	appearance = look
	..()

/obj/effect/temp_visual/projectile_beam/tracer
	icon_state = "tracer_beam"

/obj/effect/temp_visual/projectile_beam/tracer/aiming
	icon_state = "gbeam"
	duration = 1
