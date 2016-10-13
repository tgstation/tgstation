
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
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

	w_class = 4
	slot_flags = SLOT_BACK
	resistance_flags = FIRE_PROOF

	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/wearer = null
	var/slowdown_ground = 1
	var/slowdown_air = 0
	var/slowdown_brake = 1
	var/flight = 0
	var/flight_passflags = PASSTABLE
	var/powersetting = 2
	var/powersetting_high = 3
	var/powersetting_low = 1
	var/override_safe = 0

	var/boost = 0
	var/boost_maxcharge = 50	//Vroom! If you hit someone while boosting they'll likely be knocked flying. Fun.
	var/boost_charge = 50
	var/boost_speed = 2
	var/boost_power = 50
	var/boost_chargerate = 0.5
	var/boost_drain = 5			//Keep in mind it charges and drains at the same time, so drain realistically is drain-charge=change

	var/momentum_x = 0		//Realistic physics. No more "Instant stopping while barreling down a hallway at Mach 1".
	var/momentum_y = 0
	var/momentum_max = 250
	var/momentum_impact_coeff = 0.4	//At this speed you'll start coliding with people resulting in momentum loss and them being knocked back, but no injuries or knockdowns
	var/momentum_impact_loss = 50
	var/momentum_crash_coeff = 0.8	//At this speed if you hit a dense object, you will careen out of control, while that object will be knocked flying.
	var/momentum_speed = 0	//How fast we are drifting around
	var/momentum_drift_tick = 0 //Cooldowns
	var/momentum_passive_loss = 2
	var/momentum_gain = 20

	var/stabilizer = 1
	var/stabilizer_decay_amount = 20
	var/gravity = 1
	var/gravity_decay_amount = 4
	var/pressure = 1
	var/pressure_decay_amount = 4
	var/pressure_threshold = 30
	var/brake = 0
	var/airbrake_decay_amount = 30

	var/resync = 0	//Used to resync the flight-suit every 30 seconds or so.

	var/disabled = 0	//Whether it is disabled from crashes/emps/whatever
	var/crash_disable_message = 0	//To not spam the user with messages
	var/emp_disable_message = 0

	//This is probably too much code just for EMP damage.
	var/emp_damage = 0	//One hit should make it hard to control, continuous hits will cripple it and then simply shut it off/make it crash. Direct hits count more.
	var/emp_strong_damage = 1.5
	var/emp_weak_damage = 1
	var/emp_heal_amount = 0.1		//How much emp damage to heal per process.
	var/emp_disable_threshold = 3	//3 weak ion, 2 strong ion hits.
	var/emp_disabled = 0

	var/crash_damage = 0	//Same thing, but for crashes. This is in addition to possible amounts of brute damage to the wearer.
	var/crash_damage_low = 1
	var/crash_damage_high = 2.5
	var/crash_disable_threshold = 5
	var/crash_heal_amount = 0.2
	var/crash_disabled = 0

	var/datum/effect_system/trail_follow/ion/ion_trail

//Start/Stop processing the item to use momentum and flight mechanics.
/obj/item/device/flightpack/New()
	START_PROCESSING(SSfastprocess, src)
	..()
	ion_trail = new
	ion_trail.set_up(src)

/obj/item/device/flightpack/Destroy()
	if(suit)
		suit.pack = null
	if(shoes)
		shoes.pack = null
	STOP_PROCESSING(SSfastprocess, src)
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

