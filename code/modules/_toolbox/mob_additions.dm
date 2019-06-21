/mob
	var/ask_to_ghost_on_move = 0

/mob/living
	var/adapt_size_to_health = 0 //activating this causes a mob to shrink as it loses health.
	var/lastadaptedhealth = null
	var/adapt_original_size_to_health = 0  //this causes a mob to start off bigger based on starting maxHealth, if var editing this in game you must call update_original_size_to_health() to update.

//This controls adapt_size_to_health
/mob/living/proc/resize_on_health()
	adapt_original_size_to_health = 0 //these 2 bits of code might break eachother
	if(stat != DEAD)
		if(!lastadaptedhealth && !isnum(lastadaptedhealth))
			lastadaptedhealth = health
		if(health != lastadaptedhealth)
			var/matrix/newtransform = new()
			newtransform = newtransform * max(health/maxHealth,0.3)
			transform = newtransform
			lastadaptedhealth = health
	else
		if(lastadaptedhealth != null)
			transform = initial(transform)
			lastadaptedhealth = null

//This controls adapt_original_size_to_health
/mob/living/proc/update_original_size_to_health()
	var/basehealth = initial(maxHealth)
	var/modifier = max(maxHealth/basehealth,0.33)
	var/matrix/newtransform = new()
	newtransform = newtransform * modifier
	transform = newtransform

//degenerals request to make mega arachnid use this.
/mob/living/simple_animal/hostile/jungle/mega_arachnid/random
	adapt_original_size_to_health = 1

/mob/living/simple_animal/hostile/jungle/mega_arachnid/random/Initialize()
	var/multiplier = round(rand(10,400)/100,0.01)
	maxHealth = round(maxHealth*multiplier,1)
	health = maxHealth
	. = ..()

//Making megafauna do an admin message when teleported off z-level. -falaskian
/mob/living/simple_animal/hostile/megafauna
	var/list/past_targets = list()
	var/last_target = null
	var/turf/last_turf = null

/mob/living/simple_animal/hostile/megafauna/Life()
	alert_location_to_admin()
	. = ..()

/mob/living/simple_animal/hostile/megafauna/compute_target()
	if(!ismob(target))
		return
	var/mob/M = target
	if(!M.ckey)
		return
	past_targets[M.ckey] = world.time
	last_target = M.ckey

/mob/living/simple_animal/hostile/megafauna/proc/alert_location_to_admin()
	var/turf/T = get_turf(src)
	if(isturf(T) && (!isturf(last_turf) || last_turf.z != T.z))
		var/last_turf_text = "null space"
		if(isturf(last_turf))
			last_turf_text = "[ADMIN_COORDJMP(last_turf)]"
		var/the_message = "A megafauna \"[name]\" has been moved accross z-levels from [last_turf_text] to [ADMIN_COORDJMP(T)]."
		var/kiters = ""
		var/last_target_text = ""
		if(past_targets.len)
			var/listlen = past_targets.len
			for(var/t in past_targets)
				if(!t || !istext(t))
					past_targets.Remove(t)
			var/listnumber = 0
			for(var/t in past_targets)
				listnumber++
				var/mob/the_mob
				var/is_last_target = 0
				for(var/mob/M in GLOB.player_list)
					if(M.ckey == t)
						the_mob = M
						if(last_target && M.ckey == last_target)
							is_last_target = 1
						break
				var/time_ago = world.time-past_targets[t]
				var/ckey_text = "[t]"
				if(the_mob)
					ckey_text = "[the_mob.real_name]([t])"
				ckey_text = "[ckey_text] - [round(time_ago/10)] seconds ago"
				if(is_last_target)
					last_target_text = "Last target was [ckey_text]."
				kiters += "[ckey_text]"
				if(listnumber < listlen)
					kiters += "|"
			the_message += " The megafauna targeted these players ([kiters])."
			if(last_target_text)
				the_message += " [last_target_text]"
		else
			the_message += " The megafauna never targeted anyone."
		message_admins("[the_message]")
		log_game("[the_message]")
	last_turf = T