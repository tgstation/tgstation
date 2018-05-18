//Used to nominate oneself or ghosts for the role of Eminence.
/obj/structure/destructible/clockwork/eminence_spire
	name = "eminence spire"
	desc = "A hulking machine made of powerful alloy, with three small obelisks and a huge plate in the center."
	clockwork_desc = "This spire is used to become the Eminence, who functions as an invisible leader of the cult. Activate it to nominate yourself or propose that the Eminence should be \
	selected from available ghosts. Once an Eminence is selected, they can't normally be changed."
	icon_state = "tinkerers_daemon"
	break_message = "<span class='warning'>The spire screeches with crackling power and collapses into scrap!</span>"
	max_integrity = 400
	var/mob/eminence_nominee
	var/selection_timer //Timer ID; this is canceled if the vote is canceled
	var/kingmaking

/obj/structure/destructible/clockwork/eminence_spire/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='notice'>You can tell how powerful [src] is; you know better than to touch it.</span>")
		return
	if(kingmaking)
		return

	var/datum/antagonist/clockcult/C = user.mind.has_antag_datum(/datum/antagonist/clockcult)
	if(!C || !C.clock_team)
		return
	if(C.clock_team.eminence)
		to_chat(user, "<span class='warning'>There's already an Eminence!</span>")
		return
	if(!GLOB.servants_active)
		to_chat(user, "<span class='warning'>The Ark isn't active!</span>")
		return
	if(eminence_nominee) //This could be one large proc, but is split into three for ease of reading
		if(eminence_nominee == user)
			cancelation(user)
		else
			objection(user)
	else
		nomination(user)

