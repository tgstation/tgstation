/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M)
	var/mob/the_mob = N
	if(!the_mob)
		the_mob = M // cause this doesn't get assigned if player is a latejoiner
	if(the_mob.client && the_mob.client.prefs && (the_mob.client.prefs.chosen_gear && the_mob.client.prefs.chosen_gear.len))
		if(!ishuman(M))//no silicons allowed
			return
		for(var/i in the_mob.client.prefs.chosen_gear)
			var/datum/gear/G = i
			G = GLOB.loadout_items[slot_to_string(initial(G.category))][initial(G.name)]
			if(!G)
				continue
			var/permitted = TRUE
			if(G.restricted_roles && G.restricted_roles.len && !(M.job in G.restricted_roles))
				permitted = FALSE
			if(!permitted)
				continue
			var/obj/item/I = new G.path
			if(!M.equip_to_slot_if_possible(I, G.category, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // Try to put it in its slot, first
				if(!M.equip_to_slot_if_possible(I, slot_in_backpack, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // If it fails, try to put it in the backpack
					I.forceMove(get_turf(M)) // If everything fails, just put it on the floor under the mob.