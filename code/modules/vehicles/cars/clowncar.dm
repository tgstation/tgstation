/obj/vehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is byond me."
	icon_state = "clowncar"
	max_integrity = 150
	armor = list(MELEE = 70, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 30, BIO = 0, FIRE = 80, ACID = 80)
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	car_traits = CAN_KIDNAP
	key_type = /obj/item/bikehorn
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 8
	light_power = 2
	light_on = FALSE
	///list of headlight colors we use to pick through when we have party mode due to emag
	var/headlight_colors = list(COLOR_RED, COLOR_ORANGE, COLOR_YELLOW, COLOR_LIME, COLOR_BRIGHT_BLUE, COLOR_CYAN, COLOR_PURPLE)
	///Cooldown time inbetween [/obj/vehicle/sealed/car/clowncar/proc/roll_the_dice()] usages
	var/dice_cooldown_time = 150
	///How many times kidnappers in the clown car said thanks
	var/thankscount = 0
	///Current status of the cannon, alternates between CLOWN_CANNON_INACTIVE, CLOWN_CANNON_BUSY and CLOWN_CANNON_READY
	var/cannonmode = CLOWN_CANNON_INACTIVE

/obj/vehicle/sealed/car/clowncar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj,src)

/obj/vehicle/sealed/car/clowncar/process()
	if(light_on && (obj_flags & EMAGGED))
		set_light_color(pick(headlight_colors))

/obj/vehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/headlights, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/thank, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(is_clown_job(H.mind?.assigned_role)) //Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE)
			RegisterSignal(H, COMSIG_MOB_CLICKON, .proc/fire_cannon_at)
			M.log_message("has entered [src] as a possible driver", LOG_ATTACK)
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/mob_forced_enter(mob/M, silent = FALSE)
	. = ..()
	playsound(src, pick('sound/vehicles/clowncar_load1.ogg', 'sound/vehicles/clowncar_load2.ogg'), 75)
	if(iscarbon(M))
		var/mob/living/carbon/forced_mob = M
		if(forced_mob.has_reagent(/datum/reagent/consumable/ethanol/irishcarbomb))
			var/reagent_amount = forced_mob.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/irishcarbomb)
			forced_mob.reagents.del_reagent(/datum/reagent/consumable/ethanol/irishcarbomb)
			if(reagent_amount >= 30)
				message_admins("[ADMIN_LOOKUPFLW(forced_mob)] was forced into a clown car with [reagent_amount] unit(s) of Irish Car Bomb, causing an explosion.")
				forced_mob.log_message("was forced into a clown car with [reagent_amount] unit(s) of Irish Car Bomb, causing an explosion.", LOG_GAME)
				audible_message(span_userdanger("You hear a rattling sound coming from the engine. That can't be good..."), null, 1)
				addtimer(CALLBACK(src, .proc/irish_car_bomb), 5 SECONDS)

/obj/vehicle/sealed/car/clowncar/proc/irish_car_bomb()
	dump_mobs()
	explosion(src, light_impact_range = 1)

/obj/vehicle/sealed/car/clowncar/after_add_occupant(mob/M, control_flags)
	. = ..()
	if(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len >= 30)
		for(var/mob/voreman as anything in return_drivers())
			voreman.client.give_award(/datum/award/achievement/misc/round_and_full, voreman)

/obj/vehicle/sealed/car/clowncar/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if((user.loc != src) || user.environment_smash & (ENVIRONMENT_SMASH_WALLS|ENVIRONMENT_SMASH_RWALLS))
		return ..()

/obj/vehicle/sealed/car/clowncar/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_CLICKON)

/obj/vehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(prob(33))
		visible_message(span_danger("[src] spews out a ton of space lube!"))
		new /obj/effect/particle_effect/foam(loc) //YEET

/obj/vehicle/sealed/car/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!istype(I, /obj/item/food/grown/banana))
		return
	var/obj/item/food/grown/banana/banana = I
	atom_integrity += min(banana.seed.potency, max_integrity-atom_integrity)
	to_chat(user, span_danger("You use the [banana] to repair the [src]!"))
	qdel(banana)

/obj/vehicle/sealed/car/clowncar/Bump(atom/bumped)
	. = ..()
	if(isliving(bumped))
		if(ismegafauna(bumped))
			return
		var/mob/living/hittarget_living = bumped
		if(iscarbon(hittarget_living))
			var/mob/living/carbon/carb = hittarget_living
			carb.Paralyze(40) //I play to make sprites go horizontal
		hittarget_living.visible_message(span_warning("[src] rams into [hittarget_living] and sucks [hittarget_living.p_them()] up!")) //fuck off shezza this isn't ERP.
		mob_forced_enter(hittarget_living)
		playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
		log_combat(src, hittarget_living, "sucked up")
		return
	if(!istype(bumped, /turf/closed))
		return
	visible_message(span_warning("[src] rams into [bumped] and crashes!"))
	playsound(src, pick('sound/vehicles/clowncar_crash1.ogg', 'sound/vehicles/clowncar_crash2.ogg'), 75)
	playsound(src, 'sound/vehicles/clowncar_crashpins.ogg', 75)
	dump_mobs(TRUE)
	log_combat(src, bumped, "crashed into", null, "dumping all passengers")

/obj/vehicle/sealed/car/clowncar/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, span_danger("You scramble \the [src]'s child safety lock, and a panel with six colorful buttons appears!"))
	initialize_controller_action_type(/datum/action/vehicle/sealed/roll_the_dice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/cannon, VEHICLE_CONTROL_DRIVE)
	AddElement(/datum/element/waddling)

