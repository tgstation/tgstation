/// Simple, mostly AI-controlled critters, such as pets, bots, and drones.
/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/simple/animal.dmi'
	health = 20
	maxHealth = 20
	gender = PLURAL //placeholder
	living_flags = MOVES_ON_ITS_OWN
	status_flags = CANPUSH

	var/icon_living = ""
	///Icon when the animal is dead. Don't use animated icons for this.
	var/icon_dead = ""
	///We only try to show a gibbing animation if this exists.
	var/icon_gib = null
	///Flip the sprite upside down on death. Mostly here for things lacking custom dead sprites.
	var/flip_on_death = FALSE

	var/list/speak = list()
	///Emotes while speaking IE: `Ian [emote], [text]` -- `Ian barks, "WOOF!".` Spoken text is generated from the speak variable.
	var/list/speak_emote = list()
	var/speak_chance = 0
	///Hearable emotes
	var/list/emote_hear = list()
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see = list()

	///ticks up every time `handle_automated_movement()` is called, which is every 2 seconds at the time of documenting. 1  turns per move is 1 movement every 2 seconds.
	var/turns_per_move = 1
	var/turns_since_move = 0
	///Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/stop_automated_movement = 0
	///Does the mob wander around when idle?
	var/wander = 1
	/// Makes Goto() return FALSE and not start a move loop
	var/prevent_goto_movement = FALSE
	///When set to 1 this stops the animal from moving when someone is pulling it.
	var/stop_automated_movement_when_pulled = 1

	///When someone interacts with the simple animal.
	///Help-intent verb in present continuous tense.
	var/response_help_continuous = "pokes"
	///Help-intent verb in present simple tense.
	var/response_help_simple = "poke"
	///Disarm-intent verb in present continuous tense.
	var/response_disarm_continuous = "shoves"
	///Disarm-intent verb in present simple tense.
	var/response_disarm_simple = "shove"
	///Harm-intent verb in present continuous tense.
	var/response_harm_continuous = "hits"
	///Harm-intent verb in present simple tense.
	var/response_harm_simple = "hit"
	var/harm_intent_damage = 3
	///Maximum amount of stamina damage the mob can be inflicted with total
	var/max_staminaloss = 200
	///How much stamina the mob recovers per second
	var/stamina_recovery = 5

	///Minimal body temperature without receiving damage
	var/minbodytemp = NPC_DEFAULT_MIN_TEMP
	///Maximal body temperature without receiving damage
	var/maxbodytemp = NPC_DEFAULT_MAX_TEMP
	///This damage is taken when the body temp is too cold.
	var/unsuitable_cold_damage
	///This damage is taken when the body temp is too hot.
	var/unsuitable_heat_damage

	/// List of weather immunity traits that are then added on Initialize(), see traits.dm.
	var/list/weather_immunities

	///Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	///Leaving something at 0 means it's off - has no maximum.
	var/list/atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	///This damage is taken when atmos doesn't fit all the requirements above.
	var/unsuitable_atmos_damage = 1

	///How fast the mob's temperature normalizes. The greater the value, the slower their temperature normalizes. Should always be greater than 0.
	var/temperature_normalization_speed = 5

	//Defaults to zero so Ian can still be cuddly. Moved up the tree to living! This allows us to bypass some hardcoded stuff.
	melee_damage_lower = 0
	melee_damage_upper = 0
	///how much damage this simple animal does to objects, if any.
	var/obj_damage = 0
	///How much armour they ignore, as a flat reduction from the targets armour value.
	var/armour_penetration = 0
	///Damage type of a simple mob's melee attack, should it do damage.
	var/melee_damage_type = BRUTE
	/// 1 for full damage , 0 for none , -1 for 1:1 heal from that source.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	///Attacking verb in present continuous tense.
	var/attack_verb_continuous = "attacks"
	///Attacking verb in present simple tense.
	var/attack_verb_simple = "attack"
	/// Sound played when the critter attacks.
	var/attack_sound
	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_vis_effect
	///Attacking, but without damage, verb in present continuous tense.
	var/friendly_verb_continuous = "nuzzles"
	///Attacking, but without damage, verb in present simple tense.
	var/friendly_verb_simple = "nuzzle"
	///Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls.
	var/environment_smash = ENVIRONMENT_SMASH_NONE

	///LETS SEE IF I CAN SET SPEEDS FOR SIMPLE MOBS WITHOUT DESTROYING EVERYTHING. Higher speed is slower, negative speed is faster.
	var/speed = 1

	///Hot simple_animal baby making vars.
	var/list/childtype = null
	var/next_scan_time = 0
	///Sorry, no spider+corgi buttbabies.
	var/animal_species

	///Simple_animal access.
	///Innate access uses an internal ID card.
	var/obj/item/card/id/access_card = null
	///If the mob can be spawned with a gold slime core. HOSTILE_SPAWN are spawned with plasma, FRIENDLY_SPAWN are spawned with blood.
	var/gold_core_spawnable = NO_SPAWN

	///Sentience type, for slime potions.
	var/sentience_type = SENTIENCE_ORGANIC

	///List of things spawned at mob's loc when it dies.
	var/list/loot = list()
	///Causes mob to be deleted on death, useful for mobs that spawn lootable corpses.
	var/del_on_death = 0

	var/allow_movement_on_non_turfs = FALSE

	///Played when someone punches the creature.
	var/attacked_sound = SFX_PUNCH

	///The Status of our AI, can be set to AI_ON (On, usual processing), AI_IDLE (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever).
	var/AIStatus = AI_ON
	///once we have become sentient, we can never go back.
	var/can_have_ai = TRUE

	///convenience var for forcibly waking up an idling AI on next check.
	var/shouldwakeup = FALSE

	///I don't want to confuse this with client registered_z.
	var/my_z
	///What kind of footstep this mob should have. Null if it shouldn't have any.
	var/footstep_type

	///How much wounding power it has
	var/wound_bonus = CANT_WOUND
	///How much bare wounding power it has
	var/bare_wound_bonus = 0
	///If the attacks from this are sharp
	var/sharpness = NONE
	///Generic flags
	var/simple_mob_flags = NONE

	///Limits how often mobs can hunt other mobs
	COOLDOWN_DECLARE(emote_cooldown)
	var/turns_since_scan = 0

	///Is this animal horrible at hunting?
	var/inept_hunter = FALSE


