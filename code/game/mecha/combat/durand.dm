#define COMSIG_ACTIVATE "activate"
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"

/obj/mecha/combat/durand
	desc = "An aging combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "\improper Durand"
	icon_state = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list("melee" = 40, "bullet" = 35, "laser" = 15, "energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 50, "fire" = 100, "acid" = 100)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand
	var/obj/durand_shield/shield

/obj/mecha/combat/durand/Initialize()
	shield = new/obj/durand_shield
	shield.chassis = src
	shield.layer = layer
	RegisterSignal(src, COMSIG_ACTIVATE, .proc/relay)
//	RegisterSignal(src, COMSIG_PROJECTILE_PREHIT, .proc/prehit)
	. = ..()

/obj/mecha/combat/durand/Destroy()
	. = ..()
	qdel(shield)

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/process()
	. = ..()
	if(defence_mode)
		if(!use_power(100))
			defense_action.Activate(forced_state = TRUE)

/obj/mecha/combat/durand/domove(direction)
	. = ..()
	if(shield)
		shield.forceMove(loc)
		shield.dir = dir

/obj/mecha/combat/durand/forceMove(var/turf/T)
	. = ..()
	shield.forceMove(T)

/obj/mecha/combat/durand/go_out(forced, atom/newloc = loc)
	if(defence_mode)
		defense_action.Activate(forced_state = TRUE)
	. = ..()

/obj/mecha/combat/durand/proc/relay(datum/source, list/signal_args)
	if(!shield)
		return
	SEND_SIGNAL(shield, COMSIG_ACTIVATE, source, signal_args)

///obj/mecha/combat/durand/proc/prehit(obj/item/projectile/source, list/signal_args)
//	if(defence_check(source.loc))
//		signal_args[2] = shield


/**Checks if defense mode is enabled, and if the attacker is standing in an area covered by the shield.
Expects a turf. Returns true if the attack should be blocked, false if not.*/
/obj/mecha/combat/durand/proc/defence_check(var/turf/aloc)
	if (!defence_mode || shield.switching)
		return FALSE
	var/blocked = FALSE
	switch(dir)
		if (1)
			if(abs(x - aloc.x) <= (y - aloc.y) * -2)
				blocked = TRUE
		if (2)
			if(abs(x - aloc.x) <= (y - aloc.y) * 2)
				blocked = TRUE
		if (4)
			if(abs(y - aloc.y) <= (x - aloc.x) * -2)
				blocked = TRUE
		if (8)
			if(abs(y - aloc.y) <= (x - aloc.x) * 2)
				blocked = TRUE
	if(blocked)
		return TRUE
	return FALSE

obj/mecha/combat/durand/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0)
	if(defence_check(user.loc))
		log_message("Attack absorbed by defence field. Attacker - [user].", LOG_MECHA, color="orange")
		shield.attack_generic(user, damage_amount, damage_type, damage_flag, sound_effect, armor_penetration)
	else
		. = ..()

/obj/mecha/combat/durand/blob_act(obj/structure/blob/B)
	if(defence_check(B.loc))
		log_message("Attack by blob. Attacker - [B].", LOG_MECHA, color="red")
		log_message("Attack absorbed by defence field.", LOG_MECHA, color="orange")
		shield.blob_act(B)
	else
		. = ..()

/obj/mecha/combat/durand/bullet_act(obj/item/projectile/Proj)
	if(defence_check(Proj.loc))
		log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).", LOG_MECHA, color="red")
		log_message("Attack absorbed by defence field.", LOG_MECHA, color="orange")
		Proj.hitsound = 'sound/mecha/mech_shield_deflect.ogg'
		shield.bullet_act(Proj)
	else
		. = ..()

/obj/mecha/combat/durand/attackby(obj/item/W as obj, mob/user as mob, params)
	if(defence_check(user.loc))
		log_message("Attack absorbed by defence field. Attacker - [user], with [W]", LOG_MECHA, color="orange")
		shield.attackby(W, user, params)
	else
		. = ..()

/obj/mecha/combat/durand/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(defence_check(AM.loc))
		log_message("Impact with [AM] absorbed by defence field.", LOG_MECHA, color="orange")
		shield.hitby(AM, skipcatch, hitpush, blocked, throwingdatum)
	else
		. = ..()

////////////////////////////
///// Shield processing ////
////////////////////////////

/**An object to take the hit for us when using the Durand's defense mode.
It is spawned in during the durand's initilization, and always stays on the same tile.
Normally invisible, until defense mode is actvated. When the durand detects an attack that hsould be blocked, the
attack is passed to the shield. The shield takes the damage, uses it to calculate charge cost, and then sets its
own integrity back to max. Shield is automatically dropped if we run out of power or the user gets out.*/

/obj/durand_shield //projectiles get passed to this when defence mode is enabled
	name = "defence grid"
	icon = 'icons/mecha/durand_shield.dmi'
	icon_state = "shield_null"
	pixel_y = 4
	max_integrity = 10000
	obj_integrity = 10000
	var/obj/mecha/combat/durand/chassis ///Our link back to the durand
	var/switching = FALSE ///To keep track of things during the animation

/obj/durand_shield/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ACTIVATE, .proc/activate)

/obj/durand_shield/proc/activate(datum/source, var/datum/action/innate/mecha/mech_defence_mode/button, list/signal_args)
	if(!chassis || !chassis.occupant)
		return
	if(switching && !signal_args[1])
		return
	switching = TRUE
	chassis.defence_mode = !chassis.defence_mode
	chassis.defense_action.button_icon_state = "mech_defense_mode_[chassis.defence_mode ? "on" : "off"]" //This is backwards because we haven't changed the var yet
	if(!signal_args[1])
		chassis.occupant_message("<span class='notice'>You [chassis.defence_mode?"enable":"disable"] [chassis] defence mode.</span>")
		chassis.log_message("User has toggled defence mode -- now [chassis.defence_mode?"enabled":"disabled"].", LOG_MECHA)
	else
		chassis.log_message("Defence mode state changed -- now [chassis.defence_mode?"enabled":"disabled"].", LOG_MECHA)
	chassis.defense_action.UpdateButtonIcon()

	if(chassis.defence_mode)
		flick("shield_deploy", src)
		set_light(l_range = MINIMUM_USEFUL_LIGHT_RANGE	, l_power = 5, l_color = "#00FFFF")
		sleep(3)
		icon_state = "shield"
	else
		flick("shield_drop", src)
		sleep(5)
		set_light(0)
		icon_state = "shield_null"
	switching = FALSE

/obj/durand_shield/take_damage()
	if(!chassis)
		qdel(src)
		return
	. = ..()
	if(!chassis.use_power((max_integrity - obj_integrity) * 100))
		chassis.cell?.charge = 0
		chassis.defense_action.Activate(forced_state = TRUE)
	obj_integrity = 10000

/obj/durand_shield/play_attack_sound()
	playsound(src, 'sound/mecha/mech_shield_deflect.ogg', 100, 1)

/datum/action/innate/mecha/mech_defence_mode
	name = "Toggle an energy shield that blocks all attacks from the faced direction at a heavy power cost."
	button_icon_state = "mech_defense_mode_off"
	var/image/def_overlay