/*
	The actual player controlled slime type
*/

/mob/living/simple_animal/hostile/infection/infectionspore/sentient
	name = "evolving slime"
	desc = "An extremely strong slime in the early stages of life, what will it become next?"
	hud_type = /datum/hud/infection_spore
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	crystal_color = "#ff8c00"
	// respawn time for the slime
	var/respawn_time = 30
	// the time left to respawn
	var/current_respawn_time = 0
	// the upgrade points the spore has stored
	var/upgrade_points = 0
	// the spent upgrade points, half of these are given back when they refund the upgrades
	var/spent_upgrade_points = 0
	// the maximum number of upgrade points that the slime is allowed to have
	var/max_upgrade_points = 1000
	// the upgrade types given to the slime
	var/list/upgrade_types = list()
	// the actual upgrades
	var/list/upgrades = list()
	// the upgrade subtype added to upgrade types
	var/upgrade_subtype = /datum/infection_upgrade/spore_type_change
	// handles the menu for upgrading
	var/datum/infection_menu/menu_handler
	// Actions that the slime starts with
	var/list/default_actions = list()
	// the mob we get moved to while respawning
	var/mob/camera/infectionslime/respawnmob
	// things that can drop after the slime dies a fake death
	var/list/slime_drops = list(/obj/item/gun/energy/laser=1,
								/obj/item/stack/spacecash/c500=1,
								/obj/item/clothing/head/hardhat/cakehat=2,
								/obj/item/clothing/gloves/color/yellow=1,
								/obj/item/extinguisher=2,
								/obj/item/pickaxe/drill/diamonddrill=1,
								/obj/item/clothing/shoes/magboots=1)

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/Initialize(mapload, var/obj/structure/infection/factory/linked_node, commander)
	. = ..()
	generate_upgrades()
	for(var/type_action in default_actions)
		var/datum/action/cooldown/infection/add_action = new type_action()
		add_action.Grant(src)

/*
	Generates the actual upgrade datums for this slime
*/
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
	if(overmind && !overmind.placed)
		stat(null, "Time Before Automatic Placement: [max(round((overmind.autoplace_time - world.time)*0.1, 0.1), 0)]")

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

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		if(ROLE_INFECTION in L.faction)
			return FALSE
	. = ..()

