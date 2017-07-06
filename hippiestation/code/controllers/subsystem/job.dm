/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M)
	if(N.client && N.client.prefs && (N.client.prefs.chosen_gear && N.client.prefs.chosen_gear.len))
		to_chat(world, "B")
		for(var/i in N.client.prefs.chosen_gear)
			to_chat(world, "[i]")
			var/datum/gear/G = i
			G = GLOB.loadout_items[slot_to_string(initial(G.category))][initial(G.name)]
			if(!G)
				to_chat(world, "Aaaa")
				continue
			var/permitted = TRUE
			if(G.restricted_roles && G.restricted_roles.len && !(M.job in G.restricted_roles))
				permitted = FALSE
			if(!permitted)
				to_chat(N, "<span class='warning'>Your current job  does not permit you to spawn with [G.name]!</span>")
				continue
			if(!M.equip_to_slot_or_del(new G.path, G.category))
				to_chat(world, "AAAAAAAAAAAA[M.job]")
				continue