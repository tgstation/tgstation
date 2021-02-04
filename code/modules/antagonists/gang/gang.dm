/datum/antagonist/gang
	name = "Family Member"
	roundend_category = "gangsters"
	antag_hud_type = ANTAG_HUD_GANGSTER
	antag_hud_name = "hud_gangster"
	antagpanel_category = "Family"
	show_in_antagpanel = FALSE // i don't *think* this base class is buggy but it's too worthless to test
	/// The overarching family that the owner of this datum is a part of. Family teams are generic and imprinted upon by the per-person antagonist datums.
	var/datum/team/gang/my_gang
	/// The name of the family corresponding to this family member datum.
	var/gang_name = "Leet Like Jeff K"
	/// The abbreviation of the family corresponding to this family member datum.
	var/gang_id = "LLJK"
	/// The list of clothes that are acceptable to show allegiance to this family.
	var/list/acceptable_clothes = list()
	/// The list of clothes that are given to family members upon induction into the family.
	var/list/free_clothes = list()
	/// The action used to spawn family induction packages.
	var/datum/action/cooldown/spawn_induction_package/package_spawner = new()
	/// The textual description of the family's overarching objective.
	var/gang_objective = "Be super cool and stuff."
	/// Whether or not this family member is the first of their family.
	var/starter_gangster = FALSE

	/// A reference to the handler datum that manages the families gamemode. In case of no handler (admin-spawned during round), this will be null; this is fine.
	var/datum/gang_handler/handler

/datum/antagonist/gang/get_team()
	return my_gang

/datum/antagonist/gang/get_admin_commands()
	. = ..()
	.["Give extra equipment"] = CALLBACK(src,.proc/equip_gangster_in_inventory)

/datum/antagonist/gang/create_team(team_given) // gets called whenever add_antag_datum() is called on a mind
	if(team_given)
		my_gang = team_given
		return
	/* if team_given is falsey, this gang member didn't join a gang by using a recruitment package. so there are two things we need to consider
	1. does a gang handler exist -- does this round have a gang_handler instanced by the families gamemode or ruleset?
	2. does the gang we're trying to join already exist?
	if 1 is true and 2 is false, we were probably added by the gang_handler, and probably already have a "handler" var.
	if we don't have a "handler" var, and a gang_handler exists, we need to grab it, since our "handler" is null.
	if the gang exists, we need to join it; if the gang doesn't exist, we need to make it. */
	var/found_gang = FALSE
	if(!starter_gangster) // if they're a starter gangster according to the handler, we don't need to check this shit
		for(var/datum/team/gang/G in GLOB.antagonist_teams)
			if(G.my_gang_datum.handler) // if one of the gangs in the gang list has a handler, nab that
				handler = G.my_gang_datum.handler
			if(G.name == gang_name)
				my_gang = G
				found_gang = TRUE
				break
	if(!found_gang)
		var/new_gang = new /datum/team/gang()
		my_gang = new_gang
		if(handler) // if we have a handler, the handler should track this gang
			handler.gangs += my_gang
		my_gang.name = gang_name
		my_gang.gang_id = gang_id
		my_gang.acceptable_clothes = acceptable_clothes.Copy()
		my_gang.free_clothes = free_clothes.Copy()
		my_gang.my_gang_datum = src
		starter_gangster = TRUE

/datum/antagonist/gang/on_gain()
	if(starter_gangster)
		equip_gangster_in_inventory()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/thatshowfamiliesworks.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	..()

/datum/antagonist/gang/on_removal()
	if(my_gang.my_gang_datum == src) // if we're the first gangster, we need to replace ourselves so that objectives function correctly
		var/datum/antagonist/gang/replacement_datum = new type()
		replacement_datum.handler = handler
		replacement_datum.my_gang = my_gang
		my_gang.my_gang_datum = replacement_datum
		/* all we need to replace; the gang's "my_gang_datum" is just a person's datum because we assign it while we
		have that datum onhand. it would be easier if all of the code the gang team calls on its my_gang_datum was
		just in the team datum itself, and there were different types of teams instead of different types of gangster
		that imprint on generic teams, but i'm too lazy to refactor THAT too */
	..()

