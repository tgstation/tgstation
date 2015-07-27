/*

Prototype board sources:
	dismantling strange devices
	cargo crate
	some very expensive R&D design ? 
Prototype chassis can be printed at R&D, put one or two in experimentor lab


*/

/datum/prototype
	var/obj/structure/prototype/owner

/datum/prototype/New(var/obj/structure/prototype/master)
	owner = master

//Activators

#define ACTIVATOR_HAND 1
#define ACTIVATOR_ENERGY 2
#define ACTIVATOR_PROCESS 3

/datum/prototype/activator/proc/activate_check(user,type)
	return 0

/datum/prototype/activator/proc/activate(user,type)
	if(owner.cooldown<world.time)
		if(activate_check(user,type))
			log_game("[key_name(user)] activated prototype with [owner.effect.type] effect at ([owner.x], [owner.y], [owner.z]).")
			owner.cooldown = world.time + owner.effect.cooldown * owner.target.cooldown_multiplier
			owner.visible_message("<span class='warning'>[owner] activates!</span>")
			owner.visible_message("<span class='warning'>[owner] [owner.effect.message]</span>")
			if(owner.effect.no_target)
				owner.effect.activate(user)
			var/list/targets = owner.target.get_targets(user)
			if(targets)
				for(var/T in targets)
					owner.effect.apply(T)
	else
		user << "<span class='notice'>[owner] is recharging.</span>"


/datum/prototype/activator/simple/activate_check(user,type)
	return type == ACTIVATOR_HAND


//EFFECTS
/datum/prototype/effect
	var/cooldown = 300
	var/no_target = 0 //If the effect does not need targets/have static ones
	var/message = "hums." //For these effects that would be very hard to identify

/datum/prototype/effect/proc/apply(target) /// Ugh, i could use the method resolution hack but i guess this is more understandable
	if(ishuman(target))
		human_effect(target)
	else if(istype(target,/mob))
		mob_effect(target)
	else if(istype(target,/turf))
		turf_effect(target)
	return

/datum/prototype/effect/proc/human_effect(mob/living/carbon/human/target)
	return
/datum/prototype/effect/proc/mob_effect(mob/target)
	return
/datum/prototype/effect/proc/turf_effect(turf/target)
	return
/datum/prototype/effect/proc/activate(mob/user)
	return

//Effects proper
/datum/prototype/effect/hunger/human_effect(mob/living/carbon/human/target)
	target.nutrition -= 50
	target << "<span class='warning'>You feel hungry</span>"

/datum/prototype/effect/hallucination
	var/halo_type = "xeno"
/datum/prototype/effect/hallucination/New()
	halo_type = pick("xeno","whispers","delusion")
	..()

/datum/prototype/effect/hallucination/human_effect(mob/living/carbon/human/target)
	target.hallucinate(halo_type)

/datum/prototype/effect/wall_rust/turf_effect(turf/target)	
	if(istype(target,/turf/simulated/wall/r_wall))
		var/turf/simulated/wall/r_wall/W  = target
		W.ChangeTurf(/turf/simulated/wall/r_wall/rust)
	else if(istype(target,/turf/simulated/wall))
		var/turf/simulated/wall/W = target
		W.ChangeTurf(/turf/simulated/wall/rust)
	return

/datum/prototype/effect/lube/turf_effect(turf/target)	
	var/turf/simulated/T = target
	T.MakeSlippery(2)

/datum/prototype/effect/spawner
	var/path = /mob/living/simple_animal/mouse
	message = "universal constructor activates."
	no_target = 1

/datum/prototype/effect/spawner/activate(mob/user)
	new path(get_turf(owner))

/datum/prototype/effect/spawner/popcorn
	path = /obj/item/weapon/reagent_containers/food/snacks/popcorn

/datum/prototype/effect/injector
	var/reagent = "ethanol"
	var/amount = 5

