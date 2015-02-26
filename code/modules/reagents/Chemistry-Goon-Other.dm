#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REM REAGENTS_EFFECT_MULTIPLIER

var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")

datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/carpet/reaction_turf(var/turf/simulated/T, var/volume)
	if(istype(T, /turf/simulated/floor/plating) || istype(T, /turf/simulated/floor/plasteel))
		var/turf/simulated/floor/F = T
		F.visible_message("[T] gets a layer of carpeting applied!")
		F.ChangeTurf(/turf/simulated/floor/fancy/carpet)
	..()
	return

datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "A burnt solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = "carpet"
	required_reagents = list("space_drugs" = 1, "blood" = 1)
	result_amount = 2


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	result = "ash"
	required_reagents = list("oil" = 1)
	result_amount = 1
	required_temp = 480

datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("stable_plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1)
	result_amount = 5

datum/reagent/colorful_reagent/on_mob_life(var/mob/living/M as mob)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
	return

datum/reagent/colorful_reagent/reaction_mob(var/mob/living/M, var/volume)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
	return
datum/reagent/colorful_reagent/reaction_obj(var/obj/O, var/volume)
	if(O)
		O.color = pick(random_color_list)
	..()
	return
datum/reagent/colorful_reagent/reaction_turf(var/turf/T, var/volume)
	if(T)
		T.color = pick(random_color_list)
	..()
	return


datum/reagent/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/triple_citrus
	name = "triple_citrus"
	id = "triple_citrus"
	result = "triple_citrus"
	required_reagents = list("lemonjuice" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 5

datum/reagent/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 5
	required_temp = 374

datum/reagent/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "Decays into sugar."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/corn_syrup/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 3)
	M.reagents.remove_reagent("corn_syrup", 1)
	..()
	return

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = "corgium"
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	required_temp = 374

datum/reagent/corgium
	name = "Corgium"
	id = "corgium"
	description = "Creates a corgi at the reaction location."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/corgium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/corgi(location)
	..()
	return

datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "radium" = 1, "space_drugs" = 1)
	result_amount = 5

datum/reagent/hair_dye/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hair_color = pick(potential_colors)
		H.facial_hair_color = pick(potential_colors)
		H.update_hair()
	..()
	return

datum/reagent/barbers_aid
	name = "Barber's Aid"
	id = "barbers_aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/barbers_aid
	name = "barbers_aid"
	id = "barbers_aid"
	result = "barbers_aid"
	required_reagents = list("carpet" = 1, "radium" = 1, "space_drugs" = 1)
	result_amount = 5

datum/reagent/barbers_aid/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/sprite_accessory/hair/picked_hair = pick(hair_styles_list)
		var/datum/sprite_accessory/facial_hair/picked_beard = pick(facial_hair_styles_list)
		H.hair_style = picked_hair
		H.facial_hair_style = picked_beard
		H.update_hair()
	..()
	return

datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	id = "concentrated_barbers_aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/chemical_reaction/concentrated_barbers_aid
	name = "concentrated_barbers_aid"
	id = "concentrated_barbers_aid"
	result = "concentrated_barbers_aid"
	required_reagents = list("barbers_aid" = 1, "mutagen" = 1)
	result_amount = 2

datum/reagent/concentrated_barbers_aid/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hair_style = "Very Long Hair"
		H.facial_hair_style = "Very Long Beard"
		H.update_hair()
	..()
	return


datum/reagent/liquid_drama
	name = "Liquid Drama"
	id = "liquid_drama"
	description = "All the hatred of the galaxy, compacted into 1 liquid."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/ramble_phrases = list("Goddamn fucking workers! They always shit stuff up!", "Stop misusing the bullshit we give you!", "Our department isn't being serious enough about their jobs!", "This bullshit isn't good enough for me!", "I need more interaction with my coworkers!", "I fucking hate all this random violence!")
	var/list/possible_actions = list("starts typing into an invisible keyboard!", "rants and raves!", "glares angrily at an invisible screen!", "screams and pulls at their hair!")
	var/list/idedplsnerf = list("toolboxes", "cyborgs", "the AI", "clowns", "security officers", "heads", "nuke ops", "assistants", "guns", "stuns", "stamps", "paperwork", "forums", "spacemen", "space", "air", "breathing", "existing", "moving", "chemistry", "science", "mining", "the bar")
	var/list/gonna_add_this_shit = list("off-station locations", "space anomalies", "spatial disruptions", "chemical based toolboxes", "an automated assistant smasher", "mafia chemistry", "space mafia", "currency", "the cybernet", "the metaverse", "modular systems")

