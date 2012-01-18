/datum/organ
	var
		name = "organ"
		owner = null


	proc/process()
		return 0


	proc/receive_chem(chemical as obj)
		return 0



/****************************************************
				EXTERNAL ORGANS
****************************************************/
/datum/organ/external
	name = "external"
	var
		icon_name = null
		body_part = null

		damage_state = "00"
		brute_dam = 0
		burn_dam = 0
		bandaged = 0
		max_damage = 0
		wound_size = 0
		max_size = 0


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

		var/result = src.update_icon()
		return result


	proc/heal_damage(brute, burn)
		src.brute_dam = max(0, src.brute_dam - brute)
		src.burn_dam = max(0, src.burn_dam - burn)
		return update_icon()


	proc/get_damage()	//returns total damage
		return src.brute_dam + src.burn_dam	//could use src.health?


// new damage icon system
// returns just the brute/burn damage code
	proc/damage_state_text()
		var/tburn = 0
		var/tbrute = 0

		if(burn_dam ==0)
			tburn =0
		else if (src.burn_dam < (src.max_damage * 0.25 / 2))
			tburn = 1
		else if (src.burn_dam < (src.max_damage * 0.75 / 2))
			tburn = 2
		else
			tburn = 3

		if (src.brute_dam == 0)
			tbrute = 0
		else if (src.brute_dam < (src.max_damage * 0.25 / 2))
			tbrute = 1
		else if (src.brute_dam < (src.max_damage * 0.75 / 2))
			tbrute = 2
		else
			tbrute = 3
		return "[tbrute][tburn]"


// new damage icon system
// adjusted to set damage_state to brute/burn code only (without r_name0 as before)
	proc/update_icon()
		var/n_is = src.damage_state_text()
		if (n_is != src.damage_state)
			src.damage_state = n_is
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



/****************************************************
				INTERNAL ORGANS
****************************************************/
/datum/organ/internal
	name = "internal"