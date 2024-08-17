#define PET_CULT_ATTACK_UPPER 15
#define PET_CULT_HEALTH 50

/datum/element/cultist_pet
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///our pet cult icon's pathfile
	var/pet_cult_icon
	///our pet cult icon state
	var/pet_cult_icon_state

/datum/element/cultist_pet/Attach(datum/target, pet_cult_icon = 'icons/mob/simple/pets.dmi', pet_cult_icon_state)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.pet_cult_icon = pet_cult_icon
	src.pet_cult_icon_state = pet_cult_icon_state

	RegisterSignal(target, COMSIG_LIVING_CULT_SACRIFICED, PROC_REF(become_cultist))
	RegisterSignal(target, COMSIG_MOB_CLIENT_LOGIN, PROC_REF(on_login))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_icon_state_updated))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))

/datum/element/cultist_pet/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_MOB_LOGIN,
		COMSIG_LIVING_CULT_SACRIFICED,
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
	))

/datum/element/cultist_pet/proc/on_overlays_updated(mob/living/basic/source, list/overlays)
	SIGNAL_HANDLER

	if(isnull(source.mind) && (FACTION_CULT in source.faction)) //cult indicator we show for non sentient pets
		var/image/cult_indicator = image(icon = 'icons/mob/simple/pets.dmi', icon_state = "pet_cult_indicator", layer = ABOVE_GAME_PLANE)
		overlays += cult_indicator

/datum/element/cultist_pet/proc/on_icon_state_updated(mob/living/basic/source)
	SIGNAL_HANDLER

	if(pet_cult_icon_state && (FACTION_CULT in source.faction))
		source.icon_state = pet_cult_icon_state
		source.icon_living = pet_cult_icon_state

///turn into terrifying beasts
/datum/element/cultist_pet/proc/become_cultist(mob/living/basic/source, list/invokers, datum/team)
	SIGNAL_HANDLER

	if(source.stat == DEAD)
		return

	if(FACTION_CULT in source.faction)
		return STOP_SACRIFICE

	source.mind?.add_antag_datum(/datum/antagonist/cult, team)
	qdel(source.GetComponent(/datum/component/obeys_commands)) //if we obey commands previously, forget about them
	source.melee_damage_lower = max(PET_CULT_ATTACK_UPPER - 5, source::melee_damage_lower)
	source.melee_damage_upper = max(PET_CULT_ATTACK_UPPER, source::melee_damage_upper)
	source.maxHealth = max(PET_CULT_HEALTH, source::maxHealth)
	source.fully_heal()

	source.faction = list(FACTION_CULT) //we only serve the cult

	if(isnull(pet_cult_icon_state))
		source.add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

	var/static/list/cult_appetite = list(
		/obj/item/organ,
		/obj/effect/decal/cleanable/blood,
	)

	var/static/list/death_loot = list(
		/obj/effect/gibspawner/generic,
		/obj/item/soulstone,
	)

	source.AddElement(/datum/element/basic_eating, heal_amt = 15, food_types = cult_appetite)
	source.AddElement(/datum/element/death_drops, death_loot)

	source.basic_mob_flags &= DEL_ON_DEATH
	qdel(source.ai_controller)
	source.ai_controller = new /datum/ai_controller/basic_controller/pet_cult(source)
	var/datum/action/cooldown/spell/conjure/revive_rune/rune_ability = new(source)
	rune_ability.Grant(source)
	source.ai_controller.set_blackboard_key(BB_RUNE_ABILITY, rune_ability)
	source.ai_controller.set_blackboard_key(BB_CULT_TEAM, team)

	var/static/list/new_pet_commands = list(
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/follow,
		/datum/pet_command/free,
		/datum/pet_command/idle,
		/datum/pet_command/untargeted_ability/draw_rune,
	)
	source.AddComponent(/datum/component/obeys_commands, new_pet_commands)
	RegisterSignal(source, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(activate_rune))
	source.update_appearance()
	return STOP_SACRIFICE


/datum/element/cultist_pet/proc/activate_rune(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/effect/rune/raise_dead)) //we can only revive people...
		return NONE

	INVOKE_ASYNC(target, TYPE_PROC_REF(/atom, attack_hand), source)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/cultist_pet/proc/on_login(mob/living/source)
	SIGNAL_HANDLER

	if(!(FACTION_CULT in source.faction))
		return
	var/datum/team/cult_team = source.ai_controller.blackboard[BB_CULT_TEAM]
	if(isnull(cult_team))
		return
	source.mind.add_antag_datum(/datum/antagonist/cult, cult_team)
	source.update_appearance(UPDATE_OVERLAYS)


#undef PET_CULT_ATTACK_UPPER
#undef PET_CULT_HEALTH