/mob/living/simple_animal/Initialize(mapload)
	. = ..()
	GLOB.simple_animals[AIStatus] += src
	if(gender == PLURAL)
		gender = pick(MALE,FEMALE)
	if(!real_name)
		real_name = name
	if(!loc)
		stack_trace("Simple animal being instantiated in nullspace")
	update_simplemob_varspeed()
	ADD_TRAIT(src, TRAIT_NOFIRE_SPREAD, ROUNDSTART_TRAIT)
	if(length(weather_immunities))
		add_traits(weather_immunities, ROUNDSTART_TRAIT)
	if (environment_smash >= ENVIRONMENT_SMASH_WALLS)
		AddElement(/datum/element/wall_smasher, strength_flag = environment_smash)
	if(speak)
		speak = string_list(speak)
	if(speak_emote)
		speak_emote = string_list(speak_emote)
	if(emote_hear)
		emote_hear = string_list(emote_hear)
	if(emote_see)
		emote_see = string_list(emote_hear)
	if(damage_coeff)
		damage_coeff = string_assoc_list(damage_coeff)
	if(footstep_type)
		AddElement(/datum/element/footstep, footstep_type)
	if(isnull(unsuitable_cold_damage))
		unsuitable_cold_damage = unsuitable_atmos_damage
	if(isnull(unsuitable_heat_damage))
		unsuitable_heat_damage = unsuitable_atmos_damage

	///We need to wait for SSair to be initialized before we can check atmos/temp requirements.
	if(PERFORM_ALL_TESTS(focus_only/atmos_and_temp_requirements) && mapload && !SSair.initialized)
		RegisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(on_ssair_init))
		return
	init_atmos_temp_requirement(mapload)

