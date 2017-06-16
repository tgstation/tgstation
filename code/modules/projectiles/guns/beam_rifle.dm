
#define ZOOM_LOCK_AUTOZOOM 0
#define ZOOM_LOCK_OFF 1
#define ZOOM_LOCK_INSTANT 2

#define AUTOZOOM_PIXEL_STEP_FACTOR 48

#define AIMING_BEAM_ANGLE_CHANGE_THRESHOLD 1

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
	recoil = 4
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan)
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle
	canMouseDown = TRUE
	pin = null
	var/aiming = FALSE
	var/aiming_time = 7
	var/aiming_time_fire_threshold = 2
	var/aiming_time_left = 7
	var/aiming_time_increase_user_movement = 3
	var/scoped_slow = 1
	var/aiming_time_increase_angle_multiplier = 0.3	//More reasonable.

	var/lastangle = 0
	var/aiming_lastangle = 0
	var/mob/current_user = null
	var/obj/effect/projectile_beam/current_tracer

	var/structure_piercing = 4				//Amount * 2. For some reason structures aren't respecting this unless you have it doubled.
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

	//ZOOMING
	var/zoom_current_view_increase = 0
	var/zoom_target_view_increase = 10
	var/zoom_speed = 1
	var/zooming = FALSE
	var/zoom_lock = ZOOM_LOCK_AUTOZOOM
	var/zooming_angle
	var/current_zoom_x = 0
	var/current_zoom_y = 0

	var/static/image/charged_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_charged")
	var/static/image/drained_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_empty")

/obj/item/weapon/gun/energy/beam_rifle/debug
	delay = 0
	cell_type = /obj/item/weapon/stock_parts/cell/infinite
	aiming_time = 0
	recoil = 0
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/energy/beam_rifle/proc/smooth_zooming(delay_override = null)
	if(!check_user() || !zooming)
		return
	var/total_time = SSfastprocess.wait
	if(delay_override)
		total_time = delay_override
	if(zoom_lock == ZOOM_LOCK_INSTANT)
		total_time = 0
	animate(current_user.client, pixel_x = current_zoom_x, pixel_y = current_zoom_y , total_time, SINE_EASING, ANIMATION_PARALLEL)

