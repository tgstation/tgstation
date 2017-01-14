
//So how this is planned to work is it is an item that allows you to fly with some interesting movement mechanics.
//You will still move instantly like usual, but when you move in a direction you gain "momentum" towards that direction
//Momentum will have a maximum value that it will be capped to, and will go down over time
//There is toggleable "stabilizers" that will make momentum go down FAST instead of its normal slow rate
//The suit is heavy and will slow you down on the ground but is a bit faster then usual in air
//The speed at which you drift is determined by your current momentum
//Also, I should probably add in some kind of limiting mechanic but I really don't like having to refill this all the time, expecially as it will be NODROP.
//Apparently due to code limitations you have to detect mob movement with.. shoes.
//The object that handles the flying itself - FLIGHT PACK --------------------------------------------------------------------------------------
/obj/item/device/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual ion engines powerful enough to grant a humanoid flight. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	icon_state = "flightpack_off"
	item_state = "flightpack_off"
	var/icon_state_active = "flightpack_on"
	var/item_state_active = "flightpack_on"
	var/icon_state_boost = "flightpack_boost"
	var/item_state_boost = "flightpack_boost"
	actions_types = list(/datum/action/item_action/flightpack/toggle_flight, /datum/action/item_action/flightpack/engage_boosters, /datum/action/item_action/flightpack/toggle_stabilizers, /datum/action/item_action/flightpack/change_power, /datum/action/item_action/flightpack/toggle_airbrake)
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 100, acid = 100)

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/mob/living/carbon/human/wearer = null
	var/slowdown_ground = 1
	var/slowdown_air = 0
	var/slowdown_brake = TRUE
	var/flight = FALSE
	var/flight_passflags = PASSTABLE
	var/powersetting = 1
	var/powersetting_high = 3
	var/powersetting_low = 1
	var/override_safe = FALSE

	var/boost = FALSE
	var/boost_maxcharge = 30	//Vroom! If you hit someone while boosting they'll likely be knocked flying. Fun.
	var/boost_charge = 30
	var/boost_speed = 2
	var/boost_power = 50
	var/boost_chargerate = 0.3
	var/boost_drain = 6	//Keep in mind it charges and drains at the same time, so drain realistically is drain-charge=change

	var/momentum_x = 0		//Realistic physics. No more "Instant stopping while barreling down a hallway at Mach 1".
	var/momentum_y = 0
	var/momentum_max = 500
	var/momentum_impact_coeff = 0.5	//At this speed you'll start coliding with people resulting in momentum loss and them being knocked back, but no injuries or knockdowns
	var/momentum_impact_loss = 50
	var/momentum_crash_coeff = 0.8	//At this speed if you hit a dense object, you will careen out of control, while that object will be knocked flying.
	var/momentum_drift_coeff = 0.04
	var/momentum_speed = 0	//How fast we are drifting around
	var/momentum_speed_x = 0
	var/momentum_speed_y = 0
	var/momentum_passive_loss = 4
	var/momentum_gain = 20
	var/drift_tolerance = 2

	var/stabilizer = TRUE
	var/stabilizer_decay_amount = 11
	var/gravity = TRUE
	var/gravity_decay_amount = 3
	var/pressure = TRUE
	var/pressure_decay_amount = 3
	var/pressure_threshold = 30
	var/brake = FALSE
	var/airbrake_decay_amount = 30

	var/resync = FALSE	//Used to resync the flight-suit every 30 seconds or so.

	var/disabled = FALSE	//Whether it is disabled from crashes/emps/whatever
	var/crash_disable_message = FALSE	//To not spam the user with messages
	var/emp_disable_message = FALSE

	//This is probably too much code just for EMP damage.
	var/emp_damage = 0	//One hit should make it hard to control, continuous hits will cripple it and then simply shut it off/make it crash. Direct hits count more.
	var/emp_strong_damage = 1.5
	var/emp_weak_damage = 1
	var/emp_heal_amount = 0.06		//How much emp damage to heal per process.
	var/emp_disable_threshold = 3	//3 weak ion, 2 strong ion hits.
	var/emp_disabled = FALSE

	var/crash_damage = 0	//Same thing, but for crashes. This is in addition to possible amounts of brute damage to the wearer.
	var/crash_damage_low = 1
	var/crash_damage_high = 2.5
	var/crash_disable_threshold = 5
	var/crash_heal_amount = 0.06
	var/crash_disabled = FALSE
	var/crash_dampening = 0

	var/datum/effect_system/trail_follow/ion/flight/ion_trail

	var/assembled = FALSE
	var/obj/item/weapon/stock_parts/manipulator/part_manip = null
	var/obj/item/weapon/stock_parts/scanning_module/part_scan = null
	var/obj/item/weapon/stock_parts/capacitor/part_cap = null
	var/obj/item/weapon/stock_parts/micro_laser/part_laser = null
	var/obj/item/weapon/stock_parts/matter_bin/part_bin = null

	var/crashing = FALSE	//Are we currently getting wrecked?


//Start/Stop processing the item to use momentum and flight mechanics.
/obj/item/device/flightpack/New()
	ion_trail = new
	ion_trail.set_up(src)
	START_PROCESSING(SSflightpacks, src)
	..()
	update_parts()

/obj/item/device/flightpack/full/New()
	part_manip = new /obj/item/weapon/stock_parts/manipulator/pico(src)
	part_scan = new /obj/item/weapon/stock_parts/scanning_module/phasic(src)
	part_cap = new /obj/item/weapon/stock_parts/capacitor/super(src)
	part_laser = new /obj/item/weapon/stock_parts/micro_laser/ultra(src)
	part_bin = new /obj/item/weapon/stock_parts/matter_bin/super(src)
	assembled = TRUE
	..()

