/mob/living/carbon/
	gender = MALE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD)
	var/list/stomach_contents	= list()
	var/list/internal_organs	= list()	//List of /obj/item/organ in the mob. they don't go in the contents.

	var/silent = 0 		//Can't talk. Value goes down every life proc. //NOTE TO FUTURE CODERS: DO NOT INITIALIZE NUMERICAL VARS AS NULL OR I WILL MURDER YOU.

	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps use this.

//inventory slots
	var/obj/item/back = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/weapon/tank/internals/internal = null

	var/datum/dna/dna = null//Carbon
