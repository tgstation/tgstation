
/mob/living/simple_animal/Life()

	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			stat = CONSCIOUS
			density = 1
		return
	else if(health < 1)
		Die()
	else if(health > maxHealth)
		health = maxHealth

	//Movement
	if(!ckey && !stop_automated_movement)
		if(isturf(src.loc) && !resting && !buckled && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				Move(get_step(src,pick(cardinal)))
				turns_since_move = 0

	//Speaking
	if(prob(speak_chance))
		var/length = speak.len + emote_hear.len + emote_see.len
		if(speak.len && prob((speak.len / length) * 100))
			say(pick(speak))
		else if(emote_see.len && prob((emote_see.len / length) * 100))
			emote("auto",1,pick(emote_see))
		else if(emote_hear.len)
			emote("auto",2,pick(emote_hear))
			//var/act,var/m_type=1,var/message = null

	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc
	if(isturf(A))
		var/turf/T = A
		var/areatemp = T.temperature
		if( abs(areatemp - bodytemperature) > 50 )
			var/diff = areatemp - bodytemperature
			diff = diff / 5
			//world << "changed from [bodytemperature] by [diff] to [bodytemperature + diff]"
			bodytemperature += diff

		if(istype(T,/turf/simulated))
			var/turf/simulated/ST = T
			if(ST.air)
				var/tox = ST.air.toxins
				var/oxy = ST.air.oxygen
				var/n2  = ST.air.nitrogen
				var/co2 = ST.air.carbon_dioxide

				if(min_oxy)
					if(oxy < min_oxy)
						atmos_suitable = 0
				if(max_oxy)
					if(oxy > max_oxy)
						atmos_suitable = 0
				if(min_tox)
					if(tox < min_tox)
						atmos_suitable = 0
				if(max_tox)
					if(tox > max_tox)
						atmos_suitable = 0
				if(min_n2)
					if(n2 < min_n2)
						atmos_suitable = 0
				if(max_n2)
					if(n2 > max_n2)
						atmos_suitable = 0
				if(min_co2)
					if(co2 < min_co2)
						atmos_suitable = 0
				if(max_co2)
					if(co2 > max_co2)
						atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		health -= cold_damage_per_tick
	else if(bodytemperature > maxbodytemp)
		health -= heat_damage_per_tick

	if(!atmos_suitable)
		health -= unsuitable_atoms_damage
