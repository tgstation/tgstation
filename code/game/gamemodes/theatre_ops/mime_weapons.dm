// TRANQUILLITE SWORD

/obj/item/melee/transforming/energy/sword/tranquillite
	name = "tranquillite sword"
	desc = "An elegant weapon, forged for a master of stealth. One hit from this blade will leave your opponent silently crying out in terror."
	force = 0
	throwforce = 0
	force_on = 0
	throwforce_on = 0
	hitsound = null
	attack_verb_on = list("silenced")
	sharpness = IS_BLUNT
	sword_color = "white"
	heat = 0
	light_color = "#ffffff"
	var/silence_length = 50
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/melee/transforming/energy/sword/tranquillite/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/melee
	chameleon_action.chameleon_name = "Sword"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/melee, only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/melee/transforming/energy/sword/tranquillite/attack(mob/living/M, mob/living/user)
	..()
	if(active && iscarbon(M))
		var/mob/living/carbon/C = M
		C.silent += silence_length //No cap.

/obj/item/melee/transforming/energy/sword/tranquillite/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(active && iscarbon(hit_atom))
		var/mob/living/carbon/M = hit_atom
		M.silent += silence_length //Also no cap.

/obj/item/melee/transforming/energy/sword/tranquillite/suicide_act(mob/living/carbon/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message("<span class='suicide'>[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku, but the blade only permanently silenced [user.p_them()]!</span>")
	user.gain_trauma_type(/datum/brain_trauma/severe/mute, TRAUMA_RESILIENCE_ABSOLUTE)
	return SHAME

/obj/item/shield/energy/tranquillite
	name = "tranquillite energy shield"
	desc = "A shield that stops most melee attacks, protects user from almost all energy projectiles, and can be thrown to render opponents deaf and mute."
	throw_speed = 1
	base_icon_state = "tranquileshield"
	force = 0
	throwforce = 0
	throw_range = 5
	on_force = 0
	on_throwforce = 0
	on_throw_speed = 1
	var/silence_length = 100
	var/mute_length = 100
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/shield/energy/tranquillite/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/shield
	chameleon_action.chameleon_name = "Sword"
	chameleon_action.initialize_disguises()

/obj/item/shield/energy/tranquillite/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force)
	if(active)
		if(iscarbon(thrower))
			var/mob/living/carbon/C = thrower
			C.throw_mode_on() //so they can catch it on the return.
	return ..()

/obj/item/shield/energy/tranquillite/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(active)
		var/caught = hit_atom.hitby(src, FALSE, FALSE, throwingdatum=throwingdatum)
		if(iscarbon(hit_atom) && !caught)//if they are a carbon and they didn't catch it
			var/mob/living/carbon/H = hit_atom
			H.silent += silence_length
			H.adjustEarDamage(0, mute_length)
		if(thrownby && !caught)
			sleep(1)
			throw_at(thrownby, throw_range+2, throw_speed, null, TRUE)
	else
		return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/reticence/combat
	name = "silenced combat RCD"
	desc = "An exosuit-mounted Rapid Construction Device. This one is designed to be especially quiet, and produce Tranquillite walls and floors on demand."
	floor_type = /turf/open/floor/mineral/tranquillite
	wall_type = /turf/closed/wall/mineral/tranquillite
	airlock_type = /obj/machinery/door/airlock/tranquillite

/obj/mecha/combat/reticence/dark
	desc = "Produced by \"..., INC\", this stealth exosuit is designed as heavy mime-support. Owing to the difficulty of subtle infiltration using a mech suit, this model has been designed to be especially hard to see."
	name = "\improper Dark H.O.N.K"
	icon_state = "reticence" //Like anyone is going to be able to tell it's the same sprite
	max_integrity = 200
	deflect_chance = 15
	step_in = 1 //it's FAST
	armor = list("melee" = 40, "bullet" = 40, "laser" = 90, "energy" = 35, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100) //You're gonna try to shoot the almost perfectly transparent mech with a laser?
	max_temperature = 35000
	operation_req_access = list(ACCESS_SYNDICATE)
	internals_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/reticence/dark
	max_equip = 4
	color = "#25252510" //darker and harder to see.

/obj/mecha/combat/reticence/dark/add_cell(obj/item/stock_parts/cell/C)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/hyper(src)

/obj/mecha/combat/reticence/dark/loaded/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker()
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana()//Needed more offensive weapons.
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/rcd/reticence
	ME.attach(src)

/obj/structure/mecha_wreckage/reticence/dark
	name = "\improper Dark Reticence wreckage"
	icon_state = "reticence-broken"
	color = "#25252510"
	desc = "<span class='big bold'>...</span>"