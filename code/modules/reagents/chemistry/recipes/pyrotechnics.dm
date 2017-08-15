/datum/chemical_reaction/reagent_explosion
	name = "Generic explosive"
	id = "reagent_explosion"
	var/strengthdiv = 10
	var/modifier = 0

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/area/A = get_area(T)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [key_name_admin(M)]"
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[ADMIN_LOOKUPFLW(toucher)]"
	message_admins("Reagent explosion reaction occurred at [A] [ADMIN_COORDJMP(T)][inside_msg]. Last Fingerprint: [touch_msg].")
	log_game("Reagent explosion reaction occurred at [A] [COORD(T)]. Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(modifier + round(created_volume/strengthdiv, 1), T, 0, 0)
	e.start()
	holder.clear_reagents()


/datum/chemical_reaction/reagent_explosion/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	results = list("nitroglycerin" = 2)
	required_reagents = list("glycerol" = 1, "facid" = 1, "sacid" = 1)
	strengthdiv = 2

/datum/chemical_reaction/reagent_explosion/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("nitroglycerin", created_volume*2)
	..()

/datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion
	name = "Nitroglycerin explosion"
	id = "nitroglycerin_explosion"
	required_reagents = list("nitroglycerin" = 1)
	required_temp = 474
	strengthdiv = 2


/datum/chemical_reaction/reagent_explosion/potassium_explosion
	name = "Explosion"
	id = "potassium_explosion"
	required_reagents = list("water" = 1, "potassium" = 1)
	strengthdiv = 10

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom
	name = "Holy Explosion"
	id = "holyboom"
	required_reagents = list("holywater" = 1, "potassium" = 1)

/datum/chemical_reaction/reagent_explosion/potassium_explosion/holyboom/on_reaction(datum/reagents/holder, created_volume)
	if(created_volume >= 150)
		playsound(get_turf(holder.my_atom), 'sound/effects/pray.ogg', 80, 0, round(created_volume/48))
		strengthdiv = 8
		for(var/mob/living/simple_animal/revenant/R in get_hearers_in_view(7,get_turf(holder.my_atom)))
			var/deity
			if(SSreligion.deity)
				deity = SSreligion.deity
			else
				deity = "Christ"
			to_chat(R, "<span class='userdanger'>The power of [deity] compels you!</span>")
			R.stun(20)
			R.reveal(100)
			R.adjustHealth(50)
		sleep(20)
		for(var/mob/living/carbon/C in get_hearers_in_view(round(created_volume/48,1),get_turf(holder.my_atom)))
			if(iscultist(C))
				to_chat(C, "<span class='userdanger'>The divine explosion sears you!</span>")
				C.Knockdown(40)
				C.adjust_fire_stacks(5)
				C.IgniteMob()
	..()


/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	results = list("blackpowder" = 3)
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	required_reagents = list("blackpowder" = 1)
	required_temp = 474
	strengthdiv = 6
	modifier = 1
	mix_message = "<span class='boldannounce'>Sparks start flying around the black powder!</span>"

/datum/chemical_reaction/reagent_explosion/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	sleep(rand(50,100))
	..()

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	results = list("thermite" = 3)
	required_reagents = list("aluminium" = 1, "iron" = 1, "oxygen" = 1)

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 12), round(created_volume / 7), 1)
	holder.clear_reagents()

/datum/chemical_reaction/stabilizing_agent
	name = "stabilizing_agent"
	id = "stabilizing_agent"
	results = list("stabilizing_agent" = 3)
	required_reagents = list("iron" = 1, "oxygen" = 1, "hydrogen" = 1)

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	results = list("clf3" = 4)
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	required_temp = 424

/datum/chemical_reaction/clf3/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)
	holder.chem_temp = 1000 // hot as shit

/datum/chemical_reaction/reagent_explosion/methsplosion
	name = "Meth explosion"
	id = "methboom1"
	results = list("methboom1" = 1)
	required_temp = 420 //high enough to not blow up in the meth syringes
	required_reagents = list("methamphetamine" = 1)
	strengthdiv = 6
	modifier = 1