//ACTION BUTTON CODE
/obj/item/device/flightpack/ui_action_click(owner, action)
	if(wearer != owner)
		wearer = owner
	if(action == /datum/action/item_action/flightpack/toggle_flight)
		if(!flight)
			enable_flight()
		else
			disable_flight()
	if(action == /datum/action/item_action/flightpack/engage_boosters)
		if(!boost)
			activate_booster()
		else
			deactivate_booster()
	if(action == /datum/action/item_action/flightpack/toggle_stabilizers)
		if(!stabilizer)
			enable_stabilizers()
		else
			disable_stabilizers()
	if(action == /datum/action/item_action/flightpack/change_power)
		cycle_power()
	if(action == /datum/action/item_action/flightpack/toggle_airbrake)
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
	switch(dir)
		if(NORTH)
			adjust_momentum(0, momentum_increment)
		if(SOUTH)
			adjust_momentum(0, -momentum_increment)
		if(EAST)
			adjust_momentum(momentum_increment, 0)
		if(WEST)
			adjust_momentum(-momentum_increment, 0)
	world << "MOMENTUM: [momentum_x] [momentum_y] MOMENTUM SPEED : [momentum_speed] MOMENTUM TICK : [momentum_drift_tick]"

//The wearer has momentum left. Move them and take some away, while negating the momentum that moving the wearer would gain. Or force the wearer to lose control if they are incapacitated.
/obj/item/device/flightpack/proc/momentum_drift()
	if(!flight)
		return 0
	var/drift_x = 0
	var/drift_dir_x = 0
	var/drift_y = 0
	var/drift_dir_y = 0
	if(momentum_x > 0)
		drift_x = 1
		drift_dir_x = EAST
	if(momentum_x < 0)
		drift_x = 1
		drift_dir_x = WEST
	if(momentum_y > 0)
		drift_y = 1
		drift_dir_y = NORTH
	if(momentum_y < 0)
		drift_y = 1
		drift_dir_y = SOUTH
	if(momentum_speed == 0)
		return 0
	if(suit)
		if(suit.user)
			if(suit.user.canmove)
				if(momentum_speed == 3)
					if(drift_x)
						step(suit.user, drift_dir_x)
					if(drift_y)
						step(suit.user, drift_dir_y)
				else if(momentum_speed == 2)
					if(drift_x)
						step(suit.user, drift_dir_x)
					if(drift_y)
						step(suit.user, drift_dir_y)
				else if(momentum_speed == 1)
					if(drift_x)
						step(suit.user, drift_dir_x)
					if(drift_y)
						step(suit.user, drift_dir_y)
			else
				losecontrol()
			momentum_decay()
	momentum_drift_tick = 0

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
	if(!resync)
		addtimer(src, "resync", 600)
		resync = 1
	if(!suit)
		disable_flight(1)
		wearer << "<span class='wearerdanger'>Your flight pack shuts off. Somehow your flight suit was unlinked from the control mechanisms!</span>"
	if(!shoes)
		disable_flight(1)
		wearer << "<span class='wearerdanger'>Your flight pack shuts off. Somehow your flight shoes were unlinked from the control mechanisms!</span>"
	if(!wearer)	//Oh god our user fell off!
		disable_flight(1)
	//Add check for wearer wearing the shoes and suit here
	if(suit)
		if(suit.user)
			if(suit.user.has_gravity())
				gravity = 1
			else
				gravity = 0
			var/turf/T = get_turf(suit.user)
			var/datum/gas_mixture/gas = T.return_air()
			var/envpressure =	gas.return_pressure()
			if(envpressure >= pressure_threshold)
				pressure = 1
			else
				pressure = 0

//Resync the suit
/obj/item/device/flightpack/proc/resync()
	resync = 0
	suit.resync()

//How fast should the wearer be?
/obj/item/device/flightpack/proc/update_slowdown()
	if(!flight)
		suit.slowdown = slowdown_ground
		return
	if(brake)
		suit.slowdown = slowdown_brake
	else if(boost)
		suit.slowdown = -boost_speed
	else
		suit.slowdown = slowdown_air

/obj/item/device/flightpack/process()
	check_conditions()
	handle_flight()
	update_slowdown()
	calculate_momentum_speed()
	momentum_drift_tick++
	momentum_drift()
	handle_boost()
	handle_damage()
	update_icon()

