
////////////////
// BASE TYPE ///
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/infection
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 360
	unique_name = 1
	a_intent = INTENT_HARM
	stat_attack = DEAD
	var/mob/camera/commander/overmind = null
	var/obj/structure/infection/factory/factory = null

/mob/living/simple_animal/hostile/infection/update_icons()
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/infection/Destroy()
	if(overmind)
		overmind.infection_mobs -= src
	return ..()

/mob/living/simple_animal/hostile/infection/blob_act(obj/structure/infection/I)
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.color
			else
				H.color = "#000000"
		adjustHealth(-maxHealth*0.0125)

/mob/living/simple_animal/hostile/infection/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature)
		adjustFireLoss(CLAMP(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/structure/infection) || istype(mover, /obj/item/projectile/bullet/infection))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/Process_Spacemove(movement_dir = 0)
	for(var/obj/structure/infection/I in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/infection/proc/infection_chat(msg)
	var/spanned_message = say_quote(msg, get_spans())
	var/rendered = "<font color=\"#EE4000\"><b>\[Infection Telepathy\] [real_name]</b> [spanned_message]</font>"
	for(var/M in GLOB.mob_list)
		if(iscommander(M) || isovermind(M) || istype(M, /mob/living/simple_animal/hostile/infection))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

/////////////////////
// INFECTION SPORE //
/////////////////////

/mob/living/simple_animal/hostile/infection/infectionspore
	name = "infection spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health = 30
	maxHealth = 30
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = 2
	melee_damage_upper = 4
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit1.ogg'
	movement_type = FLYING
	del_on_death = 1
	deathmessage = "dissapates in the atmosphere!"
	var/mob/living/carbon/human/oldguy
	var/is_zombie = 0

/mob/living/simple_animal/hostile/infection/infectionspore/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
	if(commander)
		overmind = commander
	. = ..()

/mob/living/simple_animal/hostile/infection/infectionspore/Life()
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == DEAD)
				Zombify(H)
				break
	if(factory && z != factory.z)
		death()
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/proc/Zombify(mob/living/carbon/human/H)
	is_zombie = 1
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		maxHealth += A.armor.melee //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "infection zombie"
	desc = "A shambling corpse animated by the infection."
	mob_biotypes += MOB_HUMANOID
	melee_damage_lower += 8
	melee_damage_upper += 11
	movement_type = GROUND
	icon = H.icon
	icon_state = "zombie"
	H.hair_style = null
	H.update_hair()
	H.forceMove(src)
	oldguy = H
	update_icons()
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/infection/infectionspore/death(gibbed)
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown
	..()

/mob/living/simple_animal/hostile/infection/infectionspore/Destroy()
	if(factory)
		factory.spores -= src
	factory = null
	if(oldguy)
		oldguy.forceMove(get_turf(src))
		oldguy = null
	return ..()

/mob/living/simple_animal/hostile/infection/infectionspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(is_zombie)
		copy_overlays(oldguy, TRUE)
		var/mutable_appearance/infection_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
		if(overmind)
			infection_head_overlay.color = overmind.color
		color = initial(color)//looks better.
		add_overlay(infection_head_overlay)

/mob/living/simple_animal/hostile/infection/infectionspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2

/*
//
// Player Controlled
//
*/

