/mob/living/simple_animal/hades
	name = "hades"
	real_name = "hades"
	desc = "A strange being, clad in dark robes. Their very presence radiates an uneasy power."
	speak_emote = list("preaches","announces","spits","conveys")
	emote_hear = list("hums.","prays.")
	response_help  = "kneels before"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/EvilPope.dmi'
	icon_state = "EvilPope"
	icon_living = "EvilPope"
	speed = 1
	a_intent = "harm"
	status_flags = CANPUSH
	attack_sound = 'sound/magic/MAGIC_MISSILE.ogg'
	death_sound = 'sound/magic/Teleport_diss.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("hades")
	attacktext = "strikes with an unholy rage at"
	maxHealth = 500
	health = 500
	healable = 0
	environment_smash = 2
	melee_damage_lower = 75
	melee_damage_upper = 85
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	loot = list(/obj/effect/decal/cleanable/blood)
	del_on_death = 1
	deathmessage = "lets fourth a piercing howl, before sobbing quietly as they're dragged back to whence they came."

	var/lastsinPerson = 0
	var/sinPersonTime = 300
	var/fakesinPersonChance = 60
	var/list/sinPersonsayings = list("You revel in only your own greed.",\
	"There is nothing but your absolution.",\
	"Your choices have led you to this.",\
	"There is only one way out.",\
	"The only way to be free is to be free of yourself.",\
	"Wallow in sin, and give yourself unto darkness.",\
	"Only the truly sinful may stand.",\
	"Find yourself and you will find Absolution.",\
	"Forego the pain of this process, and submit.")

/mob/living/simple_animal/hades/New()
	..()
	lastsinPerson = world.time
	var/list/possible_titles = list("Pope","Bishop","Lord","Cardinal","Deacon","Pontiff")
	var/chosen = "[pick(possible_titles)] of Sin"
	name = chosen
	real_name = chosen

	world << "<span class='warning'><font size=6>A [name] has entered your reality. Kneel before them.</font></span>"
	world << 'sound/effects/pope_entry.ogg'

	Appear()

/mob/living/simple_animal/hades/hitby(atom/movable/AM, skipcatch, hitpush, blocked)
	..()
	lastsinPerson -= 75

/mob/living/simple_animal/hades/bullet_act(obj/item/projectile/P, def_zone)
	..()
	lastsinPerson -= 75

/mob/living/simple_animal/hades/attack_hand(mob/living/carbon/human/M)
	..()
	lastsinPerson -= 75

/mob/living/simple_animal/hades/proc/Appear()
	new /obj/effect/timestop(get_turf(src))

/datum/objective/sinPersonholder
	explanation_text = "You are feeling sinful."
	dangerrating = 3

