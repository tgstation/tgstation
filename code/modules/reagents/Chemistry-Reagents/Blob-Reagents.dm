// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
/datum/reagent/blob
	name = "Unknown"
	description = "shouldn't exist and you should adminhelp immediately."
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt

/datum/reagent/blob/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection)
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/ripping_tendrils //does brute and a little stamina damage
	name = "Ripping Tendrils"
	id = "ripping_tendrils"
	description = "will do medium brute and stamina damage."
	color = "#7F0000"
	message_living = ", and you feel your skin ripping and tearing off"

/datum/reagent/blob/ripping_tendrils/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)
	M.adjustStaminaLoss(0.4*reac_volume)
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/boiling_oil //sets you on fire, does burn damage
	name = "Boiling Oil"
	id = "boiling_oil"
	description = "will cause medium burn damage and set targets on fire."
	color = "#B68D00"
	message = "The blob splashes you with burning oil"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	M.adjust_fire_stacks(round(reac_volume/12))
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BURN)
	M.IgniteMob()
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/envenomed_filaments //toxin, hallucination, and some bonus spore toxin
	name = "Envenomed Filaments"
	id = "envenomed_filaments"
	description = "will cause medium toxin damage, hallucinations, and inject targets with toxins."
	color = "#9ACD32"
	message_living = ", and you feel sick and nauseated"

/datum/reagent/blob/envenomed_filaments/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, TOX)
	M.hallucination += 0.6*reac_volume
	if(M.reagents)
		M.reagents.add_reagent("spore", 0.4*reac_volume)

/datum/reagent/blob/lexorin_jelly //does tons of oxygen damage and a little brute
	name = "Lexorin Jelly"
	id = "lexorin_jelly"
	description = "will cause low brute damage, high oxygen damage and cause targets to be unable to breathe."
	color = "#00FFC5"
	message_living = ", and your lungs feel heavy and weak"

/datum/reagent/blob/lexorin_jelly/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BRUTE)
	M.apply_damage(1*reac_volume, OXY)
	M.losebreath += round(0.3*reac_volume)

/datum/reagent/blob/kinetic //does semi-random brute damage
	name = "Kinetic Gelatin"
	id = "kinetic"
	description = "will do high brute damage."
	color = "#FFA500"
	message = "The blob pummels you"

/datum/reagent/blob/kinetic/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	var/damage = rand(10, 35)/25
	M.apply_damage(damage*reac_volume, BRUTE)

/datum/reagent/blob/cryogenic_liquid //does low burn damage and stamina damage and cools targets down
	name = "Cryogenic Liquid"
	id = "cryogenic_liquid"
	description = "will cause low burn, stamina damage, and cause targets to freeze."
	color = "#8BA6E9"
	message = "The blob splashes you with an icy liquid"
	message_living = ", and you feel cold and tired"

/datum/reagent/blob/cryogenic_liquid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BURN)
	M.adjustStaminaLoss(0.4*reac_volume)
	if(M.reagents)
		M.reagents.add_reagent("frostoil", 0.4*reac_volume)

/datum/reagent/blob/dark_matter //does brute damage and throws or pulls nearby objects at the target
	name = "Dark Matter"
	id = "dark_matter"
	description = "will do medium brute damage and pull nearby objects and enemies at the target."
	color = "#61407E"
	message = "You feel a thrum as the blob strikes you, and everything flies at you"

/datum/reagent/blob/dark_matter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reagent_vortex(M, 0, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/b_sorium //does brute damage and throws or pushes nearby objects away from the target
	name = "Sorium"
	id = "b_sorium"
	description = "will do medium brute damage and throw nearby objects and enemies away from the target."
	color = "#808000"
	message = "The blob slams into you, and sends you flying"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reagent_vortex(M, 1, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/proc/reagent_vortex(mob/living/M, setting_type, reac_volume)
	var/turf/pull = get_turf(M)
	var/range_power = Clamp(round(reac_volume/5, 1), 1, 5)
	for(var/atom/movable/X in range(range_power,pull))
		if(istype(X, /obj/effect))
			continue
		if(!X.anchored)
			var/distance = get_dist(X, pull)
			var/moving_power = max(range_power - distance, 1)
			spawn(0)
				if(moving_power > 2) //if the vortex is powerful and we're close, we get thrown
					if(setting_type)
						var/atom/throw_target = get_edge_target_turf(X, get_dir(X, get_step_away(X, pull)))
						var/throw_range = 5 - distance
						X.throw_at(throw_target, throw_range, 1)
					else
						X.throw_at(pull, distance, 1)
				else
					if(setting_type)
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_away(X, pull))
								break
					else
						for(var/i = 0, i < moving_power, i++)
							sleep(2)
							if(!step_towards(X, pull))
								break


/datum/reagent/blob/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	M << "<span class='userdanger'>[totalmessage]</span>"