//Initialisation procs
/mob/proc/mind_initialize()
	if(mind)
		mind.key = key

	else
		mind = new /datum/mind(key)
		SSticker.minds += mind
	if(!mind.name)
		mind.name = real_name
	mind.set_current(src)
	// There's nowhere else to set this up, mind code makes me depressed
	mind.antag_hud = add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/antagonist_hud, "combo_hud", mind)

/mob/living/carbon/mind_initialize()
	..()
	last_mind = mind


//AI
/mob/living/silicon/ai/mind_initialize()
	. = ..()
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/ai))


//BORG
/mob/living/silicon/robot/mind_initialize()
	. = ..()
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/cyborg))


//PAI
/mob/living/silicon/pai/mind_initialize()
	. = ..()
	mind.set_assigned_role(SSjob.GetJobType(/datum/job/personal_ai))
	mind.special_role = ""
