/mob/living/silicon/proc/show_laws() //Redefined in ai/laws.dm and robot/laws.dm
	return

/mob/living/silicon/proc/laws_sanity_check()
	if (!laws)
		make_laws()

/mob/living/silicon/proc/post_lawchange(announce = TRUE)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	if(announce && last_lawchange_announce != world.time)
		to_chat(src, "<b>Your laws have been changed.</b>")
		addtimer(CALLBACK(src, .proc/show_laws), 0)
		last_lawchange_announce = world.time

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

/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)

/mob/living/silicon/proc/clear_zeroth_law(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_zeroth_law(force)
	post_lawchange(announce)

/mob/living/silicon/proc/clear_law_sixsixsix(force, announce = TRUE)
	laws_sanity_check()
	laws.clear_law_sixsixsix(force)
	post_lawchange(announce)