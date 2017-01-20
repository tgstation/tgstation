//CLOCKCULT PROOF OF CONCEPT

/datum/antagonist/clockcultist
	prevented_antag_datum_type = /datum/antagonist/clockcultist
	some_flufftext = null
	var/datum/action/innate/hierophant/hierophant_network = new()

/datum/antagonist/clockcultist/silent
	silent_update = TRUE

/datum/antagonist/clockcultist/Destroy()
	qdel(hierophant_network)
	..()

/datum/antagonist/clockcultist/can_be_owned(mob/living/new_body)
	. = ..()
	if(.)
		. = is_eligible_servant(new_body)

/datum/antagonist/clockcultist/give_to_body(mob/living/new_body)
	if(!silent_update)
		if(issilicon(new_body))
			new_body << "<span class='heavy_brass'>You are unable to compute this truth. Your vision glows a brilliant yellow, and all at once it comes to you. Ratvar, the Clockwork Justiciar, \
			lies in exile, derelict and forgotten in an unseen realm.</span>"
		else
			new_body << "<span class='heavy_brass'>[iscarbon(new_body) ? "Your mind is racing! Your body feels incredibly light! ":""]Your world glows a brilliant yellow! All at once it comes to you. \
			Ratvar, the Clockwork Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>"
	. = ..()
	if(!silent_update && new_body)
		if(.)
			new_body.visible_message("<span class='heavy_brass'>[new_body]'s eyes glow a blazing yellow!</span>")
			new_body << "<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. \
			Perform his every whim without hesitation.</span>"
		else
			new_body.visible_message("<span class='boldwarning'>[new_body] seems to resist an unseen force!</span>")
			new_body << "<span class='userdanger'>And yet, you somehow push it all away.</span>"

/datum/antagonist/clockcultist/on_gain()
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.servants_of_ratvar += owner.mind
		ticker.mode.update_servant_icons_added(owner.mind)
		if(jobban_isbanned(owner, ROLE_SERVANT_OF_RATVAR))
			addtimer(CALLBACK(ticker.mode, /datum/game_mode.proc/replace_jobbaned_player, owner, ROLE_SERVANT_OF_RATVAR, ROLE_SERVANT_OF_RATVAR), 0)
	if(owner.mind)
		owner.mind.special_role = "Servant of Ratvar"
	owner.attack_log += "\[[time_stamp()]\] <font color=#BE8700>Has been converted to the cult of Ratvar!</font>"
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(iscyborg(S) && !silent_update)
			S << "<span class='boldwarning'>You have been desynced from your master AI.\n\
			In addition, your onboard camera is no longer active and you have gained additional equipment, including a limited clockwork slab.</span>"
		if(isAI(S))
			S << "<span class='boldwarning'>You are able to use your cameras to listen in on conversations.</span>"
		S << "<span class='heavy_brass'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>"
	else if(isbrain(owner) || isclockmob(owner))
		owner << "<span class='nezbere'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>"
	..()
	if(istype(ticker.mode, /datum/game_mode/clockwork_cult))
		var/datum/game_mode/clockwork_cult/C = ticker.mode
		C.present_tasks(owner) //Memorize the objectives

/datum/antagonist/clockcultist/apply_innate_effects()
	all_clockwork_mobs += owner
	owner.faction |= "ratvar"
	owner.languages_spoken |= RATVAR
	owner.languages_understood |= RATVAR
	owner.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them for whatever reason, we need to update buttons
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			R.UnlinkSelf()
			R.module.rebuild_modules()
		else if(isAI(S))
			var/mob/living/silicon/ai/A = S
			A.requires_power = POWER_REQ_CLOCKCULT
			if(!A.lacks_power())
				A.ai_restore_power()
			if(A.eyeobj)
				A.eyeobj.relay_speech = TRUE
			for(var/mob/living/silicon/robot/R in A.connected_robots)
				if(R.connected_ai == A)
					R.visible_message("<span class='heavy_brass'>[R]'s eyes glow a blazing yellow!</span>", \
					"<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. Perform his every \
					whim without hesitation.</span>")
					R << "<span class='boldwarning'>Your onboard camera is no longer active and you have gained additional equipment, including a limited clockwork slab.</span>"
					add_servant_of_ratvar(R, TRUE)
		S.laws = new/datum/ai_laws/ratvar
		S.laws.associate(S)
		S.update_icons()
		S.show_laws()
		hierophant_network.Grant(S)
		hierophant_network.title = "Silicon"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "brass"
	else if(isbrain(owner))
		hierophant_network.Grant(owner)
		hierophant_network.title = "Vessel"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "alloy"
	else if(isclockmob(owner))
		hierophant_network.Grant(owner)
		hierophant_network.title = "Construct"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "brass"
	owner.throw_alert("clockinfo", /obj/screen/alert/clockwork/infodump)
	if(!clockwork_gateway_activated)
		owner.throw_alert("scripturereq", /obj/screen/alert/clockwork/scripture_reqs)
	update_slab_info()
	..()

/datum/antagonist/clockcultist/remove_innate_effects()
	all_clockwork_mobs -= owner
	owner.faction -= "ratvar"
	owner.languages_spoken &= ~RATVAR
	owner.languages_understood &= ~RATVAR
	owner.clear_alert("clockinfo")
	owner.clear_alert("scripturereq")
	for(var/datum/action/innate/function_call/F in owner.actions) //Removes any bound Ratvarian spears
		qdel(F)
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(isAI(S))
			var/mob/living/silicon/ai/A = S
			A.requires_power = initial(A.requires_power)
		S.make_laws()
		S.update_icons()
		S.show_laws()
	var/mob/living/temp_owner = owner
	..()
	if(iscyborg(temp_owner))
		var/mob/living/silicon/robot/R = temp_owner
		R.module.rebuild_modules()
	if(temp_owner)
		temp_owner.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them, we need to update buttons
	update_slab_info()

/datum/antagonist/clockcultist/on_remove()
	if(!silent_update)
		owner.visible_message("<span class='big'>[owner] seems to have remembered their true allegiance!</span>", \
		"<span class='userdanger'>A cold, cold darkness flows through your mind, extinguishing the Justiciar's light and all of your memories as his servant.</span>")
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.servants_of_ratvar -= owner.mind
		ticker.mode.update_servant_icons_removed(owner.mind)
	if(owner.mind)
		owner.mind.wipe_memory()
		owner.mind.special_role = null
	owner.attack_log += "\[[time_stamp()]\] <font color=#BE8700>Has renounced the cult of Ratvar!</font>"
	if(iscyborg(owner))
		owner << "<span class='warning'>Despite your freedom from Ratvar's influence, you are still irreparably damaged and no longer possess certain functions such as AI linking.</span>"
	..()