/mob/living/simple_animal/hostile/infection/infectionspore/sentient
	name = "evolving spore"
	desc = "An extremely strong spore in the early stages of life, what will it become next?"
	hud_type = /datum/hud/infection_spore
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/respawn_time = 15
	var/upgrade_points = 0
	var/list/upgrade_list = list() // upgrades that are unlockable
	var/list/upgrade_types = list(/datum/infection/upgrade/defensive_spore, /datum/infection/upgrade/offensive_spore, /datum/infection/upgrade/supportive_spore) // types of upgrades

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	. = ..()
	if(overmind)
		upgrade_points = overmind.all_upgrade_points
	else
		upgrade_points = 5
	if(upgrade_types.len > 0)
		for(var/upgrade_type in upgrade_types)
			upgrade_list += new upgrade_type()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Life()
	. = ..()
	var/list/infection_in_area = range(2, src)
	var/healed = FALSE
	if(locate(/obj/structure/infection/core) in infection_in_area)
		adjustHealth(-maxHealth*0.1)
		healed = TRUE
	if(locate(/obj/structure/infection/node) in infection_in_area)
		adjustHealth(-maxHealth*0.05)
		healed = TRUE
	if(healed)
		var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
		if(overmind)
			H.color = overmind.color

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/evolve_menu()
	var/list/choices = list(
		"Upgrades" = image(icon = 'icons/mob/blob.dmi', icon_state = "ui_increase"),
		"Upgrades Overview" = image(icon = 'icons/mob/blob.dmi', icon_state = "ui_help_radial")
	)
	var/choice = show_radial_menu(src, src, choices, tooltips = TRUE)
	if(choice == choices[1])
		upgrade_menu()
	if(choice == choices[2])
		to_chat(src, show_description())
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/upgrade_menu()
	var/list/choices = list()
	var/list/upgrades_temp = list()
	for(var/datum/infection/upgrade/U in upgrade_list)
		if(U.times == 0)
			continue
		var/upgrade_index = "[U.name] ([U.cost])"
		choices[upgrade_index] = image(icon = U.radial_icon, icon_state = U.radial_icon_state)
		upgrades_temp += U
	if(!choices.len)
		to_chat(src, "<span class='warning'>You have already bought every evolution for yourself!</span>")
		return
	var/choice = show_radial_menu(src, src, choices, tooltips = TRUE)
	var/upgrade_index = choices.Find(choice)
	if(!upgrade_index)
		return
	var/datum/infection/upgrade/Chosen = upgrades_temp[upgrade_index]
	if(can_upgrade(Chosen.cost))
		Chosen.do_upgrade(src)
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more upgrade points! Destroy beacons to acquire them!</span>")
		return 0
	upgrade_points = diff
	return 1

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/show_description()
	to_chat(src, "<span class='cultlarge'>Upgrades List</span>")
	for(var/datum/infection/upgrade/U in upgrade_list)
		to_chat(src, "<span class='notice'>[U.name]: [U.description]</span>")
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/infection_help()
	to_chat(src, "<b>You are an evolving infection spore!</b>")
	to_chat(src, "You are an evolving creature that gets stronger as the infection does \n<span class='cultlarge'>You are impossible to kill as long as the core still exists.</span>")
	to_chat(src, "You can communicate with other infectious creatures via <b>:b</b>")
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(updating_health)
		update_health_hud()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/update_health_hud()
	if(hud_used)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round((health / maxHealth) * 100, 0.5)]%</font></div>"

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/death(gibbed)
	if(overmind.infection_core.respawn_point) // cant die as long as core is still alive
		forceMove(overmind.infection_core.respawn_point)
		adjustHealth(-maxHealth * 0.2)
		INVOKE_ASYNC(src, .proc/respawn)
		return
	. = ..()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/respawn()
	var/time_left = respawn_time
	while(time_left > 0)
		to_chat(src, "<b>Respawning in [time_left] seconds.</b>")
		sleep(10)
		if(!overmind.infection_core)
			time_left = 0
		time_left--
	if(overmind.infection_core)
		to_chat(src, "<b>You have respawned!</b>")
		var/atom/pos = pick(range(2, overmind.infection_core))
		forceMove(get_turf(pos))
	else
		to_chat(src, "<b>You feel the life draining from you... the last words that echo in your head are those of failure.</b>")
		death()
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Zombify(mob/living/carbon/human/H)
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/defensive
	name = "defensive spore"
	desc = "A hulking spore that blocks your every move."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	health = 150
	maxHealth = 150
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 20
	upgrade_types = list() // types of upgrades

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/offensive
	name = "offensive spore"
	desc = "An aggressive spore that looks like it's out for blood."
	icon_state = "offensive_spore"
	icon_living = "offensive_spore"
	health = 60
	maxHealth = 60
	damage_coeff = list(BRUTE = 0.75, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = 30
	melee_damage_upper = 30
	obj_damage = 60
	upgrade_types = list() // types of upgrades

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/supportive
	name = "supportive spore"
	desc = "A spore that seems to know your every movement."
	icon_state = "support_spore"
	icon_living = "support_spore"
	health = 40
	maxHealth = 40
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = 5
	melee_damage_upper = 5
	obj_damage = 40
	upgrade_types = list() // types of upgrades