/mob/living/simple_animal/proc/on_ssair_init(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSair, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	init_atmos_temp_requirement(TRUE)

/mob/living/simple_animal/proc/init_atmos_temp_requirement(mapload)
	if(atmos_requirements && unsuitable_atmos_damage)
		atmos_requirements = string_assoc_list(atmos_requirements)
		AddElement(/datum/element/atmos_requirements, atmos_requirements, unsuitable_atmos_damage, mapload)
	if((unsuitable_cold_damage || unsuitable_heat_damage) && (minbodytemp > 0 || maxbodytemp < INFINITY))
		AddElement(/datum/element/body_temp_sensitive, minbodytemp, maxbodytemp, unsuitable_cold_damage, unsuitable_heat_damage, mapload)

/mob/living/simple_animal/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(staminaloss > 0)
		adjustStaminaLoss(-stamina_recovery * seconds_per_tick, FALSE, TRUE)

/mob/living/simple_animal/Destroy()
	QDEL_NULL(access_card)
	GLOB.simple_animals[AIStatus] -= src
	SSnpcpool.currentrun -= src

	return ..()

/mob/living/simple_animal/examine(mob/user)
	. = ..()
	if(stat == DEAD)
		if(HAS_MIND_TRAIT(user, TRAIT_NAIVE))
			. += span_deadsay("Upon closer examination, [p_they()] appear[p_s()] to be asleep.")
		else
			. += span_deadsay("Upon closer examination, [p_they()] appear[p_s()] to be dead.")
	if(access_card)
		. += "There appears to be [icon2html(access_card, user)] \a [access_card] pinned to [p_them()]."

/mob/living/simple_animal/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= 0)
			death()
		else
			set_stat(CONSCIOUS)
	med_hud_set_status()

/**
 * Updates the simple mob's stamina loss.
 *
 * Updates the speed and staminaloss of a given simplemob.
 * Reduces the stamina loss by stamina_recovery
 */
/mob/living/simple_animal/update_stamina()
	if(damage_coeff[STAMINA] <= 0) //we shouldn't reset our speed to its initial value if we don't need to, as that can mess with things like mulebot motor wires
		return
	set_varspeed(initial(speed) + (staminaloss * 0.06))

/mob/living/simple_animal/proc/handle_automated_action()
	set waitfor = FALSE
	return

/mob/living/simple_animal/proc/handle_automated_movement()
	set waitfor = FALSE
	if(stop_automated_movement || !wander)
		return
	if(!isturf(loc) && !allow_movement_on_non_turfs)
		return
	if(!(mobility_flags & MOBILITY_MOVE)) //This is so it only moves if it's not inside a closet, gentics machine, etc.
		return TRUE

	turns_since_move++
	if(turns_since_move < turns_per_move)
		return TRUE
	if(stop_automated_movement_when_pulled && pulledby) //Some animals don't move when pulled
		return TRUE
	var/anydir = pick(GLOB.cardinals)
	if(Process_Spacemove(anydir))
		Move(get_step(src, anydir), anydir)
		turns_since_move = 0
	return TRUE

/mob/living/simple_animal/proc/handle_automated_speech(override)
	set waitfor = FALSE
	if(speak_chance)
		if(prob(speak_chance) || override)
			if(speak?.len)
				if((emote_hear?.len) || (emote_see?.len))
					var/length = speak.len
					if(emote_hear?.len)
						length += emote_hear.len
					if(emote_see?.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak), forced = "automated speech")
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							manual_emote(pick(emote_see))
						else
							manual_emote(pick(emote_hear))
				else
					say(pick(speak), forced = "automated speech")
			else
				if(!(emote_hear?.len) && (emote_see?.len))
					manual_emote(pick(emote_see))
				if((emote_hear?.len) && !(emote_see?.len))
					manual_emote(pick(emote_hear))
				if((emote_hear?.len) && (emote_see?.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						manual_emote(pick(emote_see))
					else
						manual_emote(pick(emote_hear))

/mob/living/simple_animal/handle_environment(datum/gas_mixture/environment, seconds_per_tick, times_fired)
	var/atom/A = loc
	if(isturf(A))
		var/areatemp = get_temperature(environment)
		var/temp_delta = areatemp - bodytemperature
		if(abs(temp_delta) > 5)
			if(temp_delta < 0)
				if(!on_fire)
					adjust_bodytemperature(clamp(temp_delta * seconds_per_tick / temperature_normalization_speed, temp_delta, 0))
			else
				adjust_bodytemperature(clamp(temp_delta * seconds_per_tick / temperature_normalization_speed, 0, temp_delta))

/mob/living/simple_animal/gib()
	if(butcher_results || guaranteed_butcher_results)
		var/list/butcher = list()
		if(butcher_results)
			butcher += butcher_results
		if(guaranteed_butcher_results)
			butcher += guaranteed_butcher_results
		var/atom/Tsec = drop_location()
		for(var/path in butcher)
			for(var/i in 1 to butcher[path])
				new path(Tsec)
	..()

/mob/living/simple_animal/gib_animation()
	if(icon_gib)
		new /obj/effect/temp_visual/gib_animation/animal(loc, icon_gib)


/mob/living/simple_animal/get_default_say_verb()
	return length(speak_emote) ? pick(speak_emote) : ..()

/mob/living/simple_animal/proc/set_varspeed(var_value)
	speed = var_value
	update_simplemob_varspeed()

/mob/living/simple_animal/proc/update_simplemob_varspeed()
	if(speed == 0)
		remove_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed)
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simplemob_varspeed, multiplicative_slowdown = speed)

