// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
/datum/reagent/blob
	var/message = "The blob strikes you" //message sent to any mob hit by the blob
	var/message_living = null //extension to first mob sent to only living mobs i.e. silicons have no skin to be burnt

/datum/reagent/blob/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message, touch_protection)
	return round(reac_volume * min(1.5 - touch_protection, 1), 0.1) //full touch protection means 50% volume, any prot below 0.5 means 100% volume.

/datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	id = "boiling_oil"
	description = ""
	color = "#B68D00"
	message = "The blob splashes you with burning oil"

/datum/reagent/blob/boiling_oil/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	M.adjust_fire_stacks(round(reac_volume/12))
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BURN)
	M.IgniteMob()
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/toxic_goop
	name = "Toxic Goop"
	id = "toxic_goop"
	description = ""
	color = "#008000"
	message_living = ", and you feel sick and nauseated"

/datum/reagent/blob/toxic_goop/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.8*reac_volume, TOX)

/datum/reagent/blob/skin_ripper
	name = "Skin Ripper"
	id = "skin_ripper"
	description = ""
	color = "#FF4C4C"
	message_living = ", and you feel your skin ripping and tearing off"

/datum/reagent/blob/skin_ripper/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.8*reac_volume, BRUTE)
	if(iscarbon(M))
		M.emote("scream")

// Combo Reagents

/datum/reagent/blob/skin_melter
	name = "Skin Melter"
	id = "skin_melter"
	description = ""
	color = "#7F0000"
	message_living = ", and you feel your skin char and melt"

/datum/reagent/blob/skin_melter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	M.adjust_fire_stacks(round(reac_volume/12))
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BRUTE)
	M.apply_damage(0.4*reac_volume, BURN)
	M.IgniteMob()
	if(iscarbon(M))
		M.emote("scream")

/datum/reagent/blob/lung_destroying_toxin
	name = "Lung Destroying Toxin"
	id = "lung_destroying_toxin"
	description = ""
	color = "#00FFC5"
	message_living = ", and your lungs feel heavy and weak"

/datum/reagent/blob/lung_destroying_toxin/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.8* reac_volume, OXY)
	M.losebreath += round(0.6*reac_volume)
	M.apply_damage(0.8*reac_volume, TOX)

// Special Reagents

/datum/reagent/blob/radioactive_liquid
	name = "Radioactive Liquid"
	id = "radioactive_liquid"
	description = ""
	color = "#00EE00"
	message_living = ", and your skin feels papery and everything hurts"

/datum/reagent/blob/radioactive_liquid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.4*reac_volume, BRUTE)
	if(ishuman(M))
		M.irradiate(1.6*reac_volume)
		if(prob(1.3*reac_volume))
			randmuti(M)
			if(prob(98))
				randmutb(M)
			domutcheck(M, null)
			updateappearance(M)

/datum/reagent/blob/dark_matter
	name = "Dark Matter"
	id = "dark_matter"
	description = ""
	color = "#61407E"
	message = "You feel a thrum as the blob strikes you, and everything flies at you"

/datum/reagent/blob/dark_matter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reagent_vortex(M, 0, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/b_sorium
	name = "Sorium"
	id = "b_sorium"
	description = ""
	color = "#808000"
	message = "The blob slams into you, and sends you flying"

/datum/reagent/blob/b_sorium/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reagent_vortex(M, 1, reac_volume)
	reac_volume = ..()
	M.apply_damage(0.6*reac_volume, BRUTE)

/datum/reagent/blob/explosive // I'm gonna burn in hell for this one
	name = "Explosive Gelatin"
	id = "explosive"
	description = ""
	color = "#FFA500"
	message = "The blob strikes you, and its tendrils explode"

/datum/reagent/blob/explosive/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(prob(3*reac_volume))
		explosion(M.loc, 0, 0, 1, 0, 0)

/datum/reagent/blob/omnizine
	name = "Omnizine"
	id = "b_omnizine"
	description = ""
	color = "#C8A5DC"
	message = "The blob squirts something at you"
	message_living = ", and you feel great"

/datum/reagent/blob/omnizine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.reagents.add_reagent("omnizine", 0.6*reac_volume)

/datum/reagent/blob/spacedrugs
	name = "Space drugs"
	id = "b_space_drugs"
	description = ""
	color = "#60A584"
	message = "The blob squirts something at you"
	message_living = ", and you feel funny"

/datum/reagent/blob/spacedrugs/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	reac_volume = ..()
	M.hallucination += 0.8*reac_volume
	M.reagents.add_reagent("space_drugs", 0.6*reac_volume)
	M.apply_damage(0.4*reac_volume, TOX)


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