

/obj/item/clothing/suit/space/space_ninja/proc/ntick(mob/living/carbon/human/U = affecting)
	set background = BACKGROUND_ENABLED

	//Runs in the background while the suit is initialized.
	spawn while(cell.charge)

		//Let's check for some safeties.
		if(s_initialized && !affecting)
			terminate()//Kills the suit and attached objects.
		if(!s_initialized)
			return//When turned off the proc stops.

		//Now let's do the normal processing.
		if(s_coold)
			s_coold--//Checks for ability s_cooldown first.

		var/A = s_cost//s_cost is the default energy cost each ntick, usually 5.
		if(s_active)//If stealth is active.
			A += s_acost
		cell.charge-=A

		if(!cell.charge)
			cell.charge=0
			cancel_stealth()

		sleep(10)//Checks every second.
