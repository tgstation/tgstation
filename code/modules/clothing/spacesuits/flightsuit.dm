
#define FLIGHTPACK_SPRITE_ON_APPEND "_on"
#define FLIGHTPACK_SPRITE_BOOST_APPEND "_boost"
#define FLIGHTPACK_SPRITE_OFF_APPEND "_off"
#define FLIGHTPACK_SPRITE_BASE "flightpack"

//So how this is planned to work is it is an item that allows you to fly with some interesting movement mechanics.
//You will still move instantly like usual, but when you move in a direction you gain "momentum" towards that direction
//Momentum will have a maximum value that it will be capped to, and will go down over time
//There is toggleable "stabilizers" that will make momentum go down FAST instead of its normal slow rate
//The suit is heavy and will slow you down on the ground but is a bit faster then usual in air
//The speed at which you drift is determined by your current momentum
//Also, I should probably add in some kind of limiting mechanic but I really don't like having to refill this all the time, expecially as it will be NODROP_1.
//Apparently due to code limitations you have to detect mob movement with.. shoes.
//The object that handles the flying itself - FLIGHT PACK --------------------------------------------------------------------------------------
/obj/item/flightpack
	name = "flight pack"
	desc = "An advanced back-worn system that has dual ion engines powerful enough to grant a humanoid flight. Contains an internal self-recharging high-current capacitor for short, powerful boosts."
	icon = 'icons/obj/device.dmi'
	icon_state = FLIGHTPACK_SPRITE_BASE
	item_state = FLIGHTPACK_SPRITE_BASE
	actions_types = list(/datum/action/item_action/flightpack/toggle_flight, /datum/action/item_action/flightpack/engage_boosters, /datum/action/item_action/flightpack/toggle_stabilizers, /datum/action/item_action/flightpack/change_power, /datum/action/item_action/flightpack/toggle_airbrake)
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 30, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = FIRE_PROOF

	var/processing_mode = FLIGHTSUIT_PROCESSING_FULL
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
	var/emp_disable_message = FALSE

	//This is probably too much code just for EMP damage.
	var/emp_damage = 0	//One hit should make it hard to control, continuous hits will cripple it and then simply shut it off/make it crash. Direct hits count more.
	var/emp_strong_damage = 4
	var/emp_weak_damage = 2.5
	var/emp_heal_amount = 0.06		//How much emp damage to heal per process.
	var/emp_disable_threshold = 3	//3 weak ion, 2 strong ion hits.
	var/emp_disabled = FALSE

	var/requires_suit = TRUE

	var/datum/effect_system/trail_follow/ion/flight/ion_trail

	var/assembled = FALSE
	var/obj/item/stock_parts/manipulator/part_manip = null
	var/obj/item/stock_parts/scanning_module/part_scan = null
	var/obj/item/stock_parts/capacitor/part_cap = null
	var/obj/item/stock_parts/micro_laser/part_laser = null
	var/obj/item/stock_parts/matter_bin/part_bin = null

	var/crashing = FALSE	//Are we currently getting wrecked?

	var/atom/movable/cached_pull		//recipe for disaster again.
	var/afterForceMove = FALSE
	var/datum/component/mobhook

/obj/item/flightpack/proc/changeWearer(mob/changeto)
	if(wearer)
		LAZYREMOVE(wearer.user_movement_hooks, src)
	wearer = null
	QDEL_NULL(mobhook)
	cached_pull = null
	if(istype(changeto))
		wearer = changeto
		LAZYADD(wearer.user_movement_hooks, src)
		cached_pull = changeto.pulling
		mobhook = changeto.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED), CALLBACK(src, .proc/on_mob_move, changeto))

/obj/item/flightpack/Initialize()
	ion_trail = new
	ion_trail.set_up(src)
	START_PROCESSING(SSflightpacks, src)
	update_parts()
	sync_processing(SSflightpacks)
	update_icon()
	..()

/obj/item/flightpack/full/Initialize()
	part_manip = new /obj/item/stock_parts/manipulator/pico(src)
	part_scan = new /obj/item/stock_parts/scanning_module/phasic(src)
	part_cap = new /obj/item/stock_parts/capacitor/super(src)
	part_laser = new /obj/item/stock_parts/micro_laser/ultra(src)
	part_bin = new /obj/item/stock_parts/matter_bin/super(src)
	..()

/obj/item/flightpack/proc/usermessage(message, span = "boldnotice", mob/mob_override = null)
	var/mob/targ = wearer
	if(ismob(loc))
		targ = loc
	if(istype(mob_override))
		targ = mob_override
	if(!istype(targ))
		return
	to_chat(targ, "[icon2html(src, targ)]<span class='[span]'>|[message]</span>")