/datum/prototype/effect/injector/human_effect(mob/living/carbon/human/target)
	mob_effect(target)

/datum/prototype/effect/injector/mob_effect(mob/target)
	if(isliving(target))
		var/mob/living/M = target
		var/datum/reagents/R = new(amount)
		R.my_atom = owner
		R.add_reagent(reagent,amount)
		R.reaction(M,INGEST)
		R.trans_to(M,amount)
		M << "<span class='warning'>You feel a tiny prick!</span>"

/datum/prototype/effect/injector/drugs
	reagent = "space_drugs"
	amount = 10

/datum/prototype/effect/injector/brainheal
	reagent = "mannitol"
	amount = 10

/datum/prototype/effect/grass/turf_effect(turf/target)
	if(istype(target,/turf/simulated/floor))
		var/turf/simulated/floor/F = target
		F.ChangeTurf(/turf/simulated/floor/grass)

/datum/prototype/effect/painter
	var/color = "C73232" //Red

/datum/prototype/effect/painter/turf_effect(turf/target)
	target.color = "#" + color

/datum/prototype/effect/painter/blue
	color = "5998FF" //Blue
/datum/prototype/effect/painter/green
	color = "2A9C3B" //Green


/datum/prototype/effect/screamer/human_effect(mob/living/carbon/human/target)
	target.emote("scream")

/datum/prototype/effect/boombox/human_effect(mob/living/carbon/human/target)
	target << 'sound/effects/Explosion1.ogg'


/datum/prototype/effect/tamer/human_effect(mob/living/carbon/human/target)
	mob_effect(target)

/datum/prototype/effect/tamer/mob_effect(mob/target)
	target.faction |= "neutral"
	target << "<span class='notice'>You feel calm.</span>"


/datum/prototype/effect/fireworks/turf_effect(var/turf/target)
	var/obj/effect/effect/sparks/S = new(target)
	S.color = pick("#C73232","#5998FF","#2A9C3B")

/datum/prototype/effect/bleedstop
	message = "emits a soothing sound."
/datum/prototype/effect/bleedstop/human_effect(mob/living/carbon/human/target)
	target.suppress_bloodloss(600)

/datum/prototype/effect/hatsoff/human_effect(mob/living/carbon/human/target)
	if(target.head)
		if(target.unEquip(target.head))
			target << "<span class='warning'>Your headgear suddenly falls off!</span>"

/datum/prototype/effect/growth
	message = "sprays something into the air."
/datum/prototype/effect/growth/turf_effect(turf/target)
	for(var/obj/machinery/hydroponics/H in target)
		H.adjustWater(100)
		H.adjustNutri(10)
		H.update_icon()

/datum/prototype/effect/bolt
	message = "pings."

/datum/prototype/effect/bolt/turf_effect(var/turf/target)
	for(var/obj/machinery/door/airlock/A in target)
		A.bolt()

/datum/prototype/effect/zombie
	message = "emits an omnious sound."
/datum/prototype/effect/zombie/human_effect(mob/living/carbon/human/target)
	if(target.stat == DEAD)
		var/mob/living/simple_animal/hostile/blob/blobspore/B = new(target.loc)
		B.Zombify(target)

/datum/prototype/effect/cigar/human_effect(mob/living/carbon/human/target)
	if(!target.wear_mask)
		var/obj/item/clothing/mask/cigarette/cigar/I = new
		target.equip_to_slot_or_del(I,slot_wear_mask)
		target << "<span class='warning'>Suddenly [I] appears in your mouth!</span>"

/datum/prototype/effect/thehorror/human_effect(mob/living/carbon/human/target)
	//Has science gone too far ?
	if(target.dna && target.dna.species.id == "human" && prob(25))
		target.dna.features["tail_human"] = "Cat"
		target.dna.features["ears"] = "Cat"
		target.regenerate_icons()
	else
		target << "<span class='notice'>Meow?</span>"

