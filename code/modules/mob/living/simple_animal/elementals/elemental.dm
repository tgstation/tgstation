/mob/living/simple_animal/elemental
	name = "elemental"
	desc = "A physical manifestation of the elements."
	icon = 'icons/mob/elemental.dmi'
	icon_state = "necrotic"
	icon_living = "necrotic"
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

	harm_intent_damage = 0
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch3.ogg'
	playstyle_string = "<b>You are an earth elemental. While slow, you are quite strong and can withstand a lot of damage before dying. Most common weapons cannot hurt you.</b>"
	deathmessage = "falls apart into a pile of rocks."

/mob/living/simple_animal/elemental/air //Glass cannon; offensive
	name = "air elemental"
	desc = "A swirling cyclone that crackles with electricity."
	health = 50
	maxHealth = 50
	speak_emote = list("blows")
	speed = -1 //Fast because made of wind

	harm_intent_damage = 0 //Made of wind...
	melee_damage_upper = 25
	melee_damage_lower = 25
	attacktext = "shocks"
	attack_sound = 'sound/magic/lightningbolt.ogg'
	damtype = BURN
	playstyle_string = "<b>You are an air elemental. You are very fast but also very fragile. You can use your attacks and abilities to harness the storm..</b>"
	deathmessage = "flies apart, breaking away and leaving nothing."

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

	harm_intent_damage = 0
	attacktext = "splashes"
	attack_sound = 'sound/magic/exit_blood.ogg'
	playstyle_string = "<b>You are a water elemental. You are well-rounded, and your abilities can be used to influence many things around you.</b>"
	deathmessage = "falls into a formless pile of water."

/mob/living/simple_animal/elemental/life //Healing; defensive
	name = "nature elemental"
	desc = "A walking treant made of bark and leaves."
	speak_emote = list("creaks", "pines")

	melee_damage_upper = 5 //Based around healing so he doesn't hit very hard
	melee_damage_upper = 5
	attacktext = "thwacks"
	playstyle_string = "<b>You are a nature elemental. You don't do much damage, but you have many useful healing abilities to keep your master and subordinates in the fight.</b>"
	deathmessage = "collapses, withers, and dies."

/mob/living/simple_animal/elemental/necrotic //All-rounder; offensive
	name = "necrotic elemental"
	desc = "A floating black mist with sinister red eyes."
	speak_emote = list("hisses")

	melee_damage_upper = 30 //Completely offensive
	melee_damage_upper = 30
	attacktext = "drains"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	playstyle_string = "<b>You are a necrotic elemental. You are focused around doing high amounts of damage in a short amount of time. You cannot be affected by healing, however.</b>"
	deathmessage = "disperses into nothing."

/mob/living/simple_animal/elemental/arcane //All-rounder; both
	name = "mana elemental"
	desc = "A translucent blue form shaped somewhat like a man."
	speak_emote = list("swoons")

	attacktext = "claws"
	playstyle_string = "<b>You are a mana elemental. A raw manifestation of magic, you can harness the aura to great extent. Your power will wax and wane depending on your master's living status.</b>"
	deathmessage = "glows, flares, and breaks apart."

/mob/living/simple_animal/elemental/unbound //Random; random
	name = "unbound elemental"
	desc = "Oh. God. What is this horrible abomination of magic? This poor thing probably lives its tortured existence in eternal agony."
	speak_emote = list("screams", "cries", "screeches", "stammers")

	attacktext = "slices"
	playstyle_string = "<b>You are an unbound elemental. Living a life in eternal agony, you are an aberration of all the elements. All of your stats are randomized and your abilities are also randomized.</b>"
	deathmessage = "screams horribly, broken and awful, before mercifully breaking apart."

/mob/living/simple_animal/elemental/unbound/New()
	..()
	melee_damage_upper = rand(1,30)
	melee_damage_lower = rand(1,30)
	maxHealth = rand(50,200)
	health = maxHealth
	harm_intent_damage = rand(1,10)
