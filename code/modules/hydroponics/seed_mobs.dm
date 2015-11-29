/datum/seed
	var/product_requires_player // If yes, product will ask for a player among the ghosts.
	var/list/currently_querying // Used to avoid asking the same ghost repeatedly.
	var/searching = 0			// Are we currently looking for a ghost?

// The following procs are used to grab players for mobs produced by a seed (mostly for dionaea).
/datum/seed/proc/handle_living_product(var/mob/living/host)
	if(!host || !istype(host)) return

	if(!product_requires_player)
		return

	currently_querying = list()
	request_player(host)

	spawn(675)
		if(!host.ckey && !host.client)
			host.death()  // This seems redundant, but a lot of mobs don't
			host.stat = 2 // handle death() properly. Better safe than etc.
			host.visible_message("<span class='warning'><b>[host] is malformed and unable to survive. It expires pitifully, leaving behind some seeds.</span>")

			if(mob_drop)
				new mob_drop(get_turf(host))
			else
				var/obj/item/seeds/S = new(get_turf(host))
				S.seed_type = name
				S.update_seed()

//poll="Someone is harvesting [display_name]. Would you like to play as one?"

/datum/seed/proc/request_player(var/mob/living/host)
	if(!host)
		return

	searching = 1
	var/list/active_candidates = get_active_candidates(ROLE_PLANT)

	for(var/mob/dead/observer/O in active_candidates)
		if(!check_observer(O))
			continue

		currently_querying |= O
		to_chat(O, "<span class='recruit'>Someone is harvesting [display_name]. You have been added to the list of potential ghosts. (<a href='?src=\ref[O];jump=\ref[host]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>retract</a>)</span>")

	for(var/mob/dead/observer/O in dead_mob_list - active_candidates)
		if(!check_observer(O))
			continue

		to_chat(O, "<span class='recruit'>Someone is harvesting [display_name]. (<a href='?src=\ref[O];jump=\ref[host]'>Teleport</a> | <a href='?src=\ref[src];signup=\ref[O]'>Sign up</a>)</span>")

	spawn(600)
		if(!currently_querying || !currently_querying.len)
			return

		var/mob/dead/observer/O

		O = pick(currently_querying)
		while(currently_querying.len && !check_observer(O)) //While we the list has something and
			currently_querying -= O				//Remove them from the list if they don't get checked properly
			O = pick(currently_querying)

		if(!check_observer(O))
			return

		transfer_personality(O.client, host)

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

	to_chat(host, "<span class='good'><B>You awaken slowly, stirring into sluggish motion as the air caresses you.</B></span>")

	// This is a hack, replace with some kind of species blurb proc.
	if(istype(host,/mob/living/carbon/monkey/diona))
		to_chat(host, "<B>You are [host], one of a race of drifting interstellar plantlike creatures that sometimes share their seeds with human traders.</B>")
		to_chat(host, "<B>Too much darkness will send you into shock and starve you, but light will help you heal.</B>")

	var/newname = input(host,"Enter a name, or leave blank for the default name.", "Name change","") as text
	newname = copytext(sanitize(newname),1,MAX_NAME_LEN)
	if (newname != "")
		host.real_name = newname
		host.name = host.real_name

/datum/seed/Topic(var/href, var/list/href_list)
	if(href_list["signup"])
		var/mob/dead/observer/O = locate(href_list["signup"])
		if(!O)
			return

		volunteer(O)

/datum/seed/proc/volunteer(var/mob/dead/observer/O)
	if(!searching || !istype(O))
		return

	if(!check_observer(O))
		to_chat(O, "<span class='warning'>You cannot be [display_name].</span>")//Jobbanned or something.

		return

	if(O in currently_querying)
		to_chat(O, "<span class='notice'>Removed from registration list.</span>")
		currently_querying -= O
		return

	else
		to_chat(O, "<span class='notice'>Added to registration list.</span>")
		currently_querying += O
		return

/datum/seed/proc/check_observer(var/mob/dead/observer/O)
	if(O.has_enabled_antagHUD == 1 && config.antag_hud_restricted)
		return 0

	if(jobban_isbanned(O, "Dionaea") || (!is_alien_whitelisted(src, "Diona") && config.usealienwhitelist))
		return 0

	return O.client
