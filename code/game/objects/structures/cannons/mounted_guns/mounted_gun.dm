//Mounted guns are basically a smaller equivalent to cannons, designed to use pre-existing ammo rather than cannonballs.
//Due to using pre-existing ammo, they dont require to be loaded with gunpowder or an equivalent.

/obj/structure/mounted_gun
	name = "Mounted Gun"
	desc = "Default mounted gun for inheritance purposes."
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/weapons/cannons.dmi'
	icon_state = "falconet_patina"
	base_icon_state = "falconet_patina"
	max_integrity = 300
	/// Suffix added to base icon state when firing
	var/fire_suffix = "_fire"
	///whether the cannon can be unwrenched from the ground. Anchorable_cannon equivalent.
	var/anchorable_gun = TRUE
	/// does this thing need ammo at all or does it just make ammo?
	var/uses_ammo = TRUE
	///Max shots per firing of the gun.
	var/max_shots_per_fire = 1
	///Delay it takes to load the gun. Set to 0 if none.
	var/load_delay = 0 SECONDS
	///Message displayed when loading gun
	var/loading_message = "gun loaded"
	///Shots currently loaded. Should never be more than max_shots_per_fire.
	var/shots_in_gun = 1
	///shots added to gun, per piece of ammo loaded.
	var/shots_per_load = 1
	///Accepted "ammo" type
	var/ammo_type = /obj/item/ammo_casing/strilka310
	///Projectile to fire
	var/projectile_type = /obj/projectile/bullet/strilka310
	///Delay in firing the gun after lighting
	var/fire_delay = 5 DECISECONDS
	///Delay between shots
	var/shot_delay = 3 DECISECONDS
	///If the gun shakes the camera when firing
	var/firing_shakes_camera = TRUE
	///sound of firing for all but last shot
	var/fire_sound = 'sound/items/weapons/gun/general/mountedgun.ogg'
	///sound of firing for last shot
	var/last_fire_sound = 'sound/items/weapons/gun/general/mountedgunend.ogg'
	///So you can't reload it mid-firing
	var/is_firing = FALSE
	/// How many degrees to vary fire angle if the gun is not anchored
	var/unanchored_variance = 20
	/// What items to spawn when destroyed
	var/list/debris = list(
		/obj/item/stack/sheet/iron = 4,
		/obj/item/stack/rods = 3,
		/obj/item/assembly/igniter = 1,
	)

/obj/structure/mounted_gun/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchorable_gun) /// Can't anchor an unanchorable gun.
		return FALSE
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

