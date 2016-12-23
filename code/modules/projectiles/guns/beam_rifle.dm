
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
	var/impact_delay = 10
	var/zoom_out_amt = 13
	var/power =
	var/maxpower =
	var/hipfire_inaccuracy = 7
	var/hipfire_recoil = 10
	var/scoped_inaccuracy = 0
	var/scoped_recoil = 3
	var/obj/item/weapon/stock_parts/capacitor/cap = new /obj/item/weapon/stock_parts/capacitor
	var/obj/item/weapon/stock_parts/scanning_module/scan = new /obj/item/weapon/stock_parts/scanning_module
	var/obj/item/weapon/stock_parts/manipulator/manip = new /obj/item/weapon/stock_parts/manipulator
	var/obj/item/weapon/stock_parts/micro_laser/laser = new /obj/item/weapon/stock_parts/micro_laser
	var/obj/item/weapon/stock_parts/matter_bin/bin = new /obj/item/weapon/stock_parts/matter_bin
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle


/obj/item/weapon/gun/attackby(obj/item/I, mob/user, params)
	if(can_flashlight)
		if(istype(I, /obj/item/device/flashlight/seclite))
			var/obj/item/device/flashlight/seclite/S = I
			if(!gun_light)
				if(!user.unEquip(I))
					return
				user << "<span class='notice'>You click [S] into place on [src].</span>"
				if(S.on)
					SetLuminosity(0)
				gun_light = S
				I.loc = src
				update_icon()
				update_gunlight(user)
				verbs += /obj/item/weapon/gun/proc/toggle_gunlight
				var/datum/action/A = new /datum/action/item_action/toggle_gunlight(src)
				if(loc == user)
					A.Grant(user)

		if(istype(I, /obj/item/weapon/screwdriver))
			if(gun_light)
				for(var/obj/item/device/flashlight/seclite/S in src)
					user << "<span class='notice'>You unscrew the seclite from [src].</span>"
					gun_light = null
					S.forceMove(get_turf(user))
					update_gunlight(user)
					S.update_brightness(user)
					update_icon()
					verbs -= /obj/item/weapon/gun/proc/toggle_gunlight
				for(var/datum/action/item_action/toggle_gunlight/TGL in actions)
					qdel(TGL)
	else
		..()

/obj/item/weapon/gun/pickup(mob/user)
	..()
	if(gun_light)
		if(gun_light.on)
			user.AddLuminosity(gun_light.brightness_on)
			SetLuminosity(0)
	if(azoom)
		azoom.Grant(user)

/obj/item/weapon/gun/dropped(mob/user)
	..()
	if(gun_light)
		if(gun_light.on)
			user.AddLuminosity(-gun_light.brightness_on)
			SetLuminosity(gun_light.brightness_on)
	zoom(user,FALSE)
	if(azoom)
		azoom.Remove(user)


/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/cell_type = /obj/item/weapon/stock_parts/cell
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = 1 //Can it be charged in a recharger?
	var/charge_sections = 4
	ammo_x_offset = 2
	var/shaded_charge = 0 //if this gun uses a stateful charge bar for more detail
	var/selfcharge = 0
	var/charge_tick = 0
	var/charge_delay = 4
	var/use_cyborg_cell = 0 //whether the gun's cell drains the cyborg user's cell to recharge

/obj/item/weapon/gun/energy/emp_act(severity)
	power_supply.use(round(power_supply.charge / severity))
	chambered = null //we empty the chamber
	recharge_newshot() //and try to charge a new shot
	update_icon()


/obj/item/weapon/gun/energy/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	update_ammo_types()
	recharge_newshot(1)
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/weapon/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for (var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/weapon/gun/energy/Destroy()
	if(power_supply)
		qdel(power_supply)
		power_supply = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/process()
	if(selfcharge)
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!power_supply)
			return
		power_supply.give(100)
		if(!chambered) //if empty chamber we try to charge a new shot
			recharge_newshot(1)
		update_icon()

/obj/item/weapon/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()

/obj/item/weapon/gun/energy/can_shoot()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return power_supply.charge >= shot.e_cost

/obj/item/weapon/gun/energy/recharge_newshot(no_cyborg_drain)
	if (!ammo_type || !power_supply)
		return
	if(use_cyborg_cell && !no_cyborg_drain)
		if(iscyborg(loc))
			var/mob/living/silicon/robot/R = loc
			if(R.cell)
				var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
				if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
					power_supply.give(shot.e_cost)	//... to recharge the shot
	if(!chambered)
		var/obj/item/ammo_casing/energy/AC = ammo_type[select]
		if(power_supply.charge >= AC.e_cost) //if there's enough power in the power_supply cell...
			chambered = AC //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/weapon/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		power_supply.use(shot.e_cost)//... drain the power_supply cell
	chambered = null //either way, released the prepared shot
	recharge_newshot() //try to charge a new shot

