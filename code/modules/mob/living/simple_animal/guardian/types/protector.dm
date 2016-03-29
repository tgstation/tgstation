//Protector
/mob/living/simple_animal/hostile/guardian/protector
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_coeff = list(BRUTE = 0.3, BURN = 0.3, TOX = 0.3, CLONE = 0.3, STAMINA = 0, OXY = 0.3)
	playstyle_string = "<span class='holoparasite'>As a <b>protector</b> type you have very high damage resistance, a decent attack, and cause your summoner to leash to you instead of you leashing to them.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Guardian, a stalwart protector that never leaves the side of its charge.</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Protector modules loaded. Holoparasite swarm online.</span>"

/mob/living/simple_animal/hostile/guardian/protector/snapback() //snap to what? snap to the guardian!
	if(summoner)
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			summoner << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>!</span>"
			summoner.visible_message("<span class='danger'>\The [summoner] jumps back to \his protector.</span>")
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase/out, get_turf(summoner))
			summoner.forceMove(get_turf(src))
			PoolOrNew(/obj/effect/overlay/temp/guardian/phase, get_turf(summoner))