/mob/living/simple_animal/get_status_tab_items()
	. = ..()
	. += "Health: [round((health / maxHealth) * 100)]%"
	. += "Combat Mode: [combat_mode ? "On" : "Off"]"

/mob/living/simple_animal/proc/drop_loot()
	if (!length(loot))
		return
	for(var/i in loot)
		new i(drop_location())
	loot.Cut()

/mob/living/simple_animal/death(gibbed)
	drop_loot()
	if(del_on_death)
		..()
		//Prevent infinite loops if the mob Destroy() is overridden in such
		//a manner as to cause a call to death() again //Pain
		del_on_death = FALSE
		qdel(src)
		return

	health = 0
	icon_state = icon_dead
	if(flip_on_death)
		transform = transform.Turn(180)
	ADD_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)
	return ..()

/mob/living/simple_animal/proc/CanAttack(atom/the_target)
	if(!isatom(the_target)) // no
		stack_trace("Invalid target in CanAttack(): [the_target]")
		return FALSE
	if(see_invisible < the_target.invisibility)
		return FALSE
	if(ismob(the_target))
		var/mob/mob = the_target
		if(HAS_TRAIT(mob, TRAIT_GODMODE))
			return FALSE
	if (isliving(the_target))
		var/mob/living/L = the_target
		if(L.stat != CONSCIOUS)
			return FALSE
	if (ismecha(the_target))
		var/obj/vehicle/sealed/mecha/M = the_target
		if(LAZYLEN(M.occupants))
			return FALSE
	return TRUE

/mob/living/simple_animal/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return
	icon_state = icon_living
	REMOVE_TRAIT(src, TRAIT_UNDENSE, BASIC_MOB_DEATH_TRAIT)

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || next_scan_time > world.time || !childtype || !animal_species || !SSticker.IsRoundInProgress())
		return
	next_scan_time = world.time + 400
	var/alone = TRUE
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/M in view(7, src))
		if(M.stat != CONSCIOUS) //Check if it's conscious FIRST.
			continue
		var/is_child = is_type_in_list(M, childtype)
		if(is_child) //Check for children SECOND.
			children++
		else if(istype(M, animal_species))
			if(M.ckey)
				continue
			else if(!is_child && M.gender == MALE && !(M.flags_1 & HOLOGRAM_1)) //Better safe than sorry ;_;
				partner = M

		else if(isliving(M) && !faction_check_atom(M)) //shyness check. we're not shy in front of things that share a faction with us.
			return //we never mate when not alone, so just abort early

	if(alone && partner && children < 3)
		var/childspawn = pick_weight(childtype)
		var/turf/target = get_turf(loc)
		if(target)
			return new childspawn(target)

/mob/living/simple_animal/update_resting()
	if(resting)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	return ..()

/mob/living/simple_animal/proc/sentience_act() //Called when a simple animal gains sentience via gold slime potion
	toggle_ai(AI_OFF) // To prevent any weirdness.
	can_have_ai = FALSE

/mob/living/simple_animal/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
			set_sight(null)
		else if(is_secret_level(z))
			set_sight(initial(sight))
		else
			set_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		set_invis_see(SEE_INVISIBLE_OBSERVER)
		return

	lighting_color_cutoffs = list(lighting_cutoff_red, lighting_cutoff_green, lighting_cutoff_blue)
	set_invis_see(initial(see_invisible))
	if(SSmapping.level_trait(z, ZTRAIT_NOXRAY))
		set_sight(null)
	else
		set_sight(initial(sight))
	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return
	return ..()

