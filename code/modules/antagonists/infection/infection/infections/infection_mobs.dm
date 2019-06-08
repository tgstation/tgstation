
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
	var/can_cross_beacons = FALSE
	var/mob/camera/commander/overmind = null
	var/obj/structure/infection/factory/factory = null

/mob/living/simple_animal/hostile/infection/Initialize(mapload, owner_overmind)
	. = ..()
	verbs -= /mob/living/verb/pulled
	if(!can_cross_beacons)
		AddComponent(/datum/component/no_beacon_crossing)

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
	if(istype(src, /mob/living/simple_animal/hostile/infection/infectionspore/sentient))
		return
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
		if(iscommander(M) || isinfectionmonster(M))
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
	update_icons()
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


//////////////////////
// Player Controlled//
//////////////////////

/mob/living/simple_animal/hostile/infection/infectionspore/sentient
	name = "evolving spore"
	desc = "An extremely strong spore in the early stages of life, what will it become next?"
	hud_type = /datum/hud/infection_spore
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	obj_damage = 20
	var/respawn_time = 30
	var/current_respawn_time = -1
	var/upgrade_points = 0
	var/spent_upgrade_points = 0
	var/max_upgrade_points = 1000
	var/cycle_cooldown = 0 // cooldown before you can cycle nodes again
	var/list/upgrade_types = list()
	var/list/upgrades = list()
	var/upgrade_subtype = /datum/infection_upgrade/spore_type_change

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	. = ..()
	generate_upgrades()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/generate_upgrades()
	if(ispath(upgrade_subtype))
		upgrade_types += subtypesof(upgrade_subtype)
	for(var/upgrade_type in upgrade_types)
		upgrades += new upgrade_type()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Upgrade Points: [upgrade_points]")

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Life()
	. = ..()
	add_points(get_point_generation_rate())
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

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/set_points(var/value)
	add_points(value - upgrade_points)

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/add_points(var/value)
	upgrade_points = CLAMP(upgrade_points + value, 0, max_upgrade_points)
	hud_used.infectionpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(upgrade_points)]</font></div>"

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/get_point_generation_rate()
	return 2

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/find_anchor()
	var/list/possible_anchors = GLOB.infection_nodes + GLOB.infection_core
	var/found_node
	for(var/obj/structure/infection/I in possible_anchors)
		if(get_dist(src, I) <= 1 || I == loc)
			found_node = I
			break
	return found_node

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/evolve_menu()
	var/found_node = find_anchor()
	if(!found_node)
		to_chat(src, "<span class='warning'>We may only upgrade while next to a node, or while next to the core!</span>")
		return
	to_chat(src, show_description())
	upgrade_menu(found_node)
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/upgrade_menu(var/found_node)
	var/list/choices = list()
	var/list/upgrades_temp = list()
	for(var/datum/infection_upgrade/U in get_upgrades())
		if(U.times == 0)
			continue
		var/upgrade_index = "[U.name] ([U.cost])"
		choices[upgrade_index] = image(icon = U.radial_icon, icon_state = U.radial_icon_state)
		upgrades_temp += U
	if(!choices.len)
		to_chat(src, "<span class='warning'>You have already bought every evolution for yourself!</span>")
		return
	var/choice = show_radial_menu(src, found_node, choices, tooltips = TRUE, require_near = TRUE)
	var/upgrade_index = choices.Find(choice)
	if(!upgrade_index)
		return
	var/datum/infection_upgrade/Chosen = upgrades_temp[upgrade_index]
	if(can_upgrade(Chosen.cost))
		spent_upgrade_points += Chosen.cost
		Chosen.do_upgrade(src)
		to_chat(src, "<span class='warning'>Successfully upgraded [Chosen.name]!</span>")
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/get_upgrades()
	return upgrades

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more upgrade points! Destroy beacons to acquire them!</span>")
		return 0
	upgrade_points = diff
	return 1

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/show_description()
	to_chat(src, "<span class='cultlarge'>Upgrades List</span>")
	for(var/datum/infection_upgrade/U in get_upgrades())
		to_chat(src, "<b>[U.name]:</b> [U.description]")
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/infection_help()
	to_chat(src, "<b>You are an evolving spore!</b>")
	to_chat(src, "You are an evolving creature that can select evolutions in order to become stronger \n<b>You will respawn as long as the core still exists.</b>")
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
	if(overmind.infection_core) // cant die as long as core is still alive
		forceMove(overmind.infection_core)
		INVOKE_ASYNC(src, .proc/respawn)
		return
	. = ..()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/dust()
	death()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/respawn(var/set_time = respawn_time)
	current_respawn_time = set_time
	while(current_respawn_time > 0)
		if(current_respawn_time < 10 || current_respawn_time % 5 == 0)
			to_chat(src, "<b>Respawning in [current_respawn_time] seconds.</b>")
		sleep(10)
		if(!src)
			return
		if(!overmind.infection_core)
			death()
			return
		current_respawn_time--
	to_chat(src, "<b>You have respawned!</b>")
	playsound(src, 'sound/effects/genetics.ogg', 100)
	adjustHealth(health * 0.8)
	forceMove(get_turf(src))
	current_respawn_time = -1
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/transfer_to_type(var/new_type)
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/new_spore = new new_type(loc, null, overmind)
	new_spore.key = key
	new_spore.upgrade_points = upgrade_points
	new_spore.spent_upgrade_points = spent_upgrade_points
	// check if we were respawning
	if(current_respawn_time != -1)
		// restart respawn for new spore
		INVOKE_ASYNC(new_spore, .proc/respawn, current_respawn_time)
	overmind.infection_mobs += new_spore
	qdel(src)
	new_spore.update_icons()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/refund_upgrades()
	if(spent_upgrade_points == 0)
		to_chat(src, "<span class='warning'>We are unable to revert our form any further!</span>")
		return
	to_chat(src, "<span class='warning'>Successfully reverted to base evolution!</span>")
	set_points(spent_upgrade_points)
	// reset the spore to default
	transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient)

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/cycle_node()
	if(cycle_cooldown > world.time)
		return
	var/obj/structure/infection/I = loc
	if(!I)
		return // we aren't even in an infection why are we cycling?
	var/curr
	if(istype(I, /obj/structure/infection/core))
		curr = 0
	else
		curr = GLOB.infection_nodes.Find(I)
	if(curr == GLOB.infection_nodes.len && GLOB.infection_nodes.len)
		forceMove(overmind.infection_core)
		to_chat(src, "<span class='warning'>Shifted spawn location to core.</span>")
	else if(GLOB.infection_nodes.len)
		forceMove(GLOB.infection_nodes[curr + 1])
		to_chat(src, "<span class='warning'>Shifted spawn location to node [curr + 1].</span>")
	cycle_cooldown = world.time + 5

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Zombify(mob/living/carbon/human/H)
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/myconid
	name = "myconid spore"
	desc = "A weak spore with fungi poking out of every end. It is the only spore with the capability to cross beacon walls."
	icon_state = "myconid"
	icon_living = "myconid"
	health = 40
	maxHealth = 40
	melee_damage_lower = 10
	melee_damage_upper = 10
	can_cross_beacons = TRUE
	upgrade_subtype = /datum/infection_upgrade/myconid

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector
	name = "infector spore"
	desc = "A spore that oozes infective pus from all of it's pores. It can reanimate corpses of the dead to do its bidding."
	icon_state = "infector"
	icon_living = "infector"
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 20
	upgrade_subtype = /datum/infection_upgrade/infector

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter
	name = "hunter spore"
	desc = "A congealed but fast moving spore with the abilities to hunt down and consume intruders of the infection."
	icon_state = "hunter"
	icon_living = "hunter"
	health = 60
	maxHealth = 60
	speed = -1
	melee_damage_lower = 20
	melee_damage_upper = 20
	upgrade_subtype = /datum/infection_upgrade/hunter

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive
	name = "destructive spore"
	desc = "A slow moving but bulky and heavily damaging spore that is useful for taking out buildings and walls, as well as defending infection structures."
	icon_state = "destructive"
	icon_living = "destructive"
	health = 100
	maxHealth = 100
	speed = 1
	melee_damage_lower = 40
	melee_damage_upper = 40
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	upgrade_subtype = /datum/infection_upgrade/destructive