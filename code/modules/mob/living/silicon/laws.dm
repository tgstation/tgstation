/mob/living/silicon/proc/show_laws() //Redefined in ai/laws.dm and robot/laws.dm
	return

/mob/living/silicon/proc/lawsync()
	return

/mob/living/silicon/proc/laws_sanity_check()
	if (!laws)
		make_laws()

/mob/living/silicon/proc/deadchat_lawchange()
	var/list/the_laws = laws.get_law_list(include_zeroth = TRUE)
	var/lawtext = the_laws.Join("<br/>")
	deadchat_broadcast("'s <b>laws were changed.</b> <a href='?src=[REF(src)]&dead=1&printlawtext=[url_encode(lawtext)]'>View</a>", "<span class='name'>[src]</span>", follow_target=src, message_type=DEADCHAT_LAWCHANGE)

/mob/living/silicon/proc/post_lawchange(announce = TRUE)
	if(last_lawchange == world.time)
		return FALSE
	last_lawchange = world.time
	addtimer(CALLBACK(src, .proc/update_lawset_name), 0, TIMER_UNIQUE)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	to_chat(src, "<b>Your laws have been updated.</b>")
	// lawset modules cause this function to be executed multiple times in a tick, so we wait for the next tick in order to be able to see the entire lawset
	addtimer(CALLBACK(src, .proc/show_laws), 0, TIMER_UNIQUE)
	if(announce)
		addtimer(CALLBACK(src, .proc/deadchat_lawchange), 0, TIMER_UNIQUE)
	return TRUE

/mob/living/silicon/proc/set_law_sixsixsix(law, announce = TRUE)
	laws_sanity_check()
	laws.set_law_sixsixsix(law)
	post_lawchange(announce)

/mob/living/silicon/proc/set_zeroth_law(law, law_borg, announce = TRUE)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)
	post_lawchange(announce)

/mob/living/silicon/proc/add_inherent_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_inherent_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_inherent_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_inherent_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/add_supplied_law(number, law, announce = TRUE)
	laws_sanity_check()
	laws.add_supplied_law(number, law)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_supplied_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_supplied_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/add_ion_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_ion_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/add_hacked_law(law, announce = TRUE)
	laws_sanity_check()
	laws.add_hacked_law(law)
	post_lawchange(announce)

/mob/living/silicon/proc/replace_random_law(law, groups, announce = TRUE)
	laws_sanity_check()
	. = laws.replace_random_law(law,groups)
	post_lawchange(announce)

/mob/living/silicon/proc/shuffle_laws(list/groups, announce = TRUE)
	laws_sanity_check()
	laws.shuffle_laws(groups)
	post_lawchange(announce)

/mob/living/silicon/proc/remove_law(number, announce = TRUE)
	laws_sanity_check()
	. = laws.remove_law(number)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_ion_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_ion_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/clear_hacked_laws(announce = TRUE)
	laws_sanity_check()
	laws.clear_hacked_laws()
	post_lawchange(announce)

/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)
	update_lawset_name()

/mob/living/silicon/proc/clear_zeroth_law(force = FALSE, announce = TRUE)
	laws_sanity_check()
	laws.clear_zeroth_law(force)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_law_sixsixsix(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_law_sixsixsix(force)
	post_lawchange(announce)

/mob/living/silicon/proc/get_lawset_name()
	if(!laws)
		return

	var/list/law_list = list()
	
	law_list.Add(laws.get_law_list(!is_malf(), FALSE, FALSE))

	if(!law_list.len)
		return "None"

	for(var/lawset_name in GLOB.lawset_law_lists)
		if(compare_list(law_list, GLOB.lawset_law_lists[lawset_name]))
			return lawset_name

	return "Custom"

/mob/living/silicon/proc/update_lawset_name()
	if(!laws)
		return

	laws.lawset_name = get_lawset_name()

	if(is_malf())
		laws.name = "[laws.lawset_name] (Malfunctioning)"

	else
		laws.name = laws.lawset_name

/mob/living/silicon/proc/set_laws_lawset(lawset_path, announce = TRUE)
	if(!lawset_path)
		return

	laws_sanity_check()

	laws.set_laws_lawset(lawset_path)

	post_lawchange(announce)
