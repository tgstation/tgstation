//Mounted guns are basically a smaller equivalent to cannons, designed to use pre-existing ammo rather than cannonballs.
//Due to using pre-existing ammo, they dont require to be loaded with gunpowder or an equivalent.

/obj/structure/mounted_gun
	name = "Mounted Gun"
	desc = "Default mounted gun for inheritance purposes."
	density = TRUE
	anchored = FALSE
	icon = 'icons/obj/weapons/cannons.dmi'
	icon_state = "falconet_patina"
	var/icon_state_base = "falconet_patina"
	var/icon_state_loaded = "falconet_patina"
	var/icon_state_fire = "falconet_patina_fire"
	max_integrity = 300
	///whether the cannon can be unwrenched from the ground. Anchorable_cannon equivalent.
	var/anchorable_gun = TRUE
	/// does this thing need ammo at all or does it just make ammo?
	var/uses_ammo = TRUE
	///Max shots per firing of the gun.
	var/max_shots_per_fire = 1
	///Delay it takes to load the gun. Set to 0 if none.
	var/load_delay = 0
	///Message displayed when loading gun
	var/loading_message = "gun loaded"
	///Shots currently loaded. Should never be more than max_shots_per_fire.
	var/shots_in_gun = 1
	///shots added to gun, per piece of ammo loaded.
	var/shots_per_load = 1
	///Does it have an alternative ammo type it can uses
	var/has_alt_ammo = FALSE
	//Is it loaded with said alternative ammo?
	var/use_alt_ammo = FALSE
	///Accepted "ammo" type
	var/obj/item/ammo_type = /obj/item/ammo_casing/strilka310
	///Alternative ammo types, for extra effects!
	var/obj/item/alt_ammo_type = /obj/item/ammo_casing/strilka310
	///Projectile from said gun. Doesnt automatically inherit said ammo's projectile in case you wanted to make a gun that shoots floor tiles or something.
	var/obj/projectile/projectile_type = /obj/projectile/bullet/strilka310
	///Projectile from said gun. Doesnt automatically inherit said ammo's projectile in case you wanted to make a gun that shoots floor tiles or something.
	var/obj/projectile/alt_projectile_type = /obj/projectile/bullet/strilka310
	///If the gun has anything in it.
	var/loaded_gun = TRUE
	///If the gun is currently loaded with its maximum capacity.
	var/fully_loaded_gun = TRUE
	///delay in firing the gun after lighting
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

/obj/structure/mounted_gun/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchorable_gun) /// Can't anchor an unanchorable gun.
		return FALSE
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

///Covers Reloading and lighting of the gun
/obj/structure/mounted_gun/attackby(obj/item/ammo_casing/used_item, mob/user, params)
	if(is_firing)
		balloon_alert(user, "gun is firing!")
		return
	if(istype(used_item, ammo_type) && (uses_ammo == TRUE)) //see if the gun needs to be loaded in some way.
		if(fully_loaded_gun)
			balloon_alert(user, "already fully loaded!")
			return

		if(load_delay > 0 && !do_after(user, load_delay, target = src))
			return

		shots_in_gun = shots_in_gun + shots_per_load //Add one to the shots in the gun
		balloon_alert(user, loading_message)
		loaded_gun = TRUE // Make sure it registers theres ammo in there, so it can fire.
		QDEL_NULL(used_item)
		if(shots_in_gun >= max_shots_per_fire)
			shots_in_gun = max_shots_per_fire // in case of somehow firing only some of a guns shots, and reloading, you still cant get above the maximum ammo size.
			fully_loaded_gun = TRUE //So you cant load extra.
		icon_state = icon_state_loaded
		return

/obj/structure/mounted_gun/attack_hand(mob/living/user, list/modifiers)
	if(is_firing)
		balloon_alert(user, "gun is firing!")
		return
	user.log_message("fired a mounted gun", LOG_ATTACK)
	log_game("[key_name(user)] fired a mounted gun in [AREACOORD(src)]")
	addtimer(CALLBACK(src, PROC_REF(fire)), fire_delay) //uses fire proc as shown below to shoot the gun
	return

