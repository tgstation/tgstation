/datum/intercept_text
	var/text
	var/prob_correct_person_lower = 20
	var/prob_correct_person_higher = 80
	var/prob_correct_job_lower = 20
	var/prob_correct_job_higher = 80
	var/prob_correct_prints_lower = 20
	var/prob_correct_print_higher = 80
	var/prob_correct_objective_lower = 20
	var/prob_correct_objective_higher = 80
	var/list/org_names_1 = list(
		"Blighted",
		"Defiled",
		"Unholy",
		"Murderous",
		"Ugly",
		"French",
		"Blue",
		"Farmer"
	)
	var/list/org_names_2 = list(
		"Reapers",
		"Swarm",
		"Rogues",
		"Menace",
		"Jeff Worshippers",
		"Drunks",
		"Strikers",
		"Creed"
	)
	var/list/anomalies = list(
		"Huge electrical storm",
		"Photon emitter",
		"Meson generator",
		"Blue swirly thing"
	)
	var/list/SWF_names = list(
		"Grand Wizard",
		"His Most Unholy Master",
		"The Most Angry",
		"Bighands",
		"Tall Hat",
		"Deadly Sandals"
	)
	var/list/changeling_names = list(
		"Odo",
		"The Thing",
		"Booga",
		"The Goatee of Wrath",
		"Tam Lin",
		"Species 3157"
	)


/datum/intercept_text/proc/build(var/mode_type, datum/mind/correct_person)
	switch(mode_type)
		if("revolution")
			src.text = ""
			src.build_rev(correct_person)
			return src.text
		if("cult")
			src.text = ""
			src.build_cult(correct_person)
			return src.text
		if("wizard")
			src.text = ""
			src.build_wizard(correct_person)
			return src.text
		if("nuke")
			src.text = ""
			src.build_nuke(correct_person)
			return src.text
		if("traitor")
			src.text = ""
			src.build_traitor(correct_person)
			return src.text
		if("malf")
			src.text = ""
			src.build_malf(correct_person)
			return src.text
		if("changeling","traitorchan")
			src.text = ""
			src.build_changeling(correct_person)
			return src.text
		else
			return null


/datum/intercept_text/proc/pick_mob()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in player_list)
		if (!man.mind) continue
		if (man.mind.assigned_role=="MODE") continue
		dudes += man
	if(dudes.len==0)
		return null
	return pick(dudes)


/datum/intercept_text/proc/pick_fingerprints()
	var/mob/living/carbon/human/dude = src.pick_mob()
	//if (!dude) return pick_fingerprints() //who coded that is totally crasy or just a traitor. -- rastaf0
	if(dude)
		return num2text(md5(dude.dna.uni_identity))
	else
		return num2text(md5(num2text(rand(1,10000))))


/datum/intercept_text/proc/build_traitor(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	var/fingerprints
	var/traitor_name
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	if(prob(prob_right_dude) && ticker.mode == "traitor")
		if(correct_person:assigned_role=="MODE")
			traitor_name = pick_mob()
		else
			traitor_name = correct_person:current
	else if(prob(prob_right_dude))
		traitor_name = pick_mob()
	else
		fingerprints = pick_fingerprints()

	src.text += "<BR><BR>The <B>[name_1] [name_2]</B> implied an undercover operative was acting on their behalf on the station currently.<BR>"
	src.text += "After some investigation, we "
	if(traitor_name)
		src.text += "are [prob_right_dude]% sure that [traitor_name] may have been involved, and should be closely observed."
		src.text += "<BR>Note: This group are known to be untrustworthy, so do not act on this information without proper discourse."
	else
		src.text += "discovered the following set of fingerprints ([fingerprints]) on sensitive materials, and their owner should be closely observed."
		src.text += "However, these could also belong to a current Cent. Com employee, so do not act on this without reason."


/datum/intercept_text/proc/build_cult(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_cult(correct_person))
		if (correct_person)
			if(correct_person:assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person:assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp.Remove("Captain", "Chaplain", "AI", "Cyborg", "Security Officer", "Detective", "Head Of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Chief Medical Officer")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode == "cult")
		if(correct_person:assigned_role=="MODE")
			traitor_name = src.pick_mob()
		else
			traitor_name = correct_person:current
	else
		traitor_name = pick_mob()

	src.text += "<BR><BR>It has been brought to our attention that the [name_1] [name_2] have stumbled upon some dark secrets. They apparently want to spread the dangerous knowledge on as many stations as they can.<BR>"
	src.text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been converted "
	src.text += "and instilled with the idea of the flimsiness of the real world, seeking to destroy it. "
	if(prob(prob_right_dude))
		src.text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		src.text += "organisation."
	src.text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."


/datum/intercept_text/proc/build_rev(datum/mind/correct_person)
	var/name_1 = pick(src.org_names_1)
	var/name_2 = pick(src.org_names_2)
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_rev(correct_person))
		if (correct_person)
			if(correct_person.assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person.assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp-=nonhuman_positions
		job_tmp-=command_positions
		job_tmp.Remove("Security Officer", "Detective", "Warden", "MODE")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode.config_tag == "revolution")
		if(correct_person.assigned_role=="MODE")
			traitor_name = src.pick_mob()
		else
			traitor_name = correct_person.current
	else
		traitor_name = src.pick_mob()

	src.text += "<BR><BR>It has been brought to our attention that the [name_1] [name_2] are attempting to stir unrest on one of our stations in your sector. <BR>"
	src.text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been brainwashed "
	src.text += "at a recent conference, and their department should be closely monitored for signs of mutiny. "
	if(prob(prob_right_dude))
		src.text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		src.text += "organisation."
	src.text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."


