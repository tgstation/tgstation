/mob/living
	see_invisible = SEE_INVISIBLE_LIVING
	languages_spoken = HUMAN
	languages_understood = HUMAN
	sight = 0
	see_in_dark = 2
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD)
	pressure_resistance = 10

	//Health and life related vars
	var/maxHealth = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS
	var/bruteloss = 0	//Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	var/oxyloss = 0		//Oxygen depravation damage (no air in lungs)
	var/toxloss = 0		//Toxic damage caused by being poisoned or radiated
	var/fireloss = 0	//Burn damage caused by being way too hot, too cold or burnt.
	var/cloneloss = 0	//Damage caused by being cloned or ejected from the cloner early. slimes also deal cloneloss damage to victims
	var/brainloss = 0	//'Retardation' damage caused by someone hitting you in the head with a bible or being infected with brainrot.
	var/staminaloss = 0		//Stamina damage, or exhaustion. You recover it slowly naturally, and are stunned if it gets too high. Holodeck and hallucinations deal this.


	var/hallucination = 0 //Directly affects how long a mob will hallucinate for

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	//Allows mobs to move through dense areas without restriction. For instance, in space or out of holder objects.
	var/incorporeal_move = 0 //0 is off, 1 is normal, 2 is for ninjas.

	var/list/surgeries = list()	//a list of surgery datums. generally empty, they're added when the player wants them.

	var/now_pushing = null //used by living/Bump() and living/PushAM() to prevent potential infinite loop.

	var/cameraFollow = null

	var/tod = null // Time of death

	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks = 0 //Tracks how many stacks of fire we have on, max is usually 20

	var/bloodcrawl = 0 //0 No blood crawling, BLOODCRAWL for bloodcrawling, BLOODCRAWL_EAT for crawling+mob devour
	var/holder = null //The holder for blood crawling
	var/ventcrawler = 0 //0 No vent crawling, 1 vent crawling in the nude, 2 vent crawling always
	var/limb_destroyer = 0 //1 Sets AI behavior that allows mobs to target and dismember limbs with their basic attack.

	var/mob_size = MOB_SIZE_HUMAN
	var/metabolism_efficiency = 1 //more or less efficiency to metabolize helpful/harmful reagents and regulate body temperature..
	var/list/image/staticOverlays = list()
	var/has_limbs = 0 //does the mob have distinct limbs?(arms,legs, chest,head)

	var/list/pipes_shown = list()
	var/last_played_vent

	var/smoke_delay = 0 //used to prevent spam with smoke reagent reaction on mob.

	var/list/say_log = list() //a log of what we've said, with a timestamp as the key for each message

	var/bubble_icon = "default" //what icon the mob uses for speechbubbles

	var/last_bumped = 0
	var/unique_name = 0 //if a mob's name should be appended with an id when created e.g. Mob (666)

	var/list/butcher_results = null
	var/hellbound = 0 //People who've signed infernal contracts are unrevivable.

	var/list/weather_immunities = list()

	var/stun_absorption = null //converted to a list of stun absorption sources this mob has when one is added

	var/blood_volume = 0 //how much blood the mob has
	var/obj/effect/proc_holder/ranged_ability //Any ranged ability the mob has, as a click override

	var/list/status_effects //a list of all status effects the mob has

	var/list/implants = null
	var/tesla_ignore = FALSE
