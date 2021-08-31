/datum/antagonist/gang
	name = "Family Member"
	roundend_category = "gangsters"
	antag_hud_type = ANTAG_HUD_GANGSTER
	antag_hud_name = "hud_gangster"
	antagpanel_category = "Family"
	show_in_antagpanel = FALSE // i don't *think* this base class is buggy but it's too worthless to test
	suicide_cry = "FOR THE FAMILY!!"
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
			my_gang.current_theme = handler.current_theme
		my_gang.name = gang_name
		my_gang.gang_id = gang_id
		my_gang.acceptable_clothes = acceptable_clothes.Copy()
		my_gang.free_clothes = free_clothes.Copy()
		my_gang.my_gang_datum = src
		starter_gangster = TRUE

/datum/antagonist/gang/on_gain()
	if(starter_gangster)
		equip_gangster_in_inventory()
	var/datum/atom_hud/H = GLOB.huds[ANTAG_HUD_GANGSTER]
	H.add_hud_to(owner.current)
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
	var/datum/atom_hud/H = GLOB.huds[ANTAG_HUD_GANGSTER]
	H.remove_hud_from(owner.current)
	..()

/datum/antagonist/gang/greet()
	to_chat(owner.current, "<B>As you're the first gangster, your uniform and spraycan are in your inventory!</B>")

	to_chat(owner.current, "<B><font size=3 color=red>[gang_name] for life!</font></B>")
	to_chat(owner.current, "<B><font size=2 color=red>You're a member of the [gang_name] now!<br>Tag turf with a spraycan, wear your group's colors, and recruit more gangsters with the Induction Packages!</font></B>")
	to_chat(owner.current, "<B><font size=6 color=red>You are still a team-oriented antagonist! Do what is best for your gang.</font></B>")
	to_chat(owner.current, "<B><font size=6 color=red>You are still a team-oriented antagonist! Do what is best for your gang and it's objective.</font></B>")
	var/assigned_objective = my_gang.current_theme.gang_objectives[src.type]
	if(!assigned_objective)
		assigned_objective = "ERROR, FILE A REPORT WITH THIS INFO: Gang Name: [gang_name], Theme Name: [my_gang.current_theme.name]"
	to_chat(owner.current, "<B><font size=4 color=red>Family's Objective:</B> [assigned_objective]</font>")

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	..()
	package_spawner.Grant(owner.current)
	package_spawner.my_gang_datum = src
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	package_spawner.Remove(owner.current)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
	..()

/// Gives a gangster their equipment in their backpack and / or pockets.
/datum/antagonist/gang/proc/equip_gangster_in_inventory()
	if(istype(owner.current, /mob/living/carbon/human))
		var/list/slots = list (
			"backpack" = ITEM_SLOT_BACKPACK,
			"left pocket" = ITEM_SLOT_LPOCKET,
			"right pocket" = ITEM_SLOT_RPOCKET,
			"hands" = ITEM_SLOT_HANDS
		)
		for(var/clothing in my_gang.free_clothes)
			var/obj/O = new clothing(owner.current)
			var/mob/living/carbon/human/H = owner.current
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(owner.current, "Your [O] has been placed at your feet.")
				O.forceMove(get_turf(H))
		for(var/bonus_item in my_gang.current_theme.bonus_items)
			var/obj/O = new bonus_item(owner.current)
			var/mob/living/carbon/human/H = owner.current
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(owner.current, "Your [O] has been placed at your feet.")
				O.forceMove(get_turf(H))
		for(var/bonus_starter_item in my_gang.current_theme.bonus_first_gangster_items)
			var/obj/O = new bonus_starter_item(owner.current)
			var/mob/living/carbon/human/H = owner.current
			var/equipped = H.equip_in_one_of_slots(O, slots)
			if(!equipped)
				to_chat(owner.current, "Your [O] has been placed at your feet.")
				O.forceMove(get_turf(H))
/datum/team/gang
	/// The abbreviation of this family.
	var/gang_id = "LLJK"
	/// The list of clothes that are acceptable to show allegiance to this family.
	var/list/acceptable_clothes = list()
	/// The list of clothes that are given to family members upon induction into the family.
	var/list/free_clothes = list()
	/// The specific, occupied family member antagonist datum that is used to reach the handler / check objectives, and from which the above properties (sans points) are inherited.
	var/datum/antagonist/gang/my_gang_datum
	/// The current theme. Used to pull important stuff such as spawning equipment and objectives.
	var/datum/gang_theme/current_theme

