/mob/proc/add_spell(var/spell/spell_to_add, var/spell_base = "wiz_spell_ready", var/master_type = /obj/screen/movable/spell_master)
	if(!spell_masters)
		spell_masters = list()

	if(spell_masters.len)
		for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
			if(spell_master.type == master_type)
				spell_list.Add(spell_to_add)
				spell_master.add_spell(spell_to_add)
				return 1

	var/obj/screen/movable/spell_master/new_spell_master = new master_type //we're here because either we didn't find our type, or we have no spell masters to attach to
	if(client)
		src.client.screen += new_spell_master
	new_spell_master.spell_holder = src
	new_spell_master.add_spell(spell_to_add)
	if(spell_base)
		new_spell_master.icon_state = spell_base
	spell_masters.Add(new_spell_master)
	spell_list.Add(spell_to_add)
	return 1

/mob/proc/remove_spell(var/spell/spell_to_remove)
	if(!spell_to_remove || !istype(spell_to_remove))
		return

	if(!(spell_to_remove in spell_list))
		return

	if(!spell_masters || !spell_masters.len)
		return

	spell_list.Remove(spell_to_remove)
	for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.remove_spell(spell_to_remove)
	return 1

/mob/proc/silence_spells(var/amount = 0)
	if(!(amount >= 0))
		return

	if(!spell_masters || !spell_masters.len)
		return

	for(var/obj/screen/movable/spell_master/spell_master in spell_masters)
		spell_master.silence_spells(amount)