/obj/item/device/flightpack/proc/handle_damage()
	if(crash_damage)
		crash_damage = Clamp(crash_damage-crash_heal_amount, 0, crash_disable_threshold*10)
		if(crash_damage >= crash_disable_threshold)
			crash_disabled = 1
		if(crash_disabled && (crash_damage <= 1))
			crash_disabled = 0
			crash_disable_message = 0
			wearer << "<span class='notice'>Flightpack: Stabilizers re-calibrated. Flightpack re-enabled.</span>"
	if(emp_damage)
		emp_damage = Clamp(emp_damage-emp_heal_amount, 0, emp_disable_threshold * 10)
		if(emp_damage >= emp_disable_threshold)
			emp_disabled = 1
		if(emp_disabled && (emp_damage <= 0.5))
			emp_disabled = 0
			wearer << "<span class='notice'>Flightpack: Systems rebooted. Flightpack re-enabled.</span>"
	disabled = crash_disabled + emp_disabled
	if(disabled)
		if(crash_disabled && (!crash_disable_message))
			wearer << "<span class='userdanger'>Flightpack: WARNING: STABILIZERS DAMAGED. UNABLE TO CONTINUE OPERATION. PLEASE WAIT FOR AUTOMATIC RECALIBRATION.</span>"
			wearer << "<span class='warning'>Your flightpack abruptly shuts off!</span>"
			crash_disable_message = 1
		if(emp_disabled)
			wearer << "<span class='userdanger'>Flightpack: WARNING: POWER SURGE DETECTED FROM INTERNAL SHORT CIRCUIT. PLEASE WAIT FOR AUTOMATIC REBOOT.</span>"
			wearer << "<span class='warning'>Your flightpack abruptly shuts off!</span>"
			emp_disable_message = 1
		if(flight)
			disable_flight(1)

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
	wearer.update_inv_wear_suit()
	..()

/obj/item/device/flightpack/proc/handle_flight()
	if(!flight)
		return 0
	wearer.float(2)

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
	if(suit)
		if(suit.user)
			wearer << "<span class='notice'>FLIGHTPACK: Engines set to force [momentum_gain].</span>"


/obj/item/device/flightpack/proc/losecontrol()
	wearer.visible_message("<span class='warning'>[wearer]'s flight suit careens wildly as they lose control of it!</span>")
	if(wearer)
		while(momentum_x != 0 || momentum_y != 0)
			spawn(2)
			step(wearer, pick(cardinal))
			momentum_decay()
			adjust_momentum(0, 0, 10)
		wearer.visible_message("<span class='warning'>[wearer]'s flight suit crashes into the ground and shuts off!</span>")
	momentum_x = 0
	momentum_y = 0
	if(flight)
		disable_flight()

/obj/item/device/flightpack/proc/enable_flight(forced = 0)
	wearer.dna.species.specflags |= FLYING
	wearer.pass_flags |= flight_passflags
	wearer.visible_message("<font color='blue' size='2'>[wearer]'s flight engines activate as they lift into the air!</font>")
	//I DONT HAVE SOUND EFFECTS YET playsound(
	flight = 1
	shoes.toggle(1)
	update_icon()
	ion_trail.start()

/obj/item/device/flightpack/proc/disable_flight(forced = 0)
	if(forced)
		losecontrol()
		return 1
	if(abs(momentum_x) <= 20 && abs(momentum_y) <= 20)
		momentum_x = 0
		momentum_y = 0
		suit.user.visible_message("<font color='blue' size='2'>[wearer] drops to the ground as their flight engines cut out!</font>")
		//NO SOUND YET	playsound(
		ion_trail.stop()
		wearer.dna.species.specflags |= FLYING
		wearer.pass_flags &= ~flight_passflags
		flight = 0
		shoes.toggle(0)
	else
		if(override_safe)
			disable_flight(1)
			return 1
		wearer << "<span class='warning'>You are moving too fast to safely stop flying! Try to stop flying once more to override the safety restrictions.</span>"
		override_safe = 1
		addtimer(src, "enable_safe", 50)
		return 0
	update_icon()

