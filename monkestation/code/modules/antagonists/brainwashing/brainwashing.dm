/datum/antagonist/brainwashed
	name = "\improper Brainwashed Victim"
	job_rank = ROLE_BRAINWASHED
	roundend_category = "brainwashed victims"
	show_in_antagpanel = TRUE
	antag_hud_name = "brainwashed"
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE
	ui_name = "AntagInfoBrainwashed"
	suicide_cry = "FOR... SOMEONE!!"
	var/popup_shown = FALSE // since it's not uncommon for someone to be brainwashed while dead, it's easy for them to completely miss the fact they're brainwashed once they're revived.

/datum/antagonist/brainwashed/on_gain()
	owner.current.log_message("has been brainwashed!", LOG_ATTACK, color = "#960000")
	return ..()

/datum/antagonist/brainwashed/on_removal()
	owner.current.log_message("is no longer brainwashed!", LOG_ATTACK, color = "#960000")
	return ..()

/datum/antagonist/brainwashed/greet()
	to_chat(owner,  span_big(span_hypnophrase("Your mind reels as it begins focusing on a single purpose...")))
	to_chat(owner, span_userdanger("Follow the Directives, at any cost!"))
	owner.announce_objectives()
	if(owner.current.client)
		popup_shown = TRUE

/datum/antagonist/brainwashed/farewell()
	to_chat(owner, span_big(span_hypnophrase("Your mind suddenly clears...")))
	to_chat(owner, span_userdanger("You feel the weight of the Directives disappear! You no longer have to obey them."))
	owner.announce_objectives()

/datum/antagonist/brainwashed/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/user = owner.current || mob_override
	user.throw_alert(ALERT_BRAINWASHED, /atom/movable/screen/alert/brainwashed)
	RegisterSignal(user, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(greet_on_login))

/datum/antagonist/brainwashed/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/user = owner.current || mob_override
	user.clear_alert(ALERT_BRAINWASHED)
	UnregisterSignal(user, COMSIG_MOB_CLIENT_LOGIN)

/datum/antagonist/brainwashed/on_mindshield(mob/implanter)
	owner.remove_antag_datum(/datum/antagonist/brainwashed)
	return COMPONENT_MINDSHIELD_DECONVERTED

/datum/antagonist/brainwashed/proc/greet_on_login(mob/body)
	SIGNAL_HANDLER
	if(popup_shown)
		return
	greet()
	if(body.client)
		INVOKE_ASYNC(src, PROC_REF(ui_interact), body)

/datum/antagonist/brainwashed/admin_add(datum/mind/new_owner,mob/admin)
	var/mob/living/carbon/C = new_owner.current
	if(!istype(C))
		return
	var/list/objectives = list()
	do
		var/objective = tgui_input_text(admin, "Add an objective", "Brainwashing")
		if(objective)
			objectives += objective
	while(tgui_alert(admin, "Add another objective?", "More Brainwashing", list("Yes", "No")) == "Yes")

	if(tgui_alert(admin,"Confirm Brainwashing?", "Are you sure?", list("Yes", "No")) == "No")
		return

	if(!LAZYLEN(objectives))
		return

	if(QDELETED(C))
		to_chat(admin, "Mob doesn't exist anymore")
		return

	brainwash(C, objectives, "adminbus")
	var/obj_list = english_list(objectives)
	message_admins("[key_name_admin(admin)] has brainwashed [key_name_admin(C)] with the following objectives: [obj_list].")
	C.log_message("has been force-brainwashed with the objective '[obj_list]' by admin [key_name(admin)]", LOG_VICTIM, log_globally = FALSE)
	log_admin("[key_name(admin)] has brainwashed [key_name(C)] with the following objectives: [obj_list].")

/datum/objective/brainwashing
	completed = TRUE
	var/source
