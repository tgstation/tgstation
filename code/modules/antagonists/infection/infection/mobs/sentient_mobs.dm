
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
	var/datum/infection_menu/menu_handler

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	. = ..()
	generate_upgrades()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/generate_upgrades()
	if(ispath(upgrade_subtype))
		upgrade_types += subtypesof(upgrade_subtype)
	for(var/upgrade_type in upgrade_types)
		upgrades += new upgrade_type()
	menu_handler = new /datum/infection_menu(src)

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

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/evolve_menu()
	menu_handler.ui_interact(src)

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more upgrade points! Destroy beacons to acquire them!</span>")
		return FALSE
	upgrade_points = diff
	spent_upgrade_points += diff
	return TRUE

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
	add_points(spent_upgrade_points)
	spent_upgrade_points = 0
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