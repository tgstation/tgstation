<<<<<<< HEAD
/mob/living/gib(no_brain, no_organs)
	var/prev_lying = lying
	if(stat != DEAD)
		death(1)

	if(buckled)
		buckled.unbuckle_mob(src,force=1) //to update alien nest overlay, forced because we don't exist anymore

	if(!prev_lying)
		gib_animation()
	if(!no_organs)
		spill_organs(no_brain)
	spawn_gibs()
	qdel(src)

/mob/living/proc/gib_animation()
	return

/mob/living/proc/spawn_gibs()
	gibs(loc, viruses)

/mob/living/proc/spill_organs(no_brain)
	return


/mob/living/dust()
	death(1)

	if(buckled)
		buckled.unbuckle_mob(src,force=1)

	dust_animation()
	spawn_dust()
	qdel(src)

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)


/mob/living/death(gibbed)
	unset_machine()
	timeofdeath = world.time
	tod = worldtime2text()
	var/turf/T = get_turf(src)
	if(mind && mind.name && mind.active && (T.z != ZLEVEL_CENTCOM))
		var/area/A = get_area(T)
		var/rendered = "<span class='game deadsay'><span class='name'>\
			[mind.name]</span> has died at <span class='name'>[A.name]\
			</span>.</span>"
		deadchat_broadcast(rendered, follow_target = src,
			message_type=DEADCHAT_DEATHRATTLE)
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
	var/list/scripture_states = get_scripture_states()
	living_mob_list -= src
	scripture_unlock_alert(scripture_states)
	if(!gibbed)
		dead_mob_list += src
	else if(buckled)
		buckled.unbuckle_mob(src,force=1)
	paralysis = 0
	stunned = 0
	weakened = 0
	set_drugginess(0)
	SetSleeping(0, 0)
	blind_eyes(1)
	reset_perspective(null)
	hide_fullscreens()
	update_action_buttons_icon()
	update_damage_hud()
	update_health_hud()
	update_canmove()
	med_hud_set_health()
	med_hud_set_status()
=======
/mob/living/death(gibbed)
	if(!gibbed && can_butcher)
		verbs += /mob/living/proc/butcher

	//Check the global list of butchering drops for our species.
	//See code/datums/helper_datums/butchering.dm
	init_butchering_list()

	clear_fullscreens()
	..()

/mob/living/proc/init_butchering_list()
	butchering_drops = list()

	if(species_type && (!src.butchering_drops || !src.butchering_drops.len))
		if(animal_butchering_products[species_type])
			var/list/L = animal_butchering_products[species_type]

			for(var/butchering_type in L)
				src.butchering_drops += new butchering_type
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