/obj/item/device/flightpack/proc/update_parts()
	boost_chargerate = initial(boost_chargerate)
	boost_drain = initial(boost_drain)
	powersetting_high = initial(powersetting_high)
	emp_disable_threshold = initial(emp_disable_threshold)
	crash_disable_threshold = initial(crash_disable_threshold)
	stabilizer_decay_amount = initial(stabilizer_decay_amount)
	airbrake_decay_amount = initial(airbrake_decay_amount)
	var/manip = 0	//Efficiency
	var/scan = 0	//Damage avoidance/other
	var/cap = 0		//Charging
	var/laser = 0	//Power
	var/bin = 0		//Stability
	assembled = FALSE	//Ready?
	if(part_manip && part_scan && part_cap && part_laser && part_bin)
		manip = part_manip.rating
		scan = part_scan.rating
		cap = part_cap.rating
		laser = part_laser.rating
		bin = part_bin.rating
		assembled = TRUE
	boost_chargerate *= cap
	boost_drain -= manip
	powersetting_high = Clamp(laser, 0, 3)
	emp_disable_threshold = bin*1.25
	crash_disable_threshold = bin*2
	stabilizer_decay_amount = scan*3.5
	airbrake_decay_amount = manip*8
	crash_dampening = bin

/obj/item/device/flightpack/Destroy()
	if(suit)
		delink_suit()
	qdel(part_manip)
	qdel(part_scan)
	qdel(part_cap)
	qdel(part_laser)
	qdel(part_bin)
	STOP_PROCESSING(SSflightpacks, src)
	part_manip = null
	part_scan = null
	part_cap = null
	part_laser = null
	part_bin = null
	..()

/obj/item/device/flightpack/emp_act(severity)
	var/damage = 0
	if(severity == 1)
		damage = emp_strong_damage
	else
		damage = emp_weak_damage
	if(emp_damage <= (emp_disable_threshold * 1.5))
		emp_damage += damage
	wearer << "<span class='userdanger'>Flightpack: BZZZZZZZZZZZT</span>"
	wearer << "<span class='warning'>Flightpack: WARNING: Class [severity] EMP detected! Circuit damage at [(100/emp_disable_threshold)*emp_damage]!</span>"

//action BUTTON CODE
/obj/item/device/flightpack/ui_action_click(owner, action)
	if(wearer != owner)
		wearer = owner
	if(!suit)
		usermessage("The flightpack will not work without being attached to a suit first!")
		return FALSE
	if(istype(action, /datum/action/item_action/flightpack/toggle_flight))
		if(!flight)
			enable_flight()
		else
			disable_flight()
	if(istype(action, /datum/action/item_action/flightpack/engage_boosters))
		if(!boost)
			activate_booster()
		else
			deactivate_booster()
	if(istype(action, /datum/action/item_action/flightpack/toggle_stabilizers))
		if(!stabilizer)
			enable_stabilizers()
		else
			disable_stabilizers()
	if(istype(action, /datum/action/item_action/flightpack/change_power))
		cycle_power()
	if(istype(action, /datum/action/item_action/flightpack/toggle_airbrake))
		if(!brake)
			enable_airbrake()
		else
			disable_airbrake()

//Proc to change amount of momentum the wearer has, or dampen all momentum by a certain amount.
/obj/item/device/flightpack/proc/adjust_momentum(amountx, amounty, reduce_amount_total = 0)
	if(reduce_amount_total != 0)
		if(momentum_x > 0)
			momentum_x = Clamp(momentum_x - reduce_amount_total, 0, momentum_max)
		else if(momentum_x < 0)
			momentum_x = Clamp(momentum_x + reduce_amount_total, -momentum_max, 0)
		if(momentum_y > 0)
			momentum_y = Clamp(momentum_y - reduce_amount_total, 0, momentum_max)
		else if(momentum_y < 0)
			momentum_y = Clamp(momentum_y + reduce_amount_total, -momentum_max, 0)
	momentum_x = Clamp(momentum_x + amountx, -momentum_max, momentum_max)
	momentum_y = Clamp(momentum_y + amounty, -momentum_max, momentum_max)
	calculate_momentum_speed()

//Called by the pair of shoes the wearer is required to wear to detect movement.
/obj/item/device/flightpack/proc/wearer_movement(dir)
	if(!flight)
		return
	var/momentum_increment = momentum_gain
	if(boost)
		momentum_increment = boost_power
	if(brake)
		momentum_increment = 0
	if(!gravity && !pressure)
		momentum_increment -= 10
	switch(dir)
		if(NORTH)
			adjust_momentum(0, momentum_increment)
		if(SOUTH)
			adjust_momentum(0, -momentum_increment)
		if(EAST)
			adjust_momentum(momentum_increment, 0)
		if(WEST)
			adjust_momentum(-momentum_increment, 0)

//The wearer has momentum left. Move them and take some away, while negating the momentum that moving the wearer would gain. Or force the wearer to lose control if they are incapacitated.
/obj/item/device/flightpack/proc/momentum_drift()
	if(!flight)
		return FALSE
	var/drift_dir_x = 0
	var/drift_dir_y = 0
	if(momentum_x > 0)
		drift_dir_x = EAST
	if(momentum_x < 0)
		drift_dir_x = WEST
	if(momentum_y > 0)
		drift_dir_y = NORTH
	if(momentum_y < 0)
		drift_dir_y = SOUTH
	if(momentum_speed == 0)
		return FALSE
	if(suit)
		if(wearer)
			if(!wearer.canmove)
				losecontrol()
			momentum_decay()
			for(var/i in 1 to momentum_speed)
				if(momentum_speed_x >= i)
					step(wearer, drift_dir_x)
				if(momentum_speed_y >= i)
					step(wearer, drift_dir_y)
				sleep(1)

//Make the wearer lose some momentum.
/obj/item/device/flightpack/proc/momentum_decay()
	if(brake)
		adjust_momentum(0, 0, airbrake_decay_amount)
	if(gravity)
		adjust_momentum(0, 0, gravity_decay_amount)
	if(stabilizer)
		adjust_momentum(0, 0, stabilizer_decay_amount)
	if(pressure)
		adjust_momentum(0, 0, pressure_decay_amount)
	adjust_momentum(0, 0, momentum_passive_loss)

