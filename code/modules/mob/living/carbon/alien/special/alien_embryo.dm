// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/alien_embryo
	name = "\improper alien embryo" //The alien embryo, not Alien Embryo
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
					O << "<span class=\"recruit\">You have automatically been signed up for \a [src]. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Retract</a>)</span>"
					ghost_volunteers += O
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		del(src)

/obj/item/alien_embryo/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O) return
		volunteer(O)


/obj/item/alien_embryo/proc/volunteer(var/mob/dead/observer/O)
	if(!istype(O))
		O << "<span class='danger'>NO.</span>"
		return
	if(O in ghost_volunteers)
		O << "<span class='notice'>You will no longer be considered for this [src]. Click again to volunteer.</span>"
		ghost_volunteers.Remove(O)
		return
	if(!check_observer(O))
		O << "<span class='warning'>You cannot be \a [src] in your current condition.</span>"
		return
	O << "<span class='notice'>You have been added to the list of ghosts that may become this [src].  Click again to unvolunteer.</span>"
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
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "<span class='warning'>Your throat feels sore.</span>"
			if(prob(1))
				affected_mob << "<span class='warning'>Mucous runs down the back of your throat.</span>"
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				affected_mob << "<span class='warning'>Your muscles ache.</span>"
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(2))
				affected_mob << "<span class='warning'>Your stomach hurts.</span>"
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			affected_mob << "<span class='danger'>You feel something tearing its way out of your stomach...</span>"
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
				O << "<span class=\"recruit\">[affected_mob] is about to burst from \a [src]!. (<a href='?src=\ref[O];jump=\ref[src]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</span>"

	else
		picked = ghostpicked.key
	if(!picked)
		stage = 4 // Let's try again later.
		return

	if(affected_mob.lying)
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_lie")
	else
		affected_mob.overlays += image('icons/mob/alien.dmi', loc = affected_mob, icon_state = "burst_stand")
	spawn(6)
		var/mob/living/carbon/alien/larva/new_xeno = new(affected_mob.loc)
		new_xeno.key = picked
		new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
		if(gib_on_success)
			affected_mob.gib()
		del(src)

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
							del(I)