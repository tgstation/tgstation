//Fire
/mob/living/simple_animal/hostile/guardian/fire
	a_intent = "help"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/Welder.ogg'
	attacktext = "ignites"
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 0.8, CLONE = 0.8, STAMINA = 0, OXY = 0.8)
	range = 8
	playstyle_string = "<span class='holoparasite'>As a <b>chaos</b> type, you have only light damage resistance, but will ignite any enemy you attack. In addition, bumping into human targets will cause them to see other humans as you.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Wizard, bringer of endless chaos!</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Crowd control modules activated. Holoparasite swarm online.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught one! OH GOD, EVERYTHING'S ON FIRE. Except you and the fish.</span>"

/mob/living/simple_animal/hostile/guardian/fire/Life() //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	if(..())
		if(isliving(target))
			var/mob/living/M = target
			if(!hasmatchingsummoner(M) && M != summoner)
				M.fire_stacks = 7
				M.IgniteMob()

/mob/living/simple_animal/hostile/guardian/fire/Crossed(atom/movable/AM)
	..()
	collision_hallucination(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(atom/movable/AM)
	..()
	collision_hallucination(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bump(atom/movable/AM)
	..()
	collision_hallucination(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_hallucination(atom/movable/AM)
	if(ishuman(AM) && A != summoner)
		spawn(0)
			new /obj/effect/hallucination/delusion(AM.loc,AM,force_kind="custom",duration=200,skip_nearby=0, custom_icon = src.icon_state, custom_icon_file = src.icon)