/datum/intercept_text/proc/build_wizard(datum/mind/correct_person)
	var/SWF_desc = pick(SWF_names)

	src.text += "<BR><BR>The evil Space Wizards Federation have recently broke their most feared wizard, known only as \"[SWF_desc]\" out of space jail. "
	src.text += "He is on the run, last spotted in a system near your present location. If anybody suspicious is located aboard, please "
	src.text += "approach with EXTREME caution. Cent. Com also recommends that it would be wise to not inform the crew of this, due to their fearful nature."
	src.text += "Known attributes include: Brown sandals, a large blue hat, a voluptous white beard, and an inclination to cast spells."

/datum/intercept_text/proc/build_nuke(datum/mind/correct_person)
	src.text += "<BR><BR>Cent. Com recently recieved a report of a plot to destory one of our stations in your area. We believe the Nuclear Authentication Disc "
	src.text += "that is standard issue aboard your vessel may be a target. We recommend removal of this object, and it's storage in a safe "
	src.text += "environment. As this may cause panic among the crew, all efforts should be made to keep this information a secret from all but "
	src.text += "the most trusted crew-members."

/datum/intercept_text/proc/build_malf(datum/mind/correct_person)
	var/a_name = pick(src.anomalies)
	src.text += "<BR><BR>A [a_name] was recently picked up by a nearby stations sensors in your sector. If it came into contact with your ship or "
	src.text += "electrical equipment, it may have had hazardarous and unpredictable effect. Closely observe any non carbon based life forms "
	src.text += "for signs of unusual behaviour, but keep this information discreet at all times due to this possibly dangerous scenario."

/datum/intercept_text/proc/build_changeling(datum/mind/correct_person)
	var/cname = pick(src.changeling_names)
	var/orgname1 = pick(src.org_names_1)
	var/orgname2 = pick(src.org_names_2)
	var/changeling_name
	var/changeling_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job))
		if(correct_person)
			if(correct_person:assigned_role=="MODE")
				changeling_job = pick(get_all_jobs())
			else
				changeling_job = correct_person:assigned_role
	else
		changeling_job = pick(get_all_jobs())
	if(prob(prob_right_dude) && ticker.mode == "changeling")
		if(correct_person:assigned_role=="MODE")
			changeling_name = correct_person:current
		else
			changeling_name = src.pick_mob()
	else
		changeling_name = src.pick_mob()

	src.text += "<BR><BR>We have received a report that a dangerous alien lifeform known only as \"[cname]\" may have infiltrated your crew.  "
	src.text += "Our intelligence suggests a [prob_right_job]% chance that a [changeling_job] on board your station has been replaced by the alien.  "
	src.text += "Additionally, the report indicates a [prob_right_dude]% chance that [changeling_name] may have been in contact with the lifeform at a recent social gathering.  "
	src.text += "These lifeforms are assosciated with the [orgname1] [orgname2] and may be attempting to acquire sensitive materials on their behalf.  "
	src.text += "Please take care not to alarm the crew, as [cname] may take advantage of a panic situation."
