mob/living/carbon/monkey/var
	mob/npc_target = null // the NPC this monkey is attacking
	mob/npc_fleeing = null // the monkey is scared of this mob
	mob/hiding_behind = null
	hid_behind = 0

	var/list/hostiles = list()

	fleeing_duration = 0

mob/living/carbon/monkey/proc/npc_act()
	if(!client && !stat)
		if(npc_fleeing && canmove)
			var/prevloc = loc
			if(!hiding_behind)
				for(var/mob/living/carbon/human/H in view(7, src))
					if(!hostiles.Find(H))
						hiding_behind = H

			if(hiding_behind)
				if(get_dist(src, hiding_behind) == 1)
					if(!hid_behind)
						emote("me", 1, "hides behind [hiding_behind]!")
						hid_behind = 1
					step_to(src, get_step(hiding_behind, get_dir(npc_fleeing, hiding_behind)))
				else
					if(!step_to(src, hiding_behind, 1))
						hiding_behind = null
			else
				step_away(src, npc_fleeing, 7)

			if(prob(7))
				if(prob(50) && (npc_fleeing in view(8,src)))
					switch(rand(1,3))
						if(1)
							emote("me", 1, "shows [npc_fleeing] its fangs!")
						if(2)
							emote("me", 2, "gnarls at [npc_fleeing].")
						if(3)
							emote("me", 2, "eyes [npc_fleeing] fearfully.")
				else
					switch(rand(1,3))
						if(1)
							emote("whimper")
						if(2)
							emote("me", 1, "trembles heavily.")
						if(3)
							emote("me", 2, "chimpers nervously.")

			fleeing_duration--
			if(fleeing_duration <= 0)
				npc_fleeing = null
				hiding_behind = null
				hid_behind = 0

			if(loc == prevloc) dir = get_dir(src, npc_fleeing)
		else
			if(prob(33) && canmove && isturf(loc))
				step(src, pick(cardinal))
			if(prob(1))
				if(health < 70)
					switch(rand(1,3))
						if(1)
							emote("me", 1, "cowers on the floor, writhing in pain.")
						if(2)
							emote("me", 1, "trembles visibly, it seems to be in pain.")
						if(3)
							emote("me", 1, "wraps its arms around its knees, breathing heavily.")
				else
					emote(pick("scratch","jump","roll","tail"))

mob/living/carbon/monkey/react_to_attack(mob/M)
	if(npc_fleeing == M)
		fleeing_duration += 30
		return

	if(!hostiles.Find(M)) hostiles += M

	spawn(5)
		switch(rand(1,3))
			if(1)
				emote("me", 1, "flails about wildly!")
			if(2)
				emote("me", 2, "screams loudly at [M]!")
			if(3)
				emote("me", 2, "whimpers fearfully!")

		npc_fleeing = M
		fleeing_duration = 30


/*/mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/slash = 0, var/used_weapon = null)
	if(!client && !stat)
		if(damage > 10)
			if(prob(40) || health == 100)
				emote("me", 2, pick("screams loudly!", "whimpers in pain!"))
		else if(health == 100 || (damage > 0 && prob(10)))
			emote("me", 1, pick("flails about wildly!", "cringes visibly!", "chimpers nervously."))
	return ..()*/