//Check for gravity, air pressure, and whether this is still linked to a suit. Also, resync the flightpack/flight suit every minute.
/obj/item/device/flightpack/proc/check_conditions()
	if(suit)
		if(wearer)
			if(wearer.has_gravity())
				gravity = 1
			else
				gravity = 0
			var/turf/T = get_turf(wearer)
			var/datum/gas_mixture/gas = T.return_air()
			var/envpressure =	gas.return_pressure()
			if(envpressure >= pressure_threshold)
				pressure = 1
			else
				pressure = 0
	if(flight)
		if(!assembled)
			disable_flight(1)
		if(!suit)
			disable_flight(1)
		if(!resync)
			addtimer(CALLBACK(src, .proc/resync), 600)
			resync = 1
		if(!wearer)	//Oh god our user fell off!
			disable_flight(1)
	if(!pressure && brake)
		brake = FALSE
		usermessage("Airbrakes deactivated due to lack of pressure!", 2)
	if(!suit.deployedshoes)
		if(brake || stabilizer)
			brake = FALSE
			stabilizer = FALSE
			usermessage("Warning: Sensor data is not being recieved from flight shoes. Stabilizers and airbrake modules OFFLINE!", 2)

//Resync the suit
/obj/item/device/flightpack/proc/resync()
	resync = FALSE
	suit.resync()

//How fast should the wearer be?
/obj/item/device/flightpack/proc/update_slowdown()
	if(!flight)
		suit.slowdown = slowdown_ground
		return
	else
		suit.slowdown = slowdown_air

/obj/item/device/flightpack/process()
	if(!suit)
		return FALSE
	update_slowdown()
	update_icon()
	check_conditions()
	calculate_momentum_speed()
	momentum_drift()
	handle_boost()
	handle_damage()
	handle_flight()

/obj/item/device/flightpack/proc/handle_flight()
	if(!flight)
		return FALSE
	if(wearer)
		wearer.float(TRUE)

/obj/item/device/flightpack/proc/handle_damage()
	if(crash_damage)
		crash_damage = Clamp(crash_damage-crash_heal_amount, 0, crash_disable_threshold*10)
		if(crash_damage >= crash_disable_threshold)
			crash_disabled = TRUE
		if(crash_disabled && (crash_damage <= 1))
			crash_disabled = FALSE
			crash_disable_message = FALSE
			usermessage("Gyroscopic sensors recalibrated. Flight systems re-enabled.")
	if(emp_damage)
		emp_damage = Clamp(emp_damage-emp_heal_amount, 0, emp_disable_threshold * 10)
		if(emp_damage >= emp_disable_threshold)
			emp_disabled = TRUE
		if(emp_disabled && (emp_damage <= 0.5))
			emp_disabled = FALSE
			emp_disable_message = FALSE
			usermessage("Electromagnetic deflection system re-activated. Flight systems re-enabled.")
	disabled = crash_disabled + emp_disabled
	if(disabled)
		if(crash_disabled && (!crash_disable_message))
			usermessage("Internal gyroscopes scrambled from excessive impacts.", 2)
			usermessage("Deactivating to recalibrate flight systems!", 2)
			crash_disable_message = TRUE
		if(emp_disabled && (!emp_disable_message))
			usermessage("Electromagnetic deflectors overloaded. Short circuit detected in internal systems!", 1)
			usermessage("Deactivating to prevent fatal power overload!", 2)
			emp_disable_message = TRUE
		if(flight)
			disable_flight(TRUE)

/obj/item/device/flightpack/update_icon()
	if(!flight)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	if(flight)
		icon_state = icon_state_active
		item_state = item_state_active
		if(boost)
			icon_state = icon_state_boost
			item_state = item_state_boost
	if(wearer)
		wearer.update_inv_wear_suit()
		wearer.update_inv_back()
	..()

/obj/item/device/flightpack/proc/handle_boost()
	if(boost)
		boost_charge = Clamp(boost_charge-boost_drain, 0, boost_maxcharge)
		if(boost_charge < 1)
			deactivate_booster()
	if(boost_charge < boost_maxcharge)
		boost_charge = Clamp(boost_charge+boost_chargerate, 0, boost_maxcharge)


/obj/item/device/flightpack/proc/cycle_power()
	if(powersetting < powersetting_high)
		powersetting++
	else
		powersetting = 1
	momentum_gain = powersetting * 10
	usermessage("Engine output set to [momentum_gain].")
	momentum_drift_coeff = ((momentum_gain)*(drift_tolerance*1.1))/momentum_max

/obj/item/device/flightpack/proc/crash_damage(density, anchored, speed, victim_name)
	var/crashmessagesrc = "<span class='userdanger'>[wearer] violently crashes into [victim_name], "
	var/userdamage = 10
	userdamage -= stabilizer*3
	userdamage -= part_bin.rating
	userdamage -= part_scan.rating
	userdamage -= part_manip.rating
	userdamage += anchored*2
	userdamage += boost*2
	userdamage += speed*2
	if(userdamage < 0)
		userdamage = 0
	if(userdamage)
		crashmessagesrc += "that really must have hurt!"
	else
		crashmessagesrc += "but luckily [wearer]'s impact was absorbed by their suit's stabilizers!</span>"
	wearer.adjustBruteLoss(userdamage)
	usermessage("WARNING: Stabilizers taking damage!", 2)
	wearer.visible_message(crashmessagesrc)
	crash_damage = Clamp(crash_damage + crash_damage_high, 0, crash_disable_threshold*1.5)

/obj/item/device/flightpack/proc/userknockback(density, anchored, speed, dir)
	var/angle = dir2angle(dir)
	angle += 180
	if(angle > 360)
		angle -= 360
	dir = angle2dir(angle)
	var/turf/target = get_edge_target_turf(get_turf(wearer), dir)
	wearer.throw_at(target, (speed+density+anchored), 2, wearer)
	wearer.visible_message("[wearer] is knocked flying by the impact!")

