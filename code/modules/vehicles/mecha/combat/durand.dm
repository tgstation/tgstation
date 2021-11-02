/obj/vehicle/sealed/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "\improper Durand"
	icon_state = "durand"
	base_icon_state = "durand"
	movedelay = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 35, LASER = 15, ENERGY = 10, BOMB = 20, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 30000
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand
	var/obj/durand_shield/shield


/obj/vehicle/sealed/mecha/combat/durand/Initialize(mapload)
	. = ..()
	shield = new /obj/durand_shield(loc, src, layer, dir)
	RegisterSignal(src, COMSIG_MECHA_ACTION_TRIGGER, .proc/relay)
	RegisterSignal(src, COMSIG_PROJECTILE_PREHIT, .proc/prehit)


/obj/vehicle/sealed/mecha/combat/durand/Destroy()
	if(shield)
		QDEL_NULL(shield)
	return ..()


/obj/vehicle/sealed/mecha/combat/durand/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_defense_mode)

/obj/vehicle/sealed/mecha/combat/durand/process()
	. = ..()
	if(defense_mode && !use_power(100)) //Defence mode can only be on with a occupant so we check if one of them can toggle it and toggle
		for(var/O in occupants)
			var/mob/living/occupant = O
			var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/mech_defense_mode)
			if(action)
				action.Trigger()
				break

/obj/vehicle/sealed/mecha/combat/durand/Move(direction)
	. = ..()
	if(shield)
		shield.forceMove(loc)
		shield.setDir(dir)

/obj/vehicle/sealed/mecha/combat/durand/forceMove(turf/T)
	. = ..()
	shield.forceMove(T)

/obj/vehicle/sealed/mecha/combat/durand/mob_exit(mob/M, silent, randomstep, forced)
	if(defense_mode)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, M, /datum/action/vehicle/sealed/mecha/mech_defense_mode)
		if(action)
			INVOKE_ASYNC(action, /datum/action.proc/Trigger, FALSE)
	return ..()

///Relays the signal from the action button to the shield, and creates a new shield if the old one is MIA.
/obj/vehicle/sealed/mecha/combat/durand/proc/relay(datum/source, mob/owner, list/signal_args)
	SIGNAL_HANDLER
	if(!shield) //if the shield somehow got deleted
		stack_trace("Durand triggered relay without a shield")
		shield = new /obj/durand_shield(loc, src, layer)
	shield.setDir(dir)
	SEND_SIGNAL(shield, COMSIG_MECHA_ACTION_TRIGGER, owner, signal_args)

//Redirects projectiles to the shield if defense_check decides they should be blocked and returns true.
/obj/vehicle/sealed/mecha/combat/durand/proc/prehit(obj/projectile/source, list/signal_args)
	SIGNAL_HANDLER
	if(defense_check(source.loc) && shield)
		signal_args[2] = shield

/**Checks if defense mode is enabled, and if the attacker is standing in an area covered by the shield.
Expects a turf. Returns true if the attack should be blocked, false if not.*/
/obj/vehicle/sealed/mecha/combat/durand/proc/defense_check(turf/aloc)
	if (!defense_mode || !shield || shield.switching)
		return FALSE
	. = FALSE
	switch(dir)
		if (1)
			if(abs(x - aloc.x) <= (y - aloc.y) * -2)
				. = TRUE
		if (2)
			if(abs(x - aloc.x) <= (y - aloc.y) * 2)
				. = TRUE
		if (4)
			if(abs(y - aloc.y) <= (x - aloc.x) * -2)
				. = TRUE
		if (8)
			if(abs(y - aloc.y) <= (x - aloc.x) * 2)
				. = TRUE
	return

/obj/vehicle/sealed/mecha/combat/durand/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0)
	if(defense_check(user.loc))
		log_message("Attack absorbed by defense field. Attacker - [user].", LOG_MECHA, color="orange")
		shield.attack_generic(user, damage_amount, damage_type, damage_flag, sound_effect, armor_penetration)
	else
		. = ..()

/obj/vehicle/sealed/mecha/combat/durand/blob_act(obj/structure/blob/B)
	if(defense_check(B.loc))
		log_message("Attack by blob. Attacker - [B].", LOG_MECHA, color="red")
		log_message("Attack absorbed by defense field.", LOG_MECHA, color="orange")
		shield.blob_act(B)
	else
		. = ..()

/obj/vehicle/sealed/mecha/combat/durand/attackby(obj/item/W as obj, mob/user as mob, params)
	if(defense_check(user.loc))
		log_message("Attack absorbed by defense field. Attacker - [user], with [W]", LOG_MECHA, color="orange")
		shield.attackby(W, user, params)
	else
		. = ..()

/obj/vehicle/sealed/mecha/combat/durand/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(defense_check(AM.loc))
		log_message("Impact with [AM] absorbed by defense field.", LOG_MECHA, color="orange")
		shield.hitby(AM, skipcatch, hitpush, blocked, throwingdatum)
	else
		. = ..()

////////////////////////////
///// Shield processing ////
////////////////////////////

