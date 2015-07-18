/mob/living/carbon/human
	languages = HUMAN
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ID_HUD,WANTED_HUD,IMPLOYAL_HUD,IMPCHEM_HUD,IMPTRACK_HUD,ANTAG_HUD)
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
	var/blood_type = "A+"	//Player's bloodtype

	var/underwear = "Nude"	//Which underwear the player wants
	var/undershirt = "Nude" //Which undershirt the player wants
	var/socks = "Nude" //Which socks the player wants
	var/backbag = 1		//Which backpack type the player has chosen. Backpack.or Satchel

	//Equipment slots
	var/obj/item/wear_suit = null
	var/obj/item/w_uniform = null
	var/obj/item/shoes = null
	var/obj/item/belt = null
	var/obj/item/gloves = null
	var/obj/item/glasses = null
	var/obj/item/ears = null
	var/obj/item/wear_id = null
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/obj/item/s_store = null

	var/icon/base_icon_state = "caucasian1_m"

	var/special_voice = "" // For changing our voice. Used by a symptom.

	var/gender_ambiguous = 0 //if something goes wrong during gender reassignment this generates a line in examine

	var/blood_max = 0 //how much are we bleeding
	var/bleedsuppress = 0 //for stopping bloodloss, eventually this will be limb-based like bleeding

	var/list/organs = list() //Gets filled up in the constructor (human.dm, New() proc.

	var/datum/martial_art/martial_art = null

	var/name_override //For temporary visible name changes

	var/heart_attack = 0