/obj/vehicle/sealed/car/clowncar/atom_destruction(damage_flag)
	playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
	STOP_PROCESSING(SSobj,src)
	return ..()

/**
 * Plays a random funky effect
 * Only available while car is emagged
 * Possible effects:
 * * Spawn bananapeel
 * * Spawn random reagent foam
 * * Make the clown car look like a singulo temporarily
 * * Spawn Laughing chem gas
 * * Drop oil
 * * Fart and make everyone nearby laugh
 */
/obj/vehicle/sealed/car/clowncar/proc/roll_the_dice(mob/user)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CLOWNCAR_RANDOMNESS))
		to_chat(user, span_notice("The button panel is currently recharging."))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_CLOWNCAR_RANDOMNESS, dice_cooldown_time)
	switch(rand(1,6))
		if(1)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and a special banana peel drops out of it."))
			new /obj/item/grown/bananapeel/specialpeel(loc)
		if(2)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and unknown chemicals flood out of it."))
			var/datum/reagents/randomchems = new/datum/reagents(300)
			randomchems.my_atom = src
			randomchems.add_reagent(get_random_reagent_id(), 100)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, loc, randomchems)
			foam.start()
		if(3)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car turns on its singularity disguise system."))
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			addtimer(CALLBACK(src, .proc/reset_icon), 10 SECONDS)
		if(4)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car spews out a cloud of laughing gas."))
			var/datum/reagents/funnychems = new/datum/reagents(300)
			funnychems.my_atom = src
			funnychems.add_reagent(/datum/reagent/consumable/superlaughter, 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new()
			smoke.set_up(funnychems, 4)
			smoke.attach(src)
			smoke.start()
		if(5)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car starts dropping an oil trail."))
			RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/cover_in_oil)
			addtimer(CALLBACK(src, .proc/stop_dropping_oil), 3 SECONDS)
		if(6)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car lets out a comedic toot."))
			playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
			for(var/mob/living/L in orange(loc, 6))
				L.emote("laughs")
			for(var/mob/living/L as anything in occupants)
				L.emote("laughs")

///resets the icon and iconstate of the clowncar after it was set to singulo states
/obj/vehicle/sealed/car/clowncar/proc/reset_icon()
	icon = initial(icon)
	icon_state = initial(icon_state)

///Deploys oil when the clowncar moves in oil deploy mode
/obj/vehicle/sealed/car/clowncar/proc/cover_in_oil()
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/oil/slippery(loc)

///Stops dropping oil after the time has run up
/obj/vehicle/sealed/car/clowncar/proc/stop_dropping_oil()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

///Toggles the on and off state of the clown cannon that shoots random kidnapped people
/obj/vehicle/sealed/car/clowncar/proc/toggle_cannon(mob/user)
	if(cannonmode == CLOWN_CANNON_BUSY)
		to_chat(user, span_notice("Please wait for the vehicle to finish its current action first."))
		return
	if(cannonmode) //canon active, deactivate
		flick("clowncar_fromfire", src)
		icon_state = "clowncar"
		addtimer(CALLBACK(src, .proc/deactivate_cannon), 2 SECONDS)
		playsound(src, 'sound/vehicles/clowncar_cannonmode2.ogg', 75)
		visible_message(span_danger("The [src] starts going back into mobile mode."))
	else
		canmove = FALSE //anchor and activate canon
		flick("clowncar_tofire", src)
		icon_state = "clowncar_fire"
		visible_message(span_danger("The [src] opens up and reveals a large cannon."))
		addtimer(CALLBACK(src, .proc/activate_cannon), 2 SECONDS)
		playsound(src, 'sound/vehicles/clowncar_cannonmode1.ogg', 75)
	cannonmode = CLOWN_CANNON_BUSY

///Finalizes canon activation
/obj/vehicle/sealed/car/clowncar/proc/activate_cannon()
	mouse_pointer = 'icons/effects/mouse_pointers/mecha_mouse.dmi'
	cannonmode = CLOWN_CANNON_READY
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.update_mouse_pointer()

///Finalizes canon deactivation
/obj/vehicle/sealed/car/clowncar/proc/deactivate_cannon()
	canmove = TRUE
	mouse_pointer = null
	cannonmode = CLOWN_CANNON_INACTIVE
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.update_mouse_pointer()

///Fires the cannon where the user clicks
/obj/vehicle/sealed/car/clowncar/proc/fire_cannon_at(mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(cannonmode != CLOWN_CANNON_READY || !length(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED)))
		return
	//The driver can still examine things and interact with his inventory.
	if(modifiers[SHIFT_CLICK] || (ismovable(target) && !isturf(target.loc)))
		return
	var/mob/living/unlucky_sod = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
	mob_exit(unlucky_sod, TRUE)
	flick("clowncar_recoil", src)
	playsound(src, pick('sound/vehicles/carcannon1.ogg', 'sound/vehicles/carcannon2.ogg', 'sound/vehicles/carcannon3.ogg'), 75)
	unlucky_sod.throw_at(target, 10, 2)
	log_combat(user, unlucky_sod, "fired", src, "towards [target]") //this doesn't catch if the mob hits something between the car and the target
	return COMSIG_MOB_CANCEL_CLICKON

///Increments the thanks counter every time someone thats been kidnapped thanks the driver
/obj/vehicle/sealed/car/clowncar/proc/increment_thanks_counter()
	thankscount++
	if(thankscount < 100)
		return
	for(var/mob/busdriver as anything in return_drivers())
		busdriver.client.give_award(/datum/award/achievement/misc/the_best_driver, busdriver)
