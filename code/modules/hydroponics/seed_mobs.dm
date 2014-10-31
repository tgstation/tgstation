/datum/seed
	var/product_requires_player // If yes, product will ask for a player among the ghosts.
	var/list/currently_querying // Used to avoid asking the same ghost repeatedly.

// The following procs are used to grab players for mobs produced by a seed (mostly for dionaea).
/datum/seed/proc/handle_living_product(var/mob/living/host)

	if(!host || !istype(host)) return

	if(product_requires_player)
		spawn(0)
			request_player(host)
		spawn(75)
			if(!host.ckey && !host.client)
				host.death()  // This seems redundant, but a lot of mobs don't
				host.stat = 2 // handle death() properly. Better safe than etc.
				host.visible_message("\red <b>[host] is malformed and unable to survive. It expires pitifully, leaving behind some seeds.")

				var/total_yield = rand(1,3)
				for(var/j = 0;j<=total_yield;j++)
					var/obj/item/seeds/S = new(get_turf(host))
					S.seed_type = name
					S.update_seed()

/datum/seed/proc/request_player(var/mob/living/host)
	if(!host) return
	for(var/mob/dead/observer/O in player_list)
		if(jobban_isbanned(O, "Dionaea") || (!is_alien_whitelisted(src, "Diona") && config.usealienwhitelist))
			continue
		if(O.client)
			if(O.client.prefs.be_special & BE_PLANT && !(O.client in currently_querying))
				currently_querying |= O.client
				question(O.client,host)

/datum/seed/proc/question(var/client/C,var/mob/living/host)
	spawn(0)

		if(!C || !host || !(C.mob && istype(C.mob,/mob/dead))) return // We don't want to spam them repeatedly if they're already in a mob.

		var/response = alert(C, "Someone is harvesting [display_name]. Would you like to play as one?", "Sentient plant harvest", "Yes", "No", "Never for this round.")

		if(!C || !host || !(C.mob && istype(C.mob,/mob/dead))) return // ...or accidentally accept an invalid argument for transfer.

		if(response == "Yes")
			transfer_personality(C,host)
		else if (response == "Never for this round")
			C.prefs.be_special ^= BE_PLANT

		currently_querying -= C

/datum/seed/proc/transfer_personality(var/client/player,var/mob/living/host)

	//Something is wrong, abort.
	if(!player || !host) return

	//Host already has a controller, pike off slowpoke.
	if(host.client && host.ckey) return

	//Transfer them over.
	host.ckey = player.ckey
	if(player.mob && player.mob.mind)
		player.mob.mind.transfer_to(host)

	if(host.dna) host.dna.real_name = host.real_name

	// Update mode specific HUD icons.
	callHook("harvest_podman", list(host))

	host << "\green <B>You awaken slowly, stirring into sluggish motion as the air caresses you.</B>"

	// This is a hack, replace with some kind of species blurb proc.
	if(istype(host,/mob/living/carbon/monkey/diona))
		host << "<B>You are [host], one of a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>"
		host << "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>"

	var/newname = input(host,"Enter a name, or leave blank for the default name.", "Name change","") as text
	newname = sanitize(newname)
	if (newname != "")
		host.real_name = newname
		host.name = host.real_name