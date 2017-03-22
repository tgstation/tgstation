/obj/effect/proc_holder/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proprotions, we defeat common altgorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera or seen by AI units while using this skill. However, humans looking at us will find us... uncanny."
	dna_cost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/obj/effect/proc_holder/changeling/digitalcamo/sting_action(mob/user)

	if(user.digitalcamo)
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		user.digitalinvis = 0
		user.digitalcamo = 0
	else
		to_chat(user, "<span class='notice'>We distort our form to hide from the AI</span>")
		user.digitalcamo = 1
		user.digitalinvis = 1


	feedback_add_details("changeling_powers","CAM")
	return 1

/obj/effect/proc_holder/changeling/digitalcamo/on_refund(mob/user)
	user.digitalcamo = 0
	user.digitalinvis = 0