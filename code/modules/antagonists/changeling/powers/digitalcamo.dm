/obj/effect/proc_holder/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera or seen by AI units while using this skill. However, humans looking at us will find us... uncanny."
	dna_cost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/obj/effect/proc_holder/changeling/digitalcamo/sting_action(mob/user)

	if(user.hiddenFlags & DIGITAL_CAMO)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		user.hiddenFlags &= ~DIGITAL_CAMO
		user.remove_alt_appearance("digitalcamo")
		for(var/mob in GLOB.ai_list)
			user.showHudOf(mob, HIDE_DATA_HUDS)
	else
		to_chat(user, "<span class='notice'>We distort our form to hide from the AI</span>")
		user.hiddenFlags |= DIGITAL_CAMO
		var/image/I = image(loc = user)
		I.override = TRUE
		user.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/AI, "digitalcamo", I, FALSE)
		for(var/mob in GLOB.ai_list)
			user.hideHudOf(mob, HIDE_DATA_HUDS)
	return TRUE

/obj/effect/proc_holder/changeling/digitalcamo/on_refund(mob/user)
	user.hiddenFlags &= ~DIGITAL_CAMO
	user.remove_alt_appearance("digitalcamo")