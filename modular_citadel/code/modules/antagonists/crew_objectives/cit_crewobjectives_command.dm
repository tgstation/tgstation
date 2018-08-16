/*				COMMAND OBJECTIVES				*/

/datum/objective/crew/caphat //Ported from Goon
	explanation_text = "Don't lose your hat."
	jobs = "captain"

/datum/objective/crew/caphat/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/clothing/head/caphat))
		return TRUE
	else
		return FALSE

/datum/objective/crew/datfukkendisk //Ported from old Hippie
	explanation_text = "Defend the nuclear authentication disk at all costs, and be the one to personally deliver it to Centcom."
	jobs = "captain" //give this to other heads at your own risk.

/datum/objective/crew/datfukkendisk/check_completion()
	if(owner && owner.current && owner.current.check_contents_for(/obj/item/disk/nuclear) && SSshuttle.emergency.shuttle_areas[get_area(owner.current)])
		return TRUE
	else
		return FALSE

/datum/objective/crew/ian //Ported from old Hippie
	explanation_text = "Defend Ian at all costs, and ensure he gets delivered to Centcom at the end of the shift."
	jobs = "headofpersonnel"

/datum/objective/crew/ian/check_completion()
	if(owner && owner.current)
		for(var/mob/living/simple_animal/pet/dog/corgi/Ian/goodboy in GLOB.mob_list)
			if(goodboy.stat != DEAD && SSshuttle.emergency.shuttle_areas[get_area(goodboy)])
				return TRUE
		return FALSE
	return FALSE
