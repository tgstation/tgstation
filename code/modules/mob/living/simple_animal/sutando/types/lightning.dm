//gwyn

/obj/effect/ebeam/chain
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/datum/sutando_abilities/lightning
	id = "lightning"
	name = "Controlled Current"
	value = 7
	var/datum/beam/userchain
	var/list/enemychains
	var/successfulshocks = 0

/datum/sutando_abilities/lightning/handle_stats()

	stand.melee_damage_lower += 4
	stand.melee_damage_upper += 4
	stand.attacktext = "shocks"
	stand.melee_damage_type = BURN
	stand.attack_sound = 'sound/machines/defib_zap.ogg'
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.15
	stand.range += 4

/datum/sutando_abilities/lightning/recall_act()
	removechains()

/datum/sutando_abilities/lightning/ability_act()
	if(isliving(stand.target) && stand.target != stand && stand.target != user)
		cleardeletedchains()
		for(var/chain in enemychains)
			var/datum/beam/B = chain
			if(B.target == stand.target)
				return //oh this guy already HAS a chain, let's not chain again
		if(enemychains.len > 2)
			var/datum/beam/C = pick(enemychains)
			qdel(C)
			enemychains -= C
		enemychains += stand.Beam(stand.target, "lightning[rand(1,12)]", time=70, maxdistance=7, beam_type=/obj/effect/ebeam/chain)

/datum/sutando_abilities/lightning/Destroy()
	removechains()
	return ..()

/datum/sutando_abilities/lightning/manifest_act()
	if(.)
		if(user)
			userchain = stand.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		while(stand.loc != user)
			if(successfulshocks > 5)
				successfulshocks = 0
			if(shockallchains())
				successfulshocks++
			sleep(3)



/datum/sutando_abilities/lightning/proc/cleardeletedchains()
	if(userchain && QDELETED(userchain))
		userchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/datum/sutando_abilities/lightning/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(user)
		if(!userchain)
			userchain = stand.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(userchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/datum/sutando_abilities/lightning/proc/removechains()
	QDEL_NULL(userchain)
	if(enemychains.len)
		enemychains.Cut()

/datum/sutando_abilities/lightning/proc/chainshock(datum/beam/B)
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
			if(L.stat != DEAD && L != stand && L != user)
				if(stand.hasmatchingsummoner(L)) //if the user matches don't hurt them
					continue
				if(successfulshocks > 4)
					if(iscarbon(L))
						var/mob/living/carbon/C = L
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							H.electrocution_animation(20)
						C.jitteriness += 1000
						C.do_jitter_animation(stand.jitteriness)
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
