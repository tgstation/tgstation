/datum/controller/subsystem/job/proc/equip_loadout(mob/dead/new_player/N, mob/living/M, equipbackpackstuff)
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
			if(G.restricted_roles && G.restricted_roles.len && !(M.mind.assigned_role in G.restricted_roles))
				permitted = FALSE
			if(G.ckeywhitelist && G.ckeywhitelist.len && !(the_mob.client.ckey in G.ckeywhitelist))
				permitted = FALSE
			if(!equipbackpackstuff && G.category == SLOT_IN_BACKPACK)//snowflake check since plopping stuff in the backpack doesnt work for pre-job equip loadout stuffs
				permitted = FALSE
			if(equipbackpackstuff && G.category != SLOT_IN_BACKPACK)//ditto
				permitted = FALSE
			if(!permitted)
				continue
			var/obj/item/I = new G.path
			if(!M.equip_to_slot_if_possible(I, G.category, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // If the job's dresscode compliant, try to put it in its slot, first
				if(!M.equip_to_slot_if_possible(I, SLOT_IN_BACKPACK, disable_warning = TRUE, bypass_equip_delay_self = TRUE)) // Otherwise, try to put it in the backpack
					I.forceMove(get_turf(M)) // If everything fails, just put it on the floor under the mob.

/datum/controller/subsystem/job/proc/FreeRole(rank)
	if(!rank)
		return
	var/datum/job/job = GetJob(rank)
	if(!job)
		return FALSE
	job.current_positions = max(0, job.current_positions - 1)
