//this proc handles adding xp to you
/proc/add_jobxp(client/target, amount, job, needs_job = TRUE)
	if(!target || !target.prefs || !amount || !job)
		return
	if(target.mob.mind.assigned_role.title != job && needs_job)
		return
	target.prefs.job_xp_list[job] += amount
	target.prefs.check_levelup(job)

//this shouldn't normally ever be called unless your sadistic
/proc/remove_jobxp(client/target, amount, job, needs_job = TRUE)
	if(!target || !target.prefs || !amount || !job)
		return
	if(target.mob.mind.assigned_role.title != job && needs_job)
		return
	target.prefs.job_xp_list[job] -= amount

//this proc handles adding xp to you but on a chance basis useful for super spamable stuff
/proc/add_jobxp_chance(client/target, amount, job, chance, needs_job = TRUE)
	if(!target || !target.prefs || !amount || !job)
		return
	if(target.mob.mind.assigned_role.title != job && needs_job)
		return
	if(prob(chance))
		target.prefs.job_xp_list[job] += amount
		target.prefs.check_levelup(job)

/proc/add_jobxp_chance_delayed_check(client/target, amount, job, chance, needs_job = TRUE)
	if(!target || !target.prefs || !amount || !job)
		return
	if(target.mob.mind.assigned_role.title != job && needs_job)
		return
	if(prob(chance))
		target.prefs.job_xp_list[job] += amount

		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(checklevelup_delayer), target, job), 1 SECONDS)

/proc/checklevelup_delayer(client/target, job)
	target.prefs.check_levelup(job)
