<<<<<<< HEAD
// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)
var/const/ALIEN_AFK_BRACKET = 450 // 45 seconds

/obj/item/organ/body_egg/alien_embryo
	name = "alien embryo"
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/stage = 0

/obj/item/organ/body_egg/alien_embryo/on_find(mob/living/finder)
	..()
	if(stage < 4)
		finder << "It's small and weak, barely the size of a foetus."
	else
		finder << "It's grown quite large, and writhes slightly as you look at it."
		if(prob(10))
			AttemptGrow(0)

/obj/item/organ/body_egg/alien_embryo/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("sacid", 10)
	return S

/obj/item/organ/body_egg/alien_embryo/on_life()
	switch(stage)
		if(2, 3)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(2))
				owner << "<span class='danger'>Your throat feels sore.</span>"
			if(prob(2))
				owner << "<span class='danger'>Mucous runs down the back of your throat.</span>"
		if(4)
			if(prob(2))
				owner.emote("sneeze")
			if(prob(2))
				owner.emote("cough")
			if(prob(4))
				owner << "<span class='danger'>Your muscles ache.</span>"
				if(prob(20))
					owner.take_organ_damage(1)
			if(prob(4))
				owner << "<span class='danger'>Your stomach hurts.</span>"
				if(prob(20))
					owner.adjustToxLoss(1)
		if(5)
			owner << "<span class='danger'>You feel something tearing its way out of your stomach...</span>"
			owner.adjustToxLoss(10)

/obj/item/organ/body_egg/alien_embryo/egg_process()
	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage()

	if(stage == 5 && prob(50))
		for(var/datum/surgery/S in owner.surgeries)
			if(S.location == "chest" && istype(S.get_surgery_step(), /datum/surgery_step/manipulate_organs))
				AttemptGrow(0)
				return
		AttemptGrow()



/obj/item/organ/body_egg/alien_embryo/proc/AttemptGrow(gib_on_success = 1)
	if(!owner) return
	var/list/candidates = get_candidates(ROLE_ALIEN, ALIEN_AFK_BRACKET, "alien candidate")
	var/client/C = null

	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 4, so we don't do a process heavy check everytime.

	if(candidates.len)
		C = pick(candidates)
	else if(owner.client && !(jobban_isbanned(owner, "alien candidate") || jobban_isbanned(owner, "Syndicate")))
		C = owner.client
	else
		stage = 4 // Let's try again later.
		return

	var/overlay = image('icons/mob/alien.dmi', loc = owner, icon_state = "burst_lie")
	owner.add_overlay(overlay)

	var/atom/xeno_loc = get_turf(owner)
	var/mob/living/carbon/alien/larva/new_xeno = new(xeno_loc)
	new_xeno.key = C.key
	new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
	new_xeno.canmove = 0 //so we don't move during the bursting animation
	new_xeno.notransform = 1
	new_xeno.invisibility = INVISIBILITY_MAXIMUM
	spawn(6)
		if(new_xeno)
			new_xeno.canmove = 1
			new_xeno.notransform = 0
			new_xeno.invisibility = 0
		if(gib_on_success)
			owner.gib()
		else
			owner.adjustBruteLoss(40)
			owner.overlays -= overlay
		qdel(src)


/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/AddInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			var/I = image('icons/mob/alien.dmi', loc = owner, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/organ/body_egg/alien_embryo/RemoveInfectionImages()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == owner)
					qdel(I)
=======
// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/alien_embryo
	name = "alien embryo" //The alien embryo, not Alien Embryo
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/list/ghost_volunteers[0]
	var/picked=null
	var/stage = 0

/obj/item/alien_embryo/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		processing_objects.Add(src)

		for(var/mob/dead/observer/O in get_active_candidates(ROLE_ALIEN,poll="[affected_mob] has been infected by \a [src]!"))
			if(O.client && O.client.desires_role(ROLE_ALIEN))
				if(check_observer(O))
					to_chat(O, "<span class=\"recruit\">You have automatically been signed up for \a [src]. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>")
					ghost_volunteers += O
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		qdel(src)

/obj/item/alien_embryo/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O) return
		volunteer(O)


/obj/item/alien_embryo/proc/volunteer(var/mob/dead/observer/O)
	if(!istype(O))
		to_chat(O, "<span class='danger'>NO.</span>")
		return
	if(O in ghost_volunteers)
		to_chat(O, "<span class='notice'>You will no longer be considered for this [src]. Click again to volunteer.</span>")
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		to_chat(O, "<span class='warning'>You cannot be \a [src] in your current condition.</span>")
		return
	to_chat(O, "<span class='notice'>You have been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>")
	ghost_volunteers.Add(O)

