/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M)
	if(N.client && N.client.prefs && (N.client.prefs.chosen_gear && N.client.prefs.chosen_gear.len))
		for(var/i in N.client.prefs.chosen_gear)
			var/datum/gear/G = i
			G = GLOB.loadout_items[slot_to_string(initial(G.category))][initial(G.name)]
			if(!G)
				continue
			var/permitted = TRUE
			if(G.restricted_roles && G.restricted_roles.len && !(M.job in G.restricted_roles))
				permitted = FALSE
			if(!permitted)
				continue
			if(!M.equip_to_slot_or_del(new G.path, G.category))
				continue