/obj/item/device/flightpack/proc/enable_safe()
	if(override_safe)
		override_safe = 0

/obj/item/device/flightpack/dropped(mob/wearer)
	..()

/obj/item/device/flightpack/item_action_slot_check(slot)
	if(slot == SLOT_BACK)
		return 1

/obj/item/device/flightpack/equipped(mob/wearer, slot)
	..()

/obj/item/device/flightpack/proc/calculate_momentum_speed()
	if(momentum_x == 0 && momentum_y == 0)
		momentum_speed = 0
	else if((abs(momentum_x) >= (momentum_crash_coeff*momentum_max))||(abs(momentum_y) >= (momentum_crash_coeff*momentum_max)))
		momentum_speed = 3
	else if((abs(momentum_x) >= (momentum_impact_coeff*momentum_max))||(abs(momentum_y) >= (momentum_impact_coeff*momentum_max)))
		momentum_speed = 2
	else if((momentum_x != 0)||(momentum_y != 0))
		momentum_speed = 1

/obj/item/device/flightpack/item_action_slot_check(slot)
	if(slot == slot_back)
		return 1

/obj/item/device/flightpack/proc/enable_stabilizers()
	wearer << "<span class='notice'>Your [name]'s integrated stabilizer system restarts as fins fold out and thrusters steady your movement!</span>"
	stabilizer = 1

/obj/item/device/flightpack/proc/disable_stabilizers()
	if(wearer)
		if(brake)
			disable_airbrake()
		wearer << "<span class='warning'>Your [name]'s stabilizers cut off, fins folding in and maneuvering thrusters shutting off!</span>"
	stabilizer = 0

/obj/item/device/flightpack/proc/activate_booster()
	if(boost_charge < 5)
		wearer << "<span class='warning'>Your [name] beeps an alert. Its boost capacitors are still charging!</span>"
		return 0
	wearer << "<span class='notice'>Flightpack: Boosters engaged!</span>"
	wearer.visible_message("<span class='notice'>[wearer.name]'s flightpack engines flare in intensity as they are rocketed forward by the immense thrust!</span>")
	boost = 1

/obj/item/device/flightpack/proc/deactivate_booster()
	wearer << "<span class='warning'>Flightpack: Boosters disengaged!</span>"
	boost = 0

/obj/item/device/flightpack/proc/enable_airbrake()
	if(wearer)
		if(!stabilizer)
			enable_stabilizers()
		wearer << "<span class='notice'>You enable your suit's airbrakes, slowing you down to a slow cruise.</span>"
	brake = 1

/obj/item/device/flightpack/proc/disable_airbrake()
	if(wearer)
		wearer << "<span class='notice'>You disable your suit's airbrakes, speeding up back to normal.</span>"
	brake = 0

/obj/item/device/flightpack/on_mob_move(dir, mob)
	wearer_movement(dir)

//MOB MOVEMENT STUFF----------------------------------------------------------------------------------------------------------------------------------------------

/mob/proc/get_flightpack()
	return

/mob/living/carbon/get_flightpack()
	var/obj/item/device/flightpack/F = back
	if(istype(F))
		return F

/obj/item/device/flightpack/proc/allow_thrust()
	return 1

//FLIGHT SHOES FOR MOVEMENT DETECTION------------------------------------------------------------------------------------------------------------------------------

/obj/item/clothing/shoes/flightshoes
	name = "flight shoes"
	desc = "A pair of specialized boots that contain stabilizers and sensors nessacary for flight gear to work" //Apparently you need these to detect mob movement.
	icon_state = "flightshoes"
	item_state = "flightshoes_mob"
	var/obj/item/clothing/suit/space/hardsuit/flightsuit/suit = null
	var/obj/item/device/flightpack/pack = null
	var/mob/living/carbon/human/wearer = null
	var/active = 0
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/flightshoes/Destroy()
	if(suit)
		suit.shoes = null
	if(pack)
		pack.shoes = null

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
		return 1