/obj/item/alien_embryo/proc/check_observer(var/mob/dead/observer/O)
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0
	if(jobban_isbanned(O, "Syndicate")) // Antag-banned
		return 0
	if(!O.client)
		return 0
	if(((O.client.inactivity/10)/60) <= ALIEN_SELECT_AFK_BUFFER) // Filter AFK
		return 1
	return 0

/obj/item/alien_embryo/Destroy()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		spawn(0)
			RemoveInfectionImages(affected_mob)
	..()

/obj/item/alien_embryo/process()
	if(!affected_mob)	return
	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		processing_objects.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return

	if(stage < 5 && prob(3))
		stage++
		spawn(0)
			RefreshInfectionImage(affected_mob)

	switch(stage)
		if(2, 3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.audible_cough()
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Your throat feels sore.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Mucous runs down the back of your throat.</span>")
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.audible_cough()
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Your muscles ache.</span>")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Your stomach hurts.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			to_chat(affected_mob, "<span class='danger'>You feel something tearing its way out of your stomach...</span>")
			affected_mob.adjustToxLoss(10)
			affected_mob.updatehealth()
			if(prob(50))
				AttemptGrow()

/obj/item/alien_embryo/proc/AttemptGrow(var/gib_on_success = 1)
	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 2, so we don't do a process heavy check everytime.
	var/mob/dead/observer/ghostpicked
	while(ghost_volunteers.len)
		ghostpicked = pick_n_take(ghost_volunteers)
		if(!istype(ghostpicked))
			continue
		break
	if(!ghostpicked || !istype(ghostpicked))
		var/list/candidates = get_active_candidates(ROLE_ALIEN, buffer=ALIEN_SELECT_AFK_BUFFER, poll=1)
		if(!candidates.len)
			picked = affected_mob.key //Pick the person who was infected
		else
			for(var/mob/dead/observer/O in candidates)
				to_chat(O, "<span class=\"recruit\">\a [src] is about to burst out of \the [affected_mob]!(<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</span>")

	else
		picked = ghostpicked.key
	if(!picked)
		stage = 4 // Let's try again later.
		var/list/candidates = get_active_candidates(ROLE_ALIEN, buffer=ALIEN_SELECT_AFK_BUFFER, poll=1)
		for(var/mob/dead/observer/O in candidates) //Shiggy
			to_chat(O, "<span class=\"recruit\">\a [src] is about to burst out of \the [affected_mob]!(<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</span>")
		return

	if(affected_mob.lying)
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_lie")
	else
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_stand")
	spawn(6)
		var/mob/living/carbon/alien/larva/new_xeno = new(get_turf(affected_mob))
		new_xeno.key = picked
		new_xeno << sound('sound/voice/hiss5.ogg', 0, 0, 0, 100)//To get the player's attention

		if(gib_on_success)
			affected_mob.gib()
		qdel(src)

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes all infection images from aliens and places an infection image on all infected mobs for aliens.
----------------------------------------*/
/obj/item/alien_embryo/proc/RefreshInfectionImage()
	for(var/mob/living/carbon/alien/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected"))
					alien.client.images -= I
			for(var/mob/living/L in mob_list)
				if(iscorgi(L) || iscarbon(L))
					if(L.status_flags & XENO_HOST)
						var/I = image('icons/mob/alien.dmi', loc = L, icon_state = "infected[stage]")
						alien.client.images += I

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Checks if the passed mob (C) is infected with the alien egg, then gives each alien client an infected image at C.
----------------------------------------*/
/obj/item/alien_embryo/proc/AddInfectionImages(var/mob/living/C)
	if(C)
		for(var/mob/living/carbon/alien/alien in player_list)
			if(alien.client)
				if(C.status_flags & XENO_HOST)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[stage]")
					alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes the alien infection image from all aliens in the world located in passed mob (C).
----------------------------------------*/

/obj/item/alien_embryo/proc/RemoveInfectionImages(var/mob/living/C)
	if(C)
		for(var/mob/living/carbon/alien/alien in player_list)
			if(alien.client)
				for(var/image/I in alien.client.images)
					if(I.loc == C)
						if(dd_hasprefix_case(I.icon_state, "infected"))
							//del(I)
							alien.client.images -= I
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
