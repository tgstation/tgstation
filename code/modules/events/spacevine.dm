/datum/round_event_control/spacevine
	name = "Spacevine"
	typepath = /datum/round_event/spacevine
	weight = 15
	max_occurrences = 3

/datum/round_event/spacevine/start()
	var/list/turfs = list() //list of all the empty floor turfs in the hallway areas

	for(var/area/hallway/A in world)
		for(var/turf/simulated/F in A)
			if(!F.density && !F.contents.len)
				turfs += F

	if(turfs.len) //Pick a turf to spawn at if we can
		var/turf/simulated/T = pick(turfs)
		spawn(0)	new/obj/effect/spacevine_controller(T) //spawn a controller at turf


/datum/spacevine_mutation
	var/name = ""
	var/severity = 1
	var/hue
	var/quality

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


/datum/spacevine_mutation/space_covering
	name = "space protective"
	hue = "#aa77aa"
	quality = POSITIVE

/turf/simulated/floor/vines
	color = "#aa77aa"
	icon_state = "vinefloor"
	broken_states = list()
	ignoredirt = 1


//All of this shit is useless for vines

/turf/simulated/floor/vines/attackby()
	return

/turf/simulated/floor/vines/burn_tile()
	return

/turf/simulated/floor/vines/break_tile()
	return

/turf/simulated/floor/vines/make_plating()
	return

/turf/simulated/floor/vines/break_tile_to_plating()
	return

/turf/simulated/floor/vines/ex_act(severity, target)
	if(severity < 3 || target == src)
		ChangeTurf(src.baseturf)

/turf/simulated/floor/vines/narsie_act()
	if(prob(20))
		ChangeTurf(src.baseturf) //nar sie eats this shit

/turf/simulated/floor/vines/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			ChangeTurf(src.baseturf)

/turf/simulated/floor/vines/ChangeTurf(turf/simulated/floor/T)
	for(var/obj/effect/spacevine/SV in src)
		qdel(SV)
	..()
	UpdateAffectingLights()

/datum/spacevine_mutation/space_covering/on_grow(obj/effect/spacevine/holder)
	if(istype(holder.loc, /turf/space))
		var/turf/spaceturf = holder.loc
		spaceturf.ChangeTurf(/turf/simulated/floor/vines)

/datum/spacevine_mutation/space_covering/process_mutation(obj/effect/spacevine/holder)
	if(istype(holder.loc, /turf/space))
		var/turf/spaceturf = holder.loc
		spaceturf.ChangeTurf(/turf/simulated/floor/vines)

/datum/spacevine_mutation/space_covering/on_death(obj/effect/spacevine/holder)
	if(istype(holder.loc, /turf/simulated/floor/vines))
		var/turf/spaceturf = holder.loc
		spawn(0)
			spaceturf.ChangeTurf(/turf/space)

/datum/spacevine_mutation/bluespace
	name = "bluespace"
	hue = "#3333ff"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/bluespace/on_spread(obj/effect/spacevine/holder, turf/target)
	if(holder.energy > 1 && !locate(/obj/effect/spacevine) in target)
		holder.master.spawn_spacevine_piece(target, holder)

/datum/spacevine_mutation/light
	name = "light"
	hue = "#ffff00"
	quality = POSITIVE

/datum/spacevine_mutation/light/on_grow(obj/effect/spacevine/holder)
	if(prob(10*severity))
		holder.SetLuminosity(4)

/datum/spacevine_mutation/toxicity
	name = "toxic"
	hue = "#ff00ff"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/toxicity/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(issilicon(crosser))
		return
	if(prob(severity) && istype(crosser))
		crosser << "<span class='alert'>You accidently touch the vine and feel a strange sensation.</span>"
		crosser.adjustToxLoss(5)

/datum/spacevine_mutation/toxicity/on_eat(obj/effect/spacevine/holder, mob/living/eater)
	eater.adjustToxLoss(5)

/datum/spacevine_mutation/explosive  //OH SHIT IT CAN CHAINREACT RUN!!!
	name = "explosive"
	hue = "#ff0000"
	quality = NEGATIVE

/datum/spacevine_mutation/explosive/on_death(obj/effect/spacevine/holder, mob/hitter, obj/item/I)
	var/turf/T = holder.loc
	src = T
	spawn(10)
		explosion(T, 0, 0, 2, 0, 0)

