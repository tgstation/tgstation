// These can only be applied by blobs. They are what blobs are made out of.
// The 4 damage
datum/reagent/blob/boiling_oil
	name = "Boiling Oil"
	id = "boiling_oil"
	description = ""
	color = "#000000"

datum/reagent/blob/boiling_oil/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(20, BURN)
		M << "You feel your skin burning!"
		M.emote("scream")

datum/reagent/blob/toxic_goop
	name = "Toxic Goop"
	id = "toxic_goop"
	description = ""
	color = "#008000"

datum/reagent/blob/toxic_goop/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(20, TOX)
		M << "You feel sick!"

datum/reagent/blob/skin_ripper
	name = "Skin Ripper"
	id = "skin_ripper"
	description = ""
	color = "#FF0000"

datum/reagent/blob/skin_ripper/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(20, BRUTE)
		M << "You feel your skin being ripped off!"
		M.emote("scream")

datum/reagent/blob/anti_oxygenation
	name = "Anti-Oxygenation Liquid"
	id = "anti_oxygenation"
	description = ""
	color = "#00FFFF"

datum/reagent/blob/anti_oxygenation/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(20, OXY)
		M << "You can't breathe!"

datum/reagent/blob/stamina_drainer
	name = "Stamina Drainer"
	id = "stamina_drainer"
	description = ""
	color = "#FFFF00"

datum/reagent/blob/stamina_drainer/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(20, STAMINA)
		M << "You feel incredibly tired!"

// Combo Reagents

datum/reagent/blob/skin_melter
	name = "Skin Melter"
	id = "skin_melter"
	description = ""
	color = "#7F0000"

datum/reagent/blob/skin_melter/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(10, BRUTE)
		M.apply_damage(10, BURN)
		M << "You feel your skin burning and melting!"
		M.emote("scream")

datum/reagent/blob/lung_destroying_toxin
	name = "Lung Destroying Toxin"
	id = "boiling_oil"
	description = ""
	color = "#00FFC5"

datum/reagent/blob/lung_destroying_toxin/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.apply_damage(10, OXY)
		M.apply_damage(10, TOX)
		M << "You feel your lungs rotting!"
// Special Reagents
datum/reagent/blob/acid
	name = "Acidic Liquid"
	id = "blob_acid"
	description = ""
	color = "#912CEE"

datum/reagent/blob/acid/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.acid_act(20,20,20)
		M << "You feel your skin and equipment melting off!"
