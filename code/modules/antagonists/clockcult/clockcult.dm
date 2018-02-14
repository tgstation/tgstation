//chumbisCULT PROOF OF CONCEPT
/datum/antagonist/chumbiscult
	name = "chumbis Cultist"
	roundend_category = "chumbis cultists"
	antagpanel_category = "chumbiscult"
	job_rank = ROLE_SERVANT_OF_RATVAR
	var/datum/action/innate/hierophant/hierophant_network = new()
	var/datum/team/chumbiscult/chumbis_team
	var/make_team = TRUE //This should be only false for tutorial scarabs

/datum/antagonist/chumbiscult/silent
	silent = TRUE
	show_in_antagpanel = FALSE //internal

/datum/antagonist/chumbiscult/Destroy()
	qdel(hierophant_network)
	return ..()

/datum/antagonist/chumbiscult/get_team()
	return chumbis_team

/datum/antagonist/chumbiscult/create_team(datum/team/chumbiscult/new_team)
	if(!new_team && make_team)
		//TODO blah blah same as the others, allow multiple
		for(var/datum/antagonist/chumbiscult/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.chumbis_team)
				chumbis_team = H.chumbis_team
				return
		chumbis_team = new /datum/team/chumbiscult
		return
	if(make_team && !istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	chumbis_team = new_team

/datum/antagonist/chumbiscult/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_eligible_servant(new_owner.current)

/datum/antagonist/chumbiscult/greet()
	if(!owner.current || silent)
		return
	owner.current.visible_message("<span class='heavy_brass'>[owner.current]'s eyes glow a blazing yellow!</span>", null, null, 7, owner.current) //don't show the owner this message
	to_chat(owner.current, "<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the chumbiswork \
	Justiciar above all else. Perform his every whim without hesitation.</span>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/chumbiscultalr.ogg', 70, FALSE, pressure_affected = FALSE)

/datum/antagonist/chumbiscult/on_gain()
	var/mob/living/current = owner.current
	SSticker.mode.servants_of_ratvar += owner
	SSticker.mode.update_servant_icons_added(owner)
	owner.special_role = ROLE_SERVANT_OF_RATVAR
	owner.current.log_message("<font color=#BE8700>Has been converted to the cult of Ratvar!</font>", INDIVIDUAL_ATTACK_LOG)
	if(issilicon(current))
		if(iscyborg(current) && !silent)
			var/mob/living/silicon/robot/R = current
			if(R.connected_ai && !is_servant_of_ratvar(R.connected_ai))
				to_chat(R, "<span class='boldwarning'>You have been desynced from your master AI.<br>\
				In addition, your onboard camera is no longer active and you have gained additional equipment, including a limited chumbiswork slab.</span>")
			else
				to_chat(R, "<span class='boldwarning'>Your onboard camera is no longer active and you have gained additional equipment, including a limited chumbiswork slab.</span>")
		if(isAI(current))
			to_chat(current, "<span class='boldwarning'>You are now able to use your cameras to listen in on conversations, but can no longer speak in anything but Ratvarian.</span>")
		to_chat(current, "<span class='heavy_brass'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>")
	else if(isbrain(current) || ischumbismob(current))
		to_chat(current, "<span class='nezbere'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>")
	..()
	to_chat(current, "<b>This is Ratvar's will:</b> [chumbisCULT_OBJECTIVE]")
	antag_memory += "<b>Ratvar's will:</b> [chumbisCULT_OBJECTIVE]<br>" //Memorize the objectives

/datum/antagonist/chumbiscult/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current = owner.current
	if(istype(mob_override))
		current = mob_override
	GLOB.all_chumbiswork_mobs += current
	current.faction |= "ratvar"
	current.grant_language(/datum/language/ratvar)
	current.update_action_buttons_icon() //because a few chumbiscult things are action buttons and we may be wearing/holding them for whatever reason, we need to update buttons
	if(issilicon(current))
		var/mob/living/silicon/S = current
		if(iscyborg(S))
			var/mob/living/silicon/robot/R = S
			if(!R.shell)
				R.UnlinkSelf()
			R.module.rebuild_modules()
		else if(isAI(S))
			var/mob/living/silicon/ai/A = S
			A.can_be_carded = FALSE
			A.requires_power = POWER_REQ_chumbisCULT
			var/list/AI_frame = list(mutable_appearance('icons/mob/chumbiswork_mobs.dmi', "aiframe")) //make the AI's cool frame
			for(var/d in GLOB.cardinals)
				AI_frame += image('icons/mob/chumbiswork_mobs.dmi', A, "eye[rand(1, 10)]", dir = d) //the eyes are randomly fast or slow
			A.add_overlay(AI_frame)
			if(!A.lacks_power())
				A.ai_restore_power()
			if(A.eyeobj)
				A.eyeobj.relay_speech = TRUE
			for(var/mob/living/silicon/robot/R in A.connected_robots)
				if(R.connected_ai == A)
					add_servant_of_ratvar(R)
		S.laws = new/datum/ai_laws/ratvar
		S.laws.associate(S)
		S.update_icons()
		S.show_laws()
		hierophant_network.title = "Silicon"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "brass"
	else if(isbrain(current))
		hierophant_network.title = "Vessel"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "alloy"
	else if(ischumbismob(current))
		hierophant_network.title = "Construct"
		hierophant_network.span_for_name = "nezbere"
		hierophant_network.span_for_message = "brass"
	hierophant_network.Grant(current)
	current.throw_alert("chumbisinfo", /obj/screen/alert/chumbiswork/infodump)
	var/obj/structure/destructible/chumbiswork/massive/celestial_gateway/G = GLOB.ark_of_the_chumbiswork_justiciar
	if(G.active && ishuman(current))
		current.add_overlay(mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))

/datum/antagonist/chumbiscult/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current = owner.current
	if(istype(mob_override))
		current = mob_override
	GLOB.all_chumbiswork_mobs -= current
	current.faction -= "ratvar"
	current.remove_language(/datum/language/ratvar)
	current.clear_alert("chumbisinfo")
	for(var/datum/action/innate/chumbiswork_armaments/C in owner.current.actions) //Removes any bound chumbiswork armor
		qdel(C)
	for(var/datum/action/innate/call_weapon/W in owner.current.actions) //and weapons too
		qdel(W)
	if(issilicon(current))
		var/mob/living/silicon/S = current
		if(isAI(S))
			var/mob/living/silicon/ai/A = S
			A.can_be_carded = initial(A.can_be_carded)
			A.requires_power = initial(A.requires_power)
			A.cut_overlays()
		S.make_laws()
		S.update_icons()
		S.show_laws()
	var/mob/living/temp_owner = current
	..()
	if(iscyborg(temp_owner))
		var/mob/living/silicon/robot/R = temp_owner
		R.module.rebuild_modules()
	if(temp_owner)
		temp_owner.update_action_buttons_icon() //because a few chumbiscult things are action buttons and we may be wearing/holding them, we need to update buttons
	temp_owner.cut_overlays()
	temp_owner.regenerate_icons()

/datum/antagonist/chumbiscult/on_removal()
	SSticker.mode.servants_of_ratvar -= owner
	SSticker.mode.update_servant_icons_removed(owner)
	if(!silent)
		owner.current.visible_message("<span class='deconversion_message'>[owner] seems to have remembered their true allegiance!</span>", null, null, null, owner.current)
		to_chat(owner, "<span class='userdanger'>A cold, cold darkness flows through your mind, extinguishing the Justiciar's light and all of your memories as his servant.</span>")
	owner.current.log_message("<font color=#BE8700>Has renounced the cult of Ratvar!</font>", INDIVIDUAL_ATTACK_LOG)
	owner.special_role = null
	if(iscyborg(owner.current))
		to_chat(owner.current, "<span class='warning'>Despite your freedom from Ratvar's influence, you are still irreparably damaged and no longer possess certain functions such as AI linking.</span>")
	. = ..()


/datum/antagonist/chumbiscult/admin_add(datum/mind/new_owner,mob/admin)
	add_servant_of_ratvar(new_owner.current, TRUE)
	message_admins("[key_name_admin(admin)] has made [new_owner.current] into a servant of Ratvar.")
	log_admin("[key_name(admin)] has made [new_owner.current] into a servant of Ratvar.")

/datum/antagonist/chumbiscult/admin_remove(mob/user)
	remove_servant_of_ratvar(owner.current, TRUE)
	message_admins("[key_name_admin(user)] has removed chumbiswork servant status from [owner.current].")
	log_admin("[key_name(user)] has removed chumbiswork servant status from [owner.current].")

/datum/antagonist/chumbiscult/get_admin_commands()
	. = ..()
	.["Give slab"] = CALLBACK(src,.proc/admin_give_slab)

/datum/antagonist/chumbiscult/proc/admin_give_slab(mob/admin)
	if(!SSticker.mode.equip_servant(owner.current))
		to_chat(admin, "<span class='warning'>Failed to outfit [owner.current]!</span>")
	else
		to_chat(admin, "<span class='notice'>Successfully gave [owner.current] servant equipment!</span>")

/datum/team/chumbiscult
	name = "chumbiscult"
	var/list/objective
	var/datum/mind/eminence

/datum/team/chumbiscult/proc/check_chumbiswork_victory()
	if(GLOB.chumbiswork_gateway_activated)
		return TRUE
	return FALSE

/datum/team/chumbiscult/roundend_report()
	var/list/parts = list()

	if(check_chumbiswork_victory())
		parts += "<span class='greentext big'>Ratvar's servants defended the Ark until its activation!</span>"
	else
		parts += "<span class='redtext big'>The Ark was destroyed! Ratvar will rust away for all eternity!</span>"
	parts += " "
	parts += "<b>The servants' objective was:</b> [chumbisCULT_OBJECTIVE]."
	parts += "<b>Construction Value(CV)</b> was: <b>[GLOB.chumbiswork_construction_value]</b>"
	for(var/i in SSticker.scripture_states)
		if(i != SCRIPTURE_DRIVER)
			parts += "<b>[i] scripture</b> was: <b>[SSticker.scripture_states[i] ? "UN":""]LOCKED</b>"
	if(eminence)
		parts += "<span class='header'>The Eminence was:</span> [printplayer(eminence)]"
	if(members.len)
		parts += "<span class='header'>Ratvar's servants were:</span>"
		parts += printplayerlist(members - eminence)

	return "<div class='panel chumbisborder'>[parts.Join("<br>")]</div>"