/datum/spacevine_mutation/fire_proof
	name = "fire proof"
	hue = "#ff8888"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/fire_proof/process_temperature(obj/effect/spacevine/holder, temp, volume)
	return 1

/datum/spacevine_mutation/vine_eating
	name = "vine eating"
	hue = "#ff7700"
	quality = MINOR_NEGATIVE

/datum/spacevine_mutation/vine_eating/on_spread(obj/effect/spacevine/holder, turf/target)
	var/obj/effect/spacevine/prey = locate() in target
	if(prey && !prey.mutations.Find(src))  //Eat all vines that are not of the same origin
		qdel(prey)

/datum/spacevine_mutation/aggressive_spread  //very OP, but im out of other ideas currently
	name = "aggressive spreading"
	hue = "#333333"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/aggressive_spread/on_spread(obj/effect/spacevine/holder, turf/target)
	for(var/atom/A in target)
		if(!istype(A, /obj/effect))
			A.ex_act(severity)  //To not be the same as self-eating vine

/datum/spacevine_mutation/aggressive_spread/on_buckle(obj/effect/spacevine/holder, mob/living/buckled)
	buckled.ex_act(severity)

/datum/spacevine_mutation/transparency
	name = "transparent"
	hue = ""
	quality = POSITIVE

/datum/spacevine_mutation/transparency/on_grow(obj/effect/spacevine/holder)
	holder.SetOpacity(0)
	holder.alpha = 125

/datum/spacevine_mutation/oxy_eater
	name = "oxygen consuming"
	hue = "#ffff88"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/oxy_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.oxygen = max(0, GM.oxygen - severity * holder.energy)

/datum/spacevine_mutation/nitro_eater
	name = "nitrogen consuming"
	hue = "#8888ff"
	severity = 3
	quality = NEGATIVE

/datum/spacevine_mutation/nitro_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.nitrogen = max(0, GM.nitrogen - severity * holder.energy)

/datum/spacevine_mutation/carbondioxide_eater
	name = "CO2 consuming"
	hue = "#00ffff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/carbondioxide_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.carbon_dioxide = max(0, GM.carbon_dioxide - severity * holder.energy)

/datum/spacevine_mutation/plasma_eater
	name = "toxins consuming"
	hue = "#ffbbff"
	severity = 3
	quality = POSITIVE

/datum/spacevine_mutation/plasma_eater/process_mutation(obj/effect/spacevine/holder)
	var/turf/simulated/floor/T = holder.loc
	if(istype(T))
		var/datum/gas_mixture/GM = T.air
		GM.toxins = max(0, GM.toxins - severity * holder.energy)

/datum/spacevine_mutation/thorns
	name = "thorny"
	hue = "#666666"
	severity = 10
	quality = NEGATIVE

/datum/spacevine_mutation/thorns/on_cross(obj/effect/spacevine/holder, mob/living/crosser)
	if(prob(severity) && istype(crosser))
		var/mob/living/M = crosser
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"

/datum/spacevine_mutation/thorns/on_hit(obj/effect/spacevine/holder, mob/living/hitter)
	if(prob(severity) && istype(hitter))
		var/mob/living/M = hitter
		M.adjustBruteLoss(5)
		M << "<span class='alert'>You cut yourself on the thorny vines.</span>"

/datum/spacevine_mutation/woodening
	name = "hardened"
	hue = "#997700"
	quality = NEGATIVE

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
			qdel(holder)
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
	mouse_opacity = 2 //Clicking anywhere on the turf is good enough
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null
	var/list/mutations = list()

/obj/effect/spacevine/Destroy()
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_death(src)
	if(master)
		master.vines -= src
		master.growth_queue -= src
		if(!master.vines.len)
			var/obj/item/seeds/kudzuseed/KZ = new(loc)
			KZ.mutations |= mutations
			KZ.potency = min(100, master.mutativness * 10)
			KZ.production = (master.spread_cap / initial(master.spread_cap)) * 50
	mutations = list()
	SetOpacity(0)
	if(buckled_mob)
		unbuckle_mob()
	..()

/obj/effect/spacevine/proc/on_chem_effect(datum/reagent/R)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_chem(src, R)
	if(!override && istype(R, /datum/reagent/toxin/plantbgone))
		if(prob(50))
			qdel(src)

/obj/effect/spacevine/proc/eat(mob/eater)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_eat(src, eater)
	if(!override)
		if(prob(10))
			eater.say("Nom")
		qdel(src)

