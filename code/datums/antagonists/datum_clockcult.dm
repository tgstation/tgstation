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
	if(iscyborg(new_body))
		var/mob/living/silicon/robot/R = new_body
		if(R.deployed)
			var/mob/living/silicon/ai/AI = R.mainframe
			R.undeploy()
			var/converted = add_servant_of_ratvar(AI, silent_update)
			to_chat(AI, "<span class='userdanger'>Anomaly Detected. Returned to core!</span>")	//The AI needs to be in its core to properly be converted
			return converted
	if(!silent_update)
		if(issilicon(new_body))
			to_chat(new_body, "<span class='heavy_brass'>You are unable to compute this truth. Your vision glows a brilliant yellow, and all at once it comes to you. Ratvar, the Clockwork Justiciar, \
			lies in exile, derelict and forgotten in an unseen realm.</span>")
		else
			to_chat(new_body, "<span class='heavy_brass'>[iscarbon(new_body) ? "Your mind is racing! Your body feels incredibly light! ":""]Your world glows a brilliant yellow! All at once it comes to you. \
			Ratvar, the Clockwork Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>")
	. = ..()
	if(!silent_update && new_body)
		if(.)
			new_body.visible_message("<span class='heavy_brass'>[new_body]'s eyes glow a blazing yellow!</span>")
			to_chat(new_body, "<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. \
			Perform his every whim without hesitation.</span>")
		else
			new_body.visible_message("<span class='boldwarning'>[new_body] seems to resist an unseen force!</span>")
			to_chat(new_body, "<span class='userdanger'>And yet, you somehow push it all away.</span>")

/datum/antagonist/clockcultist/on_gain()
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.servants_of_ratvar += owner.mind
		ticker.mode.update_servant_icons_added(owner.mind)
		if(jobban_isbanned(owner, ROLE_SERVANT_OF_RATVAR))
			INVOKE_ASYNC(ticker.mode, /datum/game_mode.proc/replace_jobbaned_player, owner, ROLE_SERVANT_OF_RATVAR, ROLE_SERVANT_OF_RATVAR)
	if(owner.mind)
		owner.mind.special_role = "Servant of Ratvar"
	owner.log_message("<font color=#BE8700>Has been converted to the cult of Ratvar!</font>", INDIVIDUAL_ATTACK_LOG)
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(iscyborg(S) && !silent_update)
			to_chat(S, "<span class='boldwarning'>You have been desynced from your master AI.\n\
			In addition, your onboard camera is no longer active and you have gained additional equipment, including a limited clockwork slab.</span>")
		if(isAI(S))
			to_chat(S, "<span class='boldwarning'>You are able to use your cameras to listen in on conversations.</span>")
		to_chat(S, "<span class='heavy_brass'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>")
	else if(isbrain(owner) || isclockmob(owner))
		to_chat(owner, "<span class='nezbere'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>")
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
			if(!R.shell)
				R.UnlinkSelf()
			R.module.rebuild_modules()
		else if(isAI(S))
			var/mob/living/silicon/ai/A = S
			A.can_be_carded = FALSE
			A.requires_power = POWER_REQ_CLOCKCULT
			A.languages_spoken &= ~HUMAN
			var/list/AI_frame = list(image('icons/mob/clockwork_mobs.dmi', A, "aiframe")) //make the AI's cool frame
			for(var/d in cardinal)
				AI_frame += image('icons/mob/clockwork_mobs.dmi', A, "eye[rand(1, 10)]", dir = d) //the eyes are randomly fast or slow
			A.add_overlay(AI_frame)
			if(!A.lacks_power())
				A.ai_restore_power()
			if(A.eyeobj)
				A.eyeobj.relay_speech = TRUE
			for(var/mob/living/silicon/robot/R in A.connected_robots)
				if(R.connected_ai == A)
					R.visible_message("<span class='heavy_brass'>[R]'s eyes glow a blazing yellow!</span>", \
					"<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. Perform his every \
					whim without hesitation.</span>")
					to_chat(R, "<span class='boldwarning'>Your onboard camera is no longer active and you have gained additional equipment, including a limited clockwork slab.</span>")
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
			A.can_be_carded = initial(A.can_be_carded)
			A.requires_power = initial(A.requires_power)
			A.languages_spoken |= HUMAN
			A.cut_overlays()
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
	owner.log_message("<font color=#BE8700>Has renounced the cult of Ratvar!</font>", INDIVIDUAL_ATTACK_LOG)
	if(iscyborg(owner))
		to_chat(owner, "<span class='warning'>Despite your freedom from Ratvar's influence, you are still irreparably damaged and no longer possess certain functions such as AI linking.</span>")
	..()
