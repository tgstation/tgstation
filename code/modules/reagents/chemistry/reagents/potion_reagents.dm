/*
 *Magical elixirs for potion flasks. Identify them via your local chemist or test your luck. Whats the worst that could happen?
 */


/datum/reagent/consumable/potion
	name = "strange elixir"
	id = "genericpotion"
	description = "A strange mixture of various components. There appears to be no real identifier to what its suppose to do."
	color = "#FFF804" // rgb: 225, 248, 4
	nutriment_factor = 0


//healing potion
/datum/reagent/consumable/potion/healing
	id = "healingpotion"
	description = "A strange mixture of various components. Pleasant fumes drift aimlessly off the mixture, just smelling it makes you feel better."
	color = "#FF0000" // rgb: 255, 0, 0

/datum/reagent/consumable/potion/healing/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(TOUCH, VAPOR, PATCH))
			if(show_message)
				M << "<span class='notice'>Your skin tingles as you feel your ailments seem to almost fade away.</span>"
				M.adjustOxyLoss(-3 * reac_volume)
				M.adjustBruteLoss(-3 * reac_volume)
				M.adjustFireLoss(-3 * reac_volume)
		else
			if(show_message)
				M << "<span class='notice'>A rejuvenating rush of energy travels throughout your body, you've never felt better!</span>"
				M.adjustOxyLoss(-5 * reac_volume)
				M.adjustBruteLoss(-5 * reac_volume)
				M.adjustFireLoss(-5 * reac_volume)
				M.dizziness = 0
				M.drowsyness = 0
				M.stuttering = 0
				M.confused = 0
				M.radiation = 0
	..()


//poison potion
/datum/reagent/consumable/potion/poison
	id = "poisonpotion"
	description = "A strange mixture of various components. Foul fumes drift off the horrible mixture as it occassionally bubbles. Why would anyone make this?"
	color = "#00FF00" // rgb: 0, 255, 0

/datum/reagent/consumable/potion/poison/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(TOUCH, VAPOR, PATCH))
			if(show_message)
				M << "<span class='userdanger'>A horrible pain washes over you, it feels like something is eating away at your skin!</span>"
				M.adjustBruteLoss(25)
		else
			if(show_message)
				M << "<span class='userdanger'>You cry out in pain as you feel your insides twist and turn. Oh god, make it stop!</span>"
				M.Stun(7)
				M.Weaken(7)
				M.emote("scream")
				M.visible_message("<span class='danger'><b>[M]</b> violently retches, grabbing their chest as they fall to the ground!")
	..()

/datum/reagent/consumable/potion/poison/on_mob_life(mob/living/M) //this is why you identify your potions before drinking them, nerd
	M.adjustToxLoss(2*REM, 0)
	M.adjustBruteLoss(1*REM, 0)
	. = 1
	for(var/datum/reagent/A in M.reagents.reagent_list)
		if(A != src)
			M.reagents.remove_reagent(A.id,3)
	..()



//fire potion
/datum/reagent/consumable/potion/combustion
	id = "combustionpotion"
	description = "A strange mixture of various components. The mixture sloshes around violently, irradiating an aura of immense heat."
	color = "#FF9A00" // rgb: 255, 145, 0

/datum/reagent/consumable/potion/combustion/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(TOUCH, VAPOR, PATCH))
			if(show_message)
				M << "<span class='userdanger'>Your skin violently erupts into flames!</span>"
				M.adjust_fire_stacks(10)
				M.IgniteMob()
				M.adjustFireLoss(10, 0)
				PoolOrNew(/obj/effect/hotspot, M.loc)
		else
			if(show_message)
				M << "<span class='userdanger'>The mixture violently reacts inside you as flames erupt from every orifice!</span>"
				M.adjust_fire_stacks(20)
				M.IgniteMob()
				M.adjustFireLoss(30, 0)
				M.emote("scream")
				PoolOrNew(/obj/effect/hotspot, M.loc)
		..()

/datum/reagent/consumable/potion/combustion/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(2)
	M.adjustFireLoss(5, 0)
	..()
	. = 1


//speed potion
/datum/reagent/consumable/potion/speed
	id = "speedpotion"
	description = "A strange mixture of various components. The mixture splashes around erratically, never stopping."
	color = "#289AF2" // rgb: 40, 154, 242

/datum/reagent/consumable/potion/speed/reaction_mob(mob/living/M, method=INGEST, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		if(method in list(TOUCH, VAPOR, PATCH))
			if(show_message)
				M << "<span class='userdanger'>The mixture soaks into your skin. Other than a little jitter, you feel fine.</span>"
		else
			if(show_message)
				M << "<span class='userdanger'>You feel a huge burst of energy surge throughout your entire body! You could take on the world!</span>"
				M.Jitter(10)
		..()

/datum/reagent/consumable/potion/speed/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.AdjustSleeping(-2, 0)
	..()
	. = 1