/obj/item/weapon/gun/energy/proc/select_fire(mob/living/user)
	select++
	if (select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		user << "<span class='notice'>[src] is now set to [shot.select_name].</span>"
	chambered = null
	recharge_newshot(1)
	update_icon()
	return

/obj/item/weapon/gun/energy/update_icon()
	cut_overlays()
	var/ratio = Ceiling((power_supply.charge / power_supply.maxcharge) * charge_sections)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if (modifystate)
		add_overlay("[icon_state]_[shot.select_name]")
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(power_supply.charge < shot.e_cost)
		add_overlay("[icon_state]_empty")
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				add_overlay(image(icon = icon, icon_state = iconState, pixel_x = ammo_x_offset * (i -1)))
		else
			add_overlay(image(icon = icon, icon_state = "[icon_state]_charge[ratio]"))
	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		add_overlay(image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset))
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/weapon/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/weapon/gun/energy/suicide_act(mob/user)
	if (src.can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			power_supply.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brains out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return (OXYLOSS)


/obj/item/weapon/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("selfcharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 0
	anchored = 1
	flags = ABSTRACT
	pass_flags = PASSTABLE
	mouse_opacity = 0
	hitsound = 'sound/weapons/pierce.ogg'
	var/hitsound_wall = ""

	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/suppressed = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again
	var/paused = FALSE //for suspending the projectile midair
	var/p_x = 16
	var/p_y = 16			// the pixel location of the tile that the player clicked. Default is the center
	var/speed = 0.8			//Amount of deciseconds it takes for projectile to travel
	var/Angle = 0
	var/spread = 0			//amount (in degrees) of projectile spread
	var/legacy = 0			//legacy projectile system
	animate_movement = 0	//Use SLIDE_STEPS in conjunction with legacy

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
	var/projectile_type = /obj/item/projectile
	var/range = 50 //This will de-increment every step. When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
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

/obj/item/projectile/Process_Spacemove(var/movement_dir = 0)
	return 1 //Bullets don't drift in space

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


/obj/item/projectile/proc/preparePixelProjectile(atom/target, var/turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	src.loc = get_turf(user)
	src.starting = get_turf(user)
	src.current = curloc
	src.yo = targloc.y - curloc.y
	src.xo = targloc.x - curloc.x

	if(params)
		var/list/mouse_control = params2list(params)
		if(mouse_control["icon-x"])
			src.p_x = text2num(mouse_control["icon-x"])
		if(mouse_control["icon-y"])
			src.p_y = text2num(mouse_control["icon-y"])
		if(mouse_control["screen-loc"])
			//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
			var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")

			//Split X+Pixel_X up into list(X, Pixel_X)
			var/list/screen_loc_X = splittext(screen_loc_params[1],":")

			//Split Y+Pixel_Y up into list(Y, Pixel_Y)
			var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
			// world << "X: [screen_loc_X[1]] PixelX: [screen_loc_X[2]] / Y: [screen_loc_Y[1]] PixelY: [screen_loc_Y[2]]"
			var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
			var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32

			//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
			var/screenview = (user.client.view * 2 + 1) * world.icon_size //Refer to http://www.byond.com/docs/ref/info.html#/client/var/view for mad maths

			var/ox = round(screenview/2) //"origin" x
			var/oy = round(screenview/2) //"origin" y
			// world << "Pixel position: [x] [y]"
			var/angle = Atan2(y - oy, x - ox)
			// world << "Angle: [angle]"
			src.Angle = angle
	if(spread)
		src.Angle += spread


/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	..()
	if(isliving(AM) && AM.density && !checkpass(PASSMOB))
		Bump(AM, 1)

/obj/item/projectile/Destroy()
	return ..()

/obj/item/projectile/experience_pressure_difference()
	return
/obj/item/ammo_casing
	name = "bullet casing"
	desc = "A bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/fire_sound = null						//What sound should play when this ammo is fired
	var/caliber = null							//Which kind of guns it can be loaded into
	var/projectile_type = null					//The bullet type to create when New() is called
	var/obj/item/projectile/BB = null 			//The loaded bullet
	var/pellets = 1								//Pellets for spreadshot
	var/variance = 0							//Variance for inaccuracy fundamental to the casing
	var/randomspread = 0						//Randomspread for automatics
	var/delay = 0								//Delay for energy weapons
	var/click_cooldown_override = 0				//Override this to make your gun have a faster fire rate, in tenths of a second. 4 is the default gun cooldown.
	var/firing_effect_type = /obj/effect/overlay/temp/dir_setting/firing_effect	//the visual effect appearing when the ammo is fired.


/obj/item/ammo_casing/New()
	..()
	if(projectile_type)
		BB = new projectile_type(src)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	setDir(pick(alldirs))
	update_icon()

/obj/item/ammo_casing/update_icon()
	..()
	icon_state = "[initial(icon_state)][BB ? "-live" : ""]"
	desc = "[initial(desc)][BB ? "" : " This one is spent"]"

//proc to magically refill a casing with a new projectile
/obj/item/ammo_casing/proc/newshot() //For energy weapons, syringe gun, shotgun shells and wands (!).
	if(!BB)
		BB = new projectile_type(src)

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		if(isturf(loc))
			var/boolets = 0
			for(var/obj/item/ammo_casing/bullet in loc)
				if (box.stored_ammo.len >= box.max_ammo)
					break
				if (bullet.BB)
					if (box.give_round(bullet, 0))
						boolets++
				else
					continue
			if (boolets > 0)
				box.update_icon()
				user << "<span class='notice'>You collect [boolets] shell\s. [box] now contains [box.stored_ammo.len] shell\s.</span>"
			else
				user << "<span class='warning'>You fail to collect anything!</span>"
	else
		return ..()