/obj/structure/mounted_gun/proc/fire()
	if (!loaded_gun)
		balloon_alert_to_viewers("gun is not loaded!","",2)
		return
	is_firing = TRUE
	for(var/times_fired = 1, times_fired <= shots_in_gun, times_fired++) //The normal DM for loop structure since the times it has fired is changing in the loop itself.
		for(var/mob/shaken_mob in urange(10, src))
			if(shaken_mob.stat == CONSCIOUS && firing_shakes_camera == TRUE) //is the mob awake to feel the shaking?
				shake_camera(shaken_mob, 3, 1)
			icon_state = icon_state_fire
		if(loaded_gun)

			if (times_fired < shots_in_gun)
				playsound(src, fire_sound, 50, FALSE, 5)
			else
				playsound(src, last_fire_sound, 50, TRUE, 5) //for the empty fire sound

			var/obj/projectile/fired_projectile = (use_alt_ammo) ? new alt_projectile_type(get_turf(src)) : new projectile_type(get_turf(src))
			fired_projectile.firer = src
			fired_projectile.fired_from = src
			fired_projectile.fire(dir2angle(dir))
		sleep(shot_delay)

	if(uses_ammo == TRUE)
		loaded_gun = FALSE
		use_alt_ammo = FALSE
		shots_in_gun = 0
		fully_loaded_gun = FALSE
		is_firing = FALSE
	icon_state = icon_state_base

/obj/structure/mounted_gun/organ_gun

	name = "Pipe Organ Gun"
	desc = "To become master over one who has killed, one must become a better killer. This engine of destruction is one of many things made to that end."
	icon_state = "pipeorgangun"
	icon_state_base = "pipeorgangun"
	icon_state_loaded = "pipeorgangun"
	icon_state_fire = "pipeorgangun_fire"
	anchored = FALSE
	anchorable_gun = TRUE
	max_shots_per_fire = 8
	shots_in_gun = 8
	shots_per_load = 2
	ammo_type = /obj/item/ammo_casing/junk
	projectile_type = /obj/projectile/bullet/junk
	loaded_gun = TRUE
	fully_loaded_gun = TRUE
	fire_delay = 3 DECISECONDS
	shot_delay = 2 DECISECONDS
	firing_shakes_camera = FALSE
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 24.5, /datum/material/wood = SHEET_MATERIAL_AMOUNT * 15, /datum/material/glass = SMALL_MATERIAL_AMOUNT)

/obj/structure/mounted_gun/organ_gun/examine_more(mob/user)
	. = ..()
	. += span_notice("<b><i>Looking down at \the [src], you recall a tale told to you in some distant memory...</i></b>")

	. += span_info("To commit an act of vengeance is not unlike to enter a blood pact with a devil, ending the life of another, at the cost of your own.")
	. += span_info("When humanity first spilled the blood of its own kind, with likely nothing more than a rock, the seal was broken. Vengeance was borne unto the world.")
	. += span_info("However, vengeance alone is not enough to carry through the grim deed of murder. One must gain an advantage over their adversary.")
	. += span_info("As such, the man who ended another's life with a stone, was in turn smote himself by another wielding a spear. After spears, bows. Swords. Guns. Tanks. Missiles. And on and on Vengeance fed. Growing stronger. Growing Worse.")
	. += span_info("Vengeance persists to this day. It sometimes may slumber, seemingly content with having gorged itself, but in the end, its ceaseless hunger can be neither numbed nor sated.")