/obj/item/flightpack/proc/sync_processing(datum/controller/subsystem/processing/flightpacks/FPS)
	processing_mode = FPS.flightsuit_processing
	if(processing_mode == FLIGHTSUIT_PROCESSING_NONE)
		momentum_x = 0
		momentum_y = 0
		momentum_speed_x = 0
		momentum_speed_y = 0
		momentum_speed = 0
		boost_charge = 0
		boost = FALSE
		update_slowdown()

/obj/item/flightpack/proc/update_parts()
	boost_chargerate = initial(boost_chargerate)
	boost_drain = initial(boost_drain)
	powersetting_high = initial(powersetting_high)
	emp_disable_threshold = initial(emp_disable_threshold)
	stabilizer_decay_amount = initial(stabilizer_decay_amount)
	airbrake_decay_amount = initial(airbrake_decay_amount)
	assembled = FALSE	//Ready?
	if(part_manip && part_scan && part_cap && part_laser && part_bin)
		var/manip = part_manip.rating
		var/scan = part_scan.rating
		var/cap = part_cap.rating
		var/laser = part_laser.rating
		var/bin = part_bin.rating
		assembled = TRUE
		boost_chargerate *= cap
		boost_drain -= manip
		powersetting_high = CLAMP(laser, 0, 3)
		emp_disable_threshold = bin*1.25
		stabilizer_decay_amount = scan*3.5
		airbrake_decay_amount = manip*8

/obj/item/flightpack/Destroy()
	if(suit)
		delink_suit()
	changeWearer()
	disable_flight(TRUE)
	QDEL_NULL(part_manip)
	QDEL_NULL(part_scan)
	QDEL_NULL(part_cap)
	QDEL_NULL(part_laser)
	QDEL_NULL(part_bin)
	QDEL_NULL(ion_trail)
	QDEL_NULL(mobhook)
	STOP_PROCESSING(SSflightpacks, src)
	. = ..()

/obj/item/flightpack/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/damage = severity == 1 ? emp_strong_damage : emp_weak_damage
	if(emp_damage <= (emp_disable_threshold * 1.5))
		emp_damage += damage
		usermessage("WARNING: Class [severity] EMP detected! Circuit damage at [(emp_damage/emp_disable_threshold)*100]%!", "boldwarning")

//Proc to change amount of momentum the wearer has, or dampen all momentum by a certain amount.
/obj/item/flightpack/proc/adjust_momentum(amountx, amounty, reduce_amount_total = 0)
	if(reduce_amount_total != 0)
		if(momentum_x > 0)
			momentum_x = CLAMP(momentum_x - reduce_amount_total, 0, momentum_max)
		else if(momentum_x < 0)
			momentum_x = CLAMP(momentum_x + reduce_amount_total, -momentum_max, 0)
		if(momentum_y > 0)
			momentum_y = CLAMP(momentum_y - reduce_amount_total, 0, momentum_max)
		else if(momentum_y < 0)
			momentum_y = CLAMP(momentum_y + reduce_amount_total, -momentum_max, 0)
	momentum_x = CLAMP(momentum_x + amountx, -momentum_max, momentum_max)
	momentum_y = CLAMP(momentum_y + amounty, -momentum_max, momentum_max)
	calculate_momentum_speed()

//The wearer has momentum left. Move them and take some away, while negating the momentum that moving the wearer would gain. Or force the wearer to lose control if they are incapacitated.
/obj/item/flightpack/proc/momentum_drift()
	if(!flight || !wearer || (momentum_speed == 0))
		return FALSE
	else if(!wearer.canmove)
		losecontrol()
	var/drift_dir_x = 0
	var/drift_dir_y = 0
	if(momentum_x > 0)
		drift_dir_x = EAST
	else if(momentum_x < 0)
		drift_dir_x = WEST
	if(momentum_y > 0)
		drift_dir_y = NORTH
	else if(momentum_y < 0)
		drift_dir_y = SOUTH
	momentum_decay()
	for(var/i in 1 to momentum_speed)
		if(momentum_speed_x >= i)
			step(wearer, drift_dir_x)
		if(momentum_speed_y >= i)
			step(wearer, drift_dir_y)
		sleep(1)
	if(prob(emp_damage * 15))
		step(wearer, pick(GLOB.alldirs))

/obj/item/flightpack/proc/on_mob_move(mob/mob, turf/oldLoc, dir, forced)
	if(forced)
		if(cached_pull && istype(oldLoc) && (get_dist(oldLoc, loc) <= 1) && !oldLoc.density)
			cached_pull.forceMove(oldLoc)
			mob.start_pulling(cached_pull, TRUE)
			afterForceMove = TRUE
		else
			cached_pull = null
	else
		if(afterForceMove && !oldLoc.density)
			cached_pull.forceMove(oldLoc)
			wearer.start_pulling(cached_pull, TRUE)
			cached_pull = null
		else
			cached_pull = wearer.pulling
		afterForceMove = FALSE
	if(flight)
		ion_trail.generate_effect()

