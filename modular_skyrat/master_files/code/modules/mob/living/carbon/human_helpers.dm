/mob/living/carbon/human/proc/generate_death_examine_text()
	var/mob/dead/observer/ghost = get_ghost(TRUE, TRUE)
	var/t_He = p_they(TRUE)
	var/t_his = p_their(TRUE)
	var/t_is = p_are()
	//This checks to see if the body is revivable
	if(key || !getorgan(/obj/item/organ/brain) || ghost?.can_reenter_corpse)
		return span_deadsay("[t_He] [t_is] limp and unresponsive; there are no signs of life...")
	else
		return span_deadsay("[t_He] [t_is] limp and unresponsive. [t_his] consciousness has degraded beyond revival.")