//Will always check hands first, because access_card is internal to the mob and can't be removed or swapped.
/mob/living/simple_animal/get_idcard(hand_first)
	return (..() || access_card)

/mob/living/simple_animal/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, ignore_animation = TRUE)
	. = ..()
	update_held_items()

/mob/living/simple_animal/update_held_items()
	. = ..()
	if(!client || !hud_used || hud_used.hud_version == HUD_STYLE_NOHUD)
		return
	var/turf/our_turf = get_turf(src)
	for(var/obj/item/I in held_items)
		var/index = get_held_index_of_item(I)
		SET_PLANE(I, ABOVE_HUD_PLANE, our_turf)
		I.screen_loc = ui_hand_position(index)
		client.screen |= I

//ANIMAL RIDING

/mob/living/simple_animal/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(user.incapacitated)
		return
	for(var/atom/movable/A in get_turf(src))
		if(A != src && A != M && A.density)
			return

	return ..()

/mob/living/simple_animal/proc/toggle_ai(togglestatus)
	if(QDELETED(src))
		return
	if(!can_have_ai && (togglestatus != AI_OFF))
		return
	if (AIStatus != togglestatus)
		if (togglestatus > 0 && togglestatus < 5)
			GLOB.simple_animals[AIStatus] -= src
			GLOB.simple_animals[togglestatus] += src
			AIStatus = togglestatus
		else
			stack_trace("Something attempted to set simple animals AI to an invalid state: [togglestatus]")

///This proc is used for adding the swabbale element to mobs so that they are able to be biopsied and making sure holographic and butter-based creatures don't yield viable cells samples.
/mob/living/simple_animal/proc/add_cell_sample()
	return

/mob/living/simple_animal/relaymove(mob/living/user, direction)
	if(user.incapacitated)
		return
	return relaydrive(user, direction)

/mob/living/simple_animal/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	. = AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown, CALLBACK(src, PROC_REF(stop_deadchat_plays)))

	if(. == COMPONENT_INCOMPATIBLE)
		return

	stop_automated_movement = TRUE

/mob/living/simple_animal/proc/stop_deadchat_plays()
	stop_automated_movement = FALSE

/mob/living/simple_animal/proc/Goto(target, delay, minimum_distance)
	if(prevent_goto_movement)
		return FALSE
	GLOB.move_manager.move_to(src, target, minimum_distance, delay)
	return TRUE

//Makes this mob hunt the prey, be it living or an object. Will kill living creatures, and delete objects.
/mob/living/simple_animal/proc/hunt(hunted)
	if(src == hunted) //Make sure it doesn't eat itself. While not likely to ever happen, might as well check just in case.
		return
	stop_automated_movement = FALSE
	if(!isturf(src.loc)) // Are we on a proper turf?
		return
	if(stat || resting || buckled) // Are we conscious, upright, and not buckled?
		return
	if(!COOLDOWN_FINISHED(src, emote_cooldown)) // Has the cooldown on this ended?
		return
	if(!Adjacent(hunted) && Goto(hunted, 3, 0))
		stop_automated_movement = TRUE
		if(Adjacent(hunted))
			hunt(hunted) // In case it gets next to the target immediately, skip the scan timer and kill it.
		return
	if(isliving(hunted)) // Are we hunting a living mob?
		var/mob/living/prey = hunted
		if(inept_hunter) // Make your hunter inept to have them unable to catch their prey.
			visible_message(span_warning("[src] chases [prey] around, to no avail!"))
			step(prey, pick(GLOB.cardinals))
			COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
			return
		if(!(prey.stat))
			manual_emote("chomps [prey]!")
			prey.death()
			prey = null
			COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
			return
	else // We're hunting an object, and should delete it instead of killing it. Mostly useful for decal bugs like ants or spider webs.
		manual_emote("chomps [hunted]!")
		qdel(hunted)
		hunted = null
		COOLDOWN_START(src, emote_cooldown, 1 MINUTES)
		return

/mob/living/simple_animal/compare_sentience_type(compare_type)
	return sentience_type == compare_type
