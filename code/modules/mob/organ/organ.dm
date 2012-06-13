//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/datum/organ
	var/name = "organ"
	var/owner = null


	proc/process()
		return 0


	proc/receive_chem(chemical as obj)
		return 0



/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"
	var/icon_name = null
	var/body_part = null

	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
//	var/bandaged = 0
	var/max_damage = 0
//	var/wound_size = 0
//	var/max_size = 0


	proc/take_damage(brute, burn)
		if((brute <= 0) && (burn <= 0))	return 0
		if((src.brute_dam + src.burn_dam + brute + burn) < src.max_damage)
			src.brute_dam += brute
			src.burn_dam += burn
		else
			var/can_inflict = src.max_damage - (src.brute_dam + src.burn_dam)
			if(can_inflict)
				if (brute > 0 && burn > 0)
					brute = can_inflict/2
					burn = can_inflict/2
					var/ratio = brute / (brute + burn)
					src.brute_dam += ratio * can_inflict
					src.burn_dam += (1 - ratio) * can_inflict
				else
					if (brute > 0)
						brute = can_inflict
						src.brute_dam += brute
					else
						burn = can_inflict
						src.burn_dam += burn
			else
				return 0

		return update_icon()


	proc/heal_damage(brute, burn)
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		return update_icon()


	proc/get_damage()	//returns total damage
		return src.brute_dam + src.burn_dam	//could use src.health?


// new damage icon system
// returns just the brute/burn damage code
	proc/update_icon()
		var/tburn
		var/tbrute
		if(burn_dam ==0)
			tburn = 0
		else if (src.burn_dam < (src.max_damage * 0.33))
			tburn = 1
		else if (src.burn_dam < (src.max_damage * 0.66))
			tburn = 2
		else
			tburn = 3

		if (src.brute_dam == 0)
			tbrute = 0
		else if (src.brute_dam < (src.max_damage * 0.33))
			tbrute = 1
		else if (src.brute_dam < (src.max_damage * 0.66))
			tbrute = 2
		else
			tbrute = 3
		if((tbrute != brutestate) || (tburn != burnstate))
			brutestate = tbrute
			burnstate = tburn
			return 1
		return 0



	proc/getDisplayName()
		switch(src.name)
			if("l_leg")
				return "left leg"
			if("r_leg")
				return "right leg"
			if("l_arm")
				return "left arm"
			if("r_arm")
				return "right arm"
			else
				return src.name


/*
/****************************************************
				INTERNAL ORGANS
****************************************************/
/datum/organ/internal
	name = "internal"
*/
