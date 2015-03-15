/datum/round_event_control/alien_infestation
	name = "Alien Infestation"
	typepath = /datum/round_event/alien_infestation
	weight = 5
	max_occurrences = 1

/datum/round_event/alien_infestation
	announceWhen	= 400

	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.


/datum/round_event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	spawncount = rand(1, 2)

/datum/round_event/alien_infestation/kill()
	if(!successSpawn && control)
		control.occurrences--
	return ..()

/datum/round_event/alien_infestation/announce()
	if(successSpawn)
		priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", 'sound/AI/aliens.ogg')


/datum/round_event/alien_infestation/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 20)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)

	while(spawncount > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)

		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		new_xeno.key = C.key

		spawncount--
		successSpawn = 1



//XENO NEST WARS VARIANT
//Variant on alien_infestation, summons 2 seperate strains of xenos to have a nest war.
//Crew become a resource in a battle between two xeno strains.

/datum/round_event_control/alien_infestation/xeno_nest_wars //Subtype so only one of the two occurs (naturally)
	name = "Xeno Nest Wars"
	typepath = /datum/round_event/alien_infestation/xeno_nest_wars


//The only different proc between the two event types.
/datum/round_event/alien_infestation/xeno_nest_wars/start()

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in world)
		if(temp_vent.loc.z == ZLEVEL_STATION && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 20)	//Stops Aliens getting stuck in small networks. See: Security, Virology
				vents += temp_vent

	var/total_spawn_count = spawncount*2
	var/strain1_count = spawncount
	var/strain2_count = spawncount

	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)
	if(candidates.len < total_spawn_count) //not enough for a fair amount on each strain
		kill()
		return

	//Black, Red, Yellow xenos are all canon, so we'll stick with those for now.
	var/list/possible_strains = list("black","red","yellow")
	var/list/actual_strains = list()

	actual_strains = possible_strains - pick(possible_strains)

	while(total_spawn_count > 0 && vents.len && candidates.len)
		var/obj/vent = pick_n_take(vents)
		var/obj/vent_2 = pick_n_take(vents)
		var/client/C = pick_n_take(candidates)
		var/client/CC = pick_n_take(candidates)

		//Makes 2 xenos at once as that's the cleanest way I could code it that worked.
		//One of each team.
		var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
		var/mob/living/carbon/alien/larva/new_xeno_2 = new(vent_2.loc)
		new_xeno.key = C.key
		new_xeno_2.key = CC.key

		var/which_strain = 0 //"First" Strain, uses as keys for strain list
		var/enemy_strain = 0 //"Second" Strain, used as keys for strain list

		//Both same amount? random strain
		if(strain1_count && strain2_count && strain1_count == strain2_count)
			which_strain = rand(1,2)
			if(which_strain == 1)
				enemy_strain = 2
			else
				enemy_strain = 1

		//Ensure one of each strain is made
		if(strain1_count > strain2_count)
			which_strain = 2
			enemy_strain = 1
		else
			which_strain = 1
			enemy_strain = 2

		//Setup the "Strain" of each xeno
		new_xeno.color = setup_color(actual_strains[which_strain])
		total_spawn_count--
		strain1_count--

		new_xeno_2.color = setup_color(actual_strains[enemy_strain])
		total_spawn_count--
		strain2_count--

		//Objective to kill the other strain off
		if(new_xeno.mind)
			var/datum/objective/xeno_nest_kill/XNK = new /datum/objective/xeno_nest_kill()
			XNK.enemy_strain = actual_strains[enemy_strain]
			XNK.update_explanation_text()
			new_xeno.mind.objectives += XNK

		if(new_xeno_2.mind)
			var/datum/objective/xeno_nest_kill/XNK2 = new /datum/objective/xeno_nest_kill()
			XNK2.enemy_strain = actual_strains[which_strain]
			XNK2.update_explanation_text()
			new_xeno_2.mind.objectives += XNK2

		successSpawn = 1


/datum/round_event/alien_infestation/xeno_nest_wars/proc/setup_color(var/strain)
	. = ""
	if(strain && strain != "black")//black uses the default icons, greyscale xenos when?
		. = strain



//Xeno nest wars objectives:

/datum/objective/xeno_nest_kill
	dangerrating = 10
	var/enemy_strain = ""

//Byond accepts the text variants of colours (red, yellow etc.) but we need to make sure black is ""
/datum/objective/xeno_nest_kill/proc/get_enemy_colour_value(var/strain = "")
	. = strain
	if(strain && strain == "black")
		. = ""

/datum/objective/xeno_nest_kill/find_target_by_role()
	return

/datum/objective/xeno_nest_kill/check_completion()
	var/enemy_count = 0
	for(var/mob/living/carbon/alien/A in world)
		if(A.color == get_enemy_colour_value(enemy_strain))
			enemy_count++
			break
	if(enemy_count)
		return 0
	return 1

/datum/objective/xeno_nest_kill/update_explanation_text()
	..()
	explanation_text = "Destroy the [enemy_strain] xenomorphs!"


