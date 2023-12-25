#define PET_CULT_ATTACK 10
#define PET_CULT_HEALTH 50

///turn into terrifying beasts
/mob/living/basic/pet/proc/become_cultist()
	SIGNAL_HANDLER

	if(stat == DEAD || !can_cult_convert)
		return

	if(FACTION_CULT in faction)
		return STOP_SACRIFICE

	melee_damage_lower = max(PET_CULT_ATTACK, initial(melee_damage_lower))
	melee_damage_upper = max(PET_CULT_ATTACK + 5, initial(melee_damage_upper))
	maxHealth = max(PET_CULT_HEALTH, initial(maxHealth))
	fully_heal()
	//we only serve the cult
	faction = list(FACTION_CULT)

	if(cult_icon_state)
		update_appearance(UPDATE_ICON)
	else
		add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

	var/static/list/cult_appetite = list(
		/obj/item/organ,
		/obj/effect/decal/cleanable/blood,
	)

	var/static/list/death_loot = list(
		/obj/effect/gibspawner/generic,
		/obj/item/soulstone,
	)

	if(!HAS_TRAIT(src, TRAIT_MOB_EATER))
		AddElement(/datum/element/basic_eating, heal_amt = 15, food_types = cult_appetite)

	AddElement(/datum/element/death_drops, death_loot)

	basic_mob_flags &= DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/cultist_pet
	var/datum/action/cooldown/spell/conjure/convert_rune/rune_ability = new(src)
	rune_ability.Grant(src)
	ai_controller.set_blackboard_key(BB_RUNE_ABILITY, rune_ability)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(activate_rune))
	return STOP_SACRIFICE

#undef PET_CULT_ATTACK
#undef PET_CULT_HEALTH