/obj/item/clothing/shoes/flightshoes/equipped(mob/wearer, slot)
	..()


//FLIGHT SUIT------------------------------------------------------------------------------------------------------------------------------------------------------
//Flight pack and flight shoes/helmet are stored in here. This has to be locked to someone to use either. For both balance reasons and practical codewise reasons.

/obj/item/clothing/suit/space/hardsuit/flightsuit
	name = "flight suit"
	desc = "An advanced suit that allows the wearer flight via two high powered miniature jet engines on a deployable back-mounted unit."
	icon_state = "flightsuit"
	item_state = "flightsuit"
	strip_delay = 30
	var/locked_strip_delay = 80
	w_class = 4
	var/obj/item/device/flightpack/pack = null
	var/obj/item/clothing/shoes/flightshoes/shoes = null
	var/mob/living/carbon/human/user = null
	var/deployedpack = 0
	var/deployedshoes = 0
	var/locked = 0
	resistance_flags = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	jetpack = null
	var/flightpack
	var/flight = 0
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals, /obj/item/weapon/gun,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	actions_types = list(/datum/action/item_action/flightsuit/toggle_helmet,/datum/action/item_action/flightsuit/toggle_boots,/datum/action/item_action/flightsuit/toggle_flightpack,/datum/action/item_action/flightsuit/lock_suit)
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

/obj/item/clothing/suit/space/hardsuit/flightsuit/New()
	..()
	makepack()
	makeshoes()
	resync()

/obj/item/clothing/suit/space/hardsuit/flightsuit/Destroy()
	dropped()
	if(pack)
		pack.shoes = null
		pack.suit = null
		qdel(pack)
	if(shoes)
		shoes.pack = null
		shoes.suit = null
		qdel(shoes)
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/resync()
	if(user)
		pack.wearer = user
		shoes.wearer = user
	shoes.pack = pack
	pack.shoes = shoes
	pack.suit = src
	shoes.suit = src

/obj/item/clothing/suit/space/hardsuit/flightsuit/ui_action_click(owner, action)
	if(action == /datum/action/item_action/flightsuit/lock_suit)
		if(!locked)
			lock_suit(owner)
		else
			unlock_suit(owner)
	if(action == /datum/action/item_action/flightsuit/toggle_flightpack)
		if(!deployedpack)
			extend_flightpack()
		else
			retract_flightpack()
	if(action == /datum/action/item_action/flightsuit/toggle_boots)
		if(!deployedshoes)
			extend_flightshoes()
		else
			retract_flightshoes()
	if(action == /datum/action/item_action/flightsuit/toggle_helmet)
		ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/flightsuit/dropped()
	if(deployedpack)
		retract_flightpack(1)
	if(deployedshoes)
		retract_flightshoes(1)
	if(locked)
		unlock_suit(user)
	if(user)
		user = null
	..()