/datum/chemical_reaction/liquid_drama
	name = "liquid_drama"
	id = "liquid_drama"
	result = "liquid_drama"
	required_reagents = list("stardust" = 1, "eye_of_toad" = 1,  "solid_errors" = 1, "liquid_rage" = 1, "paprika" = 1, "singulo" = 1)
	result_amount = 6
datum/reagent/liquid_drama/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		if(prob(5))
			M.visible_message("<span class = 'userdanger'>[M] [pick(possible_actions)]</span>")
		if(prob(5))
			M << "You feel like you've caused a lot of drama!"
			M.adjustToxLoss(3)
		if(prob(5))
			M.say(";[pick(ramble_phrases)])")
		if(prob(5))
			M.say(";Fuck this shit, I'm [pick("nerfing","buffing")] [pick(idedplsnerf)]!")
		if(prob(5))
			M.say(";Fuck it, I'm [pick("adding", "removing")] [pick(gonna_add_this_shit)] next shift!")
	..()
	return

datum/reagent/stardust
	name = "Stardust"
	id = "stardust"
	description = "Powdered stardust."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/effect_text = list("glitters.", "shines.", "sparkles.")

datum/reagent/stardust/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		if(prob(10))
			M.visible_message("[M] [pick(effect_text)]")
	..()
	return

datum/reagent/eye_of_toad
	name = "Eye Of Toad"
	id = "eye_of_toad"
	description = "A liquified eye of a toad."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/effect_text = list("ribbits.", "croaks.", "burps.")

datum/reagent/eye_of_toad/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		if(prob(10))
			M.visible_message("[M] [pick(effect_text)]")
	..()
	return

datum/reagent/solid_errors
	name = "Solid Errors"
	id = "solid_errors"
	description = "A bunch of solid text. How does this even work?"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/effect_text = list("runtimes!", "errors out!", "breaks!")

datum/reagent/solid_errors/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		if(prob(10))
			M.visible_message("<span class = 'userdanger'>[M] [pick(effect_text)]")
			if(!M.color)
				M.color = "#ff5555"
	..()
	return

datum/reagent/liquid_rage
	name = "Liquid Rage"
	id = "liquid_rage"
	description = "Looks like the tears of an assistant."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	var/list/effect_text = list("FUCKING FUCK SHIT ASS FUCK!!", "GODDAMN PIECES OF SHIT FUCKING EVERYTHING UP EVERY 5 MOTHERFUCKING SECONDS!", "YOU FUCKING PIECES OF SHIT RUINED EVERYTHING GOOD AND HOLY IN THIS FUCKING STATION!")

datum/reagent/liquid_rage/on_mob_life(var/mob/living/M as mob)
	if(M && ishuman(M))
		if(prob(10))
			var/should_radio = ""
			if(prob(25))
				should_radio = ";"
			M.say("[should_radio][pick(effect_text)]")
	..()
	return

/datum/chemical_reaction/solid_errors
	name = "solid_errors"
	id = "solid_errors"
	result = "solid_errors"
	required_reagents = list("liquid_rage" = 1, "paprika" = 1)
	result_amount = 2
	required_temp = 50 // gotta supercool that shit

/datum/chemical_reaction/liquid_rage
	name = "liquid_rage"
	id = "liquid_rage"
	result = "liquid_rage"
	required_reagents = list("clf3" = 1, "liquid_dark_matter" = 1, "sorium" = 1, "blackpowder" = 1)
	result_amount = 4

/datum/chemical_reaction/eye_of_toad
	name = "eye_of_toad"
	id = "eye_of_toad"
	result = "eye_of_toad"
	required_reagents = list("stardust" = 1)
	result_amount = 1
	required_temp = 800