/obj/structure/mounted_gun/organ_gun/fire()
	if (!loaded_gun)
		balloon_alert_to_viewers("Gun is not loaded!","",2)
		return
	for(var/times_fired = 1, times_fired <= shots_in_gun, times_fired++) //The normal DM for loop structure since the times it has fired is changing in the loop itself.
		for(var/mob/shaken_mob in urange(10, src))
			if((shaken_mob.stat == CONSCIOUS)&&(firing_shakes_camera == TRUE))
				shake_camera(shaken_mob, 3, 1)
			icon_state = icon_state_fire
		if(loaded_gun)
			playsound(src, fire_sound, 50, TRUE, 5)

			var/list_of_projectiles = list(
			/obj/projectile/bullet/junk = 40,
			/obj/projectile/bullet/incendiary/fire/junk = 25,
			/obj/projectile/bullet/junk/shock = 25,
			/obj/projectile/bullet/junk/hunter = 20,
			/obj/projectile/bullet/junk/phasic = 8,
			/obj/projectile/bullet/junk/ripper = 8,
			/obj/projectile/bullet/junk/reaper = 3,
			)
			projectile_type = pick_weight(list_of_projectiles)

			var/obj/projectile/fired_projectile = new projectile_type(get_turf(src))
			fired_projectile.firer = src
			fired_projectile.fired_from = src
			fired_projectile.fire(dir2angle(dir))
		sleep(shot_delay)
	loaded_gun = FALSE
	shots_in_gun = 0
	fully_loaded_gun = FALSE
	icon_state = icon_state_base

/obj/structure/mounted_gun/canister_gatling //for the funny skeleton pirates!

	name = "Canister Gatling Gun"
	desc = "''Quantity has a quality of its own.''"
	icon_state = "canister_gatling"
	icon_state_base = "canister_gatling"
	icon_state_loaded = "canister_gatling"
	icon_state_fire = "canister_gatling_fire"
	anchored = FALSE
	anchorable_gun = TRUE
	max_shots_per_fire = 50
	shots_per_load = 50
	shots_in_gun = 50
	ammo_type = /obj/item/ammo_casing/canister_shot
	projectile_type = /obj/projectile/bullet/shrapnel
	loaded_gun = TRUE
	fully_loaded_gun = TRUE
	fire_delay = 3 DECISECONDS
	shot_delay = 1 DECISECONDS
	firing_shakes_camera = FALSE

/obj/item/ammo_casing/canister_shot
	name = "Canister Shot"
	desc = "A gigantic... well, canister of canister shot. Used for reloading the Canister Gatling Gun."
	icon_state = "canister_shot"
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/projectile/bullet/shrapnel

/obj/structure/mounted_gun/ratvarian_repeater
	name = "Ratvarian Repeater"
	desc = "''Brains? Bronze? Why not both?''"
	icon_state = "ratvarian_repeater"
	icon_state_base = "ratvarian_repeater"
	icon_state_fire = "ratvarian_repeater_fire"
	loading_message = "gun charged"
	anchored = FALSE
	anchorable_gun = TRUE
	uses_ammo = FALSE
	load_delay = 30
	max_shots_per_fire = 12
	shots_per_load = 12
	shots_in_gun = 12
	fire_sound = 'sound/items/weapons/thermalpistol.ogg'
	last_fire_sound = 'sound/items/weapons/thermalpistol.ogg'
	projectile_type = /obj/projectile/beam/laser/musket/repeater
	loaded_gun = TRUE
	fully_loaded_gun = TRUE
	fire_delay = 1
	shot_delay = 2
	firing_shakes_camera = FALSE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5.25,
		/datum/material/bronze = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.29
	)

/obj/structure/mounted_gun/ratvarian_repeater/dump_contents()
	return // Stub because we don't want to do anything here

