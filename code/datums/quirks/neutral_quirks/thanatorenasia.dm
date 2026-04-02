/datum/quirk/death_dnr_poll
	name = "Thanatorenasia"
	desc = "Whenever you die and elect to \"Do Not Resuscitate\", your body may be taken over by another ghost upon revival - \
		giving it an entirely new personality and fresh set of memories."
	icon = FA_ICON_ZAP
	value = 0
	medical_record_text = "Patient has Thanatorenasia - in the event of their death and resuscitation, \
		they may experience memory loss or a change in personality."
	medical_symptom_text = "In the event of the patient's death and resuscitation, \
		they may experience memory loss or a change in personality."
	quirk_flags = QUIRK_NO_TRANSFER

	// Used the the spawners menu to describe the quirk
	var/you_are_text = "You are a deceased crewmember, afflicted with Thanatorenasia - \
		a condition which alters personality and causes memory loss upon death and revival."
	var/flavor_text = "Something feels... different. \
		You're not entirely sure who you are or what happened - All you remember is your name and that you work here. \
		Oh well, better get back to work - the last thing you want is to be both unemployed AND an amnesiac."
	var/important_text = "Resume your assigned duty. \
		If you choose to \"Do Not Resuscitate\" upon death, another ghost will be allowed to take over the body. \
		You still roll for midround antagonists."

/datum/quirk/death_dnr_poll/add_unique(client/client_source)
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_LIVING_DNR, PROC_REF(mob_died))

/datum/quirk/death_dnr_poll/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_LIVING_DNR)

/datum/quirk/death_dnr_poll/proc/mob_died(mob/living/source, mob/dead/observer/dnring)
	SIGNAL_HANDLER

	var/whomst = source.real_name
	var/workable_job = (source.mind && !is_unassigned_job(source.mind.assigned_role))
	if(workable_job)
		whomst += "? Job: [span_notice(source.mind.assigned_role.title)]"
	if(length(source.mind?.get_special_roles()))
		whomst += "[workable_job ? "," : "?"] Status: [span_boldnotice(english_list(source.mind?.get_special_roles()))]"

	source.AddComponent(/datum/component/ghostrole_on_revive, \
		refuse_revival_if_failed = TRUE, \
		on_successful_revive = CALLBACK(src, PROC_REF(on_successful_revive)), \
		revive_title = whomst, \
		spawn_text = "Deceased Crew", \
		you_are_text = src.you_are_text, \
		flavor_text = src.flavor_text, \
		important_text = src.important_text, \
	)
	source.log_message("was made ghostrole pollable by [name] quirk.", LOG_GAME, color = COLOR_PURPLE)

/datum/quirk/death_dnr_poll/proc/on_successful_revive()
	quirk_holder.log_message("has had their body taken over by a ghost due to the [name] quirk.", LOG_GAME, color = COLOR_PURPLE)
	var/welcome_msg = boxed_message(span_notice("<b>[quirk_holder.real_name]</b> has <i>[name]</i> - you are [quirk_holder.p_their()] new owner.<br>\
		If you choose to <b>\"Do Not Resuscitate\"</b> upon death, another ghost will take over the body once again."))
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(to_chat), quirk_holder, welcome_msg), 2 SECONDS)
