/mob/living/simple_animal/elemental
	name = "elemental"
	desc = "A physical manifestation of the elements."
	icon = 'icons/mob/elemental.dmi'
	icon_state = "earth"
	icon_living = "earth"
	speak_emote = list("says")
	health = 100
	maxHealth = 100
	speed = 0

	response_help   = "touches"
	response_disarm = "punches"
	response_harm   = "punches"

	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/weapons/slash.ogg'

	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = 0

	var/mob/living/carbon/master = null //The owner of the elemental
	var/playstyle_string = "<b>You are an elemental, a physical manifestation of raw elemental power. Please alert the gods that this has happened to you, because you shouldn't exist.</b>"
	var/deathmessage = "The elemental dies!"

/mob/living/simple_animal/elemental/New()
	..()
	spawn(20)
		if(!src.mind)
			if(!src)
				return
			message_admins("[src] was created but has no mind! Will continue to search for a mind until one is found.")
			while(!src.mind)
				sleep(10)
				if(searchForMind())
					message_admins("[src] now possesses a mind.")
		src << playstyle_string
		if(master)
			src << "<b>[master] is your master. Obey and protect them at all costs.</b>"
			var/datum/objective/protect/new_objective = new /datum/objective/protect
			new_objective.owner = src.mind
			new_objective.target = master.mind
			new_objective.explanation_text = "Protect [master], your master."
			src.mind.objectives += new_objective
			ticker.mode.traitors += src.mind
			src.mind.special_role = "elemental"
			if(master.mind in ticker.mode.wizards)
				ticker.mode.update_wiz_icons_added(src.mind)
		else
			src << "<b>You have no master and obey your own will.</b>"

/mob/living/simple_animal/elemental/death()
	..(1)
	visible_message("<span class='warning'>[src] [deathmessage]</span>")
	qdel(src)

/mob/living/simple_animal/elemental/proc/searchForMind()
	if(!src.mind)
		return 0
	return 1

/mob/living/simple_animal/elemental/earth //Slow and tanky; defensive
	name = "earth elemental"
	desc = "A large mass of animated stones in a single form. It looks tough."
	speak_emote = list("rumbles")
	health = 250
	maxHealth = 250
	force_threshold = 10 //Made of rock, so pretty tanky
	speed = 1
	environment_smash = 1

	harm_intent_damage = 0
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch3.ogg'
	playstyle_string = "<b>You are an earth elemental. While slow, you are quite strong and can withstand a lot of damage before dying. Most common weapons cannot hurt you.</b>"
	deathmessage = "falls apart into a pile of rocks."

/mob/living/simple_animal/elemental/air //Glass cannon; offensive
	name = "air elemental"
	desc = "A swirling mass of bubbles."
	health = 50
	maxHealth = 50
	speak_emote = list("blows")
	speed = -1 //Fast because made of wind
	icon_state = "air"
	icon_living = "air"

	harm_intent_damage = 0 //Made of wind...
	melee_damage_upper = 25
	melee_damage_lower = 25
	attacktext = "shocks"
	attack_sound = 'sound/magic/lightningbolt.ogg'
	damtype = BURN
	playstyle_string = "<b>You are an air elemental. You are very fast but also very fragile. You can use your attacks and abilities to harness the storm..</b>"
	deathmessage = "breaks apart into errant clouds."
	ventcrawler = 1

/mob/living/simple_animal/elemental/fire //All-rounder; offensive
	name = "fire elemental"
	desc = "A raging inferno, encased within a single form."
	speak_emote = list("fires")
	icon_state = "fire"
	icon_living = "fire"

	melee_damage_upper = 15
	melee_damage_lower = 15
	attacktext = "scorches"
	attack_sound = 'sound/magic/fireball.ogg'
	damtype = BURN
	playstyle_string = "<b>You are a fire elemental. You are a very well-rounded minion, and your abilities can be used to attack and defend in many situations.</b>"
	deathmessage = "gutters, flickers, shrinks, and dies."

/mob/living/simple_animal/elemental/water //All-rounder; utility
	name = "water elemental"
	desc = "A large form of water that shimmers in the light."
	speak_emote = list("splashes")
	icon_state = "water"
	icon_living = "water"

	harm_intent_damage = 0
	attacktext = "splashes"
	attack_sound = 'sound/magic/exit_blood.ogg'
	playstyle_string = "<b>You are a water elemental. You are well-rounded, and your abilities can be used to influence many things around you.</b>"
	deathmessage = "falls into a formless pile of water."
	ventcrawler = 1

/mob/living/simple_animal/elemental/life //Healing; defensive
	name = "nature elemental"
	desc = "A walking plant with swivelling stems."
	speak_emote = list("creaks", "pines")
	icon_state = "life"
	icon_living = "life"

	melee_damage_upper = 5 //Based around healing so he doesn't hit very hard
	melee_damage_upper = 5
	attacktext = "thwacks"
	playstyle_string = "<b>You are a nature elemental. You don't do much damage, but you have many useful healing abilities to keep your master and subordinates in the fight.</b>"
	deathmessage = "collapses, withers, and dies."

/mob/living/simple_animal/elemental/arcane //All-rounder; both
	name = "mana elemental"
	desc = "A hovering mass of shimmering, translucent crystals."
	speak_emote = list("swoons")
	icon_state = "mana"
	icon_living = "mana"

	attacktext = "claws"
	playstyle_string = "<b>You are a mana elemental. A raw manifestation of magic, you can harness the aura to great extent. Your power will wax and wane depending on your master's living status.</b>"
	deathmessage = "glows, flares, and breaks apart."

/mob/living/simple_animal/elemental/unbound //Random; random
	name = "unbound elemental"
	desc = "Oh. God. What is this horrible abomination of magic? This poor thing probably lives its tortured existence in eternal agony."
	speak_emote = list("screams", "cries", "screeches", "whimpers")
	icon_state = "unbound"
	icon_living = "unbound"

	attacktext = "slices"
	playstyle_string = "<b>You are an unbound elemental. Living a life in eternal agony, you are an aberration of all the elements. All of your stats are randomized and your abilities are also randomized.</b>"
	deathmessage = "screams horribly, broken and awful, before mercifully breaking apart."

/mob/living/simple_animal/elemental/unbound/New()
	..()
	melee_damage_upper = rand(1,30)
	melee_damage_lower = rand(1,30)
	if((melee_damage_upper > 20) || (melee_damage_lower) > 20)
		src << "<i>You feel very strong. Your melee attacks will hit hard.</i>"
	else
		src << "<i>You feel weak. Your melee attacks won't hit very hard.</i>"
	maxHealth = rand(50,200)
	if(maxHealth > 100)
		src << "<i>You feel sturdy. You have a decent amount of maximum health.</i>"
	else
		src << "<i>You feel frail. You have a low amount of maximum health.</i>"
	health = maxHealth
	harm_intent_damage = rand(1,10)
	ventcrawler = rand(1,2)
	if(ventcrawler)
		src << "<i>You feel limber and agile. You can crawl through vents.</i>"
	force_threshold = rand(0,10)
	if(force_threshold > 5)
		src << "<i>Your hardened exoskeleton can absorb weaker attacks.</i>"
