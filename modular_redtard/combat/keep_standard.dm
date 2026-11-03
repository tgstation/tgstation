// Ratwood's ducal standard (rogueweapons/melee/special.dm keep_standard) and its bearer's commands
// (roguejobs/garrison/manorguard/standard_bearer.dm). Held or carried by a man-at-arms, the standard's runes accept him:
// luck and perception, the calm of certainty, limbs hard to sever and a pace no wound slows. A Standard Bearer gets its
// four commands, each planting the standard for eight seconds at a cost of stamina (and energy): Plant calls to the guards in
// sight, Rally tells every guard where the standard stands, Recuperate mends and refreshes the guards in sight a little,
// Steady lightens their step. The runes mend the standard slowly. Ratwood's verbs of a "Standard" tab are TG actions here.
// Numbers in config/redtard/mechanics/values/combat.txt, "Weapons and gear".

#define STANDARD_MODIFIER "rogue_keep_standard"
#define STANDARD_MOOD "rogue_keep_standard"
#define STANDARD_RALLY_MOOD "rogue_keep_standard_lesser"
#define STANDARD_SOUND 'modular_redtard/rockhill/sound/combat/shieldraise.ogg'
#define STANDARD_PLANT "plant"
#define STANDARD_RALLY "rally"
#define STANDARD_RECUPERATE "recuperate"
#define STANDARD_STEADY "steady"

/obj/item/rogueweapon/spear/keep_standard
	/// Whom the runes accepted or turned away (Ratwood active_item).
	var/mob/living/carbon/human/rogue_bearer
	/// The runes accepted the holder as their master.
	var/rogue_bearer_accepted = FALSE
	/// The bearer's commands while he holds it.
	var/list/datum/action/item_action/rogue_standard/rogue_commands
	/// When the runes last mended the standard (Ratwood last_repair).
	var/rogue_last_mend = 0

/obj/item/rogueweapon/spear/keep_standard/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	if(rogue_bearer)
		rogue_release_bearer(rogue_bearer)
	return ..()

/obj/item/rogueweapon/spear/keep_standard/equipped(mob/user, slot, initial)
	. = ..()
	if(rogue_bearer || !ishuman(user))
		return
	rogue_bearer = user
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_bearer_deleted))
	if(rogue_bearer.mind?.assigned_role?.title != JOB_ROCKHILL_MAN_AT_ARMS)
		to_chat(user, span_suicide("The standard's runes pulse, rejecting me as its <b>master</b>."))
		return
	rogue_bearer_accepted = TRUE
	to_chat(user, span_notice("The standard's runes pulse, accepting me as its <b>master</b>."))
	rogue_bearer.attributes?.set_variable_attribute_modifier(STANDARD_MODIFIER, list(
		ROGUE_STAT_FORTUNE = rogue_value("standard_fortune"),
		ROGUE_STAT_PERCEPTION = rogue_value("standard_perception"),
	))
	rogue_bearer.add_mood_event(STANDARD_MOOD, /datum/mood_event/rogue_keep_standard)
	ADD_TRAIT(rogue_bearer, TRAIT_HARDDISMEMBER, REF(src))
	ADD_TRAIT(rogue_bearer, TRAIT_IGNOREDAMAGESLOWDOWN, REF(src))
	if(!HAS_TRAIT(rogue_bearer, TRAIT_STANDARD_BEARER))
		return
	to_chat(user, span_notice("<small>It remains ready for your word. You need only ask.</small>"))
	rogue_commands = list()
	for(var/command_type in subtypesof(/datum/action/item_action/rogue_standard))
		var/datum/action/item_action/rogue_standard/command = new command_type(src)
		command.Grant(rogue_bearer)
		rogue_commands += command

/obj/item/rogueweapon/spear/keep_standard/dropped(mob/user, silent)
	. = ..()
	if(user == rogue_bearer)
		rogue_release_bearer(user)

/obj/item/rogueweapon/spear/keep_standard/proc/on_bearer_deleted(datum/source)
	SIGNAL_HANDLER
	rogue_release_bearer(source)

