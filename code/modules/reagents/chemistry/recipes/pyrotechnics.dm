/datum/chemical_reaction/reagent_explosion
	name = "Generic explosive"
	id = "reagent_explosion"
	result = null
	var/strengthdiv = 10
	var/modifier = 0

/datum/chemical_reaction/reagent_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	var/inside_msg
	if(ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		inside_msg = " inside [key_name_admin(M)]"
	var/lastkey = holder.my_atom.fingerprintslast
	var/touch_msg = "N/A"
	if(lastkey)
		var/mob/toucher = get_mob_by_key(lastkey)
		touch_msg = "[key_name_admin(lastkey)]<A HREF='?_src_=holder;adminmoreinfo=\ref[toucher]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[toucher]'>FLW</A>)"
	message_admins("Reagent explosion reaction occured at <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[T.loc.name] (JMP)</a>[inside_msg]. Last Fingerprint: [touch_msg].")
	log_game("Reagent explosion reaction occured at [T.loc.name] ([T.x],[T.y],[T.z]). Last Fingerprint: [lastkey ? lastkey : "N/A"]." )
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(modifier + round(created_volume/strengthdiv, 1), T, 0, 0)
	e.start()
	holder.clear_reagents()


/datum/chemical_reaction/reagent_explosion/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "facid" = 1, "sacid" = 1)
	result_amount = 2
	strengthdiv = 2

/datum/chemical_reaction/reagent_explosion/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("nitroglycerin", created_volume)
	..()

/datum/chemical_reaction/reagent_explosion/nitroglycerin_explosion
	name = "Nitroglycerin explosion"
	id = "nitroglycerin_explosion"
	required_reagents = list("nitroglycerin" = 1)
	result_amount = 1
	required_temp = 474
	strengthdiv = 2


/datum/chemical_reaction/reagent_explosion/potassium_explosion
	name = "Explosion"
	id = "potassium_explosion"
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2
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
			var/diety = ticker.Bible_deity_name
			if(!ticker.Bible_deity_name)
				diety = "Christ"
			R << "<span class='userdanger'>The power of [diety] compels you!</span>"
			R.stun(20)
			R.reveal(100)
		sleep(20)
		for(var/mob/living/carbon/C in get_hearers_in_view(round(created_volume/48,1),get_turf(holder.my_atom)))
			if(iscultist(C) || is_handofgod_cultist(C) || C.dna.species.id == "shadowling" || C.dna.species.id == "l_shadowling")
				C << "<span class='userdanger'>The divine explosion sears you!</span>"
				C.Weaken(2)
				C.adjust_fire_stacks(5)
				C.IgniteMob()
	..()


/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	required_reagents = list("aluminium" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = "napalm"
	required_reagents = list("oil" = 1, "welding_fuel" = 1, "ethanol" = 1 )
	result_amount = 3