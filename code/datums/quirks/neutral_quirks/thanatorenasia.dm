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

/datum/quirk/death_dnr_poll/add_unique(client/client_source)
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_LIVING_DNR, PROC_REF(mob_died))

/datum/quirk/death_dnr_poll/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_LIVING_DNR)

/datum/quirk/death_dnr_poll/proc/mob_died(mob/living/source, mob/dead/observer/dnring)
	SIGNAL_HANDLER

	var/whomst = source.real_name
	if(source.mind && !is_unassigned_job(source.mind.assigned_role))
		whomst += "Job: [span_notice(source.mind.assigned_role.title)]."
	if(length(source.mind?.get_special_roles()))
		whomst += "Status: [span_boldnotice(english_list(source.mind?.get_special_roles()))]."

	source.AddComponent(/datum/component/ghostrole_on_revive, \
		refuse_revival_if_failed = TRUE, \
		on_successful_revive = CALLBACK(src, PROC_REF(on_successful_revive)), \
		revive_title = whomst, \
	)
	source.log_message("was made ghostrole pollable by [name] quirk.", LOG_GAME, color = COLOR_GREEN)

/datum/quirk/death_dnr_poll/proc/on_successful_revive()
	quirk_holder.log_message("has had their body taken over by a ghost due to their [name] quirk.", LOG_GAME, color = COLOR_GREEN)
	var/welcome_msg = boxed_message(span_notice("<b>[quirk_holder.real_name]</b> has <i>[name]</i> - you are [quirk_holder.p_their()] new owner.<br>\
		If you choose to <b>\"Do Not Resuscitate\"</b> upon death, another ghost will take over the body once again."))
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(to_chat), quirk_holder, welcome_msg), 2 SECONDS)
