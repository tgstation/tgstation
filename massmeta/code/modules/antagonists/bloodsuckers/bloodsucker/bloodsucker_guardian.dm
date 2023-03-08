///Bloodsuckers spawning a Guardian will get the Bloodsucker one instead.
/obj/item/guardiancreator/spawn_guardian(mob/living/user, mob/dead/candidate)
	var/list/guardians = user.get_all_linked_holoparasites()
	if(guardians.len && !allowmultiple)
		to_chat(user, span_holoparasite("You already have a [mob_name]!"))
		used = FALSE
		return
	if(IS_BLOODSUCKER(user))
		var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch/timestop
		var/mob/living/simple_animal/hostile/guardian/punch/timestop/bloodsucker_guardian = new pickedtype(user, theme)
		bloodsucker_guardian.name = mob_name
		bloodsucker_guardian.summoner = user
		bloodsucker_guardian.key = candidate.key
		bloodsucker_guardian.mind.enslave_mind_to_creator(user)
		log_game("[key_name(user)] has summoned [key_name(bloodsucker_guardian)], a Timestop holoparasite.")
		add_verb(user, list(
			/mob/living/proc/guardian_comm,
			/mob/living/proc/guardian_recall,
			/mob/living/proc/guardian_reset,
		))
		to_chat(user, "[bloodsucker_guardian.magic_fluff_string]")
		to_chat(user, span_holoparasite("<b>[bloodsucker_guardian.real_name]</b> has been summoned!"))
		bloodsucker_guardian?.client.init_verbs()
		return

	// Call parent to deal with everyone else
	return ..()

///The Guardian
/mob/living/simple_animal/hostile/guardian/punch/timestop
	melee_damage_lower = 15
	melee_damage_upper = 20
	// Like Bloodsuckers do, you will take more damage to Burn and less to Brute
	damage_coeff = list(BRUTE = 0.5, BURN = 2.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	obj_damage = 80
	//Slightly faster - Used to be -1, why??
	speed = -0.2
	//Attacks 20% faster using the power of TIME MANIPULATION
	next_move_modifier = 0.8

	//None of these shouldn't appear in game outside of admin intervention
	playstyle_string = span_holoparasite("As a <b>time manipulation</b> type you can stop time and you have a damage multiplier instead of armor as-well as powerful melee attacks capable of smashing through walls.")
	magic_fluff_string = span_holoparasite("...And draw... The World, through sheer luck or perhaps destiny, maybe even your own physiology. Manipulator of time, a guardian powerful enough to control THE WORLD!.")
	tech_fluff_string = span_holoparasite("ERROR... T$M3 M4N!PULA%I0N modules loaded. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! It's imbued with the power of Carp'Sie herself. Time to rule THE WORLD!.")
	miner_fluff_string = span_holoparasite("You encounter... The World, the controller of time and space.")

/mob/living/simple_animal/hostile/guardian/punch/timestop/Initialize(mapload, theme)
	//Wizard Holoparasite theme, just to be more visibly stronger than regular ones
	theme = "magic"
	. = ..()
	var/datum/action/cooldown/spell/timestop/guardian/timestop_ability = new()
	timestop_ability.Grant(src)

///Guardian Timestop ability
/datum/action/cooldown/spell/timestop/guardian
	name = "Guardian Timestop"
	desc = "This spell stops time for everyone except for you and your master, allowing you to move freely while your enemies and even projectiles are frozen."
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	invocation_type = INVOCATION_NONE
	var/list/safe_people = list()

///Timestop + Adding protected_summoner to the list of protected people
/datum/action/cooldown/spell/timestop/guardian/cast(atom/cast_on)
	. = ..()
	if(!(owner in safe_people))
		var/mob/living/simple_animal/hostile/guardian/punch/timestop/bloodsucker_guardian = owner
		safe_people += bloodsucker_guardian.summoner
		safe_people += owner

	new /obj/effect/timestop/magic(get_turf(owner), timestop_range, timestop_duration, safe_people)