/obj/item/device/flightpack/proc/flight_impact(atom/unmovablevictim, crashdir)	//Yes, victim.
	if((unmovablevictim == wearer) || crashing)
		return FALSE
	crashing = TRUE
	var/crashpower = 0
	if(crashdir == NORTH || crashdir == SOUTH)
		crashpower = momentum_speed_y
	else if(crashdir == EAST || crashdir == WEST)
		crashpower = momentum_speed_x
	if(!flight)
		crashing = FALSE
		return FALSE
	if(boost)
		crashpower = 3
	if(!crashpower)
		crashing = FALSE
		return FALSE
	//crashdirs..
	var/density = FALSE
	var/anchored = TRUE	//Just in case...
	var/damage = FALSE
	if(ismob(unmovablevictim))
		var/mob/living/L = unmovablevictim
		if(L.throwing || (L.pulledby == wearer))
			crashing = FALSE
			return FALSE
		if(L.buckled)
			wearer.visible_message("<span class='warning'>[wearer] reflexively flies over [L]!</span>")
			crashing = FALSE
			return FALSE
		suit.user.forceMove(get_turf(unmovablevictim))
		crashing = FALSE
		mobknockback(L, crashpower, crashdir)
		damage = FALSE
		density = TRUE
		anchored = FALSE
	else if(istype(unmovablevictim, /obj/structure/grille))
		if(crashpower > 1)
			var/obj/structure/grille/S = unmovablevictim
			crash_grille(S)
		crashing = FALSE
		return FALSE
	else if((istype(unmovablevictim, /obj/machinery/door)) && (!istype(unmovablevictim, /obj/machinery/door/poddoor)))
		var/obj/machinery/door/D = unmovablevictim
		if(!airlock_hit(D))
			crashing = FALSE
			return FALSE
		else if(momentum_speed < 3)
			crashing = FALSE
			return FALSE
		damage = TRUE
		anchored = TRUE
		density = FALSE
	else if(istype(unmovablevictim, /obj/structure/mineral_door))
		var/obj/structure/mineral_door/D = unmovablevictim
		door_hit(D)
		crashing = FALSE
		return FALSE
	else if(isclosedturf(unmovablevictim))
		if(crashpower < 3)
			crashing = FALSE
			return FALSE
		damage = TRUE
		density = TRUE
		anchored = TRUE
	else if(ismovableatom(unmovablevictim))
		var/atom/movable/victim = unmovablevictim
		if(crashpower < 3 || victim.throwing)
			crashing = FALSE
			return FALSE
		density = victim.density
		anchored = victim.anchored
		victimknockback(victim, crashpower, crashdir)
		if(anchored)
			damage = TRUE
	if(damage)
		crash_damage(density, anchored, momentum_speed, unmovablevictim.name)
		userknockback(density, anchored, momentum_speed, dir)
		losecontrol(stun = FALSE, move = FALSE)
	crashing = FALSE

/obj/item/device/flightpack/proc/door_hit(obj/structure/mineral_door/door)
	spawn()
		door.Open()
	wearer.forceMove(get_turf(door))
	wearer.visible_message("<span class='boldnotice'>[wearer] rolls to their sides and slips past [door]!</span>")


/obj/item/device/flightpack/proc/crash_grille(obj/structure/grille/target)
	target.hitby(wearer)
	target.take_damage(60, BRUTE, "melee", 1)
	if(wearer.Move(target.loc))
		wearer.visible_message("<span class='warning'>[wearer] smashes straight past [target]!</span>")

/obj/item/device/flightpack/proc/airlock_hit(obj/machinery/door/A)
	var/pass = 0
	if(A.density)	//Is it closed?
		pass += A.locked
		pass += A.stat	//No power, no automatic open
		pass += A.emagged
		pass += A.welded
		if(A.requiresID())
			if((!A.allowed(wearer)) && !A.emergency)
				pass += 1
	else
		return pass
	if(!pass)
		spawn()
			A.open()
		wearer.visible_message("<span class='warning'>[wearer] rolls sideways and slips past [A]</span>")
		wearer.forceMove(get_turf(A))
	return pass


/obj/item/device/flightpack/proc/mobknockback(mob/living/victim, power, direction)
	if(!ismob(victim))
		return FALSE
	var/knockmessage = "<span class='warning'>[victim] is knocked back by [wearer] as they narrowly avoid a collision!"
	if(power == 1)
		knockmessage = "<span class='warning'>[wearer] soars into [victim], pushing them away!"
	var/knockback = 0
	var/stun = boost * 2 + (power - 2)
	if((stun >= 0) || (power == 3))
		knockmessage += " [wearer] dashes across [victim] at full impulse, knocking them [stun ? "down" : "away"]!"	//Impulse...
	knockmessage += "</span>"
	knockback += power
	knockback += (part_manip.rating / 2)
	knockback += (part_bin.rating / 2)
	knockback += boost*2
	switch(power)
		if(1)
			knockback = 1
		if(2)
			knockback /= 1.5
	var/throwdir = pick(alldirs)
	var/turf/target = get_step(victim, throwdir)
	for(var/i in 1 to (knockback-1))
		target = get_step(target, throwdir)
	wearer.visible_message(knockmessage)
	victim.throw_at(target, knockback, 1)
	victim.Weaken(stun)

/obj/item/device/flightpack/proc/victimknockback(atom/movable/victim, power, direction)
	if(!victim)
		return FALSE
	var/knockback = 0
	var/damage = 0
	knockback -= (density * 2)
	knockback += power
	knockback += (part_manip.rating / 2)
	knockback += (part_bin.rating / 2)
	knockback *= 4
	if(victim.anchored)
		knockback = 0
	damage = power*14	//I mean, if you REALLY want to break your skull to break an airlock...
	if(ismob(victim))	//Why the hell didn't it proc the mob one instead?
		mobknockback(victim, power, direction)
		return FALSE
	if(anchored)
		knockback = 0
	victim.visible_message("<span class='warning'>[victim.name] is sent flying by the impact!</span>")
	var/turf/target = get_turf(victim)
	for(var/i in 1 to knockback)
		target = get_step(target, direction)
	for(var/i in 1 to knockback/3)
		target = get_step(target, pick(alldirs))
	if(knockback)
		victim.throw_at(target, knockback, part_manip.rating)
	if(isobj(victim))
		var/obj/O = victim
		O.take_damage(damage)

