/datum/smite/retcon
	name = "Retcon"
	/// how long until the thing attacked by this smite gets deleted
	var/timer
	/// the time it takes to actually do the fade out animation, the victim will always have some time still fully visible
	var/fade_out_timer

/datum/smite/retcon/configure(client/user)
	timer = tgui_input_number(user, "How long should it take before the target disappears, in seconds?", "Retcon", 5)

	if (isnull(timer))
		return FALSE

	fade_out_timer = timer*3*0.2

/datum/smite/retcon/effect(client/user, mob/living/target)
	. = ..()
	target.fade_into_nothing(timer SECONDS,fade_out_timer SECONDS)
	if(ishuman(target))
		delete_record(target)
		delete_bank_account(target)
		reopen_job_slot(target)

/datum/smite/retcon/proc/delete_record(mob/living/target)
	var/name = target.real_name
	GLOB.manifest.remove(name)

/datum/smite/retcon/proc/delete_bank_account(mob/living/target)
	var/name = target.real_name
	var/account_list = flatten_list(SSeconomy.bank_accounts_by_id)
	for(var/datum/bank_account/account in account_list)
		if(account.account_holder == name)
			qdel(account)
			return

/datum/smite/retcon/proc/reopen_job_slot(mob/living/target)
	var/datum/job/target_job = target.mind?.assigned_role
	if(target_job)
		target_job.total_positions += 1