/datum/team/gang/roundend_report()
	var/list/report = list()
	report += "<span class='header'>[name]:</span>"
	if(!members.len)
		report += "<span class='redtext'>The family was wiped out!</span>"
	if(current_theme.everyone_objective)
		report += "Objective: [current_theme.everyone_objective]"
	else
		var/assigned_objective = current_theme.gang_objectives[my_gang_datum.type]
		if(assigned_objective)
			report += "Objective: [assigned_objective]"
		else
			report += "Objective: ERROR, FILE A REPORT WITH THIS INFO: Gang Name: [my_gang_datum.name], Theme Name: [current_theme.name]"
	if(members.len)
		report += "[my_gang_datum.roundend_category] were:"
		report += printplayerlist(members)

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

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
	antag_hud_name = "Triad"

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
	antag_hud_name = "Ballas"

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
	antag_hud_name = "Grove"

/datum/antagonist/gang/russian_mafia
	show_in_antagpanel = TRUE
	name = "The Mafia"
	roundend_category = "The mafiosos"
	gang_name = "The Mafia"
	gang_id = "RM"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/neck/scarf/red,
							/obj/item/clothing/under/suit/white,
							/obj/item/clothing/head/beanie/red,
							/obj/item/clothing/head/ushanka)
	free_clothes = list(/obj/item/clothing/head/ushanka,
						/obj/item/clothing/under/suit/white,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Russian"

/datum/antagonist/gang/italian_mob
	show_in_antagpanel = TRUE
	name = "The Mob"
	roundend_category = "The mobsters"
	gang_name = "The Mob"
	gang_id = "IM"
	acceptable_clothes = list(/obj/item/clothing/under/suit/checkered,
							/obj/item/clothing/head/fedora,
							/obj/item/clothing/neck/scarf/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/head/fedora,
						/obj/item/clothing/under/suit/checkered,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Italian"


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
	antag_hud_name = "Snakes"

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
	antag_hud_name = "Vagos"

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
	antag_hud_name = "Monarch"

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
	antag_hud_name = "Tojo"

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
	antag_hud_name = "JackFrost"

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
	antag_hud_name = "Dutch"

/datum/antagonist/gang/irs
	show_in_antagpanel = TRUE
	name = "Internal Revenue Service Agent"
	roundend_category = "IRS Agents"
	gang_name = "Internal Revenue Service"
	gang_id = "IRS"
	acceptable_clothes = list(/obj/item/clothing/suit/irs,
							/obj/item/clothing/under/costume/irs,
							/obj/item/clothing/head/irs)
	free_clothes = list(/obj/item/clothing/suit/irs,
							/obj/item/clothing/under/costume/irs,
							/obj/item/clothing/head/irs,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "IRS"

/datum/antagonist/gang/osi
	show_in_antagpanel = TRUE
	name = "Office of Secret Intelligence Agent"
	roundend_category = "O.S.I. Agents"
	gang_name = "Office of Secret Intelligence"
	gang_id = "OSI"
	acceptable_clothes = list(/obj/item/clothing/suit/osi,
							/obj/item/clothing/under/costume/osi,
							/obj/item/clothing/glasses/sunglasses/osi)
	free_clothes = list(/obj/item/clothing/suit/osi,
							/obj/item/clothing/under/costume/osi,
							/obj/item/clothing/glasses/sunglasses/osi,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "OSI"

/datum/antagonist/gang/tmc
	show_in_antagpanel = TRUE
	name = "The Lost M.C. Biker"
	roundend_category = "Lost M.C. Bikers"
	gang_name = "The Lost M.C."
	gang_id = "TMC"
	acceptable_clothes = list(/obj/item/clothing/suit/tmc,
							/obj/item/clothing/under/costume/tmc,
							/obj/item/clothing/head/tmc)
	free_clothes = list(/obj/item/clothing/suit/tmc,
							/obj/item/clothing/under/costume/tmc,
							/obj/item/clothing/head/tmc,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "LostMC"

/datum/antagonist/gang/pg
	show_in_antagpanel = TRUE
	name = "Powder Ganger"
	roundend_category = "Powder Gangers"
	gang_name = "Powder Gangers"
	gang_id = "PG"
	acceptable_clothes = list(/obj/item/clothing/suit/pg,
							/obj/item/clothing/under/costume/pg,
							/obj/item/clothing/head/pg)
	free_clothes = list(/obj/item/clothing/suit/pg,
							/obj/item/clothing/under/costume/pg,
							/obj/item/clothing/head/pg,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "PowderGang"

/datum/antagonist/gang/driscoll
	show_in_antagpanel = TRUE
	name = "O'Driscoll Gangster"
	roundend_category = "O'Driscoll's Gangsters"
	gang_name = "O'Driscoll's Gang"
	gang_id = "DB"
	acceptable_clothes = list(/obj/item/clothing/suit/driscoll,
							/obj/item/clothing/under/costume/driscoll,
							/obj/item/clothing/mask/gas/driscoll,
							/obj/item/clothing/shoes/cowboy)
	free_clothes = list(/obj/item/clothing/suit/driscoll,
							/obj/item/clothing/under/costume/driscoll,
							/obj/item/clothing/mask/gas/driscoll,
							/obj/item/clothing/shoes/cowboy,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Drill"


/datum/antagonist/gang/deckers
	show_in_antagpanel = TRUE
	name = "Decker"
	roundend_category = "Deckers"
	gang_name = "Deckers"
	gang_id = "DK"
	acceptable_clothes = list(/obj/item/clothing/suit/deckers,
							/obj/item/clothing/under/costume/deckers,
							/obj/item/clothing/head/deckers,
							/obj/item/clothing/shoes/deckers)
	free_clothes = list(/obj/item/clothing/suit/deckers,
							/obj/item/clothing/under/costume/deckers,
							/obj/item/clothing/head/deckers,
							/obj/item/clothing/shoes/deckers,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Deckers"

/datum/antagonist/gang/morningstar
	show_in_antagpanel = TRUE
	name = "Morningstar Member"
	roundend_category = "Morningstar Member"
	gang_name = "Morningstar"
	gang_id = "MS"
	acceptable_clothes = list(/obj/item/clothing/suit/morningstar,
							/obj/item/clothing/under/costume/morningstar,
							/obj/item/clothing/head/morningstar,
							/obj/item/clothing/shoes/morningstar)
	free_clothes = list(/obj/item/clothing/suit/morningstar,
							/obj/item/clothing/under/costume/morningstar,
							/obj/item/clothing/head/morningstar,
							/obj/item/clothing/shoes/morningstar,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "MorningStar"

/datum/antagonist/gang/saints
	show_in_antagpanel = TRUE
	name = "Third Street Saints Gangster"
	roundend_category = "Third Street Saints Gangsters"
	gang_name = "Third Street Saints"
	gang_id = "TSS"
	acceptable_clothes = list(/obj/item/clothing/suit/saints,
							/obj/item/clothing/under/costume/saints,
							/obj/item/clothing/head/saints,
							/obj/item/clothing/shoes/saints)
	free_clothes = list(/obj/item/clothing/suit/saints,
							/obj/item/clothing/under/costume/saints,
							/obj/item/clothing/head/saints,
							/obj/item/clothing/shoes/saints,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "TheSaints"

/datum/antagonist/gang/phantom
	show_in_antagpanel = TRUE
	name = "Phantom Thief"
	roundend_category = "Phantom Thieves"
	gang_name = "Phantom Thieves of Hearts"
	gang_id = "PT"
	acceptable_clothes = list(/obj/item/clothing/suit/phantom,
							/obj/item/clothing/under/costume/phantom,
							/obj/item/clothing/glasses/sunglasses/phantom,
							/obj/item/clothing/shoes/phantom)
	free_clothes = list(/obj/item/clothing/suit/phantom,
							/obj/item/clothing/under/costume/phantom,
							/obj/item/clothing/glasses/sunglasses/phantom,
							/obj/item/clothing/shoes/phantom,
						/obj/item/toy/crayon/spraycan)
	antag_hud_name = "PhantomThieves"
