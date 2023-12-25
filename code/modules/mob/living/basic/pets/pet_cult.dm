#define PET_CULT_ATTACK 10
#define PET_CULT_HEALTH 50

///turn into terrifying beasts
/mob/living/basic/pet/proc/become_cultist()
	SIGNAL_HANDLER

	if(stat == DEAD)
		return

	if(FACTION_CULT in faction)
		return STOP_SACRIFICE

	melee_damage_lower = max(PET_CULT_ATTACK, initial(melee_damage_lower))
	melee_damage_upper = max(PET_CULT_ATTACK + 5, initial(melee_damage_upper))
	maxHealth = max(PET_CULT_HEALTH, initial(maxHealth))
	heal_overall_damage(maxHealth * 0.75)
	//we only serve the cult
	faction = list(FACTION_CULT)
	if(cult_icon_state)
		update_appearance(UPDATE_ICON)
	else
		add_atom_colour(COLOR_DARK_RED, FIXED_COLOUR_PRIORITY)
	return STOP_SACRIFICE

