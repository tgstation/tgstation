
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	max_integrity = 1
	armor = list("melee" = 0, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
	var/obj/item/holosign_creator/projector

/obj/structure/holosign/New(loc, source_projector)
	if(source_projector)
		projector = source_projector
		projector.signs += src
	..()

/obj/structure/holosign/Initialize()
	. = ..()
	alpha = 0
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, plane, dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

/obj/structure/holosign/Destroy()
	if(projector)
		projector.signs -= src
		projector = null
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, "melee", 1)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"

/obj/structure/holosign/barrier
	name = "holobarrier"
	desc = "A short holographic barrier which can only be passed by walking."
	icon_state = "holosign_sec"
	pass_flags = LETPASSTHROW
	density = TRUE
	max_integrity = 20
	var/allow_walk = TRUE //can we pass through it on walk intent

/obj/structure/holosign/barrier/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if(mover.pass_flags & (PASSGLASS|PASSTABLE|PASSGRILLE))
		return TRUE
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat)	// Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.m_intent == MOVE_INTENT_WALK)
			return TRUE

/obj/structure/holosign/barrier/wetsign
	name = "wet floor holobarrier"
	desc = "When it says walk it means walk."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign"

/obj/structure/holosign/barrier/wetsign/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat)	// Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.m_intent != MOVE_INTENT_WALK)
			return FALSE

/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos
	name = "holofirelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	density = FALSE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_NO
	alpha = 150
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_LIGHT_INSULATION

/obj/structure/holosign/barrier/atmos/Initialize()
	. = ..()
	air_update_turf(TRUE)

///this is a machinery to make it possible to check on the APC power to shut it down in case of an outage
/obj/machinery/holosign/barrier/power_shield
	name = "powered shield"
	desc = "A shield to prevent changes of atmospheric and heat transfer"
	icon = 'icons/effects/effects.dmi'
	density = FALSE
	anchored = TRUE
	CanAtmosPass = ATMOS_PASS_NO
	resistance_flags = FIRE_PROOF
	///store the conductivity value of the turf is applyed so that it can be restored on removal
	var/stored_conductivity = 0
	///power drain from the apc, in W (so 5000 is 5 kW), per each holosign placed
	var/power_consumption = 5000
	var/obj/item/holosign_creator/shield_projector

/obj/machinery/holosign/barrier/power_shield/Initialize(loc, source_projector)
	. = ..()
	var/area/a = get_area(src)
	if(a.power_equip == FALSE)
		stack_trace("Power shield created without power avaiable")
		qdel(src)
		return
	if(source_projector)
		shield_projector = source_projector
		shield_projector.signs += src
	air_update_turf(TRUE)
	a.addStaticPower(power_consumption, STATIC_EQUIP)
	shield_turf()

/obj/machinery/holosign/barrier/power_shield/Destroy()
	var/turf/T = loc
	T.thermal_conductivity = stored_conductivity
	var/area/a = get_area(src)
	a.addStaticPower(-power_consumption, STATIC_EQUIP)
	if(shield_projector)
		shield_projector.signs -= src
		shield_projector = null
	return ..()

/obj/machinery/holosign/barrier/power_shield/proc/shield_turf()
	var/turf/T = loc
	if(isturf(loc))
		stored_conductivity = T.thermal_conductivity
		T.thermal_conductivity = 0

/obj/machinery/holosign/barrier/power_shield/process()
	if(machine_stat & NOPOWER)
		qdel(src)

/obj/machinery/holosign/barrier/power_shield/wall
	name = "Shield Wall"
	desc = "A powered wall to stop changes in atmospheric and the spread of heat"
	icon_state = "powershield_wall"
	layer = ABOVE_MOB_LAYER

/obj/machinery/holosign/barrier/power_shield/floor
	name = "Shield Floor"
	desc = "A powered floor to stop the heat from melting the floors under it"
	icon_state = "powershield_floor"
	CanAtmosPass = ATMOS_PASS_YES
	power_consumption = 2500
	layer = TURF_PLATING_DECAL_LAYER
	plane = FLOOR_PLANE


/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = TRUE
	max_integrity = 10
	allow_walk = FALSE

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/projectile/P)
	take_damage((P.damage / 5) , BRUTE, "melee", 1)	//Doesn't really matter what damage flag it is.
	if(istype(P, /obj/projectile/energy/electrode))
		take_damage(10, BRUTE, "melee", 1)	//Tasers aren't harmful.
	if(istype(P, /obj/projectile/beam/disabler))
		take_damage(5, BRUTE, "melee", 1)	//Disablers aren't harmful.
	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/medical
	name = "\improper PENLITE holobarrier"
	desc = "A holobarrier that uses biometrics to detect human viruses. Denies passing to personnel with easily-detected, malicious viruses. Good for quarantines."
	icon_state = "holo_medical"
	alpha = 125 //lazy :)
	var/force_allaccess = FALSE
	var/buzzcd = 0

/obj/structure/holosign/barrier/medical/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The biometric scanners are <b>[force_allaccess ? "off" : "on"]</b>.</span>"

/obj/structure/holosign/barrier/medical/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(force_allaccess)
		return TRUE
	if(istype(mover, /obj/vehicle/ridden))
		for(var/M in mover.buckled_mobs)
			if(ishuman(M))
				if(!CheckHuman(M))
					return FALSE
	if(ishuman(mover))
		return CheckHuman(mover)
	return TRUE

/obj/structure/holosign/barrier/medical/Bumped(atom/movable/AM)
	. = ..()
	icon_state = "holo_medical"
	if(ishuman(AM) && !CheckHuman(AM))
		if(buzzcd < world.time)
			playsound(get_turf(src),'sound/machines/buzz-sigh.ogg',65,TRUE,4)
			buzzcd = (world.time + 60)
		icon_state = "holo_medical-deny"

/obj/structure/holosign/barrier/medical/proc/CheckHuman(mob/living/carbon/human/sickboi)
	var/threat = sickboi.check_virus()
	if(get_disease_severity_value(threat) > get_disease_severity_value(DISEASE_SEVERITY_MINOR))
		return FALSE
	return TRUE

/obj/structure/holosign/barrier/medical/attack_hand(mob/living/user)
	if(CanPass(user) && user.a_intent == INTENT_HELP)
		force_allaccess = !force_allaccess
		to_chat(user, "<span class='warning'>You [force_allaccess ? "deactivate" : "activate"] the biometric scanners.</span>") //warning spans because you can make the station sick!
	else
		return ..()

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	max_integrity = 20
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/projectile/P)
	take_damage(P.damage, BRUTE, "melee", 1)	//Yeah no this doesn't get projectile resistance.
	return BULLET_ACT_HIT

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier", flags = SHOCK_NOGLOVES)
			shockcd = TRUE
			addtimer(CALLBACK(src, .proc/cooldown), 5)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(shockcd)
		return

	if(!ismob(AM))
		return

	var/mob/living/M = AM
	M.electrocute_act(15,"Energy Barrier", flags = SHOCK_NOGLOVES)
	shockcd = TRUE
	addtimer(CALLBACK(src, .proc/cooldown), 5)