/*
	Sets the point value for the slime
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/set_points(var/value)
	add_points(value - upgrade_points)

/*
	Adds points to the infection slime
	Does not go over or below the maximum and minimum values
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/add_points(var/value)
	upgrade_points = CLAMP(upgrade_points + value, 0, max_upgrade_points)
	if(hud_used)
		hud_used.infectionpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(upgrade_points)]</font></div>"

/*
	The amount of points given to the slime every life tick
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/get_point_generation_rate()
	if(!GLOB.infection_core)
		return 0
	return 2

/*
	Attempts to open the evolution menu of this slime
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/evolve_menu()
	if(!ISRESPAWNING(src))
		to_chat(src, "<span class='warning'>You cannot evolve unless you are reforming at a node or core!</span>")
		return
	menu_handler.ui_interact(src)

/*
	Attempts to upgrade something with this slimes points
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more points!</span>")
		return FALSE
	upgrade_points = diff
	spent_upgrade_points += cost
	return TRUE

/*
	Help text for the infection slime
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/infection_help()
	to_chat(src, "<b>You are an evolving slime!</b>")
	to_chat(src, "You are an evolving creature that can select evolutions in order to become stronger \n<b>You will respawn as long as the core still exists.</b>")
	to_chat(src, "<b>Attempt to help expand your army of infectious slimes by bringing sentient human corpses near the infection core!</b>")
	to_chat(src, "You can communicate with other infectious creatures via <b>:b</b>")
	return

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(updating_health)
		update_health_hud()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/update_health_hud()
	if(hud_used)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round((health / maxHealth) * 100, 0.5)]%</font></div>"

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/dust(just_ash, drop_items, force)
	return death()

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/death(gibbed)
	if(ISRESPAWNING(src))
		return // no you dont
	if(overmind && overmind.infection_core) // cant die as long as core is still alive
		playsound(src.loc, 'sound/effects/splat.ogg', 100, FALSE, pressure_affected = FALSE)
		visible_message("<span class='notice'>[src] fades into pure energy that races towards the core of the infection.</span>",
			"<span class='notice'>You return to the core of the infection to reform your body.</span>")
		var/type_of_drop = pickweight(slime_drops)
		var/turf/T = get_turf(src)
		if(type_of_drop && T)
			new type_of_drop(T)
		if(!respawnmob)
			create_respawn_mob(get_turf(overmind.infection_core))
		forceMove(respawnmob)
		INVOKE_ASYNC(src, .proc/start_spawn)
		return
	. = ..()

/*
	Start the respawning cycle
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/start_spawn(increase_time = respawn_time)
	if(increase_time <= 0)
		current_respawn_time = world.time
		return
	current_respawn_time = world.time + increase_time
	to_chat(src, "<b>You will be able to respawn in [round(world.time - current_respawn_time, 1)] seconds.</b>")
	sleep(increase_time)
	if(!QDELETED(src) && current_respawn_time <= world.time)
		to_chat(src, "<b>You may now respawn!</b>")
		playsound_local(src, 'sound/effects/splat.ogg', 100)

/*
	Actually respawn the slime when they request it
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/do_spawn()
	if(!ISRESPAWNING(src))
		to_chat(src, "<span class='warning'>You cannot respawn right now!</span>")
		return
	if(current_respawn_time > world.time)
		to_chat(src, "<b>You will be able to respawn in [round(world.time - current_respawn_time, 1)] seconds.</b>")
		return
	var/turf/T = get_turf(src)
	if(T)
		if((locate(/obj/structure/infection/node) in T) || (locate(/obj/structure/infection/core) in T))
			adjustHealth(-maxHealth)
			forceMove(T)
			playsound_local(src, 'sound/effects/splat.ogg', 100)
			return
	to_chat(src, "<span class='warning'>You may only respawn at the core or at a node!</span>")

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/create_respawn_mob(var/turf/T)
	if(respawnmob)
		qdel(respawnmob)
	respawnmob = new /mob/camera/infectionslime(T)
	forceMove(respawnmob)
	client.images |= image('icons/mob/cameramob.dmi', respawnmob, "marker")

/*
	Try to transfer this slimes mind and data to a new slime type
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/transfer_to_type(var/new_type)
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/new_spore = new new_type(loc, null, overmind)
	new_spore.key = key
	new_spore.upgrade_points = upgrade_points
	new_spore.spent_upgrade_points = spent_upgrade_points
	new_spore.create_respawn_mob(respawnmob.loc)
	INVOKE_ASYNC(new_spore, .proc/start_spawn, current_respawn_time - world.time)
	overmind.infection_mobs += new_spore
	menu_handler.ui.close()
	qdel(src)
	new_spore.update_icons()
	new_spore.evolve_menu() // re-update the menu since they changed type

/*
	Refund the upgrades this slime has purchased and transfer them to a base type
*/
/mob/living/simple_animal/hostile/infection/infectionspore/sentient/proc/refund_upgrades()
	var/confirm = alert("Are you sure you want to refund all of your upgrades?", "Revert Form", "Yes", "No")
	if(confirm != "Yes")
		return
	if(!ISRESPAWNING(src))
		to_chat(src, "<span class='warning'>You cannot revert unless you are reforming!</span>")
		return
	if(spent_upgrade_points == 0)
		to_chat(src, "<span class='warning'>We are unable to revert our form any further!</span>")
		return
	to_chat(src, "<span class='warning'>Successfully reverted to base evolution!</span>")
	if(!GLOB.infection_core)
		add_points(spent_upgrade_points) // no cost when in loading
	else
		add_points(round(spent_upgrade_points / 2, 1))
	spent_upgrade_points = 0
	// reset the spore to default
	transfer_to_type(/mob/living/simple_animal/hostile/infection/infectionspore/sentient)

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/infector
	name = "infector slime"
	desc = "A slime that oozes infective pus from all of it's pores."
	icon_state = "infest-moth-core"
	crystal_color = "#ffffff"
	crystal_icon_state = "infest-moth-layer"
	upgrade_subtype = /datum/infection_upgrade/infector

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/hunter
	name = "hunter slime"
	desc = "A congealed but fast moving slime with the abilities to hunt down and consume intruders of the infection."
	crystal_color = "#dc143c"
	upgrade_subtype = /datum/infection_upgrade/hunter

/mob/living/simple_animal/hostile/infection/infectionspore/sentient/destructive
	name = "destructive slime"
	desc = "A slow moving but bulky and heavily damaging slime that is useful for taking out buildings and walls, as well as defending infection structures."
	health = 100
	maxHealth = 100
	speed = 5
	crystal_color = "#4169e1"
	transform = matrix(1.5, 0, 0, 0, 1.5, 0)
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	upgrade_subtype = /datum/infection_upgrade/destructive

/mob/camera/infectionslime
	name = "Respawning Infection Slime"
	real_name = "Respawning Infection Slime"
	desc = "An infectious slime choosing where it should spawn."
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "marker"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	color = "#ffffff"
	pass_flags = PASSBLOB
	faction = list(ROLE_INFECTION)
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/mob/camera/infectionslime/Move(NewLoc, Dir = 0)
	forceMove(NewLoc)

/mob/camera/infectionslime/relaymove(mob/user, direction)
	var/NewLoc = get_step(src, direction)
	if(NewLoc)
		Move(NewLoc, direction)