/obj/structure/mounted_gun/ratvarian_repeater/attack_hand(mob/user, params) //the repeater is weird so has to have its own code since it takes no ammo.

	if(is_firing)
		balloon_alert(user, "gun is firing!")
		return

	if(!fully_loaded_gun)
		if(!do_after(user, load_delay, target = src))
			return
		shots_in_gun = shots_per_load //Add one to the shots in the gun
		balloon_alert(user, "mechanism wound.")
		playsound(src, 'sound/effects/magic/clockwork/fellowship_armory.ogg', 50, FALSE, 5)
		loaded_gun = TRUE // Make sure it registers theres ammo in there, so it can fire.
		if(shots_in_gun >= max_shots_per_fire)
			shots_in_gun = max_shots_per_fire // in case of somehow firing only some of a guns shots, and reloading, you still cant get above the maximum ammo size.
			fully_loaded_gun = TRUE //So you cant load extra.
		return

	user.log_message("fired a ratvatian repeater", LOG_ATTACK)
	log_game("[key_name(user)] fired a ratvatian repeater in [AREACOORD(src)]")
	addtimer(CALLBACK(src, PROC_REF(fire)), fire_delay) //uses fire proc as shown below to shoot the gun

/obj/structure/mounted_gun/ratvarian_repeater/fire()
	if (!loaded_gun)
		balloon_alert_to_viewers("needs winding!", vision_distance = 2)
		return
	is_firing = TRUE
	for(var/times_fired = 1, times_fired <= shots_in_gun, times_fired++) //The normal DM for loop structure since the times it has fired is changing in the loop itself.
		if(loaded_gun)
			icon_state = icon_state_fire
			if (times_fired < shots_in_gun)
				playsound(src, fire_sound, 50, FALSE, 5)
			else
				playsound(src, last_fire_sound, 50, TRUE, 5) //for the empty fire sound
			var/obj/projectile/fired_projectile = new projectile_type(get_turf(src))
			fired_projectile.firer = src
			fired_projectile.fired_from = src
			fired_projectile.fire(dir2angle(dir))
		if(times_fired % 2 != 1)//Burst Fire.
			sleep(shot_delay)
		sleep(shot_delay)
	loaded_gun = FALSE
	shots_in_gun = 0
	fully_loaded_gun = FALSE
	is_firing = FALSE
	icon_state = icon_state_base

/obj/structure/mounted_gun/ballista
	name = "Improvised Ballista"
	desc = "''Engineers like to solve problems. If there are no problems handily available, they will create their own problems.''"
	icon_state = "Improvised_Ballista"
	icon_state_base = "Improvised_Ballista"
	icon_state_loaded = "Improvised_Ballista_Loaded"
	icon_state_fire = "Improvised_Ballista"
	anchored = FALSE
	anchorable_gun = TRUE
	uses_ammo = TRUE
	load_delay = 60
	max_shots_per_fire = 1
	shots_per_load = 1
	shots_in_gun = 1
	fire_sound = 'sound/items/xbow_lock.ogg'
	last_fire_sound = 'sound/items/xbow_lock.ogg'
	has_alt_ammo = TRUE
	ammo_type = /obj/item/spear
	projectile_type = /obj/projectile/bullet/ballista_spear
	alt_ammo_type = /obj/item/spear/dragonator
	alt_projectile_type = /obj/projectile/bullet/ballista_spear_dragon
	loaded_gun = FALSE
	fully_loaded_gun = FALSE
	fire_delay = 1
	shot_delay = 1
	firing_shakes_camera = FALSE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 15.15,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 1.5
	)

/obj/structure/mounted_gun/ballista/attackby(obj/item/ammo_casing/used_item, mob/user, params) //again its single shot so its kinda weird.
	if(is_firing)
		balloon_alert(user, "gun is firing")
		return

	if(!istype(used_item, ammo_type))
		return

	if(fully_loaded_gun)
		balloon_alert(user, "already fully loaded!")
		return

	if(istype(used_item, alt_ammo_type))
		use_alt_ammo = TRUE

	playsound(src, 'sound/items/weapons/draw_bow.ogg', 50, FALSE, 5)
	do_after(user, load_delay, target = src)
	shots_in_gun = 1 //MAX OF ONE SHOT.
	balloon_alert(user, loading_message)
	loaded_gun = TRUE
	QDEL_NULL(used_item)
	fully_loaded_gun = TRUE
	icon_state = icon_state_loaded
