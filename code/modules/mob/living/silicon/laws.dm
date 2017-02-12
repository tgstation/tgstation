/mob/living/silicon/proc/show_laws() //Redefined in ai/laws.dm and robot/laws.dm
	return

/mob/living/silicon/proc/laws_sanity_check()
	if (!laws)
		make_laws()

/mob/living/silicon/proc/set_law_sixsixsix(law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.set_law_sixsixsix(law)

/mob/living/silicon/proc/set_zeroth_law(law, law_borg)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/proc/add_inherent_law(law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_inherent_law(law)

/mob/living/silicon/proc/clear_inherent_laws()
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_inherent_laws()

/mob/living/silicon/proc/add_supplied_law(number, law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_supplied_law(number, law)

/mob/living/silicon/proc/clear_supplied_laws()
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_supplied_laws()

/mob/living/silicon/proc/add_ion_law(law)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_ion_law(law)

/mob/living/silicon/proc/replace_random_law(law,groups)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.replace_random_law(law,groups)

/mob/living/silicon/proc/remove_law(number)
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.remove_law(number)

/mob/living/silicon/proc/clear_ion_laws()
	throw_alert("newlaw", /obj/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_ion_laws()

/mob/living/silicon/proc/make_laws()
	laws = new /datum/ai_laws
	laws.set_laws_config()
	laws.associate(src)

/mob/living/silicon/proc/clear_zeroth_law(force)
	laws_sanity_check()
	laws.clear_zeroth_law(force)

/mob/living/silicon/proc/clear_law_sixsixsix(force)
	laws_sanity_check()
	laws.clear_law_sixsixsix(force)