/obj/item/clothing/suit/space/hardsuit/flightsuit/ToggleHelmet()
	if(!suittoggled)
		if(!locked)
			user << "<span class='warning'>You must lock your suit before engaging the helmet!</span>"

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/lock_suit(mob/wearer)
	user = src.loc
	user = wearer
	user.visible_message("<span class='notice'>[wearer]'s flight suit locks around them, powered buckles and straps automatically adjusting to their body!</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	resync()
	strip_delay = locked_strip_delay
	locked = 1
	return 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/unlock_suit(mob/wearer)
	if(suittoggled)
		user << "<span class='warning'>You must retract the helmet before unlocking your suit!</span>"
		return 0
	if(pack.flight)
		user << "<span class='warning'>You must shut off the flight-pack before unlocking your suit!</span>"
		return 0
	if(deployedpack)
		user << "<span class='warning'>Your flightpack must be fully retracted first!</span>"
		return 0
	if(deployedshoes)
		user << "<span class='warning'>Your flight shoes must be fully retracted first!</span>"
		return 0
	user.visible_message("<span class='notice'>[wearer]'s flight suit detaches from their body, becoming nothing more then a bulky metal skeleton.</span>")
	playsound(src.loc, 'sound/items/rped.ogg', 65, 1)
	user = null
	resync()
	strip_delay = initial(strip_delay)
	locked = 0
	return 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightpack(forced = 0)
	if(deployedpack)
		retract_flightpack()
	if(!locked)
		user << "<span class='warning'>You must lock your flight suit first before deploying anything!</span>"
		return 0
	if(!pack)
		makepack()
	if(ishuman(user))
		if(user.back)
			user << "<span class='warning'>You're already wearing something on your back!</span>"
			return 0
		user.equip_to_slot_if_possible(pack,slot_back,0,0,1)
		pack.flags |= NODROP
		resync()
		user.visible_message("<span class='notice'>A [pack.name] extends from [user]'s [name] and clamps to their back!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightpack(forced = 0)
	if(ishuman(user))
		if(pack.flight && !forced)
			user << "<span class='warning'>You must disable the engines before retracting the flightpack!</span>"
			return 0
		if(pack.flight && forced)
			pack.disable_flight(1)
		pack.flags &= ~NODROP
		user.unEquip(pack, 1)
		user.update_inv_wear_suit()
		resync()
		user.visible_message("<span class='notice'>[user]'s [pack.name] detaches from their back and retracts into their [src]!</span>")
	else
		world << "DEBUG: USER NOT HUMAN"
	pack.loc = src
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedpack = 0

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/extend_flightshoes(forced = 0)
	if(deployedshoes)
		retract_flightshoes()
	if(!locked)
		user << "<span class='warning'>You must lock your flight suit first before deploying anything!</span>"
		return 0
	if(!shoes)
		makeshoes()
	if(ishuman(user))
		if(user.shoes)
			user << "<span class='warning'>You're already wearing something on your feet!</span>"
			return 0
		user.equip_to_slot_if_possible(shoes,slot_shoes,0,0,1)
		shoes.flags |= NODROP
		user.visible_message("<span class='notice'>[user]'s [name] extends a pair of [shoes.name] over their feet!</span>")
		user.update_inv_wear_suit()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = 1

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/retract_flightshoes(forced = 0)
	if(pack.flight && !forced)
		user << "<span class='warning'>You can not take off your flight shoes without shutting off the engines first!</span>"
		return 0
	if(pack.flight && forced)
		pack.disable_flight(1)
	shoes.flags &= ~NODROP
	user.unEquip(shoes, 1)
	shoes.loc = src
	user.visible_message("<span class='notice'>[user]'s [shoes.name] retracts back into their [name]!</span>")
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	deployedshoes = 0
	user.update_inv_wear_suit()

/obj/item/clothing/suit/space/hardsuit/flightsuit/proc/makepack()
	if(!pack)
		pack = new /obj/item/device/flightpack(src)
		pack.suit = src
		pack.shoes = shoes

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
			retract_flightpack(1)
		if(deployedshoes)
			retract_flightshoes(1)
		if(locked)
			unlock_suit(user)
	..()


/obj/item/clothing/suit/space/hardsuit/flightsuit/attackby(obj/item/I, mob/wearer, params)
	return


//FLIGHT HELMET----------------------------------------------------------------------------------------------------------------------------------------------------
/obj/item/clothing/head/helmet/space/hardsuit/flightsuit
	name = "flight helmet"
	desc = "A sealed helmet attached to a flight suit for EVA usage scenerios."
	icon_state = "flighthelmet"
	item_state = "flighthelmet"
	item_color = "flight"
	resistance_flags = FIRE_PROOF
	brightness_on = 7
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 10, bomb = 30, bio = 100, rad = 75, fire = 50, acid = 100)

//ITEM ACTIONS------------------------------------------------------------------------------------------------------------------------------------------------------
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