/**An object to take the hit for us when using the Durand's defense mode.
It is spawned in during the durand's initilization, and always stays on the same tile.
Normally invisible, until defense mode is actvated. When the durand detects an attack that should be blocked, the
attack is passed to the shield. The shield takes the damage, uses it to calculate charge cost, and then sets its
own integrity back to max. Shield is automatically dropped if we run out of power or the user gets out.*/

/obj/durand_shield //projectiles get passed to this when defense mode is enabled
	name = "defense grid"
	icon = 'icons/mecha/durand_shield.dmi'
	icon_state = "shield_null"
	invisibility = INVISIBILITY_MAXIMUM //no showing on right-click
	pixel_y = 4
	max_integrity = 10000
	anchored = TRUE
	light_system = MOVABLE_LIGHT
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_power = 5
	light_color = LIGHT_COLOR_ELECTRIC_CYAN
	light_on = FALSE
	///Our link back to the durand
	var/obj/vehicle/sealed/mecha/combat/durand/chassis
	///To keep track of things during the animation
	var/switching = FALSE
	var/currentuser
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF //The shield should not take damage from fire,  lava, or acid; that's the mech's job.


/obj/durand_shield/Initialize(mapload, _chassis, _layer, _dir)
	. = ..()
	chassis = _chassis
	layer = _layer
	setDir(_dir)
	RegisterSignal(src, COMSIG_MECHA_ACTION_TRIGGER, .proc/activate)


/obj/durand_shield/Destroy()
	if(chassis)
		chassis.shield = null
		chassis = null
	return ..()

/**
 * Handles activating and deactivating the shield.
 *
 * This proc is called by a signal sent from the mech's action button and
 * relayed by the mech itself. The "forced" variable, `signal_args[1]`, will
 * skip the to-pilot text and is meant for when the shield is disabled by
 * means other than the action button (like running out of power).
 *
 * Arguments:
 * * source: the shield
 * * owner: mob that activated the shield
 * * signal_args: whether it's forced
 */
/obj/durand_shield/proc/activate(datum/source, mob/owner, list/signal_args)
	SIGNAL_HANDLER
	currentuser = owner
	if(!LAZYLEN(chassis?.occupants))
		return
	if(switching && !signal_args[1])
		return
	if(!chassis.defense_mode && (!chassis.cell || chassis.cell.charge < 100)) //If it's off, and we have less than 100 units of power
		chassis.balloon_alert(owner, "insufficient power")
		return
	switching = TRUE
	chassis.defense_mode = !chassis.defense_mode
	if(!signal_args[1])
		chassis.balloon_alert(owner, "shield [chassis.defense_mode?"enabled":"disabled"]")
		chassis.log_message("User has toggled defense mode -- now [chassis.defense_mode?"enabled":"disabled"].", LOG_MECHA)
	else
		chassis.log_message("defense mode state changed -- now [chassis.defense_mode?"enabled":"disabled"].", LOG_MECHA)
	for(var/occupant in chassis.occupants)
		var/datum/action/button = chassis.occupant_actions[occupant][/datum/action/vehicle/sealed/mecha/mech_defense_mode]
		button.button_icon_state = "mech_defense_mode_[chassis.defense_mode ? "on" : "off"]"
		button.UpdateButtonIcon()

	set_light_on(chassis.defense_mode)

	if(chassis.defense_mode)
		invisibility = 0
		flick("shield_raise", src)
		playsound(src, 'sound/mecha/mech_shield_raise.ogg', 50, FALSE)
		set_light(l_range = MINIMUM_USEFUL_LIGHT_RANGE , l_power = 5, l_color = "#00FFFF")
		icon_state = "shield"
		RegisterSignal(chassis, COMSIG_ATOM_DIR_CHANGE, .proc/resetdir)
	else
		flick("shield_drop", src)
		playsound(src, 'sound/mecha/mech_shield_drop.ogg', 50, FALSE)
		set_light(0)
		icon_state = "shield_null"
		invisibility = INVISIBILITY_MAXIMUM //no showing on right-click
		UnregisterSignal(chassis, COMSIG_ATOM_DIR_CHANGE)
	switching = FALSE

/obj/durand_shield/proc/resetdir(datum/source, olddir, newdir)
	SIGNAL_HANDLER
	setDir(newdir)

/obj/durand_shield/take_damage()
	if(!chassis)
		qdel(src)
		return
	if(!chassis.defense_mode) //if defense mode is disabled, we're taking damage that we shouldn't be taking
		return
	. = ..()
	flick("shield_impact", src)
	if(!chassis.use_power((max_integrity - atom_integrity) * 100))
		chassis.cell?.charge = 0
		for(var/O in chassis.occupants)
			var/mob/living/occupant = O
			var/datum/action/action = LAZYACCESSASSOC(chassis.occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/mech_defense_mode)
			action.Trigger(FALSE)
	atom_integrity = 10000

/obj/durand_shield/play_attack_sound()
	playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 100, TRUE)

/obj/durand_shield/bullet_act()
	play_attack_sound()
	. = ..()