/// Ratwood dropped(): the runes let go of their master and take back what they gave.
/obj/item/rogueweapon/spear/keep_standard/proc/rogue_release_bearer(mob/living/carbon/human/user)
	UnregisterSignal(user, COMSIG_QDELETING)
	QDEL_LIST(rogue_commands)
	rogue_commands = null
	var/accepted = rogue_bearer_accepted
	rogue_bearer = null
	rogue_bearer_accepted = FALSE
	if(QDELETED(user))
		return
	if(!accepted)
		to_chat(user, span_suicide("The standard's runes pulse, as if sighing in relief once I let go."))
		return
	to_chat(user, span_notice("The standard's runes pulse, rhythmically, as if sad to see you release your control."))
	user.attributes?.remove_attribute_modifier(STANDARD_MODIFIER)
	user.clear_mood_event(STANDARD_MOOD)
	REMOVE_TRAIT(user, TRAIT_HARDDISMEMBER, REF(src))
	REMOVE_TRAIT(user, TRAIT_IGNOREDAMAGESLOWDOWN, REF(src))
	if(HAS_TRAIT(user, TRAIT_STANDARD_BEARER))
		to_chat(user, span_warning("<small>You feel ill. Was that a mistake?</small>"))

/// Ratwood take_damage(): a hurt standard starts to mend itself.
/obj/item/rogueweapon/spear/keep_standard/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(!QDELETED(src) && get_integrity() < max_integrity)
		START_PROCESSING(SSobj, src)

/// Ratwood process(): a share of integrity back every few minutes until whole.
/obj/item/rogueweapon/spear/keep_standard/process(seconds_per_tick)
	if(get_integrity() >= max_integrity)
		visible_message(span_notice("[src] warps and bends, mending as the implement's runes pulse..."), vision_distance = 1)
		return PROCESS_KILL
	if(world.time > rogue_last_mend + rogue_value("standard_mend_time"))
		rogue_last_mend = world.time
		repair_damage(rogue_value("standard_mend_amount"))

/// One of the bearer's commands (Ratwood standard_position(), standard_rally(), standard_recuperate(), standard_steady()):
/// the stamina (and energy) first, then eight seconds planting the standard, then the command's effect.
/obj/item/rogueweapon/spear/keep_standard/proc/rogue_command(mob/living/carbon/human/bearer, command)
	if(bearer != rogue_bearer || DOING_INTERACTION(bearer, src))
		return
	bearer.adjust_stamina_loss(rand(rogue_value("standard_stamina_min"), rogue_value("standard_stamina_max")))
	switch(command)
		if(STANDARD_RECUPERATE)
			bearer.rogue_energy_add(-rogue_value("standard_recuperate_cost"))
		if(STANDARD_STEADY)
			bearer.rogue_energy_add(-rogue_value("standard_steady_cost"))
	bearer.manual_emote("plants the standard!")
	if(!do_after(bearer, rogue_value("standard_plant_time"), interaction_key = src) || bearer != rogue_bearer)
		return
	playsound(bearer.loc, STANDARD_SOUND, 100, FALSE, -1)
	var/sight = rogue_value("standard_sight")
	switch(command)
		if(STANDARD_PLANT)
			for(var/mob/living/carbon/human/guard in viewers(sight, bearer))
				if(HAS_TRAIT(guard, TRAIT_GUARDSMAN))
					to_chat(guard, span_notice("The standard calls out to me!"))
					guard.add_mood_event(STANDARD_RALLY_MOOD, /datum/mood_event/rogue_keep_standard_lesser)
		if(STANDARD_RALLY)
			// Ratwood orange(75): every guard but the bearer within reach on the same level.
			var/reach = rogue_value("standard_rally_range")
			for(var/mob/living/carbon/human/guard as anything in GLOB.human_list)
				if(guard != bearer && guard.z == bearer.z && get_dist(guard, bearer) <= reach && HAS_TRAIT(guard, TRAIT_GUARDSMAN))
					to_chat(guard, span_warning("The standard shrieks, pulling at my mind from [rogue_standard_whereabouts(guard, bearer)]."))
		if(STANDARD_RECUPERATE)
			for(var/mob/living/carbon/human/guard in viewers(sight, bearer))
				if(!HAS_TRAIT(guard, TRAIT_GUARDSMAN))
					continue
				to_chat(guard, span_notice("The standard eases my weary mind. I feel rested."))
				guard.apply_status_effect(/datum/status_effect/rogue_miracle_heal, rogue_value("standard_heal"))
				if(guard.rogue_energy < guard.rogue_max_energy)
					guard.rogue_energy_add(rogue_value("standard_energy_gift"))
		if(STANDARD_STEADY)
			for(var/mob/living/carbon/human/guard in viewers(sight, bearer))
				if(HAS_TRAIT(guard, TRAIT_GUARDSMAN))
					to_chat(guard, span_notice("The Standard assures that we'll step true. Lightly. Steady. Unlikely to set off traps and tricks."))
					guard.apply_status_effect(/datum/status_effect/rogue/standard_steady)