/datum/antagonist/gang/greet()
	to_chat(owner.current, "<B>As you're the first gangster, your uniform and spraycan are in your inventory!</B>")

	to_chat(owner.current, "<B><font size=3 color=red>[gang_name] for life!</font></B>")
	to_chat(owner.current, "<B><font size=2 color=red>You're a member of the [gang_name] now!<br>Tag turf with a spraycan, wear your group's colors, and recruit more gangsters with the Induction Packages!</font></B>")
	to_chat(owner.current, "<B><font size=6 color=red>You are still a team-oriented antagonist! Do what is best for your gang.</font></B>")
	to_chat(owner.current, "<B><font size=4 color=red>Beware, killing innocents will result in a stronger police response.</font></B>")
	to_chat(owner.current, "<B><font size=4 color=red>Family's Objective:</B> [gang_objective]</font>")

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	..()
	package_spawner.Grant(owner.current)
	package_spawner.my_gang_datum = src
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)
	if(M.hud_used)
		var/datum/hud/H = M.hud_used
		var/atom/movable/screen/wanted/giving_wanted_lvl = new /atom/movable/screen/wanted()
		H.wanted_lvl = giving_wanted_lvl
		giving_wanted_lvl.hud = H
		H.infodisplay += giving_wanted_lvl
		H.mymob.client.screen += giving_wanted_lvl

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	package_spawner.Remove(owner.current)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
	if(M.hud_used)
		var/datum/hud/H = M.hud_used
		H.infodisplay -= H.wanted_lvl
		QDEL_NULL(H.wanted_lvl)
	..()

/// Passes points gained to the family team.
/datum/antagonist/gang/proc/add_gang_points(points_to_add)
	if(my_gang)
		my_gang.adjust_points(points_to_add)

/// Determines if a gang has completed their special objective.
/datum/antagonist/gang/proc/check_gang_objective()
	return TRUE

/// Gives a gangster their equipment in their backpack and / or pockets.
/datum/antagonist/gang/proc/equip_gangster_in_inventory()
	if(istype(owner.current, /mob/living/carbon/human))
		for(var/C in my_gang.free_clothes)
			var/obj/O = new C(owner.current)
			var/list/slots = list (
				"backpack" = ITEM_SLOT_BACKPACK,
				"left pocket" = ITEM_SLOT_LPOCKET,
				"right pocket" = ITEM_SLOT_RPOCKET
			)
			var/mob/living/carbon/human/H = owner.current
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(owner.current, "Unfortunately, you could not bring your [O] to this shift. You will need to find one.")
				qdel(O)

/datum/team/gang
	/// The number of points this family has gained. Used for determining a victor if multiple families complete their objectives.
	var/points = 0
	/// The abbreviation of this family.
	var/gang_id = "LLJK"
	/// The list of clothes that are acceptable to show allegiance to this family.
	var/list/acceptable_clothes = list()
	/// The list of clothes that are given to family members upon induction into the family.
	var/list/free_clothes = list()
	/// The specific, occupied family member antagonist datum that is used to reach the handler / check objectives, and from which the above properties (sans points) are inherited.
	var/datum/antagonist/gang/my_gang_datum

/datum/team/gang/roundend_report()
	var/list/report = list()
	report += "<span class='header'>[name]:</span>"
	if(!members.len)
		report += "<span class='redtext'>The family was wiped out!</span>"
	else if(my_gang_datum.check_gang_objective())
		report += "<span class='greentext'>The family completed their objective!</span>"
	else
		report += "<span class='redtext big'>The family failed their objective!</span>"
	report += "Objective: [my_gang_datum.gang_objective]"
	report += "Points: [points]"
	if(members.len)
		report += "[my_gang_datum.roundend_category] were:"
		report += printplayerlist(members)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/// Adds points to the points var.
/datum/team/gang/proc/adjust_points(points_to_adjust)
	points += points_to_adjust

/datum/action/cooldown/spawn_induction_package
	name = "Create Induction Package"
	desc = "Generate an induction package for your family."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "recruit"
	icon_icon = 'icons/obj/gang/actions.dmi'
	cooldown_time = 300
	/// The family antagonist datum of the "owner" of this action.
	var/datum/antagonist/gang/my_gang_datum

