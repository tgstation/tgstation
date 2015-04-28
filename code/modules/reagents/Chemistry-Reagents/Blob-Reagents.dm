// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	id = "boiling_oil"
	description = ""
	color = "#B68D00"

datum/reagent/blob/boiling_oil/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(15, BURN)
		M.adjust_fire_stacks(2)
		M.IgniteMob()
		if(show_message)
			M << "<span class = 'userdanger'>The blob splashes you with burning oil!</span>"
		M.emote("scream")

datum/reagent/blob/toxic_goop
	name = "Toxic Goop"
	id = "toxic_goop"
	description = ""
	color = "#008000"

datum/reagent/blob/toxic_goop/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(20, TOX)
		if(show_message)
			M << "<span class = 'userdanger'>The blob strikes you, and you feel sick and nauseated!</span>"

datum/reagent/blob/skin_ripper
	name = "Skin Ripper"
	id = "skin_ripper"
	description = ""
	color = "#FF4C4C"

datum/reagent/blob/skin_ripper/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(20, BRUTE)
		if(show_message)
			M << "<span class = 'userdanger'>The blob strikes you, and you feel your skin ripping and tearing off!</span>"
			M.emote("scream")

// Combo Reagents

datum/reagent/blob/skin_melter
	name = "Skin Melter"
	id = "skin_melter"
	description = ""
	color = "#7F0000"

datum/reagent/blob/skin_melter/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(10, BRUTE)
		M.apply_damage(10, BURN)
		M.adjust_fire_stacks(2)
		M.IgniteMob()
		if(show_message)
			M << "<span class = 'userdanger'>The blob strikes you, and you feel your skin char and melt!</span>"
			M.emote("scream")

datum/reagent/blob/lung_destroying_toxin
	name = "Lung Destroying Toxin"
	id = "lung_destroying_toxin"
	description = ""
	color = "#00FFC5"

datum/reagent/blob/lung_destroying_toxin/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume,var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(20, OXY)
		M.losebreath += 15
		M.apply_damage(20, TOX)
		if(show_message)
			M << "<span class = 'userdanger'>The blob strikes you, and your lungs feel heavy and weak!</span>"
// Special Reagents

datum/reagent/blob/radioactive_liquid
	name = "Radioactive Liquid"
	id = "radioactive_liquid"
	description = ""
	color = "#00EE00"

datum/reagent/blob/radioactive_liquid/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume,var/show_message = 1)
	if(method == TOUCH)
		if(istype(M, /mob/living/carbon/human))
			M.apply_damage(10, BRUTE)
			M.irradiate(40)
			if(prob(33))
				randmuti(M)
				if(prob(98))
					randmutb(M)
				domutcheck(M, null)
				updateappearance(M)
			if(show_message)
				M << "<span class = 'userdanger'>The blob strikes you, and your skin feels papery and everything hurts!</span>"

datum/reagent/blob/dark_matter
	name = "Dark Matter"
	id = "dark_matter"
	description = ""
	color = "#61407E"

datum/reagent/blob/dark_matter/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(15, BRUTE)
		reagent_vortex(M, 0)
		if(show_message)
			M << "<span class = 'userdanger'>You feel a thrum as the blob strikes you, and everything flies at you!</span>"

datum/reagent/blob/b_sorium
	name = "Sorium"
	id = "b_sorium"
	description = ""
	color = "#808000"

datum/reagent/blob/b_sorium/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		M.apply_damage(15, BRUTE)
		if(show_message)
			M << "<span class = 'userdanger'>The blob slams into you, and sends you flying!</span>"
		reagent_vortex(M, 1)


datum/reagent/blob/explosive // I'm gonna burn in hell for this one
	name = "Explosive Gelatin"
	id = "explosive"
	description = ""
	color = "#FFA500"

datum/reagent/blob/explosive/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		if(prob(75))
			if(show_message)
				M << "<span class = 'userdanger'>The blob strikes you, and its tendrils explode!</span>"
			explosion(M.loc, 0, 0, 1, 0, 0)

datum/reagent/blob/omnizine
	name = "Omnizine"
	id = "b_omnizine"
	description = ""
	color = "#C8A5DC"

datum/reagent/blob/omnizine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		if(show_message)
			M << "<span class = 'userdanger'>The blob squirts something at you, and you feel great!</span>"
		M.reagents.add_reagent("omnizine", 11)

datum/reagent/blob/morphine
	name = "Morphine"
	id = "b_morphine"
	description = ""
	color = "#335555"

datum/reagent/blob/morphine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		if(show_message)
			M << "<span class = 'userdanger'>The blob squirts something at you, and you feel numb!</span>"
		M.reagents.add_reagent("morphine", 16)

datum/reagent/blob/spacedrugs
	name = "Space drugs"
	id = "b_space_drugs"
	description = ""
	color = "#60A584"

datum/reagent/blob/spacedrugs/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(method == TOUCH)
		if(show_message)
			M << "<span class = 'userdanger'>The blob squirts something at you, and you feel funny!</span>"
		M.reagents.add_reagent("space_drugs", 15)
		M.apply_damage(10, TOX)


/proc/reagent_vortex(var/mob/living/M as mob, var/setting_type)
	var/turf/pull = get_turf(M)
	for(var/atom/movable/X in range(4,pull))
		if(istype(X, /atom/movable))
			if((X) && !X.anchored)
				if(setting_type)
					step_away(X,pull)
					step_away(X,pull)
					step_away(X,pull)
					step_away(X,pull)
				else
					X.throw_at(pull)




