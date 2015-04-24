#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	id = "stabilizing_agent"
	description = "Keeps unstable chemicals stable. This does not work on everything."
	reagent_state = LIQUID
	color = "#FFFFFF"

/datum/chemical_reaction/stabilizing_agent
	name = "stabilizing_agent"
	id = "stabilizing_agent"
	result = "stabilizing_agent"
	required_reagents = list("iron" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	description = "Makes a temporary 3x3 fireball when it comes into existence, so be careful when mixing. ClF3 applied to a surface burns things that wouldn't otherwise burn, sometimes through the very floors of the station and exposing it to the vacuum of space."
	reagent_state = LIQUID
	color = "#FF0000"
	metabolization_rate = 4

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	result = "clf3"
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	result_amount = 4
	required_temp = 424

/datum/reagent/clf3/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjust_fire_stacks(4)
	M.adjustFireLoss(0.35*M.fire_stacks)
	..()
	return

/datum/chemical_reaction/clf3/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)
	holder.chem_temp = 1000 // hot as shit
	return

/datum/reagent/clf3/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/plating))
		var/turf/simulated/floor/plating/F = T
		if(prob(1))
			F.ChangeTurf(/turf/space)
	if(istype(T, /turf/simulated/floor/))
		var/turf/simulated/floor/F = T
		if(prob(volume/10))
			F.make_plating()
		if(istype(F, /turf/simulated/floor/))
			new /obj/effect/hotspot(F)
	if(istype(T, /turf/simulated/wall/))
		var/turf/simulated/wall/W = T
		if(prob(volume/10))
			W.ChangeTurf(/turf/simulated/floor)
	return

/datum/reagent/clf3/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH && isliving(M))
		M.adjust_fire_stacks(5)
		M.IgniteMob()
		new /obj/effect/hotspot(M.loc)
		return

/datum/reagent/sorium
	name = "Sorium"
	id = "sorium"
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#FFA500"

/datum/chemical_reaction/sorium
	name = "Sorium"
	id = "sorium"
	result = "sorium"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "nitrogen" = 1, "carbon" = 1)
	result_amount = 4

/datum/chemical_reaction/sorium_vortex
	name = "sorium_vortex"
	id = "sorium_vortex"
	result = null
	required_reagents = list("sorium" = 1)
	required_temp = 474

/datum/chemical_reaction/sorium_vortex/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, 5, 6)

/datum/chemical_reaction/sorium/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sorium", created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, 5, 6)

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#800080"

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	result = "liquid_dark_matter"
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/ldm_vortex
	name = "LDM Vortex"
	id = "ldm_vortex"
	result = null
	required_reagents = list("liquid_dark_matter" = 1)
	required_temp = 474

/datum/chemical_reaction/ldm_vortex/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, 5, 6)
	return
/datum/chemical_reaction/liquid_dark_matter/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("liquid_dark_matter", created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, 5, 6)
	return

/proc/goonchem_vortex(var/turf/simulated/T, var/setting_type, var/range, var/pull_times)
	for(var/atom/movable/X in orange(range, T))
		if(istype(X, /obj/effect))
			continue  //stop pulling smoke and hotspots please
		if(istype(X, /atom/movable))
			if((X) && !X.anchored)
				if(setting_type)
					for(var/i = 0, i < pull_times, i++)
						step_away(X,T)
				else
					for(var/i = 0, i < pull_times, i++)
						step_towards(X,T)

/datum/reagent/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.05

/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	result = "blackpowder"
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)
	result_amount = 3

/datum/chemical_reaction/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	result = null
	required_reagents = list("blackpowder" = 1)
	result_amount = 1
	required_temp = 474
	mix_message = "<span class = 'boldannounce'>Sparks start flying around the black powder!</span>"

/datum/chemical_reaction/blackpowder_explosion/on_reaction(var/datum/reagents/holder, var/created_volume)
	sleep(rand(50,100))
	blackpowder_detonate(holder, created_volume)
	return

/datum/reagent/blackpowder/on_ex_act()
	blackpowder_detonate(holder, volume)
	return

/proc/blackpowder_detonate(var/datum/reagents/holder, var/created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	var/ex_severe = round(created_volume / 100)
	var/ex_heavy = round(created_volume / 42)
	var/ex_light = round(created_volume / 21)
	var/ex_flash = round(created_volume / 8)
	explosion(T,ex_severe,ex_heavy,ex_light,ex_flash, 1)
	return
/datum/reagent/flash_powder
	name = "Flash Powder"
	id = "flash_powder"
	description = "Makes a very bright flash."
	reagent_state = LIQUID
	color = "#FFFF00"

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = "flash_powder"
	required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1 )
	result_amount = 3

/datum/chemical_reaction/flash_powder_flash
	name = "Flash powder activation"
	id = "flash_powder_flash"
	result = null
	required_reagents = list("flash_powder" = 1)
	required_temp = 374

/datum/chemical_reaction/flash_powder_flash/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		if(C.check_eye_prot())
			continue
		flick("e_flash", C.flash)
		if(get_dist(C, location) < 4)
			C.Weaken(5)
			continue
		C.Stun(5)

/datum/chemical_reaction/flash_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		if(C.check_eye_prot())
			continue
		flick("e_flash", C.flash)
		if(get_dist(C, location) < 4)
			C.Weaken(5)
			continue
		C.Stun(5)
	holder.remove_reagent("flash_powder", created_volume)

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	id = "smoke_powder"
	description = "Makes a large cloud of smoke that can carry reagents."
	reagent_state = LIQUID
	color = "#808080"

/datum/chemical_reaction/smoke_powder
	name = "smoke_powder"
	id = "smoke_powder"
	result = "smoke_powder"
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 3


