/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	for(var/area/hallway/A in world)
		for(var/turf/simulated/floor/F in A)
			if(!F.contents.len)
				turfs += F

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/simulated/floor/T = pick(turfs)
		spawn(0)	new/obj/effect/spacevine_controller(T) //spawn a controller at turf


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue

/datum/spacevine_mutation/proc/process_mutation(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/process_temperature(obj/effect/spacevine/holder, temp, volume)
	return

/datum/spacevine_mutation/proc/on_birth(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_grow(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_death(obj/effect/spacevine/holder)
	return

/datum/spacevine_mutation/proc/on_hit(obj/effect/spacevine/holder, mob/hitter, obj/item/I)
	return

/datum/spacevine_mutation/proc/on_cross(obj/effect/spacevine/holder, mob/crosser)
	return

/datum/spacevine_mutation/proc/on_chem(obj/effect/spacevine/holder, datum/reagent/R)
	return

/datum/spacevine_mutation/proc/on_eat(obj/effect/spacevine/holder, mob/living/eater)
	return

/datum/spacevine_mutation/proc/on_spread(obj/effect/spacevine/holder, turf/target)
	return

/datum/spacevine_mutation/proc/on_buckle(obj/effect/spacevine/holder, mob/living/buckled)
	return

/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"

/datum/spacevine_mutation/light/on_grow(obj/effect/spacevine/holder)
	if(prob(10*severity))
		holder.luminosity = 4

/datum/spacevine_mutation/toxicity
	name = "toxicity"
	hue = "#ff00ff"

/datum/spacevine_mutation/toxicity/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity))
		if(crosser.client)
			crosser << "<span class='alert'>You accidently touch the vine and feel a strange sensation.</span>"
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/effect/spacevine/holder, mob/living/eater)
	eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"

/datum/spacevine_mutation/explosive/on_death(obj/effect/spacevine/holder, mob/hitter, obj/item/I)
	sleep(10)
	explosion(holder.loc, 0, 0, 2, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire resist"
	hue = "#ff8888"

/datum/spacevine_mutation/fire_proof/process_temperature(obj/effect/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"

/datum/spacevine_mutation/vine_eating/on_spread(obj/effect/spacevine/holder, turf/target)
	var/obj/effect/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		prey.Destroy()

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/effect/spacevine/holder, turf/target)
	for(var/atom/A in target)
		if(!istype(A, /obj/effect))
			A.ex_act(severity)  //To not be the same as self-eating vine

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/effect/spacevine/holder, mob/living/buckled)
	buckled.ex_act(severity)

/datum/spacevine_mutation/transparency
	name = "transparency"
	hue = ""

/datum/spacevine_mutation/transparency/on_grow(obj/effect/spacevine/holder)
	holder.SetOpacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "oxygen consumption"
	hue = "#ffff88"

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.oxygen = max(0, GM.oxygen - severity * holder.energy)

/datum/spacevine_mutation/nitro_eater
	name = "nitrogen consumption"
	hue = "#8888ff"

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.nitrogen = max(0, GM.nitrogen - severity * holder.energy)

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consumption"
	hue = "#00ffff"

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.carbon_dioxide = max(0, GM.carbon_dioxide - severity * holder.energy)

/datum/spacevine_mutation/plasma_eater
	name = "toxins consumption"
	hue = "#ffbbff"

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.toxins = max(0, GM.toxins - severity * holder.energy)

/datum/spacevine_mutation/thorns
	name = "thorns"
	hue = "#666666"

/datum/spacevine_mutation/thorns/on_cross(obj/effect/spacevine/holder, crosser)
	if(isliving(crosser) && prob(severity))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"

/datum/spacevine_mutation/thorns/on_hit(obj/effect/spacevine/holder, hitter)
	if(ismob(hitter) && prob(severity))
		var/mob/living/M = hitter
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"

/datum/spacevine_mutation/woodening
	name = "hardening"
	hue = "#997700"

/datum/spacevine_mutation/woodening/on_grow(obj/effect/spacevine/holder)
	if(holder.energy)
		holder.density = 1

/datum/spacevine_mutation/woodening/on_hit(obj/effect/spacevine/holder, mob/hitter, obj/item/I)
	if(hitter)
		var/chance
		if(I)
			chance = I.force * 2
		else
			chance = 8
		if(prob(chance))
			holder.Destroy()
	return 1


// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/effect/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = 1
	density = 0
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null
	var/mob/living/buckled_mob
	var/list/mutations = list()

/obj/effect/spacevine/New()
	return

/obj/effect/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.vines -= src
		master.growth_queue -= src
		if(!master.vines.len)
			var/obj/item/seeds/kudzuseed/KZ = new(loc)
			KZ.mutations |= mutations
	mutations = list()
	SetOpacity(0)
	..()

/obj/effect/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			Destroy()

/obj/effect/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		if(prob(10))
			eater.say("Nom")
		Destroy()

/obj/effect/spacevine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!W || !user || !W.type) return
	user.changeNext_move(CLICK_CD_MELEE)

	var/override = 0

	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_hit(src, user)

	if(override)
		..()
		return

	switch(W.type)
		if(/obj/item/weapon/circular_saw) qdel(src)
		if(/obj/item/weapon/kitchen/utensil/knife) qdel(src)
		if(/obj/item/weapon/scalpel) qdel(src)
		if(/obj/item/weapon/twohanded/fireaxe) qdel(src)
		if(/obj/item/weapon/hatchet) qdel(src)
		if(/obj/item/weapon/melee/energy) qdel(src)
		if(/obj/item/weapon/scythe)
			for(var/obj/effect/spacevine/B in orange(src,1))
				if(prob(80))
					qdel(B)
			qdel(src)

		//less effective weapons
		if(/obj/item/weapon/wirecutters)
			if(prob(25)) qdel(src)
		if(/obj/item/weapon/shard)
			if(prob(25)) qdel(src)

		else //weapons with subtypes
			if(istype(W, /obj/item/weapon/melee/energy/sword)) qdel(src)
			else if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user)) qdel(src)
			else
				manual_unbuckle(user)
				return
		//Plant-b-gone damage is handled in its entry in chemistry-reagents.dm
	..()

/obj/effect/spacevine/Crossed(mob/crosser)
	if(isliving(crosser))
		for(var/datum/spacevine_mutation/SM in mutations)
			SM.on_cross(src, crosser)

/obj/effect/spacevine/attack_hand(mob/user as mob)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	manual_unbuckle(user)


/obj/effect/spacevine/attack_paw(mob/living/user as mob)
	user.do_attack_animation(src)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	manual_unbuckle(user)

/obj/effect/spacevine/proc/unbuckle()
	if(buckled_mob)
		if(buckled_mob.buckled == src)	//this is probably unneccesary, but it doesn't hurt
			buckled_mob.buckled = null
			buckled_mob.anchored = initial(buckled_mob.anchored)
			buckled_mob.update_canmove()
		buckled_mob = null
	return

/obj/effect/spacevine/proc/manual_unbuckle(mob/user as mob)
	if(buckled_mob)
		if(prob(50))
			if(buckled_mob.buckled == src)
				if(buckled_mob != user)
					buckled_mob.visible_message(\
						"<span class='notice'>[user.name] frees [buckled_mob.name] from the vines.</span>",\
						"<span class='notice'>[user.name] frees you from the vines.</span>",\
						"<span class='warning'>You hear shredding and ripping.</span>")
				else
					buckled_mob.visible_message(\
						"<span class='notice'>[buckled_mob.name] struggles free of the vines.</span>",\
						"<span class='notice'>You untangle the vines from around yourself.</span>",\
						"<span class='warning'>You hear shredding and ripping.</span>")
			unbuckle()
		else
			var/text = pick("rip","tear","pull")
			user.visible_message(\
				"<span class='notice'>[user.name] [text]s at the vines.</span>",\
				"<span class='notice'>You [text] at the vines.</span>",\
				"<span class='warning'>You hear shredding and ripping.</span>")
	return

/obj/effect/spacevine_controller
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	var/list/mutations_list = list()
	var/mutativness = 1
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

/obj/effect/spacevine_controller/New(loc, list/muts, mttv)
	if(!istype(src.loc,/turf/simulated/floor))
		qdel(src)

	spawn_spacevine_piece(src.loc, , muts)
	processing_objects.Add(src)
	init_subtypes(/datum/spacevine_mutation/, mutations_list)
	if(mttv != null)
		mutativness = mttv