/datum/prototype/effect/powergen
	message = "hums loudly."
/datum/prototype/effect/powergen/turf_effect(turf/target)
	for(var/obj/machinery/power/apc/A in target)
		A.cell.give(1000)
	return

/datum/prototype/effect/hearts/human_effect(mob/living/carbon/human/target)
	target << "<span class='notice'>You feel eveything is going to be alright.</span>"
	flick_overlay(image('icons/mob/animal.dmi',target,"heart-ani2",MOB_LAYER+1), list(target.client), 20)

/datum/prototype/effect/robofixer
	message = "sprays something into the air."
/datum/prototype/effect/robofixer/mob_effect(mob/target)
	if(isrobot(target))
		var/mob/living/silicon/robot/R = target
		R.adjustBruteLoss(-30)
		R << "<span class='notice'>Your are being repaired by something!</span>"

/datum/prototype/effect/glass_fill
	var/chem_id = "milk"
	message = "Extends a vapour condensator."

/datum/prototype/effect/glass_fill/turf_effect(turf/target)
	for(var/obj/item/weapon/reagent_containers/glass/G in target)
		G.reagents.add_reagent(chem_id,20)

/datum/prototype/effect/autominer
	message = "emits a high-pitched sound."
/datum/prototype/effect/autominer/turf_effect(turf/target)
	if(istype(target,/turf/simulated/mineral))
		var/turf/simulated/mineral/M = target
		M.gets_drilled()

/datum/prototype/effect/glassbreak
	message = "emits a high-pitched sound."
/datum/prototype/effect/glassbreak/turf_effect(turf/target)
	for(var/obj/structure/window/W in target)
		W.hit(50)

/datum/prototype/effect/transmute/turf_effect(turf/target)
	for(var/obj/item/stack/sheet/metal/S in target)
		var/obj/item/stack/sheet/mineral/gold/G = new(target)
		G.amount = S.amount
		qdel(S)

/datum/prototype/effect/gas
	no_target = 1
	message = "emits a cloud of smoke."
	var/chem_id = "carbon"
	var/volume = 15

/datum/prototype/effect/gas/activate(mob/user)
	var/datum/reagents/R = new/datum/reagents(volume)
	R.my_atom = owner
	if(chem_id)
		R.add_reagent(chem_id,volume)
	var/datum/effect/effect/system/smoke_spread/chem/smoke = new
	smoke.set_up(R,3,0, get_turf(owner), 0)
	smoke.start()
	return

/datum/prototype/effect/feedback
	no_target = 1
	message = "emits a loud crack!"