/datum/action/cooldown/spawn_induction_package/Trigger()
	if(!..())
		return FALSE
	if(!IsAvailable())
		return FALSE
	if(!my_gang_datum)
		return FALSE
	if(!istype(owner, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(H.stat)
		return FALSE

	var/gang_balance_cap // we need some stuff to fall back on if we're handlerless
	if(my_gang_datum.handler)
		gang_balance_cap = my_gang_datum.handler.gang_balance_cap
	else
		gang_balance_cap = 5 //just a filler default value

	var/lowest_gang_count = my_gang_datum.my_gang.members.len
	for(var/datum/team/gang/TT in GLOB.antagonist_teams)
		var/alive_gangsters = 0
		for(var/datum/mind/gangers in TT.members)
			if(ishuman(gangers.current) && gangers.current.client && !gangers.current.stat)
				alive_gangsters++
		if(!alive_gangsters || TT.members.len <= 1) // Dead or inactive gangs don't count towards the cap.
			continue
		if(TT != my_gang_datum.my_gang)
			if(alive_gangsters < lowest_gang_count)
				lowest_gang_count = alive_gangsters
	if(my_gang_datum.my_gang.members.len >= (lowest_gang_count + gang_balance_cap))
		to_chat(H, "Your gang is pretty packed right now. You don't need more members just yet. If the other families expand, you can recruit more members.")
		return FALSE
	to_chat(H, "You pull an induction package from your pockets and place it on the ground.")
	var/obj/item/gang_induction_package/GP = new(get_turf(H))
	GP.name = "\improper [my_gang_datum.name] signup package"
	GP.handler = my_gang_datum.handler
	GP.gang_to_use = my_gang_datum.type
	GP.team_to_use = my_gang_datum.my_gang
	StartCooldown()
	return TRUE

/datum/antagonist/gang/red
	show_in_antagpanel = TRUE
	name = "San Fierro Triad"
	roundend_category = "The San Fierro Triad gangsters"
	gang_name = "San Fierro Triad"
	gang_id = "SFT"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/neck/scarf/red,
							/obj/item/clothing/suit/jacket/letterman_red,
							/obj/item/clothing/under/color/red,
							/obj/item/clothing/mask/bandana/red,
							/obj/item/clothing/under/suit/red)
	free_clothes = list(/obj/item/clothing/suit/jacket/letterman_red,
						/obj/item/clothing/under/color/red,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "The Spinward Stellar Coalition police intend to interfere with our operations, by sending undercover cops. Find them and eliminate them all."
	antag_hud_name = "Triad"

/datum/antagonist/gang/red/check_gang_objective()
	for(var/C in get_antag_minds(/datum/antagonist/ert/families/undercover_cop))
		var/datum/mind/M = C
		var/mob/living/carbon/human/H = M.current
		if(considered_alive(H))
			return FALSE
	return TRUE

/datum/antagonist/gang/purple
	show_in_antagpanel = TRUE
	name = "Ballas"
	roundend_category = "The Ballas gangsters"
	gang_name = "Ballas"
	gang_id = "B"
	acceptable_clothes = list(/obj/item/clothing/head/soft/purple,
							/obj/item/clothing/under/color/lightpurple,
							/obj/item/clothing/neck/scarf/purple,
							/obj/item/clothing/head/beanie/purple,
							/obj/item/clothing/suit/apron/purple_bartender,
							/obj/item/clothing/mask/bandana/skull,
							/obj/item/clothing/under/suit/green)
	free_clothes = list(/obj/item/clothing/head/beanie/purple,
						/obj/item/clothing/under/color/lightpurple,
						/obj/item/toy/crayon/spraycan)
	var/list/cop_roles = list("Security Officer", "Warden", "Detective", "Head of Security")
	gang_objective = "We're looking to make a deal with the security pigs on this station after the shift. We scratch their back, they scratch ours. You feel me? Keep all of security safe from any trouble, and make sure they get out alive."
	antag_hud_name = "Ballas"

/datum/antagonist/gang/purple/check_gang_objective()
	for(var/mob/M in GLOB.player_list)
		if(M.mind.assigned_role in cop_roles)
			if(!considered_alive(M) && !M.suiciding)
				return FALSE
	return TRUE

/datum/antagonist/gang/green
	show_in_antagpanel = TRUE
	name = "Grove Street Families"
	roundend_category = "The Grove Street Families gangsters"
	gang_name = "Grove Street Families"
	gang_id = "GSF"
	acceptable_clothes = list(/obj/item/clothing/head/soft/green,
							/obj/item/clothing/under/color/darkgreen,
							/obj/item/clothing/neck/scarf/green,
							/obj/item/clothing/head/beanie/green,
							/obj/item/clothing/suit/poncho/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/mask/bandana/green,
						/obj/item/clothing/under/color/darkgreen,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "We lost a lot of territory recently. We gotta get that shit back. Make sure 45 rooms are tagged for Grove Street."
	antag_hud_name = "Grove"

/datum/antagonist/gang/green/check_gang_objective()
	var/tag_amount = 0
	for(var/T in GLOB.gang_tags)
		var/obj/effect/decal/cleanable/crayon/gang/tag = T
		if(tag.my_gang.gang_id == gang_id)
			tag_amount++
	if(tag_amount >= 45)
		return TRUE
	return FALSE

/datum/antagonist/gang/russian_mafia
	show_in_antagpanel = TRUE
	name = "Russian Mafia"
	roundend_category = "The Russian mafiosos"
	gang_name = "Russian Mafia"
	gang_id = "RM"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/neck/scarf/red,
							/obj/item/clothing/under/suit/white,
							/obj/item/clothing/head/beanie/red,
							/obj/item/clothing/head/ushanka)
	free_clothes = list(/obj/item/clothing/head/ushanka,
						/obj/item/clothing/under/suit/white,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "We are starting to run low on supplies at the home base, my friend. Make sure every comrade has a bottle of some kind of booze on them, friend."
	antag_hud_name = "Russian"

/datum/antagonist/gang/russian_mafia/check_gang_objective()
	for(var/R in get_antag_minds(/datum/antagonist/gang/russian_mafia))
		var/datum/mind/M = R
		if(!considered_alive(M.current))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.current.GetAllContents()
		for(var/I in items_to_check)
			var/obj/IT = I
			if(istype(IT, /obj/item/reagent_containers/food/drinks/bottle))
				continue
		return FALSE // didnt pass the bottle check, no point in continuing to loop
	return TRUE

/datum/antagonist/gang/italian_mob
	show_in_antagpanel = TRUE
	name = "Italian Mob"
	roundend_category = "The Italian mobsters"
	gang_name = "Italian Mob"
	gang_id = "IM"
	acceptable_clothes = list(/obj/item/clothing/under/suit/checkered,
							/obj/item/clothing/head/fedora,
							/obj/item/clothing/neck/scarf/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/head/fedora,
						/obj/item/clothing/under/suit/checkered,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "The boss wants it made very clear that all our esteemed members are to be held with respect. If a friend falls, ensure they are properly buried with a coffin. And keep any Chaplains alive, to ensure the corpses are properly taken care of."
	antag_hud_name = "Italian"

/datum/antagonist/gang/italian_mob/check_gang_objective()
	for(var/I in get_antag_minds(/datum/antagonist/gang/italian_mob))
		var/datum/mind/M = I
		if(M.has_antag_datum(src.type))
			if(considered_alive(M.current))
				continue
			if(istype(M.current.loc, /obj/structure/closet/crate/coffin))
				continue
			return FALSE
	for(var/mob/M in GLOB.player_list)
		if(M.mind.assigned_role == "Chaplain")
			if(!considered_alive(M) && !M.suiciding)
				return FALSE
	return TRUE

/datum/antagonist/gang/tunnel_snakes
	show_in_antagpanel = TRUE
	name = "Tunnel Snakes"
	roundend_category = "The Tunnel Snakes"
	gang_name = "Tunnel Snakes"
	gang_id = "TS"
	acceptable_clothes = list(/obj/item/clothing/under/pants/classicjeans,
							/obj/item/clothing/suit/jacket,
							/obj/item/clothing/mask/bandana/skull)
	free_clothes = list(/obj/item/clothing/suit/jacket,
						/obj/item/clothing/under/pants/classicjeans,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "TUNNEL SNAKES RULE!!! Make sure that everyone knows that, by getting 25% of people on station to wear any part of our uniform! TUNNEL SNAKES RULE!!!"
	antag_hud_name = "Snakes"

/datum/antagonist/gang/tunnel_snakes/check_gang_objective()
	var/people_on_station = 0
	var/people_reppin_tunnel_snakes = 0
	for(var/mob/M in GLOB.player_list)
		if(!considered_alive(M))
			continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			people_on_station++
			for(var/clothing in list(H.head, H.wear_mask, H.wear_suit, H.w_uniform, H.back, H.gloves, H.shoes, H.belt, H.s_store, H.glasses, H.ears, H.wear_id))
				if(is_type_in_list(clothing, acceptable_clothes))
					people_reppin_tunnel_snakes++
	if(0.25*people_on_station > people_reppin_tunnel_snakes)
		return FALSE
	return TRUE

/datum/antagonist/gang/vagos
	show_in_antagpanel = TRUE
	name = "Los Santos Vagos"
	roundend_category = "The Los Santos Vagos gangsters"
	gang_name = "Los Santos Vagos"
	gang_id = "LSV"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/color/yellow,
							/obj/item/clothing/neck/scarf/yellow,
							/obj/item/clothing/head/beanie/yellow,
							/obj/item/clothing/mask/bandana/gold)
	free_clothes = list(/obj/item/clothing/mask/bandana/gold,
						/obj/item/clothing/under/color/yellow,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "Orders from up high. We need to up our drug operation. Ensure that at least 25% of the station is addicted to meth."
	antag_hud_name = "Vagos"

/datum/antagonist/gang/vagos/check_gang_objective()
	var/people_on_station = 0
	var/people_on_crack = 0
	for(var/mob/M in GLOB.player_list)
		if(!considered_alive(M))
			continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			people_on_station++
			for(var/R in H.reagents.addiction_list)
				if(istype(R, /datum/reagent/drug/methamphetamine))
					people_on_crack++
	if(0.25*people_on_station > people_on_crack)
		return FALSE
	return TRUE

/datum/antagonist/gang/henchmen
	show_in_antagpanel = TRUE
	name = "Monarch Crew"
	roundend_category = "The Monarch henchmen"
	gang_name = "Monarch Crew"
	gang_id = "HENCH"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/suit/henchmen,
							/obj/item/clothing/neck/scarf/yellow,
							/obj/item/clothing/head/beanie/yellow,
							/obj/item/clothing/mask/bandana/gold,
							/obj/item/storage/backpack/henchmen)
	free_clothes = list(/obj/item/storage/backpack/henchmen,
						/obj/item/clothing/under/suit/henchmen,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "I have it on VERY GOOD AUTHORITY that the Research Director on this station helped Venture on a science project back in college! ENSURE THAT HE DOES NOT LEAVE THIS STATION ALIVE, HENCHMEN! THE MIGHTY MONARCH DEMANDS IT!!!"
	antag_hud_name = "Monarch"

/datum/antagonist/gang/henchmen/check_gang_objective() // gotta arch dr. venture indirectly
	for(var/mob/M in GLOB.player_list)
		if(M.mind.assigned_role == "Research Director")
			if(considered_alive(M))
				return FALSE
	return TRUE

/datum/antagonist/gang/yakuza
	show_in_antagpanel = TRUE
	name = "Tojo Clan"
	roundend_category = "The Yakuza"
	gang_name = "Tojo Clan"
	gang_id = "YAK"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/costume/yakuza,
							/obj/item/clothing/shoes/yakuza,
							/obj/item/clothing/neck/scarf/yellow,
							/obj/item/clothing/head/beanie/yellow,
							/obj/item/clothing/mask/bandana/gold,
							/obj/item/clothing/head/hardhat,
							/obj/item/clothing/suit/yakuza)
	free_clothes = list(/obj/item/clothing/under/costume/yakuza,
						/obj/item/clothing/shoes/yakuza,
						/obj/item/clothing/suit/yakuza,
						/obj/item/clothing/head/hardhat,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "The boss is thrilled about this new construction opportunity we've all been given, yadda yadda, look, he knows we're here to expand our business ventures for the clan, but Majima wanted it made VERY clear that we do NOT fuck this station's infrastructure up. If more than 15% of this station is busted when we get the hell out of here, it's your ass on the line."
	antag_hud_name = "Tojo"

/datum/antagonist/gang/yakuza/check_gang_objective()
	var/datum/station_state/current_state = new /datum/station_state()
	current_state.count()
	var/station_integrity = min(PERCENT(GLOB.start_state.score(current_state)), 100)
	if(station_integrity < 85)
		return FALSE
	return TRUE

/datum/antagonist/gang/jackbros
	show_in_antagpanel = TRUE
	name = "Jack Bros"
	roundend_category = "The Hee-hos"
	gang_name = "Jack Bros"
	gang_id = "JB"
	acceptable_clothes = list(/obj/item/clothing/head/soft/blue,
							/obj/item/clothing/under/costume/jackbros,
							/obj/item/clothing/shoes/jackbros,
							/obj/item/clothing/head/jackbros,
							/obj/item/clothing/mask/bandana/blue)
	free_clothes = list(/obj/item/clothing/under/costume/jackbros,
						/obj/item/clothing/shoes/jackbros,
						/obj/item/clothing/head/jackbros,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "Hee-hello friends! We need to expand our influence, ho! Get a King Frost in as the Captain of this joint! Either get the original Captain on board with the program, or Hee-ho a fellow Jack Frost into the position yourselves!"
	antag_hud_name = "JackFrost"

/datum/antagonist/gang/jackbros/check_gang_objective()
	for(var/J in get_antag_minds(/datum/antagonist/gang/jackbros))
		var/datum/mind/M = J
		if(!considered_alive(M.current))
			continue // dead people cant really do the objective lol
		if(ishuman(M.current))
			var/mob/living/carbon/human/H = M.current
			if(H.get_assignment() == "Captain")
				return TRUE
	return FALSE

/datum/antagonist/gang/dutch
	show_in_antagpanel = TRUE
	name = "Dutch van der Linde's Gang"
	roundend_category = "Dutch's outlaws"
	gang_name = "Dutch van der Linde's Gang"
	gang_id = "VDL"
	acceptable_clothes = list(/obj/item/clothing/head/soft/black,
							/obj/item/clothing/under/costume/dutch,
							/obj/item/clothing/suit/dutch,
							/obj/item/clothing/head/bowler,
							/obj/item/clothing/mask/bandana/black)
	free_clothes = list(/obj/item/clothing/under/costume/dutch,
						/obj/item/clothing/head/bowler,
						/obj/item/clothing/suit/dutch,
						/obj/item/toy/crayon/spraycan)
	gang_objective = "Listen here, fellas. I have a plan. Just one more score on this crappy little po-dunk station. Gold bars, friends. Get all the gold out of the silos, and leave nothing behind! Spread the gold amongst yourselves for the escape plan, make sure everyone has at least 1 bar. After this, it'll be space mangos at Tahiti. You just gotta have a little faith."
	antag_hud_name = "Dutch"

/datum/antagonist/gang/dutch/check_gang_objective()
	for(var/D in get_antag_minds(/datum/antagonist/gang/dutch))
		var/datum/mind/M = D
		if(!considered_alive(M.current))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.current.GetAllContents()
		for(var/I in items_to_check)
			var/obj/IT = I
			if(istype(IT, /obj/item/stack/sheet/mineral/gold))
				continue
		return FALSE // didnt pass the bar check, no point in continuing to loop
	var/obj/machinery/ore_silo/S = GLOB.ore_silo_default
	var/datum/component/material_container/mat_container = S.GetComponent(/datum/component/material_container)
	if(mat_container.materials[GET_MATERIAL_REF(/datum/material/gold)] >= 2000) // if theres at least 1 bar of gold left in the silo, they've failed to heist all of it
		return FALSE
	return TRUE
