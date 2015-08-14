// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)
var/const/ALIEN_AFK_BRACKET = 450 // 45 seconds

/obj/item/body_egg/alien_embryo
	name = "alien embryo"
	var/stage = 0

/obj/item/body_egg/alien_embryo/egg_process()
	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage()

	switch(stage)
		if(2, 3)
			if(affected_mob == DEAD)
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "<span class='danger'>Your throat feels sore.</span>"
			if(prob(1))
				affected_mob << "<span class='danger'>Mucous runs down the back of your throat.</span>"
		if(4)
			if(affected_mob == DEAD)
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob << "<span class='danger'>Your muscles ache.</span>"
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(2))
				affected_mob << "<span class='danger'>Your stomach hurts.</span>"
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			if(affected_mob != DEAD)
				affected_mob << "<span class='danger'>You feel something tearing its way out of your stomach...</span>"
				affected_mob.adjustToxLoss(10)
				affected_mob.updatehealth()
			if(prob(50))
				AttemptGrow()



/obj/item/body_egg/alien_embryo/proc/AttemptGrow(gib_on_success = 1)
	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
	var/client/C = null

	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 2, so we don't do a process heavy check everytime.

	if(candidates.len)
		C = pick(candidates)
	else if(affected_mob.client)
		C = affected_mob.client
	else
		stage = 4 // Let's try again later.
		return

	if(affected_mob.lying)
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_lie")
	else
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_stand")
	spawn(6)
		var/mob/living/carbon/alien/larva/new_xeno = new(affected_mob.loc)
		new_xeno.key = C.key
		new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
		if(gib_on_success)
			affected_mob.gib()
		if(istype(new_xeno.loc,/mob/living/carbon))
			var/mob/living/carbon/digester = new_xeno.loc
			digester.stomach_contents += new_xeno
		qdel(src)

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes the current icons located in the infected mob adds the current stage
----------------------------------------*/
/obj/item/body_egg/alien_embryo/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == affected_mob)
					qdel(I)
