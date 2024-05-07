#define PET_CULT_ATTACK 10
#define PET_CULT_HEALTH 50

///turn into terrifying beasts
/mob/living/basic/pet/proc/become_cultist(datum/source, list/invokers, datum/team)
	SIGNAL_HANDLER

	if(stat == DEAD || !can_cult_convert)
		return

	if(FACTION_CULT in faction)
		return STOP_SACRIFICE

	mind?.add_antag_datum(/datum/antagonist/cult, team)
	qdel(GetComponent(/datum/component/obeys_commands))
	melee_damage_lower = max(PET_CULT_ATTACK, initial(melee_damage_lower))
	melee_damage_upper = max(PET_CULT_ATTACK + 5, initial(melee_damage_upper))
	maxHealth = max(PET_CULT_HEALTH, initial(maxHealth))
	fully_heal()

	faction = list(FACTION_CULT) //we only serve the cult

	if(isnull(cult_icon_state))
		add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

	var/static/list/cult_appetite = list(
		/obj/item/organ,
		/obj/effect/decal/cleanable/blood,
	)

	var/static/list/death_loot = list(
		/obj/effect/gibspawner/generic,
		/obj/item/soulstone,
	)

	AddElement(/datum/element/basic_eating, heal_amt = 15, food_types = cult_appetite)
	AddElement(/datum/element/death_drops, death_loot)

	basic_mob_flags &= DEL_ON_DEATH
	qdel(ai_controller)
	ai_controller = new /datum/ai_controller/basic_controller/pet_cult(src)
	var/datum/action/cooldown/spell/conjure/revive_rune/rune_ability = new(src)
	rune_ability.Grant(src)
	ai_controller.set_blackboard_key(BB_RUNE_ABILITY, rune_ability)
	ai_controller.set_blackboard_key(BB_CULT_TEAM, team)

	var/static/list/new_pet_commands = list(
		/datum/pet_command/point_targeting/attack,
		/datum/pet_command/follow,
		/datum/pet_command/free,
		/datum/pet_command/idle,
		/datum/pet_command/untargeted_ability/draw_rune,
	)
	AddComponent(/datum/component/obeys_commands, new_pet_commands)
	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(activate_rune), override = TRUE)
	update_appearance()
	return STOP_SACRIFICE


/mob/living/basic/pet/proc/activate_rune(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!istype(target, /obj/effect/rune/raise_dead))
		return NONE

	target.attack_hand(src)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/mob/living/basic/pet/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	if(!(FACTION_CULT in faction))
		return
	var/datum/team/cult_team = locate(/datum/team/cult) in GLOB.antagonist_teams
	if(isnull(cult_team))
		return
	mind.add_antag_datum(/datum/antagonist/cult, cult_team)
	update_appearance(UPDATE_OVERLAYS)


#undef PET_CULT_ATTACK
#undef PET_CULT_HEALTH