/obj/item/flightpack/intercept_user_move(dir, mob, newLoc, oldLoc)
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

//Make the wearer lose some momentum.
/obj/item/flightpack/proc/momentum_decay()
	var/amt = momentum_passive_loss
	brake? (amt += airbrake_decay_amount) : 0
	gravity? (amt += gravity_decay_amount) : 0
	stabilizer? (amt += stabilizer_decay_amount) : 0
	pressure? (amt += pressure_decay_amount) : 0
	adjust_momentum(0, 0, amt)

//Check for gravity, air pressure, and whether this is still linked to a suit. Also, resync the flightpack/flight suit every minute.
/obj/item/flightpack/proc/check_conditions()
	if(flight && (!assembled || !wearer || (!suit && requires_suit)))
		disable_flight(TRUE)
	var/turf/T = get_turf(src)
	if(T)
		gravity = has_gravity()
		var/datum/gas_mixture/gas = T.return_air()
		var/envpressure = gas.return_pressure()
		pressure = envpressure >= pressure_threshold
	if(!pressure && brake)
		brake = FALSE
		usermessage("Airbrakes deactivated due to lack of pressure!", "boldwarning")
	if(suit && !suit.deployedshoes && (brake || stabilizer))
		brake = FALSE
		stabilizer = FALSE
		usermessage("Warning: Sensor data is not being received from flight shoes. Stabilizers and airbrake modules deactivated!", "boldwarning")


/obj/item/flightpack/process()
	if(processing_mode == FLIGHTSUIT_PROCESSING_NONE)
		return FALSE
	check_conditions()
	calculate_momentum_speed()
	momentum_drift()
	handle_boost()
	handle_damage()

/obj/item/flightpack/proc/update_slowdown()
	flight? (slowdown = slowdown_air) : (slowdown = slowdown_ground)

/obj/item/flightpack/proc/handle_damage()
	if(emp_damage)
		emp_damage = CLAMP(emp_damage-emp_heal_amount, 0, emp_disable_threshold * 10)
		if(emp_damage >= emp_disable_threshold)
			emp_disabled = TRUE
		if(emp_disabled && (emp_damage <= 0.5))
			emp_disabled = FALSE
			emp_disable_message = FALSE
			usermessage("Electromagnetic deflection system re-activated. Flight systems re-enabled.")
	disabled = emp_disabled
	if(disabled)
		if(emp_disabled && (!emp_disable_message))
			usermessage("Electromagnetic deflectors overloaded. Short circuit detected in internal systems!", "boldwarning")
			usermessage("Deactivating to prevent fatal power overload!", "boldwarning")
			emp_disable_message = TRUE
		if(flight)
			disable_flight(TRUE)

/obj/item/flightpack/update_icon()
	if(!flight)
		icon_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_OFF_APPEND]"
		item_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_OFF_APPEND]"
	if(flight)
		if(!boost)
			icon_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_ON_APPEND]"
			item_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_ON_APPEND]"
		else
			icon_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_BOOST_APPEND]"
			item_state = "[FLIGHTPACK_SPRITE_BASE][FLIGHTPACK_SPRITE_BOOST_APPEND]"
	if(wearer)
		wearer.update_inv_wear_suit()
		wearer.update_inv_back()

/obj/item/flightpack/proc/handle_boost()
	if(boost)
		boost_charge = CLAMP(boost_charge-boost_drain, 0, boost_maxcharge)
		if(boost_charge < 1)
			deactivate_booster()
	if(boost_charge < boost_maxcharge)
		boost_charge = CLAMP(boost_charge+boost_chargerate, 0, boost_maxcharge)

/obj/item/flightpack/proc/cycle_power()
	powersetting < powersetting_high? (powersetting++) : (powersetting = 1)
	momentum_gain = powersetting * 10
	usermessage("Engine output set to [momentum_gain].")
	momentum_drift_coeff = ((momentum_gain)*(drift_tolerance*1.1))/momentum_max

/obj/item/flightpack/proc/crash_damage(density, anchored, speed, victim_name)
	var/crashmessagesrc = "<span class='userdanger'>[wearer] violently crashes into [victim_name], "
	var/userdamage = 10 - stabilizer * 3 - part_bin.rating - part_scan.rating * part_manip.rating + anchored * 2 + boost * 2 + speed * 2
	if(userdamage > 0)
		crashmessagesrc += "that really must have hurt!"
		wearer.adjustBruteLoss(userdamage)
	else
		crashmessagesrc += "but luckily [wearer]'s impact was absorbed by [wearer.p_their()] suit's stabilizers!</span>"
	wearer.visible_message(crashmessagesrc)

/obj/item/flightpack/proc/userknockback(density, anchored, speed, dir)
	dir = turn(dir, 180)
	var/turf/target = get_edge_target_turf(get_turf(wearer), dir)
	wearer.visible_message("[wearer] is knocked flying by the impact!")
	wearer.throw_at(target, speed * 2 + density * 2 + anchored * 2, 2, wearer)