/obj/structure/destructible/clockwork/eminence_spire/attack_drone(mob/living/simple_animal/drone/user)
	if(!is_servant_of_ratvar(user))
		..()
	else
		to_chat(user, "<span class='warning'>You feel the omniscient gaze turn into a puzzled frown. Perhaps you should just stick to building.</span>")
		return

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/structure/destructible/clockwork/eminence_spire/attack_ghost(mob/user)
	if(!IsAdminGhost(user))
		return

	var/datum/mind/rando = locate() in get_antag_minds(/datum/antagonist/clockcult) //if theres no cultists new team without eminence will be created anyway.
	if(rando)
		var/datum/antagonist/clockcult/random_cultist = rando.has_antag_datum(/datum/antagonist/clockcult)
		if(random_cultist && random_cultist.clock_team && random_cultist.clock_team.eminence)
			to_chat(user, "<span class='warning'>There's already an Eminence - too late!</span>")
			return
	if(!GLOB.servants_active)
		to_chat(user, "<span class='warning'>The Ark must be active first!</span>")
		return
	if(alert(user, "Become the Eminence using admin?", "Become Eminence", "Yes", "No") != "Yes")
		return
	message_admins("<span class='danger'>Admin [key_name_admin(user)] directly became the Eminence of the cult!</span>")
	log_admin("Admin [key_name(user)] made themselves the Eminence.")
	var/mob/camera/eminence/eminence = new(get_turf(src))
	eminence.key = user.key
	hierophant_message("<span class='bold large_brass'>Ratvar has directly assigned the Eminence!</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/machines/clockcult/eminence_selected.ogg', 50, FALSE)

/obj/structure/destructible/clockwork/eminence_spire/proc/nomination(mob/living/nominee) //A user is nominating themselves or ghosts to become Eminence
	var/nomination_choice = alert(nominee, "Who would you like to nominate?", "Eminence Nomination", "Nominate Yourself", "Nominate Ghosts", "Cancel")
	if(!is_servant_of_ratvar(nominee) || !nominee.canUseTopic(src) || eminence_nominee)
		return
	switch(nomination_choice)
		if("Cancel")
			return
		if("Nominate Yourself")
			eminence_nominee = nominee
			hierophant_message("<span class='brass'><b>[nominee] nominates [nominee.p_them()]self as the Eminence!</b> You may object by interacting with the eminence spire. The vote will otherwise pass in 30 seconds.</span>")
		if("Nominate Ghosts")
			eminence_nominee = "ghosts"
			hierophant_message("<span class='brass'><b>[nominee] proposes selecting an Eminence from ghosts!</b> You may object by interacting with the eminence spire. The vote will otherwise pass in 30 seconds.</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/machines/clockcult/ocularwarden-target.ogg', 50, FALSE)
	selection_timer = addtimer(CALLBACK(src, .proc/kingmaker), 300, TIMER_STOPPABLE)

/obj/structure/destructible/clockwork/eminence_spire/proc/objection(mob/living/wright)
	if(alert(wright, "Object to the selection of [eminence_nominee] as Eminence?", "Objection!", "Object", "Cancel") == "Cancel" || !is_servant_of_ratvar(wright) || !wright.canUseTopic(src) || !eminence_nominee)
		return
	hierophant_message("<span class='brass'><b>[wright] objects to the nomination of [eminence_nominee]!</b> The eminence spire has been reset.</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
	eminence_nominee = null
	deltimer(selection_timer)

/obj/structure/destructible/clockwork/eminence_spire/proc/cancelation(mob/living/cold_feet)
	if(alert(cold_feet, "Cancel your nomination?", "Cancel Nomination", "Withdraw Nomination", "Cancel") == "Cancel" || !is_servant_of_ratvar(cold_feet) || !cold_feet.canUseTopic(src) || !eminence_nominee)
		return
	hierophant_message("<span class='brass'><b>[eminence_nominee] has withdrawn their nomination!</b> The eminence spire has been reset.</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
	eminence_nominee = null
	deltimer(selection_timer)

/obj/structure/destructible/clockwork/eminence_spire/proc/kingmaker()
	if(!eminence_nominee)
		return
	if(ismob(eminence_nominee))
		if(!eminence_nominee.client || !eminence_nominee.mind)
			hierophant_message("<span class='brass'><b>[eminence_nominee] somehow lost their sentience!</b> The eminence spire has been reset.</span>")
			for(var/mob/M in servants_and_ghosts())
				M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
			eminence_nominee = null
			return
		playsound(eminence_nominee, 'sound/machines/clockcult/ark_damage.ogg', 50, FALSE)
		eminence_nominee.visible_message("<span class='warning'>A blast of white-hot light flows into [eminence_nominee], vaporizing [eminence_nominee.p_them()] in an instant!</span>", \
		"<span class='userdanger'>allthelightintheuniverseflowing.into.YOU</span>")
		for(var/obj/item/I in eminence_nominee)
			eminence_nominee.dropItemToGround(I)
		var/mob/camera/eminence/eminence = new(get_turf(src))
		eminence_nominee.mind.transfer_to(eminence)
		eminence_nominee.dust()
		hierophant_message("<span class='bold large_brass'>[eminence_nominee] has ascended into the Eminence!</span>")
	else if(eminence_nominee == "ghosts")
		kingmaking = TRUE
		hierophant_message("<span class='brass'><b>The eminence spire is now selecting a ghost to be the Eminence...</b></span>")
		var/list/candidates = pollGhostCandidates("Would you like to play as the servants' Eminence?", ROLE_SERVANT_OF_RATVAR, null, ROLE_SERVANT_OF_RATVAR, poll_time = 100)
		kingmaking = FALSE
		if(!LAZYLEN(candidates))
			for(var/mob/M in servants_and_ghosts())
				M.playsound_local(M, 'sound/machines/clockcult/integration_cog_install.ogg', 50, FALSE)
			hierophant_message("<span class='brass'><b>No ghosts accepted the offer!</b> The eminence spire has been reset.</span>")
			eminence_nominee = null
			return
		visible_message("<span class='warning'>A blast of white-hot light spirals from [src] in waves!</span>")
		playsound(src, 'sound/machines/clockcult/ark_damage.ogg', 50, FALSE)
		var/mob/camera/eminence/eminence = new(get_turf(src))
		eminence_nominee = pick(candidates)
		eminence.key = eminence_nominee.key
		hierophant_message("<span class='bold large_brass'>A ghost has ascended into the Eminence!</span>")
	for(var/mob/M in servants_and_ghosts())
		M.playsound_local(M, 'sound/machines/clockcult/eminence_selected.ogg', 50, FALSE)
	eminence_nominee = null