/obj/item/weapon/gun/energy/beam_rifle/proc/set_autozoom_pixel_offsets_immediate(current_angle)
	current_zoom_x = sin(current_angle) + sin(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_target_view_increase
	current_zoom_y = cos(current_angle) + cos(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_target_view_increase

/obj/item/weapon/gun/energy/beam_rifle/proc/handle_zooming()
	if(!zooming || !check_user())
		return
	if(zoom_lock == ZOOM_LOCK_INSTANT)
		current_user.client.view = world.view + zoom_target_view_increase
		set_autozoom_pixel_offsets_immediate(zooming_angle)
		smooth_zooming()
		return
	for(var/i in 1 to zoom_speed)
		if(++zoom_current_view_increase > zoom_target_view_increase)
			return
		current_user.client.view += 1
		set_autozoom_pixel_offsets_immediate(zooming_angle)
		smooth_zooming(SSfastprocess.wait * zoom_target_view_increase * zoom_speed)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_zooming()
	if(zoom_lock == ZOOM_LOCK_OFF)
		return
	zooming = TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_zooming()
	zooming = FALSE
	reset_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/reset_zooming()
	if(!check_user())
		return
	animate(current_user.client, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	zoom_current_view_increase = 0
	current_user.client.view = world.view
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

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
	if(aiming)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/weapon/gun/energy/beam_rifle/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/weapon/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	set_user(null)
	clear_tracer(TRUE)
	..()

/obj/item/weapon/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()

/obj/item/weapon/gun/energy/beam_rifle/proc/aiming_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update)
		return
	aiming_lastangle = lastangle
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
	clear_tracer()
	P.fire()

/obj/item/weapon/gun/energy/beam_rifle/proc/clear_tracer()
	qdel(current_tracer)

/obj/item/weapon/gun/energy/beam_rifle/proc/terminate_aiming()
	stop_aiming()
	clear_tracer()

/obj/item/weapon/gun/energy/beam_rifle/process()
	if(!aiming)
		return
	check_user()
	handle_zooming()
	if(aiming_time_left > 0)
		aiming_time_left--

/obj/item/weapon/gun/energy/beam_rifle/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			terminate_aiming()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
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
	check_user()
	if(aiming)
		delay_penalty(aiming_time_increase_user_movement)
		process_aim()
		aiming_beam(TRUE)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_aiming(n)
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	aiming_beam(TRUE)
	zooming_angle = lastangle
	start_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_aiming()
	aiming_time_left = aiming_time
	aiming = FALSE
	stop_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/set_user(mob/user)
	if(user == current_user)
		return
		terminate_aiming()
	if(istype(current_user))
		reset_zooming()
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
	current_user = null
	if(istype(user))
		current_user = user
		LAZYADD(current_user.mousemove_intercept_objects, src)

/obj/item/weapon/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	set_user(mob)
	if(aiming)
		process_aim()
		aiming_beam()
		zooming_angle = lastangle
		set_autozoom_pixel_offsets_immediate(zooming_angle)
		smooth_zooming(2)

/obj/item/weapon/gun/energy/beam_rifle/onMouseDown(object, location, params, mob)
	set_user(mob)
	start_aiming()

/obj/item/weapon/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold && check_user())
		sync_ammo()
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	clear_tracer()

/obj/item/weapon/gun/energy/beam_rifle/equipped(mob/user)
	. = ..()
	set_user(user)

/obj/item/weapon/gun/energy/beam_rifle/dropped()
	. = ..()
	set_user(null)

/obj/item/weapon/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	terminate_aiming()
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
		if(!istype(O, /obj/item))
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
	var/tracer_type = /obj/effect/projectile_beam/tracer

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
	var/obj/effect/projectile_beam/tracer/T = new tracer_type(loc, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)
	QDEL_IN(T, 5)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/projectile_beam/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0
	var/starting_x		//i can't be assed to port trajectory datums from baystation today so have this
	var/starting_y
	var/proj_z
	var/starting_p_x
	var/starting_p_y
	var/dest_x
	var/dest_y
	var/dest_p_x
	var/dest_p_y

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/Destroy()
	spawn_tracer()
	return ..()

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/proc/spawn_tracer()
	if(!starting_x || !starting_y || !proj_z || !starting_p_x || !starting_p_y || !dest_x || !dest_y || !dest_p_x || !dest_p_y)
		return
	var/x_offset = dest_x - starting_x
	var/y_offset = dest_y - starting_y
	var/turf/midpoint = locate(round((starting_x + x_offset) / 2, 1), round((starting_y + y_offset) / 2, 1), proj_z)
	var/obj/effect/projectile_beam/tracer/aiming = new
	if(istype(gun))
		gun.current_tracer = aiming
	var/pixels_between_points = round(sqrt((abs(x_offset) ** 2) + (abs(y_offset) ** 2)), 1)
	var/scaling = round(pixels_between_points/32, 1)
	aiming.apply_vars(Angle, pixel_x, pixel_y, color, scaling, midpoint)
	to_chat(world, "DEBUG: x_offset [x_offset] y_offset [y_offset] pixels [pixels_between_points] scaling [scaling]")

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/fire()
	var/turf/T = get_turf(src)
	starting_x = T.x
	starting_y = T.y
	proj_z = T.z
	starting_p_x = pixel_x
	starting_p_y = pixel_y
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/Bump(atom/target, yes)
	var/turf/T = get_turf(src)
	dest_x = T.x
	dest_y = T.y
	dest_p_x = pixel_x
	dest_p_y = pixel_y
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/spawn_tracer_effect()
	return

/obj/effect/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = 1
	light_power = 1
	light_range = 2
	light_color = "#00ffff"
	mouse_opacity = 0
	flags = ABSTRACT

/obj/effect/projectile_beam/New(angle_override, p_x, p_y, color_override)
	apply_vars(angle_override, p_x, p_y, color_override)
	return ..()

/obj/effect/projectile_beam/proc/apply_vars(angle_override, p_x, p_y, color_override, scaling = 1, new_loc)
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	var/matrix/M = new
	M.Turn(angle_override)
	M.Scale(1,scaling)
	look.transform = M
	appearance = look
	if(!isnull(new_loc))	//If you want to null it just delete it...
		forceMove(new_loc)

/obj/effect/projectile_beam/tracer
	icon_state = "tracer_beam"

/obj/effect/projectile_beam/tracer/aiming
	icon_state = "gbeam"
