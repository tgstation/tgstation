
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
	a_intent = "hurt"
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
	faction = "cult"
	supernatural = 1
	var/list/construct_spells = list()

/mob/living/simple_animal/construct/cultify()
	return

/mob/living/simple_animal/construct/New()
	..()
	name = text("[initial(name)] ([rand(1, 1000)])")
	real_name = name
	for(var/spell in construct_spells)
		spell_list += new spell(src)
	updateicon()

/mob/living/simple_animal/construct/Die()
	..()
	new /obj/item/weapon/ectoplasm (src.loc)
	for(var/mob/M in viewers(src, null))
		if((M.client && !( M.blinded )))
			M.show_message("\red [src] collapses in a shattered heap. ")
	ghostize()
	del src
	return

/mob/living/simple_animal/construct/examine()
	set src in oview()

	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	usr << msg
	return

/mob/living/simple_animal/construct/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if(ismob(AM))
		var/mob/tmob = AM
		if(istype(tmob, /mob/living/carbon/human) && (M_FAT in tmob.mutations))
			if(prob(5))
				src << "\red <B>You fail to push [tmob]'s fat ass out of the way.</B>"
				now_pushing = 0
				return
		if(!(tmob.status_flags & CANPUSH))
			now_pushing = 0
			return
		now_pushing = 1

		tmob.LAssailant = src
	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return
	if (!( now_pushing ))
		now_pushing = 1
		if (!( AM.anchored ))
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window/full))
				for(var/obj/structure/window/win in get_step(AM,t))
					now_pushing = 0
					return
			step(AM, t)
		now_pushing = null


/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M as mob)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		if(src.health >= src.maxHealth)
			M << "\blue [src] has nothing to mend."
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
			for(var/mob/O in viewers(src, null))
				O.show_message("<span class='attack'>\The <EM>[M]</EM> [M.attacktext] \the <EM>[src]</EM>!</span>", 1)
			add_logs(M, src, "attacked", admin=1)
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
			adjustBruteLoss(damage)

/mob/living/simple_animal/construct/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		var/damage = O.force
		if (O.damtype == HALLOSS)
			damage = 0
		adjustBruteLoss(damage)
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red \b [src] has been attacked with [O] by [user]. ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with [O]. ")

/mob/living/simple_animal/construct/airflow_stun()
	return

/mob/living/simple_animal/construct/airflow_hit(atom/A)
	return

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
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall)

/mob/living/simple_animal/construct/armoured/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		if(O.force >= 11)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with [O] by [user]. ")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [O] bounces harmlessly off of [src]. ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with [O]. ")


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
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)



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
	environment_smash = 2
	attack_sound = 'sound/weapons/rapidslice.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/pylon,
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

/mob/living/simple_animal/construct/behemoth/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(O.force)
		if(O.force >= 11)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [src] has been attacked with [O] by [user]. ")
		else
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("\red \b [O] bounces harmlessly off of [src]. ")
	else
		usr << "\red This weapon is ineffective, it does no damage."
		for(var/mob/M in viewers(src, null))
			if ((M.client && !( M.blinded )))
				M.show_message("\red [user] gently taps [src] with [O]. ")


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
	var/doorcooldown = 10
	var/runecooldown = 10

/mob/living/simple_animal/construct/harvester/New()
	..()
	sight |= SEE_MOBS

////////////////Glow//////////////////
/mob/living/simple_animal/construct/proc/updateicon()
	overlays = 0
	var/overlay_layer = LIGHTING_LAYER+1
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
			usr << "\red You do not have enough power stored!"
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
			usr.visible_message("\red [cultist] appears in a flash of red light as [usr] glows with power")*/

////////////////HUD//////////////////////

/mob/living/simple_animal/construct/Life()
	. = ..()
	if(.)
		if(fire)
			if(fire_alert)							fire.icon_state = "fire1"
			else									fire.icon_state = "fire0"
		if(pullin)
			if(pulling)								pullin.icon_state = "pull1"
			else									pullin.icon_state = "pull0"

		if(construct_spell1)
			construct_spell1.overlays = 0
			if(purge)
				construct_spell1.overlays += "silence"

		if(construct_spell2)
			construct_spell2.overlays = 0
			if(purge)
				construct_spell2.overlays += "silence"

		if(construct_spell3)
			construct_spell3.overlays = 0
			if(purge)
				construct_spell3.overlays += "silence"

		if(construct_spell4)
			construct_spell4.overlays = 0
			if(purge)
				construct_spell4.overlays += "silence"

		if(construct_spell5)
			construct_spell5.overlays = 0
			if(purge)
				construct_spell5.overlays += "silence"

/mob/living/simple_animal/construct/armoured/Life()
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

		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell1.icon_state = "spell_juggerwall-off"
			else
				construct_spell1.icon_state = "spell_juggerwall"


/mob/living/simple_animal/construct/behemoth/Life()
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

	if(construct_spell1)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/wall))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell1.icon_state = "spell_wall-off"
			else
				construct_spell1.icon_state = "spell_wall"


	if(construct_spell2)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell2.icon_state = "spell_soulstone-off"
			else
				construct_spell2.icon_state = "spell_soulstone"


	if(construct_spell3)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/floor))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell3.icon_state = "spell_floor-off"
			else
				construct_spell3.icon_state = "spell_floor"


	if(construct_spell4)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell4.icon_state = "spell_shell-off"
			else
				construct_spell4.icon_state = "spell_shell"


	if(construct_spell5)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/aoe_turf/conjure/pylon))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell5.icon_state = "spell_pylon-off"
			else
				construct_spell5.icon_state = "spell_pylon"


/mob/living/simple_animal/construct/wraith/Life()
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

	if(construct_spell1)
		var/obj/effect/proc_holder/spell/S = null
		for(var/datum/D in spell_list)
			if(istype(D, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift))
				S = D
				break
		if(S)
			if(S.charge_counter < S.charge_max)
				construct_spell1.icon_state = "spell_shift-off"
			else
				construct_spell1.icon_state = "spell_shift"


/mob/living/simple_animal/construct/harvester/Life()
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

	if(construct_spell1)
		if(runecooldown < 10)
			construct_spell1.icon_state = "spell_rune-off"
		else
			construct_spell1.icon_state = "spell_rune"

	if(construct_spell2)
		if(doorcooldown < 10)
			construct_spell2.icon_state = "spell_breakdoor-off"
		else
			construct_spell2.icon_state = "spell_breakdoor"

	if(runecooldown < 10)
		runecooldown++
	if(doorcooldown < 10)
		doorcooldown++