/obj/effect/spacevine/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if (!W || !user || !W.type)
		return
	user.changeNext_move(CLICK_CD_MELEE)

	var/override = 0

	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.on_hit(src, user)

	if(override)
		..()
		return

	if(istype(W, /obj/item/weapon/scythe))
		for(var/obj/effect/spacevine/B in orange(src,1))
			if(prob(80))
				qdel(B)
		qdel(src)

	else if(is_sharp(W))
		qdel(src)

	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			qdel(src)
		else
			user_unbuckle_mob(user,user)
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
	user_unbuckle_mob(user, user)


/obj/effect/spacevine/attack_paw(mob/living/user as mob)
	user.do_attack_animation(src)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_hit(src, user)
	user_unbuckle_mob(user,user)



/obj/effect/spacevine_controller
	var/list/obj/effect/spacevine/vines = list()
	var/list/growth_queue = list()
	var/spread_multiplier = 5
	var/spread_cap = 30
	var/list/mutations_list = list()
	var/mutativness = 1

/obj/effect/spacevine_controller/New(loc, list/muts, mttv, spreading)
	spawn_spacevine_piece(loc, , muts)
	SSobj.processing |= src
	init_subtypes(/datum/spacevine_mutation/, mutations_list)
	if(mttv != null)
		mutativness = mttv / 10
	if(spreading != null)
		spread_cap *= spreading / 50
		spread_multiplier /= spreading / 50

/obj/effect/spacevine_controller/ex_act() //only killing all vines will end this suffering
	return

/obj/effect/spacevine_controller/singularity_act()
	return

/obj/effect/spacevine_controller/singularity_pull()
	return

/obj/effect/spacevine_controller/Destroy()
	SSobj.processing.Remove(src)
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
		SV.desc = parent.desc
		if(prob(mutativness))
			SV.mutations |= pick(mutations_list)
			var/datum/spacevine_mutation/randmut = pick(SV.mutations)
			SV.color = randmut.hue
			SV.desc = "An extremely expansionistic species of vine. These are "
			for(var/datum/spacevine_mutation/M in SV.mutations)
				SV.desc += "[M.name] "
			SV.desc += "vines."

	for(var/datum/spacevine_mutation/SM in SV.mutations)
		SM.on_birth(SV)

/obj/effect/spacevine_controller/process()
	if(!vines)
		qdel(src) //space  vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return

	var/length = 0

	length = min( spread_cap , max( 1 , vines.len / spread_multiplier ) )
	var/i = 0
	var/list/obj/effect/spacevine/queue_end = list()

	for( var/obj/effect/spacevine/SV in growth_queue )
		if(SV.gc_destroyed)	continue
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

/obj/effect/spacevine/buckle_mob()
	if(!buckled_mob && prob(25))
		for(var/mob/living/carbon/V in src.loc)
			for(var/datum/spacevine_mutation/SM in mutations)
				SM.on_buckle(src, V)
			if((V.stat != DEAD) && (V.buckled != src)) //not dead or captured
				V << "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>"
				..(V)
				break //only capture one mob at a time

/obj/effect/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/turf/stepturf = get_step(src,direction)
	for(var/datum/spacevine_mutation/SM in mutations)
		SM.on_spread(src, stepturf)
		stepturf = get_step(src,direction) //in case turf changes, to make sure no runtimes happen
	if(!locate(/obj/effect/spacevine, stepturf))
		if(stepturf.Enter(src))
			if(master)
				master.spawn_spacevine_piece(stepturf, src)

/*
/obj/effect/spacevine/proc/Life()
	if (!src) return
	var/Vspread
	if (prob(50)) Vspread = locate(src.x + rand(-1,1),src.y,src.z)
	else Vspread = locate(src.x,src.y + rand(-1, 1),src.z)
	var/dogrowth = 1
	if (!istype(Vspread, /turf/simulated)) dogrowth = 0
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

/obj/effect/spacevine/ex_act(severity, target)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(90))
				qdel(src)
				return
		if(3.0)
			if (prob(50))
				qdel(src)
				return
	return

/obj/effect/spacevine/temperature_expose(null, temp, volume)
	var/override = 0
	for(var/datum/spacevine_mutation/SM in mutations)
		override += SM.process_temperature(src, temp, volume)
	if(!override)
		qdel(src)