/obj/item/flightpack/proc/flight_impact(atom/impacted_atom, crashdir)	//Yes, victim.
	if(!flight || (impacted_atom == wearer) || crashing || (processing_mode == FLIGHTSUIT_PROCESSING_NONE))
		return FALSE
	crashing = TRUE
	var/crashpower = 0
	if(crashdir == NORTH || crashdir == SOUTH)
		crashpower = momentum_speed_y
	else if(crashdir == EAST || crashdir == WEST)
		crashpower = momentum_speed_x
	if(boost)
		crashpower = 3
	if(!crashpower)
		crashing = FALSE
		return FALSE
	var/density = FALSE
	var/anchored = TRUE	//Just in case...
	var/damage = FALSE
	if(istype(impacted_atom, /obj/structure/grille) && (crashpower > 1))
		crash_grille(impacted_atom)
	else if((istype(impacted_atom, /obj/machinery/door)) && (!istype(impacted_atom, /obj/machinery/door/poddoor)))
		var/obj/machinery/door/D = impacted_atom
		if(!airlock_pass(D) && (momentum_speed >= 3))
			damage = TRUE
			anchored = TRUE
			density = FALSE
	else if(istype(impacted_atom, /obj/structure/mineral_door))
		door_pass(impacted_atom)
	else if(isclosedturf(impacted_atom) && (crashpower >= 3))
		damage = TRUE
		density = TRUE
		anchored = TRUE
	else if(ismovableatom(impacted_atom))
		var/atom/movable/impacted_AM = impacted_atom
		if(!impacted_AM.throwing && (crashpower >= 3))
			density = impacted_AM.density
			anchored = impacted_AM.anchored
			damage = anchored
			atom_impact(impacted_AM, crashpower, crashdir)
	if(damage)
		crash_damage(density, anchored, momentum_speed, impacted_atom.name)
		userknockback(density, anchored, momentum_speed, crashdir)
		losecontrol(knockdown = FALSE, move = FALSE)
	crashing = FALSE

/obj/item/flightpack/proc/door_pass(obj/structure/mineral_door/door)
	INVOKE_ASYNC(door, /obj/structure/mineral_door.proc/Open)
	var/turf/T = get_turf(door)
	wearer.forceMove(T)
	wearer.visible_message("<span class='boldnotice'>[wearer] rolls to [wearer.p_their()] sides and slips past [door]!</span>")

/obj/item/flightpack/proc/crash_grille(obj/structure/grille/target)
	target.hitby(wearer)
	target.take_damage(60, BRUTE, "melee", 1)
	if(wearer.Move(target.loc))
		wearer.visible_message("<span class='warning'>[wearer] smashes straight past [target]!</span>")

/obj/item/flightpack/proc/airlock_pass(obj/machinery/door/A)
	var/nopass = FALSE
	if(!A.density)
		return TRUE
	nopass = (A.locked || A.stat || (A.obj_flags & EMAGGED) || A.welded)
	if(A.requiresID())
		if((!A.allowed(wearer)) && !A.emergency)
			nopass = TRUE
	if(!nopass)
		INVOKE_ASYNC(A, /obj/machinery/door.proc/open)
		wearer.visible_message("<span class='warning'>[wearer] rolls sideways and slips past [A]</span>")
		var/turf/target = get_turf(A)
		if(istype(A, /obj/machinery/door/window) && (get_turf(wearer) == get_turf(A)))
			target = get_step(A, A.dir)
		wearer.forceMove(target)
	return !nopass

/obj/item/flightpack/proc/atom_impact(atom/movable/victim, power, direction)
	if(!victim)
		return FALSE
	if(!victim.anchored)
		var/knockback = (power + ((part_manip.rating + part_bin.rating) / 2) - (victim.density * 2)) * 2
		victim.visible_message("<span class='warning'>[victim.name] is sent flying by the impact!</span>")
		var/turf/target = get_turf(victim)
		for(var/i in 1 to knockback)
			target = get_step(target, direction)
		for(var/i in 1 to knockback/3)
			target = get_step(target, pick(GLOB.alldirs))
		victim.throw_at(target, knockback, part_manip.rating)
	if(isobj(victim))
		var/obj/O = victim
		O.take_damage(power * 14)

/obj/item/flightpack/proc/losecontrol(knockdown = FALSE, move = TRUE)
	usermessage("Warning: Control system not responding. Deactivating!", "boldwarning")
	if(wearer)
		wearer.visible_message("<span class='warning'>[wearer]'s flight suit abruptly shuts off and [wearer.p_they()] lose[wearer.p_s()] control!</span>")
		if(move)
			while(momentum_x != 0 || momentum_y != 0)
				sleep(2)
				step(wearer, pick(GLOB.cardinals))
				momentum_decay()
				adjust_momentum(0, 0, 10)
		wearer.visible_message("<span class='warning'>[wearer]'s flight suit crashes into the ground!</span>")
		if(knockdown)
			wearer.Knockdown(80)
	momentum_x = 0
	momentum_y = 0
	calculate_momentum_speed()
	if(flight)
		disable_flight(FALSE)

