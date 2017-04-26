//gwyn

/obj/effect/ebeam/chain
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/datum/guardian_abilities/lightning
	id = "lightning"
	name = "Controlled Current"
	value = 7
	var/datum/beam/userchain
	var/list/enemychains
	var/successfulshocks = 0

/datum/guardian_abilities/lightning/handle_stats()

	guardian.melee_damage_lower += 4
	guardian.melee_damage_upper += 4
	guardian.attacktext = "shocks"
	guardian.melee_damage_type = BURN
	guardian.attack_sound = 'sound/machines/defib_zap.ogg'
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.15
	guardian.range += 4

/datum/guardian_abilities/lightning/recall_act()
	removechains()

/datum/guardian_abilities/lightning/ability_act()
	if(isliving(guardian.target) && guardian.target != guardian && guardian.target != user)
		cleardeletedchains()
		for(var/chain in enemychains)
			var/datum/beam/B = chain
			if(B.target == guardian.target)
				return //oh this guy already HAS a chain, let's not chain again
		if(enemychains.len > 2)
			var/datum/beam/C = pick(enemychains)
			qdel(C)
			enemychains -= C
		enemychains += guardian.Beam(guardian.target, "lightning[rand(1,12)]", time=70, maxdistance=7, beam_type=/obj/effect/ebeam/chain)

/datum/guardian_abilities/lightning/Destroy()
	removechains()
	return ..()

/datum/guardian_abilities/lightning/manifest_act()
	if(.)
		if(user)
			userchain = guardian.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		while(guardian.loc != user)
			if(successfulshocks > 5)
				successfulshocks = 0
			if(shockallchains())
				successfulshocks++
			sleep(3)



/datum/guardian_abilities/lightning/proc/cleardeletedchains()
	if(userchain && QDELETED(userchain))
		userchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/datum/guardian_abilities/lightning/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(user)
		if(!userchain)
			userchain = guardian.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(userchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/datum/guardian_abilities/lightning/proc/removechains()
	QDEL_NULL(userchain)
	if(enemychains.len)
		enemychains.Cut()

/datum/guardian_abilities/lightning/proc/chainshock(datum/beam/B)
	. = 0
	var/list/turfs = list()
	for(var/E in B.elements)
		var/obj/effect/ebeam/chainpart = E
		if(chainpart && chainpart.x && chainpart.y && chainpart.z)
			var/turf/T = get_turf_pixel(chainpart)
			turfs |= T
			if(T != get_turf(B.origin) && T != get_turf(B.target))
				for(var/turf/TU in circlerange(T, 1))
					turfs |= TU
	for(var/turf in turfs)
		var/turf/T = turf
		for(var/mob/living/L in T)
			if(L.stat != DEAD && L != guardian && L != user)
				if(guardian.hasmatchingsummoner(L)) //if the user matches don't hurt them
					continue
				if(successfulshocks > 4)
					if(iscarbon(L))
						var/mob/living/carbon/C = L
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							H.electrocution_animation(20)
						C.jitteriness += 1000
						C.do_jitter_animation(guardian.jitteriness)
						C.stuttering += 1
						spawn(20)
							if(C)
								C.jitteriness = max(C.jitteriness - 990, 10)
					L.visible_message(
						"<span class='danger'>[L] was shocked by the lightning chain!</span>", \
						"<span class='userdanger'>You are shocked by the lightning chain!</span>", \
						"<span class='italics'>You hear a heavy electrical crack.</span>" \
					)
				L.adjustFireLoss(1.2) //adds up very rapidly
				. = 1
