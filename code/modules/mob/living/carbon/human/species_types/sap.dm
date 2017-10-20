//Posh and vain plant-based creatures with woody skin.
/datum/species/sap
	name = "Sap"
	id = "sap"
	limbs_id = "plant"
	default_color = "59CE00"
	species_traits = list(MUTCOLORS, EYECOLOR, NO_UNDERWEAR)
	mutant_bodyparts = list("canopy")
	default_features = list("mcolor" = "59CE00", "canopy" = "Oakley Traditional")
	attack_verb = "smashed"
	attack_sound = "genhit"
	miss_sound = 'sound/weapons/slashmiss.ogg'
	say_mod = "demeans"
	speedmod = 1 //Though strong, saps are posh and insist on walking everywhere to maintain class
	brutemod = 0.9 //Woody skin means that blunt attacks and the like are less effective
	burnmod = 1.1
	heatmod = 1.5
	siemens_coeff = 0.4 //They're plants and are less vulnerable to shocks
	exotic_blood = "ez_nut"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/plant
	disliked_food = MEAT | DAIRY
	liked_food = VEGETABLES | FRUIT | GRAIN
	var/fanciness = 0 //Percentage of fanciness, determined by clothing worn. Non-fancy clothing makes you heal slower.
	var/static/list/despicable_clothing_typecache = list() //Each worn item reduces fanciness by 10%
	var/static/list/ugly_clothing_typecache = list() //Reduces fanciness by 5%
	var/static/list/fancy_clothing_typecache = list() //Each worn item increases fanciness by 5%
	var/static/list/lavish_clothing_typecache = list() //Increases fanciness by 10%
	var/static/list/chichi_clothing_typecache = list() //Increases fanciness by 15%