/datum/chemical_reaction/reagent_explosion/methsplosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)
	holder.chem_temp = 1000 // hot as shit
	..()

/datum/chemical_reaction/reagent_explosion/methsplosion/methboom2
	required_reagents = list("diethylamine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1) //diethylamine is often left over from mixing the ephedrine.
	required_temp = 420 
	results = list("methboom1" = 4) // this is ugly. Sorry goof.

/datum/chemical_reaction/sorium
	name = "Sorium"
	id = "sorium"
	results = list("sorium" = 4)
	required_reagents = list("mercury" = 1, "oxygen" = 1, "nitrogen" = 1, "carbon" = 1)

/datum/chemical_reaction/sorium/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sorium", created_volume*4)
	var/turf/T = get_turf(holder.my_atom)
	var/range = Clamp(sqrt(created_volume*4), 1, 6)
	goonchem_vortex(T, 1, range)

/datum/chemical_reaction/sorium_vortex
	name = "sorium_vortex"
	id = "sorium_vortex"
	required_reagents = list("sorium" = 1)
	required_temp = 474

/datum/chemical_reaction/sorium_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/range = Clamp(sqrt(created_volume), 1, 6)
	goonchem_vortex(T, 1, range)

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	results = list("liquid_dark_matter" = 3)
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "carbon" = 1)

/datum/chemical_reaction/liquid_dark_matter/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("liquid_dark_matter", created_volume*3)
	var/turf/T = get_turf(holder.my_atom)
	var/range = Clamp(sqrt(created_volume*3), 1, 6)
	goonchem_vortex(T, 0, range)

/datum/chemical_reaction/ldm_vortex
	name = "LDM Vortex"
	id = "ldm_vortex"
	required_reagents = list("liquid_dark_matter" = 1)
	required_temp = 474

/datum/chemical_reaction/ldm_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/range = Clamp(sqrt(created_volume/2), 1, 6)
	goonchem_vortex(T, 0, range)

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	results = list("flash_powder" = 3)
	required_reagents = list("aluminium" = 1, "potassium" = 1, "sulfur" = 1 )

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/location = get_turf(holder.my_atom)
	do_sparks(2, TRUE, location)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/3, location))
		if(C.flash_act())
			if(get_dist(C, location) < 4)
				C.Knockdown(60)
			else
				C.Stun(100)
	holder.remove_reagent("flash_powder", created_volume*3)

/datum/chemical_reaction/flash_powder_flash
	name = "Flash powder activation"
	id = "flash_powder_flash"
	required_reagents = list("flash_powder" = 1)
	required_temp = 374

/datum/chemical_reaction/flash_powder_flash/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(2, TRUE, location)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		if(C.flash_act())
			if(get_dist(C, location) < 4)
				C.Knockdown(60)
			else
				C.Stun(100)

/datum/chemical_reaction/smoke_powder
	name = "smoke_powder"
	id = "smoke_powder"
	results = list("smoke_powder" = 3)
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)

/datum/chemical_reaction/smoke_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("smoke_powder", created_volume*3)
	var/smoke_radius = round(sqrt(created_volume * 1.5), 1)
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/smoke_powder_smoke
	name = "smoke_powder_smoke"
	id = "smoke_powder_smoke"
	required_reagents = list("smoke_powder" = 1)
	required_temp = 374
	secondary = 1
	mob_react = 1

/datum/chemical_reaction/smoke_powder_smoke/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/smoke_radius = round(sqrt(created_volume / 2), 1)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, smoke_radius, location, 0)
		S.start()
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/sonic_powder
	name = "sonic_powder"
	id = "sonic_powder"
	results = list("sonic_powder" = 3)
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)

/datum/chemical_reaction/sonic_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sonic_powder", created_volume*3)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/3, location))
		C.soundbang_act(1, 100, rand(0, 5))