/// Ratwood standard_rally run_emote(): where the standard stands from the guard, the floors above or below and the direction.
/proc/rogue_standard_whereabouts(mob/living/guard, mob/living/bearer)
	var/floors
	if(guard.z != bearer.z)
		var/height = abs(guard.z - bearer.z)
		if(guard.z > bearer.z)
			floors = height > 1 ? "far below" : "below"
		else
			floors = height > 1 ? "far above" : "above"
	var/direction = dir2text(get_dir(guard, bearer))
	var/list/parts = list()
	if(floors)
		parts += "<b>[floors]</b>"
	if(direction)
		parts += "<b>[direction]</b>"
	return length(parts) ? jointext(parts, " and ") : "nearby"

/datum/action/item_action/rogue_standard
	name = "Standard"
	desc = "A command of the ducal standard."
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	var/command

/datum/action/item_action/rogue_standard/do_effect(trigger_flags)
	var/obj/item/rogueweapon/spear/keep_standard/standard = target
	var/mob/living/carbon/human/bearer = owner
	if(!istype(standard) || !istype(bearer))
		return FALSE
	INVOKE_ASYNC(standard, TYPE_PROC_REF(/obj/item/rogueweapon/spear/keep_standard, rogue_command), bearer, command)
	return TRUE

/datum/action/item_action/rogue_standard/plant
	name = "PLANT"
	desc = "Plant the standard: the guards in sight take heart."
	command = STANDARD_PLANT

/datum/action/item_action/rogue_standard/rally
	name = "RALLY"
	desc = "Plant the standard: every guard learns where it stands."
	command = STANDARD_RALLY

/datum/action/item_action/rogue_standard/recuperate
	name = "RECUPERATE"
	desc = "Plant the standard at a cost of energy: the guards in sight are mended a little and rested."
	command = STANDARD_RECUPERATE

/datum/action/item_action/rogue_standard/steady
	name = "STEADY"
	desc = "Plant the standard at a cost of energy: the guards in sight step lightly and luckily for a while."
	command = STANDARD_STEADY

/// Ratwood /datum/stressevent/keep_standard (stressadd -4, while held).
/datum/mood_event/rogue_keep_standard
	description = "The standard speaks of certainty."

/datum/mood_event/rogue_keep_standard/add_effects(...)
	mood_change = rogue_value("standard_mood")

/// Ratwood /datum/stressevent/keep_standard_lesser (stressadd -3 for three minutes).
/datum/mood_event/rogue_keep_standard_lesser
	description = "The standard calls out to me! It knows we're to see victory!"

/datum/mood_event/rogue_keep_standard_lesser/add_effects(...)
	mood_change = rogue_value("standard_plant_mood")
	timeout = rogue_value("standard_plant_mood_time")

/// Ratwood buff/standard_steady: a little luck and a light step for two minutes.
/datum/status_effect/rogue/standard_steady
	id = "rogue_standard_steady"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/rogue/standard_steady

/datum/status_effect/rogue/standard_steady/on_creation(mob/living/new_owner, set_duration)
	base_duration = rogue_value("standard_steady_duration")
	return ..()

/datum/status_effect/rogue/standard_steady/on_apply()
	. = ..()
	owner.attributes?.set_variable_attribute_modifier(id, list(ROGUE_STAT_FORTUNE = rogue_value("standard_steady_fortune")))
	ADD_TRAIT(owner, TRAIT_LIGHT_STEP, id)

/datum/status_effect/rogue/standard_steady/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	REMOVE_TRAIT(owner, TRAIT_LIGHT_STEP, id)
	return ..()

/atom/movable/screen/alert/status_effect/rogue/standard_steady
	name = "Steady"
	desc = "The Standard guides my steps. I can be sure of where I walk, trudging about with a lighter gait than I normally do..."
	icon_state = "buff"

#undef STANDARD_MODIFIER
#undef STANDARD_MOOD
#undef STANDARD_RALLY_MOOD
#undef STANDARD_SOUND
#undef STANDARD_PLANT
#undef STANDARD_RALLY
#undef STANDARD_RECUPERATE
#undef STANDARD_STEADY