///Covers Reloading and lighting of the gun
/obj/structure/mounted_gun/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!uses_ammo || user.combat_mode || !istype(tool, ammo_type)) //see if the gun needs to be loaded in some way.
		return NONE

	if(is_firing)
		balloon_alert(user, "gun firing!")
		return ITEM_INTERACT_BLOCKING

	var/fully_loaded = shots_in_gun >= max_shots_per_fire
	if(fully_loaded)
		balloon_alert(user, "already loaded!")
		return ITEM_INTERACT_BLOCKING

	if (load_delay > 0)
		user.visible_message(span_warning("[user] starts loading [src]."))
		if(!do_after(user, load_delay, target = src))
			return ITEM_INTERACT_BLOCKING

	shots_in_gun = min(shots_in_gun + shots_per_load, max_shots_per_fire)
	balloon_alert(user, loading_message)
	QDEL_NULL(tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/mounted_gun/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (.)
		return
	if (is_firing)
		balloon_alert(user, "gun firing!")
		return
	try_firing(user)

/// Start firing the weapon on interaction
/obj/structure/mounted_gun/proc/try_firing(mob/living/user)
	user.log_message("fired \a [src]", LOG_ATTACK)
	addtimer(CALLBACK(src, PROC_REF(fire_sequence), user), fire_delay)

/// Loop firing until we are done
/obj/structure/mounted_gun/proc/fire_sequence(mob/living/user)
	if (!shots_in_gun)
		balloon_alert(user, "not loaded!")
		return

	is_firing = TRUE
	icon_state = base_icon_state + fire_suffix

	while (shots_in_gun > 0)
		shots_in_gun--
		fire_loop()
		sleep(shot_delay)

	shots_in_gun = 0
	is_firing = FALSE
	icon_state = base_icon_state

/obj/structure/mounted_gun/atom_deconstruct(disassembled = TRUE)
	. = ..()
	dump_contents()
	for (var/type in debris)
		for (var/i in 1 to debris[type])
			new type(drop_location())

/obj/structure/mounted_gun/dump_contents()
	return // Generally we don't have contents to dump but some children do.

/// Perform the contents of the loop
/obj/structure/mounted_gun/proc/fire_loop()
	for(var/mob/shaken_mob in urange(3, src))
		if(shaken_mob.stat == CONSCIOUS && firing_shakes_camera) //is the mob awake to feel the shaking?
			shake_camera(shaken_mob, 3, 1)
		icon_state = base_icon_state + fire_suffix
	playsound(src, shots_in_gun > 0 ? fire_sound : last_fire_sound, vol = 50, vary = FALSE, falloff_exponent = 5)
	fire_gun()

/// Actually finally shoot the thing
/obj/structure/mounted_gun/proc/fire_gun()
	var/obj/projectile/fired_projectile = get_fired_projectile()
	fired_projectile.firer = src
	fired_projectile.fired_from = src
	var/fire_angle = dir2angle(dir) + (!anchorable_gun || anchored ? 0 : rand(-unanchored_variance, unanchored_variance))
	fired_projectile.fire(fire_angle)
	return fired_projectile

/// What kind of ammo are we shooting
/obj/structure/mounted_gun/proc/get_fired_projectile()
	return new projectile_type(get_turf(src))

/// Rapidly fires a barrage of random junk ammo
/obj/structure/mounted_gun/organ_gun
	name = "Pipe Organ Gun"
	desc = "To become master over one who has killed, one must become a better killer. This engine of destruction is one of many things made to that end."
	icon_state = "pipeorgangun"
	base_icon_state = "pipeorgangun"
	anchored = FALSE
	max_shots_per_fire = 8
	shots_in_gun = 8
	shots_per_load = 2
	ammo_type = /obj/item/ammo_casing/junk
	projectile_type = /obj/projectile/bullet/junk
	fire_delay = 3 DECISECONDS
	shot_delay = 2 DECISECONDS
	firing_shakes_camera = FALSE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 24.5,
		/datum/material/wood = SHEET_MATERIAL_AMOUNT * 15,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT
	)
	debris = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/mineral/wood = 3,
		/obj/item/storage/toolbox = 1,
		/obj/item/stack/rods = 4,
		/obj/item/assembly/igniter = 1,
	)
	/// Different kinds of bullet we can fire
	var/static/list_of_projectiles = list(
		/obj/projectile/bullet/junk = 40,
		/obj/projectile/bullet/incendiary/fire/junk = 25,
		/obj/projectile/bullet/junk/shock = 25,
		/obj/projectile/bullet/junk/hunter = 20,
		/obj/projectile/bullet/junk/phasic = 8,
		/obj/projectile/bullet/junk/ripper = 8,
		/obj/projectile/bullet/junk/reaper = 3,
	)

/obj/structure/mounted_gun/organ_gun/examine_more(mob/user)
	. = ..()
	. += span_notice("<b><i>Looking down at \the [src], you recall a tale told to you in some distant memory...</i></b>")

	. += span_info("To commit an act of vengeance is not unlike to enter a blood pact with a devil, ending the life of another, at the cost of your own.")
	. += span_info("When humanity first spilled the blood of its own kind, with likely nothing more than a rock, the seal was broken. Vengeance was borne unto the world.")
	. += span_info("However, vengeance alone is not enough to carry through the grim deed of murder. One must gain an advantage over their adversary.")
	. += span_info("As such, the man who ended another's life with a stone, was in turn smote himself by another wielding a spear. After spears, bows. Swords. Guns. Tanks. Missiles. And on and on Vengeance fed. Growing stronger. Growing Worse.")
	. += span_info("Vengeance persists to this day. It sometimes may slumber, seemingly content with having gorged itself, but in the end, its ceaseless hunger can be neither numbed nor sated.")

/obj/structure/mounted_gun/organ_gun/get_fired_projectile()
	var/random_type = pick_weight(list_of_projectiles)
	return new random_type(get_turf(src))

/// Rapidly sprays a large amount of bullets, used by pirates
/obj/structure/mounted_gun/canister_gatling
	name = "Canister Gatling Gun"
	desc = "''Quantity has a quality of its own.''"
	icon_state = "canister_gatling"
	base_icon_state = "canister_gatling"
	anchored = FALSE
	max_shots_per_fire = 50
	shots_per_load = 50
	shots_in_gun = 50
	ammo_type = /obj/item/ammo_casing/canister_shot
	projectile_type = /obj/projectile/bullet/shrapnel
	fire_delay = 3 DECISECONDS
	shot_delay = 1 DECISECONDS
	firing_shakes_camera = FALSE
	debris = list(
		/obj/item/pipe = 1,
		/obj/item/stack/sheet/mineral/wood = 3,
		/obj/item/stack/rods = 4,
		/obj/item/assembly/igniter = 1,
	)

/obj/item/ammo_casing/canister_shot
	name = "Canister Shot"
	desc = "A gigantic... well, canister of canister shot. Used for reloading the Canister Gatling Gun."
	icon_state = "canister_shot"
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/projectile/bullet/shrapnel

