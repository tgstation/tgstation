// TO DO: Replace this with job datum flags instead.
GLOBAL_LIST_INIT(exp_specialmap, list(
	EXP_TYPE_LIVING = list(), // all living mobs
	EXP_TYPE_ANTAG = list(),
	EXP_TYPE_SPECIAL = list(
		ROLE_LIFEBRINGER,
		ROLE_ASHWALKER,
		ROLE_EXILE,
		ROLE_SERVANT_GOLEM,
		ROLE_FREE_GOLEM,
		ROLE_HERMIT,
		ROLE_ESCAPED_PRISONER,
		ROLE_HOTEL_STAFF,
		ROLE_SPACE_SYNDICATE,
		ROLE_ANCIENT_CREW,
		ROLE_SPACE_DOCTOR,
		ROLE_SPACE_BARTENDER,
		ROLE_BEACH_BUM,
		ROLE_SKELETON,
		ROLE_ZOMBIE,
		ROLE_SPACE_BAR_PATRON,
		ROLE_LAVALAND_SYNDICATE,
		ROLE_MAINTENANCE_DRONE,
		ROLE_VENUSHUMANTRAP,
		ROLE_GHOST_ROLE,
		), // Ghost roles
	EXP_TYPE_GHOST = list() // dead people, observers
))
GLOBAL_PROTECT(exp_specialmap)

//this is necessary because antags happen before job datums are handed out, but NOT before they come into existence
//so I can't simply use job datum.department_head straight from the mind datum, laaaaame.
/proc/get_department_heads(job_title)
	if(!job_title)
		return list()

	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.title == job_title)
			return job.department_head //this is a list

/proc/get_full_job_name(job)
	var/static/regex/cap_expand = STATIC_INIT(new /regex("cap(?!tain)"))
	var/static/regex/cmo_expand = STATIC_INIT(new /regex("cmo"))
	var/static/regex/hos_expand = STATIC_INIT(new /regex("hos"))
	var/static/regex/hop_expand = STATIC_INIT(new /regex("hop"))
	var/static/regex/rd_expand = STATIC_INIT(new /regex("rd"))
	var/static/regex/ce_expand = STATIC_INIT(new /regex("ce"))
	var/static/regex/qm_expand = STATIC_INIT(new /regex("qm"))
	var/static/regex/sec_expand = STATIC_INIT(new /regex("(?<!security )officer"))
	var/static/regex/engi_expand = STATIC_INIT(new /regex("(?<!station )engineer"))
	var/static/regex/atmos_expand = STATIC_INIT(new /regex("atmos tech"))
	var/static/regex/doc_expand = STATIC_INIT(new /regex("(?<!medical )doctor|medic(?!al)"))
	var/static/regex/mine_expand = STATIC_INIT(new /regex("(?<!shaft )miner"))
	var/static/regex/chef_expand = STATIC_INIT(new /regex("chef"))
	var/static/regex/borg_expand = STATIC_INIT(new /regex("(?<!cy)borg"))

	job = lowertext(job)
	job = cap_expand.Replace(job, "captain")
	job = cmo_expand.Replace(job, "chief medical officer")
	job = hos_expand.Replace(job, "head of security")
	job = hop_expand.Replace(job, "head of personnel")
	job = rd_expand.Replace(job, "research director")
	job = ce_expand.Replace(job, "chief engineer")
	job = qm_expand.Replace(job, "quartermaster")
	job = sec_expand.Replace(job, "security officer")
	job = engi_expand.Replace(job, "station engineer")
	job = atmos_expand.Replace(job, "atmospheric technician")
	job = doc_expand.Replace(job, "medical doctor")
	job = mine_expand.Replace(job, "shaft miner")
	job = chef_expand.Replace(job, "cook")
	job = borg_expand.Replace(job, "cyborg")
	return job
