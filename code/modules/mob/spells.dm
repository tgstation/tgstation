/mob/proc/add_spell(var/spell/spell_to_add, var/spell_base = "wiz_spell_ready")
	if(!spell_master)
		spell_master = new
		if(spell_base)
			spell_master.icon_state = spell_base
		if(client)
			src.client.screen += spell_master
		spell_master.spell_holder = src

	spell_list.Add(spell_to_add)
	spell_master.add_spell(spell_to_add)
	return 1

/mob/proc/remove_spell(var/spell/spell_to_remove)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	if(!(spell_to_remove in spell_list))
		return

	if(!spell_master)
		return

	spell_list.Remove(spell_to_remove)
	spell_master.remove_spell(spell_to_remove)
	return 1

/mob/proc/silence_spells(var/amount = 0)
	if(!(amount >= 0))
		return

	if(!spell_master)
		return

	spell_master.silence_spells(amount)
