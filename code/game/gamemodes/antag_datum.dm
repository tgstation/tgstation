/mob/living
	var/list/antag_datums

/mob/living/proc/gain_antag_datum(datum_type)
	if(!islist(antag_datums))
		antag_datums = list()
	var/datum/antagonist/D = new datum_type()
	. = D.give_to_body(src)

/mob/living/proc/has_antag_datum(type, check_subtypes)
	if(!islist(antag_datums))
		return FALSE
	for(var/i in antag_datums)
		var/datum/antagonist/D = i
		if(check_subtypes)
			if(istype(D, type))
				return D
		else
			if(D.type == type)
				return D
	return FALSE

/datum/antagonist
	var/mob/living/owner //who's our owner and accordingly an antagonist
	var/some_flufftext = "yer an antag larry"
	var/prevented_antag_datum_type //the type of antag datum that this datum can't coexist with; should probably be a list

/datum/antagonist/New()
	if(!prevented_antag_datum_type)
		prevented_antag_datum_type = type

/datum/antagonist/Destroy()
	owner = null
	return ..()

/datum/antagonist/proc/can_be_owned(mob/living/new_body)
	return new_body && !new_body.has_antag_datum(prevented_antag_datum_type, TRUE)

/datum/antagonist/proc/give_to_body(mob/living/new_body) //tries to give an antag datum to a mob. cancels out if it can't be owned by the new body
	if(new_body && can_be_owned(new_body))
		new_body.antag_datums += src
		owner = new_body
		on_gain()
		. = src //return the datum if successful
	else
		qdel(src)
		. = FALSE

/datum/antagonist/proc/on_gain() //on initial gain of antag datum, do this. should only be called once per datum
	apply_innate_effects()
	if(some_flufftext)
		owner << some_flufftext

/datum/antagonist/proc/apply_innate_effects() //applies innate effects to the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//antag huds would go here if antag huds were less completely unworkable as-is

/datum/antagonist/proc/remove_innate_effects() //removes innate effects from the owner, may be called multiple times due to mind transferral, but should only be called once per mob
	//also antag huds but see above antag huds a shit

/datum/antagonist/proc/on_remove() //totally removes the antag datum from the owner; can only be called once per owner
	remove_innate_effects()
	owner.antag_datums -= src
	qdel(src)

/datum/antagonist/proc/transfer_to_new_body(mob/living/new_body)
	remove_innate_effects()
	if(!islist(new_body.antag_datums))
		new_body.antag_datums = list()
	new_body.antag_datums += src
	owner.antag_datums -= src
	owner = new_body
	apply_innate_effects()

//CLOCKCULT PROOF OF CONCEPT

/datum/antagonist/clockcultist
	var/silent_update = FALSE
	prevented_antag_datum_type = /datum/antagonist/clockcultist
	some_flufftext = null

/datum/antagonist/clockcultist/silent
	silent_update = TRUE

/datum/antagonist/clockcultist/can_be_owned(mob/living/new_body)
	. = ..()
	if(.)
		. = is_eligible_servant(new_body)

/datum/antagonist/clockcultist/give_to_body(mob/living/new_body)
	if(!silent_update)
		if(iscarbon(new_body))
			new_body << "<span class='heavy_brass'>Your mind is racing! Your body feels incredibly light! Your world glows a brilliant yellow! All at once it comes to you. Ratvar, the Clockwork \
			Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>"
		else if(issilicon(new_body))
			new_body << "<span class='heavy_brass'>You are unable to compute this truth. Your vision glows a brilliant yellow, and all at once it comes to you. Ratvar, the Clockwork Justiciar, lies in \
			exile, derelict and forgotten in an unseen realm.</span>"
		else
			new_body << "<span class='heavy_brass'>Your world glows a brilliant yellow! All at once it comes to you. Ratvar, the Clockwork Justiciar, lies in exile, derelict and forgotten in an unseen realm.</span>"
	. = ..()
	if(!silent_update && new_body)
		if(.)
			new_body.visible_message("<span class='heavy_brass'>[new_body]'s eyes glow a blazing yellow!</span>", \
			"<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. Perform his every \
			whim without hesitation.</span>")
		else
			new_body.visible_message("<span class='warning'>[new_body] seems to resist an unseen force!</span>")
			new_body << "<span class='warning'><b>And yet, you somehow push it all away.</b></span>"