/datum/chemical_reaction/sonic_powder_deafen
	name = "sonic_powder_deafen"
	id = "sonic_powder_deafen"
	required_reagents = list("sonic_powder" = 1)
	required_temp = 374

/datum/chemical_reaction/sonic_powder_deafen/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/carbon/C in get_hearers_in_view(created_volume/10, location))
		C.soundbang_act(1, 100, rand(0, 5))

/datum/chemical_reaction/phlogiston
	name = "phlogiston"
	id = "phlogiston"
	results = list("phlogiston" = 3)
	required_reagents = list("phosphorus" = 1, "sacid" = 1, "stable_plasma" = 1)

/datum/chemical_reaction/phlogiston/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/turf/open/T = get_turf(holder.my_atom)
	if(istype(T))
		T.atmos_spawn_air("plasma=[created_volume];TEMP=1000")
	holder.clear_reagents()
	return

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	results = list("napalm" = 3)
	required_reagents = list("oil" = 1, "welding_fuel" = 1, "ethanol" = 1 )

/datum/chemical_reaction/cryostylane
	name = "cryostylane"
	id = "cryostylane"
	results = list("cryostylane" = 3)
	required_reagents = list("water" = 1, "stable_plasma" = 1, "nitrogen" = 1)

/datum/chemical_reaction/cryostylane/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // cools the fuck down
	return


/datum/chemical_reaction/pyrosium
	name = "pyrosium"
	id = "pyrosium"
	results = list("pyrosium" = 3)
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "phosphorus" = 1)

/datum/chemical_reaction/pyrosium/on_reaction(datum/reagents/holder, created_volume)
	holder.chem_temp = 20 // also cools the fuck down
	return

/datum/chemical_reaction/teslium
	name = "Teslium"
	id = "teslium"
	results = list("teslium" = 3)
	required_reagents = list("stable_plasma" = 1, "silver" = 1, "blackpowder" = 1)
	mix_message = "<span class='danger'>A jet of sparks flies from the mixture as it merges into a flickering slurry.</span>"
	required_temp = 400

/datum/chemical_reaction/reagent_explosion/teslium_lightning
	name = "Teslium Destabilization"
	id = "teslium_lightning"
	required_reagents = list("teslium" = 1, "water" = 1)
	results = list("destabilized_teslium" = 1)
	strengthdiv = 100
	modifier = -100
	mix_message = "<span class='boldannounce'>The teslium starts to spark as electricity arcs away from it!</span>"
	mix_sound = 'sound/machines/defib_zap.ogg'

/datum/chemical_reaction/reagent_explosion/teslium_lightning/on_reaction(datum/reagents/holder, created_volume)
	var/T1 = created_volume * 20		//100 units : Zap 3 times, with powers 2000/5000/12000. Tesla revolvers have a power of 10000 for comparison.
	var/T2 = created_volume * 50
	var/T3 = created_volume * 120
	sleep(5)
	if(created_volume >= 75)
		tesla_zap(holder.my_atom, 7, T1)
		playsound(holder.my_atom, 'sound/machines/defib_zap.ogg', 50, 1)
		sleep(15)
	if(created_volume >= 40)
		tesla_zap(holder.my_atom, 7, T2)
		playsound(holder.my_atom, 'sound/machines/defib_zap.ogg', 50, 1)
		sleep(15)
	if(created_volume >= 10)			//10 units minimum for lightning, 40 units for secondary blast, 75 units for tertiary blast.
		tesla_zap(holder.my_atom, 7, T3)
		playsound(holder.my_atom, 'sound/machines/defib_zap.ogg', 50, 1)
	..()

/datum/chemical_reaction/reagent_explosion/teslium_lightning/heat
	id = "teslium_lightning2"
	required_temp = 474
	required_reagents = list("teslium" = 1)

/datum/chemical_reaction/reagent_explosion/nitrous_oxide
	name = "N2O explosion"
	id = "n2o_explosion"
	required_reagents = list("nitrous_oxide" = 1)
	strengthdiv = 7
	required_temp = 575
	modifier = 1