/obj/item/device/flightpack/proc/losecontrol(stun = FALSE, move = TRUE)
	if(!move)
		momentum_x = 0
		momentum_y = 0
		calculate_momentum_speed()
	usermessage("Warning: Control system not responding. Deactivating!", 3)
	wearer.visible_message("<span class='warning'>[wearer]'s flight suit abruptly shuts off and they lose control!</span>")
	if(wearer)
		if(move)
			while(momentum_x != 0 || momentum_y != 0)
				sleep(2)
				step(wearer, pick(cardinal))
				momentum_decay()
				adjust_momentum(0, 0, 10)
		wearer.visible_message("<span class='warning'>[wearer]'s flight suit crashes into the ground!</span>")
		if(stun)
			wearer.Weaken(4)
	momentum_x = 0
	momentum_y = 0
	if(flight)
		disable_flight(FALSE)

/obj/item/device/flightpack/proc/enable_flight(forced = FALSE)
	if(!suit)
		usermessage("Warning: Flightpack not linked to compatible flight-suit mount!", 2)
	if(disabled)
		usermessage("Internal systems recalibrating. Unable to safely proceed.", 2)
	wearer.movement_type |= FLYING
	wearer.pass_flags |= flight_passflags
	usermessage("ENGAGING FLIGHT ENGINES.")
	wearer.visible_message("<font color='blue' size='2'>[wearer]'s flight engines activate as they lift into the air!</font>")
	//I DONT HAVE SOUND EFFECTS YET playsound(
	flight = TRUE
	if(suit.shoes)
		suit.shoes.toggle(TRUE)
	update_icon()
	ion_trail.start()

/obj/item/device/flightpack/proc/disable_flight(forced = FALSE)
	if(forced)
		losecontrol(stun = TRUE)
		return TRUE
	if(momentum_speed <= 1)
		momentum_x = 0
		momentum_y = 0
		usermessage("DISENGAGING FLIGHT ENGINES.")
		wearer.visible_message("<font color='blue' size='2'>[wearer] drops to the ground as their flight engines cut out!</font>")
		//NO SOUND YET	playsound(
		ion_trail.stop()
		wearer.movement_type &= ~FLYING
		wearer.pass_flags &= ~flight_passflags
		flight = FALSE
		if(suit.shoes)
			suit.shoes.toggle(FALSE)
	else
		if(override_safe)
			disable_flight(TRUE)
			return TRUE
		usermessage("Warning: Velocity too high to safely disengage. Retry to confirm emergency shutoff.", 2)
		override_safe = TRUE
		addtimer(CALLBACK(src, .proc/enable_safe), 50)
		return FALSE
	update_icon()

/obj/item/device/flightpack/proc/enable_safe()
	if(override_safe)
		override_safe = FALSE

/obj/item/device/flightpack/dropped(mob/wearer)
	..()

/obj/item/device/flightpack/item_action_slot_check(slot)
	if(slot == SLOT_BACK)
		return TRUE

/obj/item/device/flightpack/equipped(mob/user, slot)
	if(ishuman(user))
		wearer = user
	..()

/obj/item/device/flightpack/proc/calculate_momentum_speed()
	if(abs(momentum_x) >= (momentum_crash_coeff*momentum_max))	//Calculate X
		momentum_speed_x = 3
	else if(abs(momentum_x) >= (momentum_impact_coeff*momentum_max))
		momentum_speed_x = 2
	else if(abs(momentum_x) >= (momentum_drift_coeff*momentum_max))
		momentum_speed_x = 1
	else
		momentum_speed_x = 0
	if(abs(momentum_y) >= (momentum_crash_coeff*momentum_max))	//Calculate Y
		momentum_speed_y = 3
	else if(abs(momentum_y) >= (momentum_impact_coeff*momentum_max))
		momentum_speed_y = 2
	else if(abs(momentum_y) >= (momentum_drift_coeff*momentum_max))
		momentum_speed_y = 1
	else
		momentum_speed_y = 0
	momentum_speed = max(momentum_speed_x, momentum_speed_y)

/obj/item/device/flightpack/item_action_slot_check(slot)
	if(slot == slot_back)
		return TRUE

/obj/item/device/flightpack/proc/enable_stabilizers()
	usermessage("Activating automatic stabilization controller and enabling maneuvering assistance.")
	stabilizer = TRUE

/obj/item/device/flightpack/proc/disable_stabilizers()
	if(wearer)
		if(brake)
			disable_airbrake()
		usermessage("Deactivating stabilization controllers!", 2)
	stabilizer = FALSE

/obj/item/device/flightpack/proc/activate_booster()
	if(!flight)
		usermessage("Error: Engines offline!", 2)
		return FALSE
	if(boost_charge < 5)
		usermessage("Insufficient charge in boost capacitors to engage.", 2)
		return FALSE
	usermessage("Boosters engaged!")
	wearer.visible_message("<span class='notice'>[wearer.name]'s flightpack engines flare in intensity as they are rocketed forward by the immense thrust!</span>")
	boost = TRUE
	update_slowdown()

/obj/item/device/flightpack/proc/deactivate_booster()
	usermessage("Boosters disengaged!")
	boost = FALSE
	update_slowdown()

/obj/item/device/flightpack/proc/enable_airbrake()
	if(wearer)
		if(!stabilizer)
			enable_stabilizers()
			usermessage("Stabilizers activated!")
		usermessage("Airbrakes extended!")
	brake = TRUE
	update_slowdown()

/obj/item/device/flightpack/proc/disable_airbrake()
	if(wearer)
		usermessage("Airbrakes retracted!")
	brake = FALSE
	update_slowdown()

