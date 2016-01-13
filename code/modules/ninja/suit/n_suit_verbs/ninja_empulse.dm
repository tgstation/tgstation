

//Disables nearby tech equipment.
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()
	set name = "EM Burst (25E)"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja Ability"
	set popup_menu = 0

	if(!ninjacost(250,N_STEALTH_CANCEL))
		var/mob/living/carbon/human/H = affecting
		playsound(H.loc, 'sound/effects/EMPulse.ogg', 60, 2)
		empulse(H, 4, 6) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		s_coold = 2
	return