/datum/antagonist/clockcultist/on_gain()
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.servants_of_ratvar += owner.mind
		ticker.mode.update_servant_icons_added(owner.mind)
	if(owner.mind)
		owner.mind.special_role = "Servant of Ratvar"
	owner.attack_log += "\[[time_stamp()]\] <span class='brass'>Has been converted to the cult of Ratvar!</span>"
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(isrobot(S) && !silent_update)
			S << "<span class='boldwarning'>You have been desynced from your master AI. In addition, your onboard camera is no longer active and your safeties have been disabled.</span>"
		S << "<span class='heavy_brass'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>"
	else if(isbrain(owner) || isclockmob(owner))
		owner << "<span class='nezbere'>You can communicate with other servants by using the Hierophant Network action button in the upper left.</span>"
	..()

/datum/antagonist/clockcultist/apply_innate_effects()
	all_clockwork_mobs += owner
	owner.faction |= "ratvar"
	owner.languages_spoken |= RATVAR
	owner.languages_understood |= RATVAR
	owner.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them for whatever reason, we need to update buttons
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			R.UnlinkSelf()
			R.emagged = 1
		else if(isAI(S))
			var/mob/living/silicon/ai/A = S
			for(var/C in A.connected_robots)
				var/mob/living/silicon/robot/R = C
				if(R.connected_ai == A)
					R.visible_message("<span class='heavy_brass'>[R]'s eyes glow a blazing yellow!</span>", \
					"<span class='heavy_brass'>Assist your new companions in their righteous efforts. Your goal is theirs, and theirs yours. You serve the Clockwork Justiciar above all else. Perform his every \
					whim without hesitation.</span>")
					R << "<span class='boldwarning'>Your onboard camera is no longer active and your safeties have been disabled.</span>"
					add_servant_of_ratvar(R, TRUE)
		S.laws = new/datum/ai_laws/ratvar
		S.laws.associate(S)
		S.update_icons()
		S.show_laws()
		var/datum/action/innate/hierophant/H = new()
		H.Grant(S)
		H.title = "Silicon"
		H.span_for_name = "nezbere"
	else if(isbrain(owner))
		var/datum/action/innate/hierophant/H = new()
		H.Grant(owner)
		H.title = "Vessel"
		H.span_for_name = "nezbere"
		H.span_for_message = "alloy"
	else if(isclockmob(owner))
		var/datum/action/innate/hierophant/H = new()
		H.Grant(owner)
		H.title = "Construct"
		H.span_for_name = "nezbere"
	owner.throw_alert("clockinfo", /obj/screen/alert/clockwork/infodump)
	cache_check(owner)

/datum/antagonist/clockcultist/remove_innate_effects()
	all_clockwork_mobs -= owner
	owner.faction -= "ratvar"
	owner.languages_spoken &= ~RATVAR
	owner.languages_understood &= ~RATVAR
	owner.update_action_buttons_icon() //because a few clockcult things are action buttons and we may be wearing/holding them, we need to update buttons
	owner.clear_alert("clockinfo")
	owner.clear_alert("nocache")
	for(var/datum/action/innate/function_call/F in owner.actions) //Removes any bound Ratvarian spears
		qdel(F)
	for(var/datum/action/innate/hierophant/H in owner.actions) //Removes any communication actions
		qdel(H)
	if(issilicon(owner))
		var/mob/living/silicon/S = owner
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			R.emagged = initial(R.emagged)
		S.make_laws()
		S.update_icons()
		S.show_laws()

/datum/antagonist/clockcultist/on_remove()
	if(!silent_update)
		owner.visible_message("<span class='big'>[owner] seems to have remembered their true allegiance!</span>", \
		"<span class='userdanger'>A cold, cold darkness flows through your mind, extinguishing the Justiciar's light and all of your memories as his servant.</span>")
	if(ticker && ticker.mode && owner.mind)
		ticker.mode.servants_of_ratvar -= owner.mind
		ticker.mode.update_servant_icons_removed(owner.mind)
	if(owner.mind)
		owner.mind.memory = "" //Not sure if there's a better way to do this
		owner.mind.special_role = null
	owner.attack_log += "\[[time_stamp()]\] <span class='brass'>Has renounced the cult of Ratvar!</span>"
	if(isrobot(owner))
		owner << "<span class='warning'>Despite your freedom from Ratvar's influence, you are still irreparably damaged and no longer possess certain functions such as AI linking.</span>"
	..()
