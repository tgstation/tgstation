
/mob/living/simple_animal/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon_dead = "shade_dead"
	speed = -1
	a_intent = I_HURT
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/spiderlunge.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	show_stat_health = 0
	faction = "cult"
	supernatural = 1
	flying = 1
	treadmill_speed = 0 //It floats!
	var/nullblock = 0

	mob_swap_flags = HUMAN|SIMPLE_ANIMAL|SLIME|MONKEY
	mob_push_flags = ALLMOBS

	meat_type = /obj/item/weapon/ectoplasm

	var/list/construct_spells = list()

/mob/living/simple_animal/construct/construct_chat_check(setting)
	if(!mind) return

	if(mind in ticker.mode.cult)
		return 1

/mob/living/simple_animal/construct/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	if(..())
		return 1
	if(message_mode == MODE_HEADSET && construct_chat_check(0))
		var/turf/T = get_turf(src)
		log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Cult channel: [html_encode(speech.message)]")
		for(var/mob/M in mob_list)
			if(M.construct_chat_check(2) /*receiving check*/ || ((M in dead_mob_list) && !istype(M, /mob/new_player)))
				to_chat(M, "<span class='sinister'><b>[src.name]:</b> [html_encode(speech.message)]</span>")
		return 1

/mob/living/simple_animal/construct/gib()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/construct/cultify()
	return

/mob/living/simple_animal/construct/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	add_language(LANGUAGE_CULT)
	default_language = all_languages[LANGUAGE_CULT]
	for(var/spell in construct_spells)
		src.add_spell(new spell, "const_spell_ready")
	updateicon()

/mob/living/simple_animal/construct/Die()
	..()
	for(var/i=0;i<3;i++)
		new /obj/item/weapon/ectoplasm (src.loc)
	for(var/mob/M in viewers(src, null))
		if((M.client && !( M.blinded )))
			M.show_message("<span class='warning'>[src] collapses in a shattered heap. </span>")
	ghostize()
	del src
	return

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	to_chat(user, msg)


/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		if(src.health >= src.maxHealth)
			to_chat(M, "<span class='notice'>[src] has nothing to mend.</span>")
			return
		health = min(maxHealth, health + 5) // Constraining health to maxHealth
		M.visible_message("[M] mends some of \the <EM>[src]'s</EM> wounds.","You mend some of \the <em>[src]'s</em> wounds.")
	else
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
		if(M.melee_damage_upper <= 0)
			M.emote("[M.friendly] \the <EM>[src]</EM>")
		else
			if(M.attack_sound)
				playsound(loc, M.attack_sound, 50, 1, 1)
			M.visible_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>")
			add_logs(M, src, "attacked", admin=1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			adjustBruteLoss(damage)

/mob/living/simple_animal/construct/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		if(istype(O,/obj/item/weapon/nullrod))
			damage *= 2
			purge = 3
		adjustBruteLoss(damage)
		user.visible_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		user.visible_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")



/////////////////Juggernaut///////////////



/mob/living/simple_animal/construct/armoured
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A possessed suit of armour driven by the will of the restless dead"
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armoured gauntlet into"
	speed = 3
	environment_smash = 2
	attack_sound = 'sound/weapons/heavysmash.ogg'
	status_flags = 0
	construct_spells = list(/spell/aoe_turf/conjure/forcewall/lesser)

/mob/living/simple_animal/construct/armoured/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		if(O.force >= 11)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[O] bounces harmlessly off of [src]. </span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")


/mob/living/simple_animal/construct/armoured/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x

			return -1 // complete projectile permutation

	return (..(P))



////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speed = -1
	environment_smash = 1
	see_in_dark = 7
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/spell/targeted/ethereal_jaunt/shift)



/////////////////////////////Artificer/////////////////////////



/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies"
	icon = 'icons/mob/mob.dmi'
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	speed = 0
	environment_smash = 1
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/spell/aoe_turf/conjure/construct/lesser,
							/spell/aoe_turf/conjure/wall,
							/spell/aoe_turf/conjure/floor,
							/spell/aoe_turf/conjure/soulstone,
							/spell/aoe_turf/conjure/pylon,
							///obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
							)


/////////////////////////////Behemoth/////////////////////////


/mob/living/simple_animal/construct/behemoth
	name = "Behemoth"
	real_name = "Behemoth"
	desc = "The pinnacle of occult technology, Behemoths are the ultimate weapon in the Cult of Nar-Sie's arsenal."
	icon = 'icons/mob/mob.dmi'
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 750
	health = 750
	speak_emote = list("rumbles")
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 50
	melee_damage_upper = 50
	attacktext = "brutally crushes"
	speed = 5
	environment_smash = 2
	attack_sound = 'sound/weapons/heavysmash.ogg'
	var/energy = 0
	var/max_energy = 1000
	construct_spells = list(/spell/aoe_turf/conjure/forcewall/lesser)

/mob/living/simple_animal/construct/behemoth/attackby(var/obj/item/O as obj, var/mob/user as mob)
	user.delayNextAttack(8)
	if(O.force)
		if(O.force >= 11)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[src] has been attacked with [O] by [user]. </span>")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[O] bounces harmlessly off of [src]. </span>")
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("<span class='warning'>[user] gently taps [src] with [O]. </span>")


////////////////////////Harvester////////////////////////////////