/// Hand-cranked laser repeater which does not need to be reloaded
/obj/structure/mounted_gun/ratvarian_repeater
	name = "Ratvarian Repeater"
	desc = "''Brains? Bronze? Why not both?''"
	icon_state = "ratvarian_repeater"
	base_icon_state = "ratvarian_repeater"
	loading_message = "gun charged"
	anchored = FALSE
	uses_ammo = FALSE
	load_delay = 3 SECONDS
	max_shots_per_fire = 12
	shots_per_load = 12
	shots_in_gun = 12
	fire_sound = 'sound/items/weapons/thermalpistol.ogg'
	last_fire_sound = 'sound/items/weapons/thermalpistol.ogg'
	projectile_type = /obj/projectile/beam/laser/repeater
	fire_delay = 1
	shot_delay = 2
	firing_shakes_camera = FALSE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5.25,
		/datum/material/bronze = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.29
	)
	debris = list(
		/obj/item/stack/cable_coil = 4,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/shard = 2,
		/obj/item/stack/sheet/bronze = 2,
		/obj/item/stack/rods = 3,
	)

// Charge the gun instead of firing it if it's not loaded
/obj/structure/mounted_gun/ratvarian_repeater/try_firing(mob/user)
	var/fully_loaded = shots_in_gun >= max_shots_per_fire
	if(fully_loaded)
		return ..()

	if (load_delay > 0)
		user.visible_message(span_warning("[user] starts winding [src]."))
		if(!do_after(user, load_delay, target = src))
			return

	shots_in_gun = min(shots_in_gun + shots_per_load, max_shots_per_fire)
	playsound(src, 'sound/effects/magic/clockwork/fellowship_armory.ogg', 50, FALSE, 5)

/obj/structure/mounted_gun/ratvarian_repeater/fire_loop()
	. = ..()
	if(shots_in_gun % 2 != 1) // Extra delay every other shot for burst fire
		sleep(shot_delay)

/// A makeshift structure for firing spears with increased force
/obj/structure/mounted_gun/ballista
	name = "Improvised Ballista"
	desc = "''Engineers like to solve problems. If there are no problems handily available, they will create their own problems.''"
	icon_state = "improvised_ballista"
	base_icon_state = "improvised_ballista"
	throwforce = 30
	anchored = FALSE
	uses_ammo = TRUE
	load_delay = 6 SECONDS
	max_shots_per_fire = 1
	shots_per_load = 1
	shots_in_gun = 0
	fire_sound = 'sound/items/xbow_lock.ogg'
	last_fire_sound = 'sound/items/xbow_lock.ogg'
	ammo_type = /obj/item/spear
	projectile_type = /obj/projectile/bullet/ballista_spear
	fire_delay = 1
	shot_delay = 1
	firing_shakes_camera = FALSE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15.15,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.5
	)
	debris = list(
		/obj/item/stack/cable_coil = 3,
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 3,
	)
	/// Suffix added to base icon state when loaded
	var/loaded_suffix = "_loaded"
	/// What spear has someone put in us?
	var/obj/item/loaded_spear

/obj/structure/mounted_gun/ballista/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, ammo_type) || user.combat_mode)
		return NONE

	if(is_firing)
		balloon_alert(user, "gun firing!")
		return ITEM_INTERACT_BLOCKING

	if(loaded_spear)
		balloon_alert(user, "already loaded!")
		return ITEM_INTERACT_BLOCKING

	playsound(src, 'sound/items/weapons/draw_bow.ogg', 50, FALSE, 5)
	if (load_delay > 0)
		user.visible_message(span_warning("[user] starts loading [src]."))
		if (!do_after(user, load_delay, target = src))
			return ITEM_INTERACT_BLOCKING

	shots_in_gun = 1
	icon_state = base_icon_state + loaded_suffix

	loaded_spear = tool
	loaded_spear.forceMove(src)
	RegisterSignals(loaded_spear, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(on_spear_left))

	balloon_alert(user, loading_message)
	return ITEM_INTERACT_SUCCESS

/obj/structure/mounted_gun/ballista/get_fired_projectile()
	if (istype(loaded_spear, /obj/item/spear/dragonator))
		return new /obj/projectile/bullet/ballista_spear/dragonator(get_turf(src))
	return ..()

/obj/structure/mounted_gun/ballista/fire_gun()
	var/obj/projectile/bullet/ballista_spear/fired_projectile = . = ..()
	fired_projectile.attach_spear(loaded_spear)

/// Called when our spear is not inside us any more
/obj/structure/mounted_gun/ballista/proc/on_spear_left()
	SIGNAL_HANDLER
	UnregisterSignal(loaded_spear, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	icon_state = base_icon_state
	loaded_spear = null
	shots_in_gun = 0

/obj/structure/mounted_gun/ballista/dump_contents()
	. = ..()
	loaded_spear?.forceMove(drop_location())
