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
	var/icon_state_fire = "falconet_patina_fire"
	max_integrity = 300
	///whether the cannon can be unwrenched from the ground. Anchorable_cannon equivalent.
	var/anchorable_gun = TRUE
	///Max shots per firing of the gun.
	var/max_shots_per_fire = 1
	///Shots currently loaded. Should never be more than max_shots_per_fire.
	var/shots_in_gun = 1
	///shots added to gun, per piece of ammo loaded.
	var/shots_per_load = 1
	///Accepted "ammo" type
	var/obj/item/ammo_type = /obj/item/ammo_casing/strilka310
	///Projectile from said gun. Doesnt automatically inherit said ammo's projectile in case you wanted to make a gun that shoots floor tiles or something.
	var/obj/projectile/projectile_type = /obj/projectile/bullet/strilka310
	///If the gun has anything in it.
	var/loaded_gun = TRUE
	///If the gun is currently loaded with its maximum capacity.
	var/fully_loaded_gun = TRUE
	///delay in firing the gun after lighting
	var/fire_delay = 5
	///Delay between shots
	var/shot_delay = 3
	///If the gun shakes the camera when firing
	var/firing_shakes_camera = TRUE
	///sound of firing for all but last shot
	var/fire_sound = 'sound/items/weapons/gun/general/mountedgun.ogg'
	///sound of firing for last shot
	var/last_fire_sound = 'sound/items/weapons/gun/general/mountedgunend.ogg'

/obj/structure/mounted_gun/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchorable_gun) /// Can't anchor an unanchorable gun.
		return FALSE
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

///Covers Reloading and lighting of the gun
/obj/structure/mounted_gun/attackby(obj/item/ammo_casing/used_item, mob/user, list/modifiers, list/attack_modifiers)
	var/ignition_message = used_item.ignition_effect(src, user) // Checks if item used can ignite stuff.
	if(istype(used_item, ammo_type))
		if(fully_loaded_gun)
			balloon_alert(user, "already fully loaded!")
			return
		else
			shots_in_gun = shots_in_gun + shots_per_load //Add one to the shots in the gun

			loaded_gun = TRUE // Make sure it registers theres ammo in there, so it can fire.
			QDEL_NULL(used_item)
			if(shots_in_gun >= max_shots_per_fire)
				shots_in_gun = max_shots_per_fire // in case of somehow firing only some of a guns shots, and reloading, you still cant get above the maximum ammo size.
				fully_loaded_gun = TRUE //So you cant load extra.
			return

	else if(ignition_message) // if item the player used ignites, light the gun!
		visible_message(ignition_message)
		user.log_message("fired a cannon", LOG_ATTACK)
		log_game("[key_name(user)] fired a cannon in [AREACOORD(src)]")
		addtimer(CALLBACK(src, PROC_REF(fire)), fire_delay) //uses fire proc as shown below to shoot the gun
		return
	..()

/obj/structure/mounted_gun/proc/fire()
	if (!loaded_gun)
		balloon_alert_to_viewers("gun is not loaded!","",2)
		return
	for(var/times_fired = 1, times_fired <= shots_in_gun, times_fired++) //The normal DM for loop structure since the times it has fired is changing in the loop itself.
		for(var/mob/shaken_mob in urange(10, src))
			if(shaken_mob.stat == CONSCIOUS && firing_shakes_camera == TRUE)
				shake_camera(shaken_mob, 3, 1)
			icon_state = icon_state_fire
		if(loaded_gun)

			if (times_fired < shots_in_gun)
				playsound(src, fire_sound, 50, FALSE, 5)
			else
				playsound(src, last_fire_sound, 50, TRUE, 5)
			var/obj/projectile/fired_projectile = new projectile_type(get_turf(src))
			fired_projectile.firer = src
			fired_projectile.fired_from = src
			fired_projectile.fire(dir2angle(dir))
		sleep(shot_delay)
	loaded_gun = FALSE
	shots_in_gun = 0
	fully_loaded_gun = FALSE
	icon_state = icon_state_base

/obj/structure/mounted_gun/pipe

	name = "Pipe Organ Gun"
	desc = "To become master over one who has killed, one must become a better killer. This engine of destruction is one of many things made to that end."
	icon_state = "pipeorgangun"
	icon_state_base = "pipeorgangun"
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
	fire_delay = 3
	shot_delay = 2
	firing_shakes_camera = FALSE

/obj/structure/mounted_gun/pipe/examine_more(mob/user)
	. = ..()
	. += span_notice("<b><i>Looking down at \the [src], you recall a tale told to you in some distant memory...</i></b>")

	. += span_info("To commit an act of vengeance is not unlike to enter a blood pact with a devil, ending the life of another, at the cost of your own.")
	. += span_info("When humanity first spilled the blood of its own kind, with likely nothing more than a rock, the seal was broken. Vengeance was borne unto the world.")
	. += span_info("However, vengeance alone is not enough to carry through the grim deed of murder. One must gain an advantage over their adversary.")
	. += span_info("As such, the man who ended another's life with a stone, was in turn smote himself by another wielding a spear. After spears, bows. Swords. Guns. Tanks. Missiles. And on and on Vengeance fed. Growing stronger. Growing Worse.")
	. += span_info("Vengeance persists to this day. It sometimes may slumber, seemingly content with having gorged itself, but in the end, its ceaseless hunger can be neither numbed nor sated.")

/obj/structure/mounted_gun/pipe/fire()
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
	fire_delay = 3
	shot_delay = 1
	firing_shakes_camera = FALSE

/obj/item/ammo_casing/canister_shot
	name = "Canister Shot"
	desc = "A gigantic... well, canister of canister shot. Used for reloading the Canister Gatling Gun."
	icon_state = "canister_shot"
	obj_flags = CONDUCTS_ELECTRICITY
	throwforce = 0
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/projectile/bullet/shrapnel
