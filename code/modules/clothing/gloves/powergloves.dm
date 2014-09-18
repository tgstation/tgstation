
//**************************************************************
//
// Power Gloves
// -------------------
// Allows the user to shock people from a distance
// User must be standing on a wire
// Above shockLimit, the user also takes damage (10%)
// TODO: Align shock dmg with powernets
//
//**************************************************************

/obj/item/clothing/gloves/yellow/power
	var/shockLimit = 100

/obj/item/clothing/gloves/yellow/power/Touch(atom/target)
	if(world.time < src.next_shock)
		user << "<span class='warning'>[src] aren't ready to shock again!</span>"
		return
	var/mob/user = src.loc
	var/turf/T = get_turf(src)
	var/obj/structure/cable/cable = locate(obj/structure/cable) in T
	var/datum/powernet/PN = cable.get_powernet()
	var/damage
	if(PN.avail >= 5000000)	damage = 205 //TODO: Align with powernets
	else					damage = PN.get_electrocute_damage()
	if(damage > 0)
		if(damage >= src.shockLimit)
			apply_damage((damage/10),BURN,(hand ? "l_hand" : "r_hand"))
			user << "<span class='warning'>[src] overload from the massive current shocking you in the process!"
		var/obj/item/projectile/beam/lightning/L = getFromPool(/obj/item/projectile/beam/lightning,loc)
		L.damage = damage
		var/datum/effect/effect/system/spark_spread/s = new
		s.set_up(5,1,src)
		s.start()
		playsound(get_turf(src),'sound/effects/eleczap.ogg',75,1)
		var/turf/U = get_turf(target)
		L.tang = L.adjustAngle(get_angle(U,T))
		L.icon = midicon
		L.icon_state = "[L.tang]"
		L.firer = user
		L.def_zone = get_organ_target()
		L.original = user
		L.current = U
		L.starting = U
		L.yo = U.y - T.y
		L.xo = U.x - T.x
		spawn() L.process()
		user.visible_message(
			"<span class='warning'>[user.name] fires an arc of electricity!</span>",
			"<span class='notice'>You fire an arc of electricity!</span>",
			"You hear the loud crackle of electricity!")
		src.next_shock = world.time + min(100,damage)
	return