/obj/item/flightpack/proc/enable_flight(forced = FALSE)
	if(!forced)
		if(disabled)
			usermessage("Internal systems recalibrating. Unable to safely proceed.", "boldwarning")
			return FALSE
		if(suit)
			if(suit.shoes)
				suit.shoes.toggle(TRUE)
		else if(!requires_suit)
			usermessage("Warning: Flightpack not linked to compatible flight-suit mount!", "boldwarning")
			return FALSE
	wearer.movement_type |= FLYING
	wearer.pass_flags |= flight_passflags
	usermessage("ENGAGING FLIGHT ENGINES.")
	wearer.visible_message("<font color='blue' size='2'>[wearer]'s flight engines activate as [wearer.p_they()] lift[wearer.p_s()] into the air!</font>")
	flight = TRUE
	update_slowdown()
	update_icon()
	ion_trail.start()

/obj/item/flightpack/proc/disable_flight(forced = FALSE)
	if(forced)
		losecontrol(knockdown = TRUE)
		return TRUE
	calculate_momentum_speed()
	if(momentum_speed == 0)
		momentum_x = 0
		momentum_y = 0
		calculate_momentum_speed()
		usermessage("DISENGAGING FLIGHT ENGINES.")
		wearer.visible_message("<font color='blue' size='2'>[wearer] drops to the ground as [wearer.p_their()] flight engines cut out!</font>")
		wearer.movement_type &= ~FLYING
		wearer.pass_flags &= ~flight_passflags
		flight = FALSE
		update_slowdown()
		update_icon()
		ion_trail.stop()
		if(suit && suit.shoes)
			suit.shoes.toggle(FALSE)
		if(isturf(wearer.loc))
			var/turf/T = wearer.loc
			T.Entered(src)
	else
		if(override_safe)
			disable_flight(TRUE)
			return TRUE
		usermessage("Warning: Velocity too high to safely disengage. Retry to confirm emergency shutoff.", "boldwarning")
		override_safe = TRUE
		addtimer(CALLBACK(src, .proc/enable_safe), 50)
		return FALSE

/obj/item/flightpack/proc/enable_safe()
	if(override_safe)
		override_safe = FALSE

/obj/item/flightpack/dropped(mob/wearer)
	changeWearer()
	..()

/obj/item/flightpack/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/flightpack/equipped(mob/user, slot)
	changeWearer(user)
	..()

/obj/item/flightpack/proc/calculate_momentum_speed()
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

/obj/item/flightpack/item_action_slot_check(slot)
	return slot == SLOT_BACK

/obj/item/flightpack/proc/enable_stabilizers()
	if(requires_suit && suit && !suit.deployedshoes)
		usermessage("Stabilizers requires flight shoes to be attached and deployed!", "boldwarning")
		return FALSE
	usermessage("Activating automatic stabilization controller and enabling maneuvering assistance.")
	stabilizer = TRUE
	return TRUE

/obj/item/flightpack/proc/disable_stabilizers()
	if(wearer)
		if(brake)
			disable_airbrake()
		usermessage("Deactivating stabilization controllers!", "boldwarning")
	stabilizer = FALSE

/obj/item/flightpack/proc/activate_booster()
	if(!flight)
		usermessage("Error: Engines offline!", "boldwarning")
		return FALSE
	if(boost_charge < 5)
		usermessage("Insufficient charge in boost capacitors to engage.", "boldwarning")
		return FALSE
	usermessage("Boosters engaged!")
	boost = TRUE
	update_slowdown()
	update_icon()

/obj/item/flightpack/proc/deactivate_booster()
	usermessage("Boosters disengaged!")
	boost = FALSE
	update_slowdown()
	update_icon()

/obj/item/flightpack/proc/enable_airbrake()
	if(wearer)
		if(!stabilizer && !enable_stabilizers())
			usermessage("Airbrake deployment: Stabilizer Errored.", "boldwarning")
			return FALSE
		usermessage("Airbrakes extended!")
	brake = TRUE
	update_slowdown()

/obj/item/flightpack/proc/disable_airbrake()
	if(wearer)
		usermessage("Airbrakes retracted!", "boldwarning")
	brake = FALSE
	update_slowdown()

/obj/item/flightpack/proc/relink_suit(obj/item/clothing/suit/space/hardsuit/flightsuit/F)
	if(suit && suit == F)
		return FALSE
	else
		delink_suit()
	if(istype(F))
		suit = F
		suit.pack = src
	else
		suit = null

/obj/item/flightpack/proc/delink_suit()
	if(suit)
		if(suit.pack && suit.pack == src)
			suit.pack = null
	suit = null