/obj/item/device/flightpack/on_mob_move(dir, mob)
	wearer_movement(dir)

/obj/item/device/flightpack/proc/relink_suit(obj/item/clothing/suit/space/hardsuit/flightsuit/F)
	if(suit && suit == F)
		return FALSE
	else
		delink_suit()
	if(istype(F))
		suit = F
		suit.pack = src
	else
		suit = null

/obj/item/device/flightpack/proc/delink_suit()
	if(suit)
		if(suit.pack && suit.pack == src)
			suit.pack = null
	suit = null

/obj/item/device/flightpack/proc/usermessage(message, urgency = 0)
	if(urgency == 0)
		wearer << "\icon[src]|<span class='boldnotice'>[message]</span>"
	if(urgency == 1)
		wearer << "\icon[src]|<span class='warning'>[message]</span>"
	if(urgency == 2)
		wearer << "\icon[src]|<span class='boldwarning'>[message]</span>"
	if(urgency == 3)
		wearer << "\icon[src]|<span class='userdanger'>[message]</span>"

/obj/item/device/flightpack/attackby(obj/item/I, mob/user, params)
	if(ishuman(user) && !ishuman(src.loc))
		wearer = user
	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/S = I
		if(istype(S, /obj/item/weapon/stock_parts/manipulator))
			usermessage("[I] has been sucessfully installed into systems.")
			if(user.unEquip(I))
				if(part_manip)
					part_manip.forceMove(get_turf(src))
					part_manip = null
				I.loc = src
				part_manip = I
		if(istype(S, /obj/item/weapon/stock_parts/scanning_module))
			usermessage("[I] has been sucessfully installed into systems.")
			if(user.unEquip(I))
				if(part_scan)
					part_scan.forceMove(get_turf(src))
					part_scan = null
				I.loc = src
				part_scan = I
		if(istype(S, /obj/item/weapon/stock_parts/micro_laser))
			usermessage("[I] has been sucessfully installed into systems.")
			if(user.unEquip(I))
				if(part_laser)
					part_laser.forceMove(get_turf(src))
					part_laser = null
				I.loc = src
				part_laser = I
		if(istype(S, /obj/item/weapon/stock_parts/matter_bin))
			usermessage("[I] has been sucessfully installed into systems.")
			if(user.unEquip(I))
				if(part_bin)
					part_bin.forceMove(get_turf(src))
					part_bin = null
				I.loc = src
				part_bin = I
		if(istype(S, /obj/item/weapon/stock_parts/capacitor))
			usermessage("[I] has been sucessfully installed into systems.")
			if(user.unEquip(I))
				if(part_cap)
					part_cap.forceMove(get_turf(src))
					part_cap = null
				I.loc = src
				part_cap = I
	update_parts()
	..()

//MOB MOVEMENT STUFF----------------------------------------------------------------------------------------------------------------------------------------------

/mob/proc/get_flightpack()
	return

/mob/living/carbon/get_flightpack()
	var/obj/item/device/flightpack/F = back
	if(istype(F))
		return F
	else
		return FALSE

/obj/item/device/flightpack/proc/allow_thrust(amount)
	if(flight)
		return TRUE

//FLIGHT SHOES-----------------------------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors nessacary for flight gear to work" //Apparently you need these to detect mob movement.
	icon_state = "flightshoes"
	item_state = "flightshoes_mob"
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/device/flightpack/pack = null
	var/mob/living/carbon/human/wearer = null
	var/active = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/flightshoes/Destroy()
	if(suit)
		suit.shoes = null
	return ..()

/obj/item/clothing/shoes/flightshoes/proc/toggle(toggle)
	if(suit)
		active = toggle
		if(active)
			src.flags |= NOSLIP
		if(!active)
			src.flags &= ~NOSLIP

/obj/item/clothing/shoes/flightshoes/dropped(mob/wearer)
	..()

/obj/item/clothing/shoes/flightshoes/item_action_slot_check(slot)
	if(slot == slot_shoes)
		return TRUE

/obj/item/clothing/shoes/flightshoes/proc/delink_suit()
	if(suit)
		if(suit.shoes && suit.shoes == src)
			suit.shoes = null
	suit = null

/obj/item/clothing/shoes/flightshoes/proc/relink_suit(obj/item/clothing/suit/space/hardsuit/flightsuit/F)
	if(suit && suit == F)
		return FALSE
	else
		delink_suit()
	if(istype(F))
		suit = F
		suit.shoes = src
	else
		suit = null

//FLIGHT SUIT------------------------------------------------------------------------------------------------------------------------------------------------------
//Flight pack and flight shoes/helmet are stored in here. This has to be locked to someone to use either. For both balance reasons and practical codewise reasons.

/obj/item/clothing/suit/space/hardsuit/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the wearer flight via two high powered miniature jet engines on a deployable back-mounted unit."
	icon_state = "flightsuit"
	item_state = "flightsuit"
	strip_delay = 30
	var/locked_strip_delay = 80
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/device/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/user = null
	var/deployedpack = FALSE
	var/deployedshoes = FALSE
	var/locked = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	jetpack = null
	var/flightpack
	var/flight = FALSE
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	actions_types = list(/datum/action/item_action/flightsuit/toggle_helmet,/datum/action/item_action/flightsuit/toggle_boots,/datum/action/item_action/flightsuit/toggle_flightpack,/datum/action/item_action/flightsuit/lock_suit)
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 100, acid = 100)
	var/maint_panel = FALSE
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/flightsuit/full/New()
	..()
	makepack()
	makeshoes()
	resync()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/usermessage(message, urgency = 0)
	if(!urgency)
		user << "\icon[src]<span class='notice'>|[message]</span>"
	else if(urgency == 1)
		user << "\icon[src]<span class='warning'>|[message]</span>"
	else if(urgency == 2)
		user << "\icon[src]<span class='userdanger'>|[message]</span>"

