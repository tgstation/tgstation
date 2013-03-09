
/obj/effect/bee
	name = "bees"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "bees1"
	var/strength = 1
	var/feral = 0
	var/mut = 0
	var/toxic = 0
	var/turf/target_turf
	var/mob/target_mob
	var/obj/machinery/apiary/parent
	pass_flags = PASSGRILLE|PASSTABLE

/obj/effect/bee/New(loc, var/obj/machinery/apiary/new_parent)
	..()
	processing_objects.Add(src)
	parent = new_parent

/obj/effect/bee/Del()
	processing_objects.Remove(src)
	if(parent)
		parent.owned_bee_swarms.Remove(src)
	..()

/obj/effect/bee/process()

	//if we're strong enough, sting some people
	var/overrun = strength - 5 + feral / 2
	if(prob(max( overrun * 10 + feral * 10, 0)))
		var/mob/living/carbon/human/M = locate() in src.loc
		if(M)
			var/sting_prob = 100
			var/obj/item/clothing/worn_suit = M.wear_suit
			var/obj/item/clothing/worn_helmet = M.head
			if(worn_suit)
				sting_prob -= worn_suit.armor["bio"]
			if(worn_helmet)
				sting_prob -= worn_helmet.armor["bio"]

			if( prob(sting_prob) && (M.stat == CONSCIOUS || (M.stat == UNCONSCIOUS && prob(25))) )
				M.apply_damage(overrun / 2 + mut / 2, BRUTE)
				M.apply_damage(overrun / 2 + toxic / 2, TOX)
				M << "\red You have been stung!"
				M.flash_pain()

	//if we're chasing someone, get a little bit angry
	if(target_mob && prob(10))
		feral++

	//calm down a little bit
	var/move_prob = 40
	if(feral > 0)
		if(prob(feral * 10))
			feral -= 1
	else
		//if feral is less than 0, we're becalmed by smoke or steam
		if(feral < 0)
			feral += 1

		if(target_mob)
			target_mob = null
			target_turf = null
		if(strength > 5)
			//calm down and spread out a little
			var/obj/effect/bee/B = new(get_turf(pick(orange(src,1))))
			B.strength = rand(1,5)
			src.strength -= B.strength
			if(src.strength <= 5)
				src.icon_state = "bees[src.strength]"
			B.icon_state = "bees[B.strength]"
			if(src.parent)
				B.parent = src.parent
				src.parent.owned_bee_swarms.Add(B)

	//make some noise
	if(prob(0.5))
		src.visible_message("\blue [pick("Buzzzz.","Hmmmmm.","Bzzz.")]")

	//smoke, water and steam calms us down
	var/calming = 0
	var/list/calmers = list(/obj/effect/effect/chem_smoke, /obj/effect/effect/water, /obj/effect/effect/foam, /obj/effect/effect/steam, /obj/effect/mist)

	for(var/this_type in calmers)
		var/obj/effect/check_effect = locate() in src.loc
		if(check_effect.type == this_type)
			calming = 1
			break

	if(calming)
		if(feral > 0)
			src.visible_message("\blue The bees calm down!")
		feral = -10
		target_mob = null
		target_turf = null

	for(var/obj/effect/bee/B in src.loc)
		if(B == src)
			continue

		if(feral > 0)
			src.strength += B.strength
			del(B)
			src.icon_state = "bees[src.strength]"
			if(strength > 5)
				icon_state = "bees_swarm"
		else if(prob(10))
			//make the other swarm of bees stronger, then move away
			var/total_bees = B.strength + src.strength
			if(total_bees < 10)
				B.strength = min(5, total_bees)
				src.strength = total_bees - B.strength

				B.icon_state = "bees[B.strength]"
				if(src.strength <= 0)
					del(src)
					return
				src.icon_state = "bees[B.strength]"
				var/turf/simulated/floor/T = get_turf(get_step(src, pick(1,2,4,8)))
				density = 1
				if(T.Enter(src, get_turf(src)))
					src.loc = T
				density = 0
			break

	if(target_mob)
		if(target_mob in view(src,7))
			target_turf = get_turf(target_mob)
		else
			for(var/mob/living/carbon/M in view(src,7))
				target_mob = M
				break

	if(target_turf)
		var/turf/next_turf = get_step(src.loc, get_dir(src,target_turf))

		//hacky, but w/e
		var/old_density = -1
		if(target_mob && get_dist(src, target_mob) <= 1)
			old_density = target_mob.density
			target_mob.density = 0
		density = 1
		if(next_turf.Enter(src, get_turf(src)))
			src.loc = next_turf
		density = 0
		if(src.loc == target_turf)
			target_turf = null
		if(target_mob && old_density != -1)
			target_mob.density = old_density
	else
		//find some flowers, harvest
		//angry bee swarms don't hang around
		if(feral > 0)
			move_prob = 60
		else if(feral < 0)
			move_prob = 0
		else
			var/obj/machinery/hydroponics/H = locate() in src.loc
			if(H)
				if(H.planted && !H.dead && H.myseed)
					move_prob = 1

		//chance to wander around
		if(prob(move_prob))
			var/turf/simulated/floor/T = get_turf(get_step(src, pick(1,2,4,8)))
			density = 1
			if(T.Enter(src, get_turf(src)))
				src.loc = T
			density = 0

	pixel_x = rand(-12,12)
	pixel_y = rand(-12,12)

	if(!parent && prob(10))
		strength -= 1
		if(strength <= 0)
			del(src)
		else if(strength <= 5)
			icon_state = "bees[strength]"

	//debugging
	/*icon_state = "[strength]"
	if(strength > 5)
		icon_state = "unknown"*/