/obj/item/flightpack/attackby(obj/item/I, mob/user, params)
	var/const/SuccessMessage = " has been successfully installed into systems."
	var/changed = FALSE
	if(istype(I, /obj/item/stock_parts))
		var/obj/item/stock_parts/S = I
		if(istype(S, /obj/item/stock_parts/manipulator))
			usermessage("[I][SuccessMessage]", mob_override = user)
			if(user.transferItemToLoc(I, src))
				if(part_manip)
					part_manip.forceMove(get_turf(src))
				part_manip = I
				changed = TRUE
		if(istype(S, /obj/item/stock_parts/scanning_module))
			usermessage("[I][SuccessMessage]", mob_override = user)
			if(user.transferItemToLoc(I, src))
				if(part_scan)
					part_scan.forceMove(get_turf(src))
				part_scan = I
				changed = TRUE
		if(istype(S, /obj/item/stock_parts/micro_laser))
			usermessage("[I][SuccessMessage]", mob_override = user)
			if(user.transferItemToLoc(I, src))
				if(part_laser)
					part_laser.forceMove(get_turf(src))
				part_laser = I
				changed = TRUE
		if(istype(S, /obj/item/stock_parts/matter_bin))
			usermessage("[I][SuccessMessage]", mob_override = user)
			if(user.transferItemToLoc(I, src))
				if(part_bin)
					part_bin.forceMove(get_turf(src))
				part_bin = I
				changed = TRUE
		if(istype(S, /obj/item/stock_parts/capacitor))
			usermessage("[I][SuccessMessage]", mob_override = user)
			if(user.transferItemToLoc(I, src))
				if(part_cap)
					part_cap.forceMove(get_turf(src))
				part_cap = I
				changed = TRUE
	if(changed)
		update_parts()
	..()

//MOB MOVEMENT STUFF----------------------------------------------------------------------------------------------------------------------------------------------

/mob/proc/get_flightpack()
	return

/mob/living/carbon/get_flightpack()
	var/obj/item/flightpack/F = back
	if(istype(F))
		return F
	else
		return FALSE

/obj/item/flightpack/proc/allow_thrust(amount)
	if(flight)
		return TRUE

//FLIGHT SHOES-----------------------------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors necessary for flight gear to work." //Apparently you need these to detect mob movement.
	icon_state = "flightshoes"
	item_state = "flightshoes_mob"
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/flightpack/pack = null
	var/mob/living/carbon/human/wearer = null
	var/active = FALSE
	permeability_coefficient = 0.01
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/flightshoes/Destroy()
	pack = null
	wearer = null
	suit = null
	. = ..()

/obj/item/clothing/shoes/flightshoes/proc/toggle(toggle)
	if(suit)
		active = toggle
		if(active)
			clothing_flags |= NOSLIP
		if(!active)
			clothing_flags &= ~NOSLIP

/obj/item/clothing/shoes/flightshoes/item_action_slot_check(slot)
	return slot == SLOT_SHOES

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
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	jetpack = null
	actions_types = list(/datum/action/item_action/flightsuit/toggle_helmet, /datum/action/item_action/flightsuit/toggle_boots, /datum/action/item_action/flightsuit/toggle_flightpack, /datum/action/item_action/flightsuit/lock_suit)
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 30, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	var/locked_strip_delay = 80
	var/obj/item/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/user = null
	var/deployedpack = FALSE
	var/deployedshoes = FALSE
	var/locked = FALSE
	var/flightpack
	var/flight = FALSE
	var/maint_panel = FALSE

/obj/item/clothing/suit/space/hardsuit/flightsuit/Initialize()
	. = ..()
	allowed = GLOB.advanced_hardsuit_allowed

/obj/item/clothing/suit/space/hardsuit/flightsuit/full/Initialize()
	makepack()
	makeshoes()
	resync()
	return ..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/ui_action_click()
	return	//Handled in action datums.

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/usermessage(message, span = "boldnotice")
	var/mob/targ = user
	if(ismob(loc))
		targ = loc
	if(!istype(targ))
		return
	to_chat(targ, "[icon2html(src, targ)]<span class='[span]'>|[message]</span>")

/obj/item/clothing/suit/space/hardsuit/flightsuit/examine(mob/user)
	..()
	to_chat(user, "<span class='boldnotice'>SUIT: [locked ? "LOCKED" : "UNLOCKED"]</span>")
	to_chat(user, "<span class='boldnotice'>FLIGHTPACK: [deployedpack ? "ENGAGED" : "DISENGAGED"] FLIGHTSHOES : [deployedshoes ? "ENGAGED" : "DISENGAGED"] HELMET : [suittoggled ? "ENGAGED" : "DISENGAGED"]</span>")
	to_chat(user, "<span class='boldnotice'>Its maintainence panel is [maint_panel ? "OPEN" : "CLOSED"]</span>")