/obj/item/clothing/suit/space/hardsuit/flightsuit/examine(mob/user)
	..()
	user << "<span class='boldnotice'>SUIT: [locked ? "LOCKED" : "UNLOCKED"]</span>"
	user << "<span class='boldnotice'>FLIGHTPACK: [deployedpack ? "ENGAGED" : "DISENGAGED"] FLIGHTSHOES : [deployedshoes ? "ENGAGED" : "DISENGAGED"] HELMET : [suittoggled ? "ENGAGED" : "DISENGAGED"]</span>"
	user << "<span class='boldnotice'>Its maintainence panel is [maint_panel ? "OPEN" : "CLOSED"]</span>"

/obj/item/clothing/suit/space/hardsuit/flightsuit/Destroy()
	dropped()
	if(pack)
		pack.delink_suit()
		qdel(pack)
	if(shoes)
		shoes.pack = null
		shoes.suit = null
		qdel(shoes)
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/resync()
	if(pack)
		pack.relink_suit(src)
	if(user)
		if(pack)
			pack.wearer = user
		if(shoes)
			shoes.wearer = user
	else
		if(pack)
			pack.wearer = null
		if(shoes)
			shoes.wearer = null
	if(shoes)
		shoes.relink_suit(src)

/obj/item/clothing/suit/space/hardsuit/flightsuit/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(src == H.wear_suit && locked)
			usermessage("You can not take a locked hardsuit off! Unlock it first!", 1)
			return
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/flightsuit/lock_suit))
		if(!locked)
			lock_suit(owner)
		else
			unlock_suit(owner)
	if(istype(action, /datum/action/item_action/flightsuit/toggle_flightpack))
		if(!deployedpack)
			extend_flightpack()
		else
			retract_flightpack()
	if(istype(action, /datum/action/item_action/flightsuit/toggle_boots))
		if(!deployedshoes)
			extend_flightshoes()
		else
			retract_flightshoes()
	if(istype(action, /datum/action/item_action/flightsuit/toggle_helmet))
		ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/flightsuit/dropped()
	if(deployedpack)
		retract_flightpack(TRUE)
	if(deployedshoes)
		retract_flightshoes(TRUE)
	if(locked)
		unlock_suit(null)
	if(user)
		user = null
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/ToggleHelmet()
	if(!suittoggled)
		if(!locked)
			usermessage("You must lock your suit before engaging the helmet!", 1)
			return FALSE
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/lock_suit(mob/wearer)
	user = wearer
	user.visible_message("<span class='notice'>[wearer]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = locked_strip_delay
	locked = TRUE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/unlock_suit(mob/wearer)
	if(suittoggled)
		usermessage("You must retract the helmet before unlocking your suit!", 1)
		return FALSE
	if(pack && pack.flight)
		usermessage("You must shut off the flight-pack before unlocking your suit!", 1)
		return FALSE
	if(deployedpack)
		usermessage("Your flightpack must be fully retracted first!", 1)
		return FALSE
	if(deployedshoes)
		usermessage("Your flight shoes must be fully retracted first!", 1)
		return FALSE
	if(wearer)
		user.visible_message("<span class='notice'>[wearer]'s flight suit detaches from their body, becoming nothing more then a bulky metal skeleton.</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = initial(strip_delay)
	locked = FALSE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightpack(forced = FALSE)
	if(!pack)
		usermessage("There is no attached flightpack!", 1)
		return FALSE
	if(deployedpack)
		retract_flightpack()
	if(!locked)
		usermessage("You must lock your flight suit first before deploying anything!", 1)
		return FALSE
	if(ishuman(user))
		if(user.back)
			usermessage("You're already wearing something on your back!", 1)
			return FALSE
		user.equip_to_slot_if_possible(pack,slot_back,0,0,1)
		pack.flags |= NODROP
		resync()
		user.visible_message("<span class='notice'>A [pack.name] extends from [user]'s [name] and clamps to their back!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightpack(forced = FALSE)
	if(ishuman(user))
		if(pack.flight && !forced)
			usermessage("You must disable the engines before retracting the flightpack!", 1)
			return FALSE
		if(pack.flight && forced)
			pack.disable_flight(1)
		pack.flags &= ~NODROP
		resync()
		if(user)
			user.unEquip(pack, 1)
			user.update_inv_wear_suit()
			user.visible_message("<span class='notice'>[user]'s [pack.name] detaches from their back and retracts into their [src]!</span>")
	pack.loc = src
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = FALSE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightshoes(forced = FALSE)
	if(!shoes)
		usermessage("Flight shoes are not installed!", 1)
		return FALSE
	if(deployedshoes)
		retract_flightshoes()
	if(!locked)
		usermessage("You must lock your flight suit first before deploying anything!", 1)
		return FALSE
	if(ishuman(user))
		if(user.shoes)
			usermessage("You're already wearing something on your feet!", 1)
			return FALSE
		user.equip_to_slot_if_possible(shoes,slot_shoes,0,0,1)
		shoes.flags |= NODROP
		user.visible_message("<span class='notice'>[user]'s [name] extends a pair of [shoes.name] over their feet!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightshoes(forced = FALSE)
	shoes.flags &= ~NODROP
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	if(user)
		user.unEquip(shoes, 1)
		user.update_inv_wear_suit()
		user.visible_message("<span class='notice'>[user]'s [shoes.name] retracts back into their [name]!</span>")
	shoes.loc = src
	deployedshoes = FALSE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makepack()
	if(!pack)
		pack = new /obj/item/device/flightpack/full(src)
		pack.relink_suit(src)

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makeshoes()
	if(!shoes)
		shoes = new /obj/item/clothing/shoes/flightshoes(src)
		shoes.pack = pack
		shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/equipped(mob/M, slot)
	if(ishuman(M))
		user = M
	if(slot != slot_wear_suit)
		if(deployedpack)
			retract_flightpack(TRUE)
		if(deployedshoes)
			retract_flightshoes(TRUE)
		if(locked)
			unlock_suit(user)
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/detach_pack()
	pack.delink_suit()
	pack.loc = get_turf(src)
	pack = null
	usermessage("You detach the flightpack.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/attach_pack(obj/item/device/flightpack/F)
	F.loc = src
	pack = F
	pack.relink_suit(src)
	usermessage("You attach and fasten the flightpack.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/detach_shoes()
	shoes.delink_suit()
	shoes.loc = get_turf(src)
	shoes = null
	usermessage("You detach the flight shoes.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/attach_shoes(obj/item/clothing/shoes/flightshoes/S)
	S.loc = src
	shoes = S
	shoes.relink_suit(src)
	usermessage("You attach and fasten a pair of flight shoes.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/attackby(obj/item/I, mob/wearer, params)
	user = wearer
	if(src == user.get_item_by_slot(slot_wear_suit))
		usermessage("You can not perform any service without taking the suit off!", 1)
		return FALSE
	if(locked)
		usermessage("You can not perform any service while the suit is locked!", 1)
		return FALSE
	if(istype(I, /obj/item/weapon/screwdriver))
		if(!maint_panel)
			maint_panel = TRUE
		else
			maint_panel = FALSE
		usermessage("You [maint_panel? "open" : "close"] the maintainence panel.")
	if(!maint_panel)
		usermessage("The maintainence panel is closed!", 1)
		return FALSE
	if(istype(I, /obj/item/weapon/crowbar))
		var/list/inputlist = list()
		if(pack)
			inputlist += "Pack"
		if(shoes)
			inputlist += "Shoes"
		if(!inputlist.len)
			usermessage("There is nothing inside the flightsuit to remove!", 1)
			return FALSE
		var/input = input(user, "What to remove?", "Removing module") as null|anything in list("Pack", "Shoes")
		if(pack && input == "Pack")
			if(pack.flight)
				usermessage("You can not pry off an active flightpack!", 1)
				return FALSE
			if(deployedpack)
				usermessage("Disengage the flightpack first!", 1)
				return FALSE
			detach_pack()
		if(shoes && input == "Shoes")
			if(deployedshoes)
				usermessage("Disengage the shoes first!", 1)
				return FALSE
			detach_shoes()
	if(istype(I, /obj/item/device/flightpack))
		var/obj/item/device/flightpack/F = I
		if(pack)
			usermessage("[src] already has a flightpack installed!", 1)
			return FALSE
		if(!F.assembled)
			var/addmsg = " It is missing a "
			var/list/addmsglist = list()
			if(!F.part_manip)
				addmsglist += "manipulator"
			if(!F.part_cap)
				addmsglist += "capacitor"
			if(!F.part_scan)
				addmsglist += "scanning module"
			if(!F.part_laser)
				addmsglist += "micro-laser"
			if(!F.part_bin)
				addmsglist += "matter bin"
			addmsg += english_list(addmsglist)
			usermessage("The flightpack you are trying to install is not fully assembled and operational![addmsg].", 1)
			return FALSE
		if(user.unEquip(F))
			attach_pack(F)
	if(istype(I, /obj/item/clothing/shoes/flightshoes))
		var/obj/item/clothing/shoes/flightshoes/S = I
		if(shoes)
			usermessage("There are already shoes installed!", 1)
			return FALSE
		if(user.unEquip(S))
			attach_shoes(S)
	..()

//FLIGHT HELMET----------------------------------------------------------------------------------------------------------------------------------------------------
/obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	name = "flight helmet"
	desc = "A sealed helmet attached to a flight suit for EVA usage scenerios. Its visor contains an information uplink HUD."
	icon_state = "flighthelmet"
	item_state = "flighthelmet"
	item_color = "flight"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	brightness_on = 7
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 100, acid = 100)
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC)
	var/zoom_range = 14
	var/zoom = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/flightpack/zoom)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/equipped(mob/living/carbon/human/wearer, slot)
	..()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = huds[hudtype]
		H.add_hud_to(wearer)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/dropped(mob/living/carbon/human/wearer)
	..()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = huds[hudtype]
		H.remove_hud_from(wearer)
	if(zoom)
		toggle_zoom(wearer, TRUE)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/flightpack/zoom))
		toggle_zoom(owner)
	. = ..()

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/proc/toggle_zoom(mob/living/user, force_off = FALSE)
	if(zoom || force_off)
		user.client.view = world.view
		user << "<span class='boldnotice'>Disabling smart zooming image enhancement...</span>"
		zoom = FALSE
		return FALSE
	else
		user.client.view = zoom_range
		user << "<span class='boldnotice'>Enabling smart zooming image enhancement!</span>"
		zoom = TRUE
		return TRUE

//ITEM actionS------------------------------------------------------------------------------------------------------------------------------------------------------
//TODO: TOGGLED BUTTON SPRITES
/datum/action/item_action/flightsuit/toggle_boots
	name = "Toggle Boots"
	button_icon_state = "flightsuit_shoes"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/toggle_helmet
	name = "Toggle Helmet"
	button_icon_state = "flightsuit_helmet"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/toggle_flightpack
	name = "Toggle Flightpack"
	button_icon_state = "flightsuit_pack"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightsuit/lock_suit
	name = "Lock Suit"
	button_icon_state = "flightsuit_lock"
	background_icon_state = "bg_tech"

/datum/action/item_action/flightpack/toggle_flight
	name = "Toggle Flight"
	button_icon_state = "flightpack_fly"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/engage_boosters
	name = "Toggle Boosters"
	button_icon_state = "flightpack_boost"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/toggle_stabilizers
	name = "Toggle Stabilizers"
	button_icon_state = "flightpack_stabilizer"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/change_power
	name = "Flight Power Setting"
	button_icon_state = "flightpack_power"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/toggle_airbrake
	name = "Toggle Airbrake"
	button_icon_state = "flightpack_airbrake"
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/flightpack/zoom
	name = "Helmet Smart Zoom"
	background_icon_state = "bg_tech_blue"
	button_icon_state = "sniper_zoom"
