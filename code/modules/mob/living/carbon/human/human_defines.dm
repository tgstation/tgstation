/mob/living/carbon/human
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD, NANITE_HUD, DIAG_NANITE_FULL_HUD,ANTAG_HUD,GLAND_HUD,SENTIENT_DISEASE_HUD)
	hud_type = /datum/hud/human
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	pressure_resistance = 25
	can_buckle = TRUE
	buckle_lying = FALSE
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	//Hair colour and style
	var/hair_color = "000"
	var/hair_style = "Bald"

	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hair_style = "Shaved"

	//Eye colour
	var/eye_color = "000"

	var/skin_tone = "caucasian1"	//Skin tone

	var/lip_style = null	//no lipstick by default- arguably misleading, as it could be used for general makeup
	var/lip_color = "white"

	var/age = 30		//Player's age (pure fluff)

	var/underwear = "Nude"	//Which underwear the player wants
	var/undershirt = "Nude" //Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/backbag = DBACKPACK		//Which backpack type the player has chosen.

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/belt = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/bleed_rate = 0 //how much are we bleeding
	var/bleedsuppress = 0 //for stopping bloodloss, eventually this will be limb-based like bleeding

	var/name_override //For temporary visible name changes

	var/datum/personal_crafting/handcrafting
	var/datum/physiology/physiology

	var/list/datum/bioware = list()

	var/creamed = FALSE //to use with creampie overlays
	var/static/list/can_ride_typecache = typecacheof(list(/mob/living/carbon/human, /mob/living/simple_animal/slime, /mob/living/simple_animal/parrot))
	var/lastpuke = 0