/datum/chemical_reaction/smoke_powder_smoke
	name = "smoke_powder_smoke"
	id = "smoke_powder_smoke"
	result = null
	required_reagents = list("smoke_powder" = 1)
	required_temp = 374
	secondary = 1
	mob_react = 1

/datum/chemical_reaction/smoke_powder_smoke/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/chem_smoke_spread/S = new /datum/effect/effect/system/chem_smoke_spread
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		if(S)
			S.set_up(holder, 10, 0, location)
			S.start()
			sleep(10)
			S.start()
		if(holder && holder.my_atom)
			holder.clear_reagents()
	return

/datum/chemical_reaction/smoke_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("smoke_powder", created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/effect/system/chem_smoke_spread/S = new /datum/effect/effect/system/chem_smoke_spread
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
		if(S)
			S.set_up(holder, 10, 0, location)
			S.start()
			sleep(10)
			S.start()
		if(holder && holder.my_atom)
			holder.clear_reagents()
	return

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	id = "sonic_powder"
	description = "Makes a deafening noise."
	reagent_state = LIQUID
	color = "#0000FF"

/datum/chemical_reaction/sonic_powder
	name = "sonic_powder"
	id = "sonic_powder"
	result = "sonic_powder"
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)
	result_amount = 3


/datum/chemical_reaction/sonic_powder_deafen
	name = "sonic_powder_deafen"
	id = "sonic_powder_deafen"
	result = null
	required_reagents = list("sonic_powder" = 1)
	required_temp = 374

/datum/chemical_reaction/sonic_powder_deafen/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.ears && (H.ears.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
				continue
		C.show_message("<span class='warning'>BANG</span>", 2)
		C.Stun(5)
		C.Weaken(5)
		C.setEarDamage(C.ear_damage + rand(0, 5), max(C.ear_deaf,15))
		if(C.ear_damage >= 15)
			C << "<span class='warning'>Your ears start to ring badly!</span>"
		else if(C.ear_damage >= 5)
			C << "<span class='warning'>Your ears start to ring!</span>"

/datum/chemical_reaction/sonic_powder/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sonic_powder", created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if((H.ears && (H.ears.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
				continue
		C.show_message("<span class='warning'>BANG</span>", 2)
		C.Stun(5)
		C.Weaken(5)
		C.setEarDamage(C.ear_damage + rand(0, 5), max(C.ear_deaf,15))
		if(C.ear_damage >= 15)
			C << "<span class='warning'>Your ears start to ring badly!</span>"
		else if(C.ear_damage >= 5)
			C << "<span class='warning'>Your ears start to ring!</span>"

/datum/reagent/phlogiston
	name = "Phlogiston"
	id = "phlogiston"
	description = "Catches you on fire and makes you ignite."
	reagent_state = LIQUID
	color = "#FF9999"

/datum/chemical_reaction/phlogiston
	name = "phlogiston"
	id = "phlogiston"
	result = "phlogiston"
	required_reagents = list("phosphorus" = 1, "sacid" = 1, "stable_plasma" = 1)
	result_amount = 3

/datum/chemical_reaction/phlogiston/on_reaction(var/datum/reagents/holder, var/created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/turf/simulated/T = get_turf(holder.my_atom)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, created_volume)
	return

/datum/reagent/phlogiston/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjust_fire_stacks(1)
	M.IgniteMob()
	M.adjustFireLoss(0.2*M.fire_stacks)
	..()
	return

/datum/reagent/napalm
	name = "Napalm"
	id = "napalm"
	description = "Very flammable."
	reagent_state = LIQUID
	color = "#FF9999"

/datum/reagent/napalm/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjust_fire_stacks(1)
	..()
	return

/datum/reagent/napalm/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH && isliving(M))
		M.adjust_fire_stacks(7)
		return

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = "napalm"
	required_reagents = list("sugar" = 1, "fuel" = 1, "ethanol" = 1 )
	result_amount = 3

datum/reagent/cryostylane
	name = "Cryostylane"
	id = "cryostylane"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Cryostylane slowly cools all other reagents in the mob down to 0K."
	color = "#B2B2FF" // rgb: 139, 166, 233

/datum/chemical_reaction/cryostylane
	name = "cryostylane"
	id = "cryostylane"
	result = "cryostylane"
	required_reagents = list("water" = 1, "stable_plasma" = 1, "nitrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/cryostylane/on_reaction(var/datum/reagents/holder, var/created_volume)
	holder.chem_temp = 20 // cools the fuck down
	return


datum/reagent/cryostylane/on_mob_life(var/mob/living/M as mob) //TODO: code freezing into an ice cube
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature -= 30
	..()
	return

datum/reagent/cryostylane/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp -= 10
		holder.handle_reactions()
	..()
	return


datum/reagent/cryostylane/reaction_turf(var/turf/simulated/T, var/volume)
	if(volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15,30))

datum/reagent/pyrosium
	name = "Pyrosium"
	id = "pyrosium"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly cools all other reagents in the mob down to 0K."
	color = "#B20000" // rgb: 139, 166, 233

/datum/chemical_reaction/pyrosium
	name = "pyrosium"
	id = "pyrosium"
	result = "pyrosium"
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "phosphorus" = 1)
	result_amount = 3

/datum/chemical_reaction/pyrosium/on_reaction(var/datum/reagents/holder, var/created_volume)
	holder.chem_temp = 20 // also cools the fuck down
	return

datum/reagent/pyrosium/on_mob_life(var/mob/living/M as mob)
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature += 30
	..()
	return

datum/reagent/pyrosium/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp += 10
		holder.handle_reactions()
	..()
	return
