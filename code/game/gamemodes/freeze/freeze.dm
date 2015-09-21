/datum/game_mode
	var/datum/mind/list/frost_scions = list()
	var/datum/mind/list/frost_pawns = list()
	var/list/frost_objectives = list()

/proc/is_scion(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.frost_scions)
/proc/is_pawn(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.frost_pawns)
/proc/is_frosty(mob/living/M)
	return is_scion(M) || is_pawn(M)

/datum/game_mode/freeze
	name = "freeze"
	config_tag = "freeze"
	antag_flag = BE_SCION

	required_players = 20
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14

	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")

/datum/game_mode/freeze/pre_setup()
	pick_objectives()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/scions = max(required_enemies, round((num_players()*0.1)*(required_enemies*0.5))) //graph of scaling: https://www.desmos.com/calculator/kh3e305nzf

	while(scions)
		var/datum/mind/scion = pick(antag_candidates)
		frost_scions += scion
		antag_candidates -= scion
		scion.special_role = "FrostScion"
		scion.restricted_roles = restricted_jobs
		scions--

	return 1

/datum/game_mode/freeze/post_setup()
	for(var/datum/mind/scion in frost_scions)
		log_game("[scion.key] (ckey) has been selected as a Scion of the Kingdom.")
		sleep(10)
		greet_scion(scion)
		finalize_scion(scion)
		memorize_frost_objectives(scion)

	return ..()

/datum/game_mode/freeze/proc/pick_objectives()
	frost_objectives += "freeze" //maybe more later? who knows

/datum/game_mode/freeze/proc/greet_scion(datum/mind/scion)
	scion.current << "<br>"
	scion.current << "<span class='shadowling'><b><font size=3>You are a Scion of the Frost Kingdom!</font></b></span>"

/datum/game_mode/freeze/proc/memorize_frost_objectives(datum/mind/frost_mind)
	for(var/i in 1 to frost_objectives.len)
		var/explanation
		switch(frost_objectives[i])
			if("freeze")
				explanation = "man I don't fuckin know talk to J_Madison"
		frost_mind.current << "<B>Objective #[i]</B>: [explanation]<BR>"
		frost_mind.memory += "<B>Objective #[i]</B>: [explanation]<BR>"

/datum/game_mode/proc/finalize_scion(datum/mind/scion)
	scion.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/spread_frost(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/targeted/chilling_grasp(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/targeted/scion_transform(null))
	var/mob/living/carbon/human/S = scion.current
	set_mrace_keep_values(S, /datum/species/human/frosty/scion)
	spawn(0)
		if(scion.assigned_role == "Clown" && S)
			S << "<span class='notice'>Your icy nature has allowed you to overcome your clownishness.</span>"
			S.dna.remove_mutation(CLOWNMUT)

/datum/game_mode/proc/make_pawn(datum/mind/pawn_mind)
	if(!istype(pawn_mind))
		return 0
	if(!(pawn_mind in frost_pawns))
		//add stuff blah balh
		set_mrace_keep_values(pawn_mind.current, /datum/species/human/frosty/pawn)
		pawn_mind.special_role = "FrostPawn"
		return 1

/datum/game_mode/proc/transform_scion(datum/mind/scion)
	if(scion.special_role != "FrostScion")
		finalize_scion(scion)
	scion.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/freeze_area(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/frostbite(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/extinguish(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/refreeze(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/scion_equipment/weapon/orb(null))
	scion.AddSpell(new /obj/effect/proc_holder/spell/scion_equipment/weapon/sceptre(null))
	set_mrace_keep_values(scion.current, /datum/species/human/frosty/scion/transformed)