/mob/living/simple_animal/hades/Life()
	..()
	if(world.time > lastsinPerson + sinPersonTime)
		if(prob(fakesinPersonChance))
			lastsinPerson = world.time
			world << "<span class='warning'><font size=4>[pick(sinPersonsayings)]</font></span>"
			//SUE ME
			var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
						'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
						'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
						'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
						'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
			world << pick(creepyasssounds)
		else
			lastsinPerson = world.time
			var/mob/living/carbon/human/sinPerson = pick(player_list)
			if(sinPerson)
				loc = get_turf(pick(oview(1,sinPerson)))
				Appear()
				var/sinPersonchoice = pick(list("Greed","Gluttony","Pride","Lust","Envy","Sloth","Wrath"))
				switch(sinPersonchoice)
					if("Greed")
						src.say("Your sin, [sinPerson], is Greed.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							var/list/greed = list(/obj/item/stack/sheet/mineral/gold,/obj/item/stack/sheet/mineral/silver,/obj/item/stack/sheet/mineral/diamond)
							for(var/i in 1 to 10)
								var/greed_type = pick(greed)
								new greed_type(get_turf(sinPerson))
						else
							src.say("Your sin will be punished, [sinPerson]!")
							new/obj/structure/closet/statue(get_turf(sinPerson),sinPerson)
					if("Gluttony")
						src.say("Your sin, [sinPerson], is Gluttony.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							var/list/allTypes = list()
							for(var/A in typesof(/obj/item/weapon/reagent_containers/food/snacks))
								var/obj/item/weapon/reagent_containers/food/snacks/O = A
								if(initial(O.cooked_type))
									allTypes += A
							for(var/i in 1 to 10)
								var/greed_type = pick(allTypes)
								new greed_type(get_turf(sinPerson))
						else
							src.say("Your sin will be punished, [sinPerson]!")
							sinPerson.reagents.add_reagent("nutriment",1000)
					if("Pride")
						src.say("Your sin, [sinPerson], is Pride.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							for(var/mob/living/carbon/human/H in player_list)
								if(H == sinPerson)
									continue
								ticker.mode.traitors += H.mind
								H.mind.special_role = "pride"
								var/datum/objective/sinPersonholder/pride = new
								pride.owner = H.mind
								pride.explanation_text = "[sinPerson] is your idol now. Praise them as much as possible."
								H.mind.objectives += pride
								H << "<B>[pride.explanation_text]</B>"
						else
							src.say("Your sin will be punished, [sinPerson]!")
							for(var/mob/living/carbon/human/H in player_list)
								if(H == sinPerson)
									continue
								ticker.mode.traitors += H.mind
								H.mind.special_role = "pride"
								var/datum/objective/sinPersonholder/pride = new
								pride.owner = H.mind
								pride.explanation_text = "[sinPerson] is insignificant to you. Show them who's boss."
								H.mind.objectives += pride
								H << "<B>[pride.explanation_text]</B>"
					if("Lust")
						src.say("Your sin, [sinPerson], is Lust.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							for(var/mob/living/carbon/human/H in player_list)
								if(H == sinPerson)
									continue
								ticker.mode.traitors += H.mind
								H.mind.special_role = "lust"
								var/datum/objective/sinPersonholder/lust = new
								lust.owner = H.mind
								lust.explanation_text = "[sinPerson] is the one person who means the world to you. Show your love for them."
								H.mind.objectives += lust
								H << "<B>[lust.explanation_text]</B>"
						else
							src.say("Your sin will be punished, [sinPerson]!")
							for(var/mob/living/carbon/human/H in player_list)
								if(H == sinPerson)
									continue
								ticker.mode.traitors += H.mind
								H.mind.special_role = "lust"
								var/datum/objective/sinPersonholder/lust = new
								lust.owner = H.mind
								lust.explanation_text = "[sinPerson] is irresistible. Make them love you at ANY cost."
								H.mind.objectives += lust
								H << "<B>[lust.explanation_text]</B>"
					if("Envy")
						src.say("Your sin, [sinPerson], is Envy.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							for(var/mob/living/carbon/human/H in player_list) // name lottery
								if(H == sinPerson)
									continue
								if(prob(25))
									spawn(10)
										sinPerson.name = H.name
										sinPerson.real_name = H.real_name
										var/datum/dna/lottery = H.dna
										lottery.transfer_identity(sinPerson, transfer_SE=1)
										sinPerson.updateappearance(mutcolor_update=1)
										sinPerson.domutcheck()
						else
							src.say("Your sin will be punished, [sinPerson]!")
							var/sinPersonspecies = pick(species_list)
							var/newtype = species_list[sinPersonspecies]
							var/datum/species/old_species = sinPerson.dna.species
							sinPerson.set_species(newtype)
							sinPerson.dna.species.admin_set_species(sinPerson,old_species)
					if("Sloth")
						src.say("Your sin, [sinPerson], is Sloth.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							sinPerson.drowsyness += 50
						else
							src.say("Your sin will be punished, [sinPerson]!")
							sinPerson.reagents.add_reagent("frostoil", 50)
					if("Wrath")
						src.say("Your sinPerson, [sinPerson], is Wrath.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							ticker.mode.traitors += sinPerson.mind
							sinPerson.mind.special_role = "wrath"
							var/datum/objective/sinPersonholder/wrath = new
							wrath.owner = sinPerson.mind
							wrath.explanation_text = "Everyone is against you, and your only choice is to fight your way out. Kill them all."
							sinPerson.mind.objectives += wrath
							sinPerson << "<B>[wrath.explanation_text]</B>"
						else
							src.say("Your sin will be punished, [sinPerson]!")
							sinPerson.reagents.add_reagent("lexorin", 100)
							sinPerson.reagents.add_reagent("mindbreaker", 100)

