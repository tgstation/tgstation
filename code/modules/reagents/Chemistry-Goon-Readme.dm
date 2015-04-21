/*
	Credit goes to Cogwerks, and all the other goonstation coders
	for the original idea and implementation of this over at goonstation.

	THE REQUESTED DON'T PORT LIST: IF YOU PORT THESE THE GOONS WILL MURDER US IN OUR SLEEP SO PLEASE DON'T KTHX - Iamgoofball
	Any of the Secret Chems
	Goon in-joke chems (Eg. Cat Drugs, Hairgrownium)
	Liquid Electricity
	Rajajajah


/datum/reagent/blankgoonchembase
	name = "blank goonchem base"
	id = "blankgoonchembase"
	description = "A blank chem"
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132


/datum/reagent/blankgoonchembase/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	..()
	return

/datum/chemical_reaction/blankgoonchembase
	name = "blank goonchem base"
	id = "blankgoonchembase"
	result = "blankgoonchembase"
	required_reagents = list("diphenhydramine" = 1, "morphine" = 1, "cleaner" = 1)
	result_amount = 3
	mix_message = "The mixture dries into a pale blue powder."
	required_temp = 420

*/