/obj/item/clothing/suit/space/hardsuit/flightsuit/Destroy()
	dropped()
	QDEL_NULL(pack)
	QDEL_NULL(shoes)
	return ..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/resync()
	if(pack)
		pack.relink_suit(src)
	if(user)
		if(pack)
			pack.changeWearer(user)
		if(shoes)
			shoes.wearer = user
	else
		if(pack)
			pack.changeWearer(null)
		if(shoes)
			shoes.wearer = null
	if(shoes)
		shoes.relink_suit(src)

/obj/item/clothing/suit/space/hardsuit/flightsuit/allow_attack_hand_drop(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(src == H.wear_suit && locked)
			usermessage("You can not take a locked hardsuit off! Unlock it first!", "boldwarning")
			return FALSE
	return ..()

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
			usermessage("You must lock your suit before engaging the helmet!", "boldwarning")
			return FALSE
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/lock_suit(mob/wearer)
	user = wearer
	user.visible_message("<span class='notice'>[wearer]'s flight suit locks around [wearer.p_them()], powered buckles and straps automatically adjusting to [wearer.p_their()] body!</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = locked_strip_delay
	locked = TRUE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/unlock_suit(mob/wearer)
	if(user)
		if(suittoggled)
			usermessage("You must retract the helmet before unlocking your suit!", "boldwarning")
			return FALSE
		if(pack && pack.flight)
			usermessage("You must shut off the flight-pack before unlocking your suit!", "boldwarning")
			return FALSE
		if(deployedpack)
			usermessage("Your flightpack must be fully retracted first!", "boldwarning")
			return FALSE
		if(deployedshoes)
			usermessage("Your flight shoes must be fully retracted first!", "boldwarning")
			return FALSE
		if(wearer)
			user.visible_message("<span class='notice'>[wearer]'s flight suit detaches from [wearer.p_their()] body, becoming nothing more then a bulky metal skeleton.</span>")
	playsound(src, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = initial(strip_delay)
	locked = FALSE
	return TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightpack(forced = FALSE)
	if(!pack)
		usermessage("There is no attached flightpack!", "boldwarning")
		return FALSE
	if(deployedpack)
		retract_flightpack()
	if(!locked)
		usermessage("You must lock your flight suit first before deploying anything!", "boldwarning")
		return FALSE
	if(ishuman(user))
		if(user.back)
			usermessage("You're already wearing something on your back!", "boldwarning")
			return FALSE
		user.equip_to_slot_if_possible(pack,SLOT_BACK,0,0,1)
		pack.item_flags |= NODROP
		resync()
		user.visible_message("<span class='notice'>A [pack.name] extends from [user]'s [name] and clamps to [user.p_their()] back!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightpack(forced = FALSE)
	if(ishuman(user))
		if(pack.flight && !forced)
			usermessage("You must disable the engines before retracting the flightpack!", "boldwarning")
			return FALSE
		if(pack.flight && forced)
			pack.disable_flight(1)
		pack.item_flags &= ~NODROP
		resync()
		if(user)
			user.transferItemToLoc(pack, src, TRUE)
			user.update_inv_wear_suit()
			user.visible_message("<span class='notice'>[user]'s [pack.name] detaches from [user.p_their()] back and retracts into [user.p_their()] [src]!</span>")
	pack.forceMove(src)
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = FALSE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightshoes(forced = FALSE)
	if(!shoes)
		usermessage("Flight shoes are not installed", "boldwarning")
		return FALSE
	if(deployedshoes)
		retract_flightshoes()
	if(!locked)
		usermessage("You must lock your flight suit first before deploying anything!", "boldwarning")
		return FALSE
	if(ishuman(user))
		if(user.shoes)
			usermessage("You're already wearing something on your feet!", "boldwarning")
			return FALSE
		user.equip_to_slot_if_possible(shoes,SLOT_SHOES,0,0,1)
		shoes.item_flags |= NODROP
		user.visible_message("<span class='notice'>[user]'s [name] extends a pair of [shoes.name] over [user.p_their()] feet!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = TRUE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightshoes(forced = FALSE)
	shoes.item_flags &= ~NODROP
	playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1)
	if(user)
		user.transferItemToLoc(shoes, src, TRUE)
		user.update_inv_wear_suit()
		user.visible_message("<span class='notice'>[user]'s [shoes.name] retracts back into [user.p_their()] [name]!</span>")
	shoes.forceMove(src)
	deployedshoes = FALSE

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makepack()
	if(!pack)
		pack = new /obj/item/flightpack/full(src)
		pack.relink_suit(src)

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makeshoes()
	if(!shoes)
		shoes = new /obj/item/clothing/shoes/flightshoes(src)
		shoes.pack = pack
		shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/equipped(mob/M, slot)
	if(ishuman(M))
		user = M
	if(slot != SLOT_WEAR_SUIT)
		if(deployedpack)
			retract_flightpack(TRUE)
		if(deployedshoes)
			retract_flightshoes(TRUE)
		if(locked)
			unlock_suit(user)
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/detach_pack()
	pack.delink_suit()
	pack.forceMove(get_turf(src))
	pack = null
	usermessage("You detach the flightpack.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/attach_pack(obj/item/flightpack/F)
	F.forceMove(src)
	pack = F
	pack.relink_suit(src)
	usermessage("You attach and fasten the flightpack.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/detach_shoes()
	shoes.delink_suit()
	shoes.forceMove(get_turf(src))
	shoes = null
	usermessage("You detach the flight shoes.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/attach_shoes(obj/item/clothing/shoes/flightshoes/S)
	S.forceMove(src)
	shoes = S
	shoes.relink_suit(src)
	usermessage("You attach and fasten a pair of flight shoes.")

/obj/item/clothing/suit/space/hardsuit/flightsuit/attackby(obj/item/I, mob/wearer, params)
	user = wearer
	if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
		usermessage("You can not perform any service without taking the suit off!", "boldwarning")
		return FALSE
	else if(locked)
		usermessage("You can not perform any service while the suit is locked!", "boldwarning")
		return FALSE
	else if(istype(I, /obj/item/screwdriver))
		if(!maint_panel)
			maint_panel = TRUE
		else
			maint_panel = FALSE
		usermessage("You [maint_panel? "open" : "close"] the maintenance panel.")
		return FALSE
	else if(!maint_panel)
		usermessage("The maintenance panel is closed!", "boldwarning")
		return FALSE
	else if(istype(I, /obj/item/crowbar))
		var/list/inputlist = list()
		if(pack)
			inputlist += "Pack"
		if(shoes)
			inputlist += "Shoes"
		if(!inputlist.len)
			usermessage("There is nothing inside the flightsuit to remove!", "boldwarning")
			return FALSE
		var/input = input(user, "What to remove?", "Removing module") as null|anything in list("Pack", "Shoes")
		if(pack && input == "Pack")
			if(pack.flight)
				usermessage("You can not pry off an active flightpack!", "boldwarning")
				return FALSE
			if(deployedpack)
				usermessage("Disengage the flightpack first!", "boldwarning")
				return FALSE
			detach_pack()
		if(shoes && input == "Shoes")
			if(deployedshoes)
				usermessage("Disengage the shoes first!", "boldwarning")
				return FALSE
			detach_shoes()
		return TRUE
	else if(istype(I, /obj/item/flightpack))
		var/obj/item/flightpack/F = I
		if(pack)
			usermessage("[src] already has a flightpack installed!", "boldwarning")
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
			usermessage("The flightpack you are trying to install is not fully assembled and operational![addmsg].", "boldwarning")
			return FALSE
		if(user.temporarilyRemoveItemFromInventory(F))
			attach_pack(F)
		return TRUE
	else if(istype(I, /obj/item/clothing/shoes/flightshoes))
		var/obj/item/clothing/shoes/flightshoes/S = I
		if(shoes)
			usermessage("There are already shoes installed!", "boldwarning")
			return FALSE
		if(user.temporarilyRemoveItemFromInventory(S))
			attach_shoes(S)
		return TRUE
	. = ..()

//FLIGHT HELMET----------------------------------------------------------------------------------------------------------------------------------------------------
/obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	name = "flight helmet"
	desc = "A sealed helmet attached to a flight suit for EVA usage scenarios. Its visor contains an information uplink HUD."
	icon_state = "flighthelmet"
	item_state = "flighthelmet"
	item_color = "flight"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	brightness_on = 7
	light_color = "#30ffff"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 10, "bomb" = 30, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100)
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_BASIC)
	var/zoom_range = 12
	var/zoom = FALSE
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/flightpack/zoom)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/equipped(mob/living/carbon/human/wearer, slot)
	..()
	for(var/hudtype in datahuds)
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		H.add_hud_to(wearer)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/dropped(mob/living/carbon/human/wearer)
	..()
	if(wearer)
		for(var/hudtype in datahuds)
			var/datum/atom_hud/H = GLOB.huds[hudtype]
			H.remove_hud_from(wearer)
		if(zoom)
			toggle_zoom(wearer, TRUE)

/obj/item/clothing/head/helmet/space/hardsuit/flightsuit/proc/toggle_zoom(mob/living/user, force_off = FALSE)
	if(zoom || force_off)
		user.client.change_view(CONFIG_GET(string/default_view))
		to_chat(user, "<span class='boldnotice'>Disabling smart zooming image enhancement...</span>")
		zoom = FALSE
		return FALSE
	else
		user.client.change_view(zoom_range)
		to_chat(user, "<span class='boldnotice'>Enabling smart zooming image enhancement!</span>")
		zoom = TRUE
		return TRUE