/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "The promised reward of the livings who follow narsie. Obtained by offering their bodies to the geometer of blood"
	icon = 'icons/mob/mob.dmi'
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 150
	health = 150
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "violently stabs"
	speed = -1
	environment_smash = 1
	see_in_dark = 7
	attack_sound = 'sound/weapons/pierce.ogg'

	construct_spells = list(
			/spell/targeted/harvest,
			/spell/aoe_turf/knock/harvester,
			/spell/rune_write
		)

/mob/living/simple_animal/construct/harvester/New()
	..()
	sight |= SEE_MOBS

////////////////Glow//////////////////
/mob/living/simple_animal/construct/proc/updateicon()
	overlays = 0
	var/overlay_layer = LIGHTING_LAYER + 1
	if(layer != MOB_LAYER)
		overlay_layer=TURF_LAYER+0.2

	overlays += image(icon,"glow-[icon_state]",overlay_layer)

////////////////Powers//////////////////


/*
/client/proc/summon_cultist()
	set category = "Behemoth"
	set name = "Summon Cultist (300)"
	set desc = "Teleport a cultist to your location"
	if (istype(usr,/mob/living/simple_animal/constructbehemoth))

		if(usr.energy<300)
			to_chat(usr, "<span class='warning'>You do not have enough power stored!</span>")
			return

		if(usr.stat)
			return

		usr.energy -= 300
	var/list/mob/living/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living))
			cultists+=H.current
			var/mob/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - usr)
			if(!cultist)
				return
			if (cultist == usr) //just to be sure.
				return
			cultist.loc = usr.loc
			usr.visible_message("<span class='warning'>[cultist] appears in a flash of red light as [usr] glows with power</span>")*/

////////////////HUD//////////////////////

/mob/living/simple_animal/construct/Life()
	if(timestopped) return 0 //under effects of time magick

	. = ..()
	if(.)
		if(fire)
			if(fire_alert)							fire.icon_state = "fire1"
			else									fire.icon_state = "fire0"
		if(pullin)
			if(pulling)								pullin.icon_state = "pull1"
			else									pullin.icon_state = "pull0"

		if(purged)
			if(purge > 0)							purged.icon_state = "purge1"
			else									purged.icon_state = "purge0"

		silence_spells(purge)

/mob/living/simple_animal/construct/armoured/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(healths)
		switch(health)
			if(250 to INFINITY)		healths.icon_state = "juggernaut_health0"
			if(208 to 249)			healths.icon_state = "juggernaut_health1"
			if(167 to 207)			healths.icon_state = "juggernaut_health2"
			if(125 to 166)			healths.icon_state = "juggernaut_health3"
			if(84 to 124)			healths.icon_state = "juggernaut_health4"
			if(42 to 83)			healths.icon_state = "juggernaut_health5"
			if(1 to 41)				healths.icon_state = "juggernaut_health6"
			else					healths.icon_state = "juggernaut_health7"


/mob/living/simple_animal/construct/behemoth/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(healths)
		switch(health)
			if(750 to INFINITY)		healths.icon_state = "juggernaut_health0"
			if(625 to 749)			healths.icon_state = "juggernaut_health1"
			if(500 to 624)			healths.icon_state = "juggernaut_health2"
			if(375 to 499)			healths.icon_state = "juggernaut_health3"
			if(250 to 374)			healths.icon_state = "juggernaut_health4"
			if(125 to 249)			healths.icon_state = "juggernaut_health5"
			if(1 to 124)			healths.icon_state = "juggernaut_health6"
			else					healths.icon_state = "juggernaut_health7"

/mob/living/simple_animal/construct/builder/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(healths)
		switch(health)
			if(50 to INFINITY)		healths.icon_state = "artificer_health0"
			if(42 to 49)			healths.icon_state = "artificer_health1"
			if(34 to 41)			healths.icon_state = "artificer_health2"
			if(26 to 33)			healths.icon_state = "artificer_health3"
			if(18 to 25)			healths.icon_state = "artificer_health4"
			if(10 to 17)			healths.icon_state = "artificer_health5"
			if(1 to 9)				healths.icon_state = "artificer_health6"
			else					healths.icon_state = "artificer_health7"



/mob/living/simple_animal/construct/wraith/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(healths)
		switch(health)
			if(75 to INFINITY)		healths.icon_state = "wraith_health0"
			if(62 to 74)			healths.icon_state = "wraith_health1"
			if(50 to 61)			healths.icon_state = "wraith_health2"
			if(37 to 49)			healths.icon_state = "wraith_health3"
			if(25 to 36)			healths.icon_state = "wraith_health4"
			if(12 to 24)			healths.icon_state = "wraith_health5"
			if(1 to 11)				healths.icon_state = "wraith_health6"
			else					healths.icon_state = "wraith_health7"


/mob/living/simple_animal/construct/harvester/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if(healths)
		switch(health)
			if(150 to INFINITY)		healths.icon_state = "harvester_health0"
			if(125 to 149)			healths.icon_state = "harvester_health1"
			if(100 to 124)			healths.icon_state = "harvester_health2"
			if(75 to 99)			healths.icon_state = "harvester_health3"
			if(50 to 74)			healths.icon_state = "harvester_health4"
			if(25 to 49)			healths.icon_state = "harvester_health5"
			if(1 to 24)				healths.icon_state = "harvester_health6"
			else					healths.icon_state = "harvester_health7"