/obj/effect/spacevine_controller/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/spacevine_controller/proc/spawn_spacevine_piece(var/turf/location, obj/effect/spacevine/parent, list/muts)
	var/obj/effect/spacevine/SV = new(location)
	growth_queue += SV
	vines += SV
	SV.master = src
	if(muts && muts.len)
		SV.mutations |= muts
	if(parent)
		SV.mutations |= parent.mutations
		SV.color = parent.color
		if(prob(mutativness))
			SV.mutations |= pick(mutations_list)
			var/datum/spacevine_mutation/randmut = pick(SV.mutations)
			SV.color = randmut.hue

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)

/obj/effect/spacevine_controller/process()
	if(!vines)
		qdel(src) //space  vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return
	if(vines.len >= 250 && !reached_collapse_size)
		reached_collapse_size = 1
	if(vines.len >= 30 && !reached_slowdown_size )
		reached_slowdown_size = 1

	var/length = 0
	if(reached_collapse_size)
		length = 0
	else if(reached_slowdown_size)
		if(prob(25))
			length = 1
		else
			length = 0
	else
		length = 1
	length = min( 30 , max( length , vines.len / 5 ) )
	var/i = 0
	var/list/obj/effect/spacevine/queue_end = list()

	for( var/obj/effect/spacevine/SV in growth_queue )
		i++
		queue_end += SV
		growth_queue -= SV
		for(var/datum/spacevine_mutation/SM in SV.mutations)
			SM.process_mutation(SV)
		if(SV.energy < 2) //If tile isn't fully grown
			if(prob(20))
				SV.grow()
		else //If tile is fully grown
			SV.buckle_mob()

		//if(prob(25))
		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end
	//sleep(5)
	//src.process()

/obj/effect/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		SetOpacity(1)
		layer = 5
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_grow(src)

/obj/effect/spacevine/proc/buckle_mob()
	if(!buckled_mob && prob(25))
		for(var/mob/living/carbon/V in src.loc)
			for(var/datum/spacevine_mutation/SM in mutations)
				SM.on_buckle(src, V)
			if((V.stat != DEAD)  && (V.buckled != src)) //if mob not dead or captured
				V.buckled = src
				V.loc = src.loc
				V.update_canmove()
				src.buckled_mob = V
				V << "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>"
				break //only capture one mob at a time.

/obj/effect/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_spread(src, step)
	if(istype(step,/turf/simulated/floor))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/effect/spacevine,F))
			if(F.Enter(src))
				if(master)
					master.spawn_spacevine_piece(F, src)

/*
/obj/effect/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated/floor)) dogrowth = 0
	for(var/obj/O in Vspread)
		if (istype(O, /obj/structure/window) || istype(O, /obj/effect/forcefield) || istype(O, /obj/effect/blob) || istype(O, /obj/effect/alien/weeds) || istype(O, /obj/effect/spacevine)) dogrowth = 0
		if (istype(O, /obj/machinery/door/))
			if(O:p_open == 0 && prob(50)) O:open()
			else dogrowth = 0
	if (dogrowth == 1)
		var/obj/effect/spacevine/B = new /obj/effect/spacevine(Vspread)
		B.icon_state = pick("vine-light1", "vine-light2", "vine-light3")
		spawn(20)
			if(B)
				B.Life()
	src.growth += 1
	if (src.growth == 10)
		src.name = "Thick Space Kudzu"
		src.icon_state = pick("vine-med1", "vine-med2", "vine-med3")
		src.opacity = 1
		src.waittime = 80
	if (src.growth == 20)
		src.name = "Dense Space Kudzu"
		src.icon_state = pick("vine-hvy1", "vine-hvy2", "vine-hvy3")
		src.density = 1
	spawn(src.waittime)
		if (src.growth < 20) src.Life()

*/

/obj/effect/spacevine/ex_act(severity)
	switch(severity)
		if(1.0)
			Destroy()
			return
		if(2.0)
			if (prob(90))
				Destroy()
				return
		if(3.0)
			if (prob(50))
				Destroy()
				return
	return

/obj/effect/spacevine/temperature_expose(null, temp, volume)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		Destroy()