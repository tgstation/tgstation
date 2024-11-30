/datum/smite/retcon
	name = "Retcon"
	/// how long until the thing attacked by this smite gets deleted
	var/timer
	/// the time it takes to actually do the fade out animation, the victim will always have some time still fully visible
	var/fade_out_timer

/datum/smite/retcon/configure(client/user)
	timer = tgui_input_number(user, "How long should it take before the retcon, in seconds?", "Retcon", 5)

	if (isnull(timer))
		return FALSE

	fade_out_timer = timer*(3/5)

/datum/smite/retcon/effect(client/user, mob/living/target)
	. = ..()
	target.fade_into_nothing(timer SECONDS,fade_out_timer SECONDS)
	if(ishuman(target))
		delete_record(target)
		delete_bank_account(target)
		//reopen_job_slot(target)

/datum/smite/retcon/proc/delete_record(mob/living/target)
	var/name = target.real_name
	GLOB.manifest.remove(target)

/datum/smite/retcon/proc/delete_bank_account(mob/living/target)
	var/name = target.real_name
	var/account_list = flatten_list(SSeconomy.bank_accounts_by_id)
	for(var/i in length(account_list))
		if(account_list[i].account_holder == name)
			var/target_account = account_list[i]
			account_list -= target_account
			qdel(target_account)
			return

///datum/smite/retcon/proc/reopen_job_slot(mob/living/target)
//	SSjob.GetJob(JOB_MIME)
//	mime_job.total_positions += 1
