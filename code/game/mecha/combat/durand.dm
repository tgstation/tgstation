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
			defense_action.turnoff()

/obj/mecha/combat/durand/go_out(forced, atom/newloc = loc)
	if(defence_mode)
		defense_action.turnoff()
	. = ..()

/**Checks if defense mode is enabled, and if the attacker is standing in an area covered by the shield.
Expects a turf. Returns true if the attack should be blocked, false if not.*/
/obj/mecha/combat/durand/proc/defence_check(var/turf/aloc)
	if (!defence_mode)
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

/obj/mecha/combat/durand/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0)
	if(defence_check(user.loc))
		log_message("Attack absorbed by defence field. Attacker - [user].", LOG_MECHA, color="orange")
		var/obj/mech_defence_mode_scapegoat/goat = new /obj/mech_defence_mode_scapegoat(loc)
		goat.chassis = src
		goat.attack_generic(user, damage_amount, damage_type, damage_flag, sound_effect, armor_penetration)
	else
		. = ..()

/obj/mecha/combat/durand/blob_act(obj/structure/blob/B)
	if(defence_check(B.loc))
		log_message("Attack by blob. Attacker - [B].", LOG_MECHA, color="red")
		log_message("Attack absorbed by defence field.", LOG_MECHA, color="orange")
		var/obj/mech_defence_mode_scapegoat/goat = new /obj/mech_defence_mode_scapegoat(loc)
		goat.chassis = src
		goat.blob_act(B)
	else
		. = ..()

/obj/mecha/combat/durand/bullet_act(obj/item/projectile/Proj)
	if(defence_check(Proj.loc))
		log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).", LOG_MECHA, color="red")
		log_message("Attack absorbed by defence field.", LOG_MECHA, color="orange")
		var/obj/mech_defence_mode_scapegoat/goat = new /obj/mech_defence_mode_scapegoat(loc)
		goat.chassis = src
		goat.bullet_act(Proj)
	else
		. = ..()

/obj/mecha/combat/durand/attackby(obj/item/W as obj, mob/user as mob, params)
	if(defence_check(user.loc))
		log_message("Attack absorbed by defence field. Attacker - [user], with [W]", LOG_MECHA, color="orange")
		var/obj/mech_defence_mode_scapegoat/goat = new /obj/mech_defence_mode_scapegoat(loc)
		goat.chassis = src
		goat.attackby(W, user, params)
	else
		. = ..()