/datum/prototype/effect/feedback/activate(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		L.electrocute_act(20)

/datum/prototype/effect/webs/turf_effect/(turf/target)
	var/obj/effect/spider/stickyweb/W = new(target)
	W.color = "#5998FF"


/datum/prototype/effect/magnet
	no_target = 1

/datum/prototype/effect/magnet/activate(mob/user)
	var/turf/center = get_turf(owner)
	for(var/obj/M in orange(7, center))
		if(!M.anchored && (M.flags & CONDUCT))
			M.throw_at(owner,16,5)

/datum/prototype/effect/noise
	no_target = 1
	message = "emits a loud noise."

/datum/prototype/effect/noise/activate(mob/user)
	playsound(owner.loc, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/L in view(owner))
		if(!L.check_ear_prot())
			L.setEarDamage(L.ear_damage + rand(0, 5), max(L.ear_deaf,15))
			if (L.ear_damage >= 15)
				L << "<span class='warning'>Your ears start to ring badly!</span>"
				if(prob(L.ear_damage - 10 + 5))
					L << "<span class='warning'>You can't hear anything!</span>"
					L.disabilities |= DEAF
			else
				if (L.ear_damage >= 5)
					L << "<span class='warning'>Your ears start to ring!</span>"

/datum/prototype/effect/augment
	no_target = 1
	message = "extends an actuator."

/datum/prototype/effect/augment/activate(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/limb/L = H.getlimb(/obj/item/organ/limb/chest)
	if(L)
		L.loc = get_turf(H)
		H.organs -= L
		var/datum/surgery_step/xenomorph_removal/xeno_removal = new
		xeno_removal.remove_xeno(user, H)
		H.organs += new /obj/item/organ/limb/robot/chest(src)
		for(var/datum/disease/appendicitis/A in H.viruses)
			A.cure(1)
		H.update_damage_overlays(0)
		H.update_augments()
		H << "<span class='warning'>[owner] augments your chest!</span>"
	else
		H << "<span class='warning'>[owner] buzzes.</span>"

/datum/prototype/effect/oracle
	no_target = 1
	message = "prints something!"

/datum/prototype/effect/oracle/activate(mob/user)
	var/text = "<h2>Stochastic Analyzer Projection:</h2><hr>"
	var/prediction = ""
	for(var/i=0,i<=rand(1,3),i++)
		switch(rand(1,10))
			if(1)
				var/threat = capitalize(lowertext(pick_list("ion_laws.txt", "ionthreats")))
				prediction = "[station_name()] - [threat] attack - Probability [rand(50,99)]%"
			if(2)
				var/place = capitalize(lowertext(pick_list("ion_laws.txt", "ionarea")))
				prediction = "[place] destruction - Probability [rand(50,99)]% "
			if(3)
				var/crew = capitalize(lowertext(pick_list("ion_laws.txt", "ioncrew")))
				prediction = "[crew] insubordination - Probability [rand(50,99)]%"
			if(4)
				var/random_code = rand(10000,99999)
				prediction = "Nuclear self-destruct device code set to [random_code] - Probability [rand(1,99)]%"
			if(5)
				var/dead_count = 0
				for(var/mob/living/carbon/human/H in dead_mob_list)
					dead_count ++
				prediction = "[dead_count] human casualties - Probability [rand(90,100)]%"
			if(6)
				var/dead = 0
				for(var/mob/dead/observer/O in dead_mob_list)
					if(!O.started_as_observer)
						dead++
				var/alive = joined_player_list.len
				var/ratio = round((dead/alive)*100,1)
				prediction = "[ratio] ectoplasmic density - Probability [rand(90,100)]%"
			if(7)//fix
				prediction = "[apcs_list.len] APCs present - Probability [rand(90,100)]%"
			if(8)
				prediction = "[mechas_list.len] mechas present - Probability [rand(90,100)]%"
			if(9)
				var/clowns = 0
				var/non_clowns = 0
				for(var/mob/living/carbon/human/H in living_mob_list)
					if(H.disabilities & CLUMSY)
						clowns++
					else
						non_clowns++
				var/ratio = clowns/(clowns + non_clowns)
				prediction = "[ratio] clown saturation - Probability [rand(90,100)]%"
			if(10)
				var/singularity_present = 0
				for(var/obj/singularity/S in world)
					singularity_present = 1
					break
				prediction = "Singularity present - Probability [singularity_present?"100%":"0%"]"
		text += prediction
		text += "</br>"
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(owner.loc)
	P.info = text
	P.name = "paper- 'Probability Analyzer Report'"

/datum/prototype/effect/ghostdetector
	no_target = 1
	message = "emits a green flash."

/datum/prototype/effect/ghostdetector/activate(mob/user)
	var/turf/center = get_turf(owner)
	var/list/counts = list("N" = 0,"S" = 0,"E" = 0,"W" = 0)
	var/cur_dir
	for(var/mob/dead/observer/O in dead_mob_list)
		cur_dir = get_dir(center,O)
		if(cur_dir & NORTH)
			counts["N"]++
		if(cur_dir & SOUTH)
			counts["S"]++
		if(cur_dir & EAST)
			counts["E"]++
		if(cur_dir & WEST)
			counts["W"]++
	var/final = ""
	var/max_value = max(counts["N"],counts["S"],counts["E"],counts["W"]) //I love byond
	for(var/i=1,i<=counts.len,i++)
		final = counts[i]
		if(counts[final] == max_value)
			break
	var/image/I = image('icons/misc/mark.dmi',owner,"basic",FLOAT_LAYER)
	var/matrix/M = matrix()
	switch(final)
		if("N")
			user << "<span class='notice'>The [owner] points north.</span>"
		if("S")
			user << "<span class='notice'>The [owner] points south.</span>"
			M.Turn(180)
			I.transform = M
		if("W")
			user << "<span class='notice'>The [owner] points west.</span>"
			M.Turn(-90)
			I.transform = M
		if("E")
			user << "<span class='notice'>The [owner] points east.</span>"
			M.Turn(90)
			I.transform = M
	flick_overlay(I,list(user.client),50)
	return

/obj/effect/rift
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0
	var/list/turf_paths = list()
	var/list/mob_paths = list()
	var/mobs_per_wave = 2
	var/current_wave = 0
	var/max_waves = 7
	var/wave_delay = 450
	var/wave_time = 0
	var/obj/item/device/assembly/signaler/rift/aSignal = null

/obj/effect/rift/attackby(obj/item/W,mob/living/user, params)
	if(istype(W,/obj/item/weapon/nullrod))
		for(var/obj/item/I in src)
			I.loc = src.loc
		user << "<span class='notice'>You disperse the [src] with the power of the [W]!</span>"
		Neutralize()
		
	if(istype(W, /obj/item/device/analyzer))
		user << "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [aSignal.code]:[format_frequency(aSignal.frequency)].</span>"

/obj/effect/rift/proc/wave(wave)
	current_wave++
	if(current_wave == max_waves)
		SSobj.processing.Remove(src)
		return
	for(var/turf/T in circlerange(src,wave))
		T.ChangeTurf(pick(turf_paths))
	for(var/i=0,i<mobs_per_wave,i++)
		var/mob_p = pick(mob_paths)
		new mob_p(get_turf(src))

/obj/effect/rift/proc/Neutralize()
	visible_message("<span class='warning'>[src] collapses!</span>")
	SSobj.processing.Remove(src)
	qdel(src)

/obj/effect/rift/Destroy()
	qdel(aSignal)
	..()

/obj/effect/rift/New()
	wave_time = world.time + wave_delay
	SSobj.processing |= src

	aSignal = new(src)
	aSignal.code = rand(1,100)

	aSignal.frequency = rand(1200, 1599)
	if(IsMultiple(aSignal.frequency, 2))//signaller frequencies are always uneven!
		aSignal.frequency++

/obj/effect/rift/process()
	if(world.time >= wave_time)
		wave(current_wave)
		wave_time = world.time + wave_delay

/obj/item/device/assembly/signaler/rift
	name = "rift signaler"
	desc = "You probably shouldn't see this"

/obj/item/device/assembly/signaler/rift/receive_signal(datum/signal/signal)
	if(!signal)
		return 0
	if(signal.encryption != code)
		return 0
	var/obj/effect/rift/R = src.loc
	if(!istype(R))
		qdel(src)
	else
		R.Neutralize()

/obj/effect/rift/cult
	turf_paths = list(/turf/simulated/floor/engine/cult)
	mob_paths =  list(/mob/living/simple_animal/hostile/faithless) //replace with constructs when they get turned into /hostile
	mobs_per_wave = 1
/obj/effect/rift/hivebot
	turf_paths = list(/turf/simulated/floor/bluegrid,/turf/simulated/floor/greengrid)
	mob_paths =  list(/mob/living/simple_animal/hostile/hivebot,/mob/living/simple_animal/hostile/hivebot/range,/mob/living/simple_animal/hostile/hivebot/strong)
	mobs_per_wave = 3

/obj/effect/rift/alien
	turf_paths = list(/turf/simulated/floor/plating/asteroid)
	mob_paths =  list(/mob/living/simple_animal/hostile/alien,/mob/living/simple_animal/hostile/alien/drone,/mob/living/simple_animal/hostile/alien/sentinel,/mob/living/simple_animal/hostile/alien/queen)
	mobs_per_wave = 1

/datum/prototype/effect/rift
	no_target = 1
	cooldown = 3000
	message = "bluespace synchronizer activates."
	var/list/rift_types = list(/obj/effect/rift/cult,/obj/effect/rift/hivebot,/obj/effect/rift/alien)

/datum/prototype/effect/rift/activate(mob/user)
	var/list/targets = list()
	for(var/turf/T in range(1,get_turf(owner)))
		targets += T
	var/turf/T = pick(targets)
	var/rift_type = pick(rift_types)
	new rift_type(T)

//Targeting datums
/datum/prototype/target
	var/cooldown_multiplier = 1

/datum/prototype/target/proc/get_targets(mob/user)
	var/list/targets = list()
	targets += user
	for(var/turf/T in range(1,get_turf(owner)))
		targets += T
	return targets

/datum/prototype/target/range
	var/power = 1

/datum/prototype/target/range/get_targets(mob/user)
	var/list/targets = list()
	for(var/mob/M in range(power,get_turf(owner)))
		targets |= M
	for(var/turf/T in range(power,get_turf(owner)))
		targets |= T
	return targets

/datum/prototype/target/range/short
	power = 2

/datum/prototype/target/range/long
	power = 7


/datum/prototype/target/view/get_targets(mob/user)
	var/list/targets = list()
	for(var/mob/M in view(get_turf(owner)))
		targets |= M
	for(var/turf/T in range(get_turf(owner)))
		targets |= T
	return targets

/datum/prototype/target/cannon
	var/power = 7
/datum/prototype/target/cannon/get_targets(mob/user)
	var/list/targets = list()
	if(!user)
		return targets
	else
		var/turf/current = get_turf(owner)
		var/dir = get_dir(get_turf(user),current)
		for(var/i=0,i<=power,i++)
			current = get_step(current,dir)
			targets |= current
			for(var/mob/M in current)
				targets |= M
	return targets

/datum/prototype/target/species
	var/target_id = "human"

/datum/prototype/target/species/get_targets(mob/user)
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.z != owner.z)
			continue
		if(H.dna && H.dna.species && H.dna.species.id == target_id)
			targets |= H
	return targets

/datum/prototype/target/species/lizard
	target_id = "lizard"

/datum/prototype/target/circle
	var/radius = 5
/datum/prototype/target/circle/get_targets(mob/user)
	var/list/targets = list()

	var/turf/center = get_turf(owner)
	var/rsq = radius * radius

	for(var/turf/T in range(radius, center))
		var/dx = T.x - center.x
		var/dy = T.y - center.y
		var/val = dx*dx + dy*dy
		if(val == rsq || val == rsq -1 || val == rsq +1)
			targets |= T

	return targets

/datum/prototype/target/wall/get_targets(mob/user)
	var/list/targets = list()
	if(!user)
		return targets
	else
		var/turf/current = get_turf(owner)
		var/dir = get_dir(get_turf(user),current)
		current = get_step(current,dir)
		targets += current
		dir = turn(dir,90)
		for(var/i=0,i<=3,i++)
			current = get_step(current,dir)
			targets |= current
		current = get_turf(owner)
		dir = get_dir(get_turf(user),current)
		current = get_step(current,dir)
		dir = turn(dir,-90)
		for(var/i=0,i<=3,i++)
			current = get_step(current,dir)
			targets |= current
	return targets

/datum/prototype/target/aim/get_targets(mob/user)
	var/list/targets = list()
	for(var/mob/living/M in view(owner))
		targets |= M
		for(var/turf/T in range(1,M))
			targets |= T
	return targets

/obj/structure/prototype
	name = "Prototype"
	desc = "Who knows what it does"
	icon = 'icons/obj/machines/research.dmi'
	icon_state	= "prototype"
	density = 1

	var/datum/prototype/activator/activator = null
	var/datum/prototype/effect/effect = null
	var/datum/prototype/target/target = null

	var/cooldown = 0

/obj/structure/prototype/attack_hand(mob/user)
	activator.activate(user,ACTIVATOR_HAND)

/obj/structure/prototype/attackby(obj/item/W,mob/living/user, params)
	if(istype(W,/obj/item/weapon/screwdriver))
		for(var/obj/item/I in src)
			I.loc = src.loc
		user << "<span class='notice'>You dismantle the [src]</span>"
		qdel(src)


/obj/structure/prototype/proc/Initialize(effect_s,target_s)
	effect_s = list2text(sortTim(list(effect_s),cmp=/proc/cmp_text_asc))
	target_s = list2text(sortTim(list(target_s),cmp=/proc/cmp_text_asc))

	activator = new /datum/prototype/activator/simple(src)
	
	var/effect_t = prototype_mapping[effect_s]
	if(ispath(effect_t,/datum/prototype/effect))
		effect = new effect_t(src)
	else
		effect = new /datum/prototype/effect(src)

	var/target_t = prototype_mapping[target_s]
	if(ispath(target_t,/datum/prototype/target))
		target = new target_t(src)
	else
		target = new /datum/prototype/target(src)

/obj/structure/prototype/random/New()
	name = "Prototype [pick("Alpha","Omega","Zero","X")]"

	var/acttype = pick(typesof(/datum/prototype/activator)-/datum/prototype/activator)
	var/efftype = pick(typesof(/datum/prototype/effect)-/datum/prototype/effect)
	var/tartype = pick(typesof(/datum/prototype/target)-/datum/prototype/target)

	activator = new acttype(src)
	effect = new efftype(src)
	target = new tartype(src)


/obj/item/protoboard
	name = "prototype board"
	desc = "Small board."
	icon = 'icons/obj/cloning.dmi'
	icon_state	= "harddisk"
	var/block = "A"

/obj/item/protoboard/New()
	block = pick("A","B","C","D","E","F","G","H")
	var/list/block_colors = list("A"="#7f6240","B"="#269954","C"="#3385cc","D"="#ee00ff","E"="#f27979","F"="#ffcc00","G"="#00331b","H"="#10f0d2")
	desc = initial(desc)+" Has a [block] stamp in the corner."
	color = block_colors[block]

/obj/item/protochassis
	name = "prototype chassis"
	desc = "work in progress"
	icon = 'icons/obj/machines/research.dmi'
	icon_state	= "prototype_o"

	var/list/effect_boards = list(null,null,null)
	var/list/target_boards = list(null,null,null)

/obj/item/protochassis/attackby(obj/item/W,mob/living/user, params)
	if(istype(W,/obj/item/weapon/screwdriver))
		if(!isturf(loc))
			user << "span class='warning'>[src] must be on the floor to be finished.</span>"
			return
		var/effect = ""
		var/target = ""
		for(var/i=1,i<=3,i++)
			if(!effect_boards[i])
				user << "<span class='notice'>[src] is not complete yet!</span>"
				return
			else
				var/obj/item/protoboard/board = effect_boards[i]
				effect += board.block
		for(var/i=1,i<=3,i++)
			if(target_boards[i])
				var/obj/item/protoboard/board = target_boards[i]
				target += board.block
		user << "<span class='notice'>You finish the prototype.</span>"
		var/obj/structure/prototype/P = new(get_turf(src))
		P.Initialize(effect,target)
		src.loc = P
		return
	else if(istype(W,/obj/item/protoboard))
		for(var/i=1,i<=3,i++)
			if(!effect_boards[i])
				if(!user.unEquip(W))
					return
				effect_boards[i] = W
				W.loc = src
				user << "<span class='notice'>You slot [W] into [src] primary track!</span>"
				return
		for(var/i=1,i<=3,i++)
			if(!target_boards[i])
				if(!user.unEquip(W))
					return
				target_boards[i] = W
				W.loc = src
				user << "<span class='notice'>You slot [W] into [src] secondary track!</span>"
				return
		user << "<span class='notice'>[src] is full!</span>"

/obj/item/protochassis/attack_self(mob/living/user)
	interact(user)

/obj/item/protochassis/interact(mob/user = usr)
	var/datum/browser/popup = new(user, "prototype","Prototype",nref=src)
	popup.set_content(get_content())
	popup.open()

/obj/item/protochassis/proc/get_content()
	var/html
	html = "<h3>Primary System</h3><hr><table><tr>"
	html += "</tr><tr>"
	for(var/i = 1,i<=3,i++)
		if(effect_boards[i])
			var/obj/item/protoboard/B = effect_boards[i]
			html += "<td><a href='?src=\ref[src];primary=[i]'>Type [B.block]</a></td>"
		else
			html += "<td><a href='?src=\ref[src];primary=[i]'>No Board</a></td>"
	html += "<td>[check_track(0)]</td>"
	html += "</tr><tr><h3>Secondary System</h3></tr><tr>"
	for(var/i = 1,i<=3,i++)
		if(target_boards[i])
			var/obj/item/protoboard/B = target_boards[i]
			html += "<td><a href='?src=\ref[src];secondary=[i]'>Type [B.block]</a></td>"
		else
			html += "<td><a href='?src=\ref[src];secondary=[i]'>No Board</a></td>"
	html += "<td>[check_track(1)]</td>"
	html += "</tr></table>"
	return html

/obj/item/protochassis/proc/check_track(track)
	var/pattern = ""
	var/boards = track ? target_boards : effect_boards
	. = "<span class='bad'>Track Unstable</span>"
	for(var/i = 1,i<=3,i++)
		if(boards[i])
			var/obj/item/protoboard/B = boards[i]
			pattern += B.block
		else
			return .

	var/id = list2text(sortTim(list(pattern),cmp=/proc/cmp_text_asc))

	var/t = prototype_mapping[id]
	if(ispath(t,track ? /datum/prototype/target : /datum/prototype/effect))
		return "<span class='good'>Track Stable</span>"

/obj/item/protochassis/Topic(href,list/href_list)
	if(usr != loc)
		usr << browse(null, "window=prototype")
		return
	if(href_list["primary"])
		var/d = text2num(href_list["primary"])
		if(effect_boards[d])
			var/obj/item/protoboard/B = effect_boards[d]
			B.loc = get_turf(src)
			effect_boards[d] = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/protoboard))
				if(!usr.drop_item())
					return
				I.loc = src
				effect_boards[d] = I
		interact()
		return
	if(href_list["secondary"])
		var/d = text2num(href_list["secondary"])
		if(target_boards[d])
			var/obj/item/protoboard/B = target_boards[d]
			B.loc = get_turf(src)
			target_boards[d] = null
		else
			var/obj/item/I = usr.get_active_hand()
			if (istype(I, /obj/item/protoboard))
				if(!usr.drop_item())
					return
				I.loc = src
				target_boards[d] = I
		interact()
		return

/obj/item/weapon/relic/attackby(obj/item/W,mob/living/user, params)
	if(istype(W,/obj/item/weapon/screwdriver))
		user << "<span class='notice'>You dismantle the [src].</span>"
		new/obj/item/protoboard(get_turf(src))
		new/obj/item/protoboard(get_turf(src))
		new/obj/item/protoboard(get_turf(src))
		qdel(src)