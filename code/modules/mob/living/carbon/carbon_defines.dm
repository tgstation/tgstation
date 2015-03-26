/mob/living/carbon/
	gender = MALE
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD)
	var/list/stomach_contents	= list()
	var/list/internal_organs	= list()	//List of /obj/item/organ in the mob. they don't go in the contents.

	var/silent = 0 		//Can't talk. Value goes down every life proc. //NOTE TO FUTURE CODERS: DO NOT INITIALIZE NUMERICAL VARS AS NULL OR I WILL MURDER YOU.

	var/obj/item/handcuffed = null //Whether or not the mob is handcuffed
	var/obj/item/legcuffed = null  //Same as handcuffs but for legs. Bear traps & legcuffs use this.

//inventory slots
	var/obj/item/back = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/weapon/tank/internal = null

	var/datum/dna/dna = null//Carbon

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/co2overloadtime = null
	var/temperature_resistance = T0C+75
	// Let's get this jumpin' party started
	var/leap_on_click = 0
	var/leap_cooldown = 0
	var/leap_cooldown_time = 100 //3 times slower than an alien's leap
	var/leaping = 0
	var/can_leap = 0 //Can this mob leap? Stops brains and such from leaping


