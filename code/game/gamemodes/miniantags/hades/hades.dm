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
	"Forego the pain of this process, and submit.",\
	"We can be one in suffering.",\
	"You stand on the precipice of ascension, give in.",\
	"You cannot fathom what lies beyond",\
	"Repent your sins.",\
	"This is the eve of your last days.",\
	"Darkness comes.")

	var/obj/effect/proc_holder/spell/targeted/lightning/sinLightning

/mob/living/simple_animal/hades/New()
	..()

	sinLightning = new/obj/effect/proc_holder/spell/targeted/lightning(src)

	sinLightning.charge_max = 1
	sinLightning.clothes_req = 0
	sinLightning.range = 32
	sinLightning.cooldown_min = 1

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
	Defend(AM)

/mob/living/simple_animal/hades/bullet_act(obj/item/projectile/P, def_zone)
	..()
	lastsinPerson -= 75
	Defend(P.firer)

/mob/living/simple_animal/hades/attack_hand(mob/living/carbon/human/M)
	..()
	lastsinPerson -= 75
	Defend(M)

/mob/living/simple_animal/hades/proc/Defend(var/mob/attacker)
	src.visible_message("<span class='warning'>[src] rounds on the [attacker], gazing at them with a [pick("cold","frosty","freezing","dark")] [pick("glare","gaze","glower","stare")].</span>")
	var/chosenDefend = rand(1,3)
	switch(chosenDefend)
		if(1)
			attacker.visible_message("<span class='warning'>[attacker] is lifted from the ground, shadowy powers tossing them aside.</span>")
			attacker.throw_at_fast(pick(orange(src,7)),10,1)
		if(2)
			attacker.visible_message("<span class='warning'>[attacker] crackles with electricity, a bolt leaping from [src] to them.</span>")
			sinLightning.Bolt(src,attacker,30,5,src)
		if(3)
			src.visible_message("<span class='warning'>[src] points his staff at [attacker], a swarm of eyeballs lurching fourth!</span>")
			for(var/i in 1 to 4)
				var/mob/living/simple_animal/hostile/carp/eyeball/E = new/mob/living/simple_animal/hostile/carp/eyeball(pick(orange(attacker,1)))
				E.faction = faction
				spawn(150)
					qdel(E)

/mob/living/simple_animal/hades/proc/Appear()
	new /obj/effect/timestop(get_turf(src))

/mob/living/simple_animal/hades/Life()
	..()
	if(world.time > lastsinPerson + sinPersonTime)
		if(prob(fakesinPersonChance))
			lastsinPerson = world.time
			visible_message("<span class='warning'><font size=4>[pick(sinPersonsayings)]</font></span>")
			//SUE ME
			var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/Heart Beat.ogg', 'sound/effects/screech.ogg',\
						'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
						'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
						'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
						'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
			playsound(get_turf(src), pick(creepyasssounds), 100, 1)
		else
			lastsinPerson = world.time
			var/mob/living/carbon/human/sinPerson = pick(living_mob_list)
			var/depth = living_mob_list.len + 1 // just in case
			if(!sinPerson.ckey)
				while(!sinPerson.ckey && depth > 0)
					--depth
					sinPerson = pick(living_mob_list)
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
							var/obj/item/weapon/twohanded/sin_pride/good = new/obj/item/weapon/twohanded/sin_pride(get_turf(sinPerson))
							good.pride_direction = FALSE
						else
							src.say("Your sin will be punished, [sinPerson]!")
							var/obj/item/weapon/twohanded/sin_pride/bad = new/obj/item/weapon/twohanded/sin_pride(get_turf(sinPerson))
							bad.pride_direction = TRUE
					if("Lust")
						src.say("Your sin, [sinPerson], is Lust.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							var/obj/item/lovestone/good = new/obj/item/lovestone(get_turf(sinPerson))
							good.lust_direction = FALSE
						else
							src.say("Your sin will be punished, [sinPerson]!")
							var/obj/item/lovestone/bad = new/obj/item/lovestone(get_turf(sinPerson))
							bad.lust_direction = TRUE
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
							sinPerson.set_species(newtype)
					if("Sloth")
						src.say("Your sin, [sinPerson], is Sloth.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							sinPerson.drowsyness += 50
						else
							src.say("Your sin will be punished, [sinPerson]!")
							sinPerson.reagents.add_reagent("frostoil", 50)
					if("Wrath")
						src.say("Your sin, [sinPerson], is Wrath.")
						if(prob(50))
							src.say("I will indulge your sin, [sinPerson].")
							sinPerson.reagents.add_reagent("bath_salts",100)
						else
							src.say("Your sin will be punished, [sinPerson]!")
							sinPerson.reagents.add_reagent("lexorin", 100)
							sinPerson.reagents.add_reagent("mindbreaker", 100)


///Sin related things
/obj/item/weapon/twohanded/sin_pride
	icon_state = "mjollnir0"
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	force = 5
	throwforce = 15
	w_class = 4
	slot_flags = SLOT_BACK
	force_unwielded = 8
	force_wielded = 18
	attack_verb = list("attacked", "smashed", "crushed", "splattered", "cracked")
	hitsound = 'sound/weapons/blade1.ogg'
	var/pride_direction = FALSE

/obj/item/weapon/twohanded/sin_pride/update_icon()
	icon_state = "mjollnir[wielded]"
	return

/obj/item/weapon/twohanded/sin_pride/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	if(!proximity) return
	if(wielded)
		if(istype(A,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = A
			if(H)
				if(pride_direction == FALSE)
					user.reagents.trans_to(H, user.reagents.total_volume, 1, 1, 0)
					user << "Your pride reflects on [H]."
					H << "You feel insecure, taking on [user]'s burden."
				else if(pride_direction == 1)
					H.reagents.trans_to(user, H.reagents.total_volume, 1, 1, 0)
					H << "Your pride reflects on [user]."
					user << "You feel insecure, taking on [H]'s burden."

/obj/item/lovestone
	name = "Stone of Lust"
	desc = "It lays within your hand, radiating pulses of uncomfortable warmth."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "lovestone"
	item_state = "lovestone"
	w_class = 1
	var/lust_direction = FALSE
	var/lastUsage = 0
	var/usageTimer = 300

/obj/item/lovestone/attack_self(mob/user)
	if(world.time > lastUsage + usageTimer)
		lastUsage = world.time
		user.visible_message("<span class='warning'>[user] grips the [src] tightly, causing it to vibrate and pulse brightly.</span>")
		spawn(25)
			if(lust_direction == FALSE)
				var/list/throwAt = list()
				for(var/atom/movable/AM in oview(7,user))
					if(!AM.anchored && AM != user)
						throwAt.Add(AM)
				for(var/counter = 1, counter < throwAt.len, ++counter)
					var/atom/movable/cast = throwAt[counter]
					cast.throw_at_fast(user,10,1)
			else if(lust_direction == 1)
				var/mob/living/carbon/human/H = user
				H << "As you hold the stone, your heart feels heavy and you struggle to breath."
				H.reagents.add_reagent("initropidril",50)
	else
		user << "The stone lays inert. It is still recharging."