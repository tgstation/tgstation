/datum/antagonist/gang
	name = "\improper Family Member"
	roundend_category = "gangsters"
	ui_name = "AntagInfoGangmember"
	antag_hud_name = "hud_gangster"
	antagpanel_category = "Family"
	show_in_antagpanel = FALSE // i don't *think* this base class is buggy but it's too worthless to test
	suicide_cry = "FOR THE FAMILY!!"
	preview_outfit = /datum/outfit/gangster
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
	/// The gangster's original real name. Used for renaming stuff, kept between gang switches.
	var/original_name
	/// Type of team to create when creating the gang in the first place. Used for renames.
	var/gang_team_type = /datum/team/gang

	/// A reference to the handler datum that manages the families gamemode. In case of no handler (admin-spawned during round), this will be null; this is fine.
	var/datum/gang_handler/handler

/datum/outfit/gangster
	name = "Gangster (Preview only)"

	uniform = /obj/item/clothing/under/suit/henchmen
	back = /obj/item/storage/backpack/henchmen

/datum/antagonist/gang/get_team()
	return my_gang

/datum/antagonist/gang/get_admin_commands()
	. = ..()
	.["Give extra equipment"] = CALLBACK(src, .proc/equip_gangster_in_inventory)
	if(!starter_gangster)
		.["Make Leader"] = CALLBACK(src, .proc/make_gangster_leader)

/datum/antagonist/gang/proc/make_gangster_leader()
	if(starter_gangster)
		return
	starter_gangster = TRUE
	package_spawner.Grant(owner.current)
	package_spawner.my_gang_datum = src
	my_gang.rename_gangster(owner, original_name, TRUE) // gives them the leader name

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
	for(var/datum/team/gang/gang_team in GLOB.antagonist_teams)
		if(gang_team.my_gang_datum.handler) // if one of the gangs in the gang list has a handler, nab that
			handler = gang_team.my_gang_datum.handler
		if(gang_team.name == gang_name)
			my_gang = gang_team
			found_gang = TRUE
			break
	if(!found_gang)
		var/new_gang = new gang_team_type()
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
	if(!original_name)
		original_name = owner.current.real_name
	my_gang.rename_gangster(owner, original_name, starter_gangster) // fully_replace_character_name
	if(starter_gangster)
		equip_gangster_in_inventory()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/thatshowfamiliesworks.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	add_objectives()
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

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	..()
	if(starter_gangster)
		package_spawner.Grant(owner.current)
		package_spawner.my_gang_datum = src
	add_team_hud(mob_override || owner.current, /datum/antagonist/gang)

/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	if(starter_gangster)
		package_spawner.Remove(owner.current)
	..()

/// Used to display gang objectives in the player's traitor panel
/datum/antagonist/gang/proc/add_objectives()
	var/datum/objective/objective = new ()
	objective.explanation_text = my_gang.current_theme.gang_objectives[type]
	objectives.Add(objective)

/// Gives a gangster their equipment in their backpack and / or pockets.
/datum/antagonist/gang/proc/equip_gangster_in_inventory()
	if(istype(owner.current, /mob/living/carbon/human))
		var/obj/item/gangster_cellphone/phone = new()
		phone.gang_id = gang_name
		phone.name = "[gang_name] branded cell phone"
		var/mob/living/carbon/human/gangster_human = owner.current
		var/phone_equipped = phone.equip_to_best_slot(gangster_human)
		if(!phone_equipped)
			to_chat(owner.current, "Your [phone.name] has been placed at your feet.")
			phone.forceMove(get_turf(gangster_human))
		for(var/clothing in my_gang.free_clothes)
			var/obj/item/clothing_object = new clothing(owner.current)
			var/equipped = clothing_object.equip_to_best_slot(gangster_human)
			if(!equipped)
				to_chat(owner.current, "Your [clothing_object.name] has been placed at your feet.")
				clothing_object.forceMove(get_turf(gangster_human))
		if(my_gang.current_theme.bonus_items)
			for(var/bonus_item in my_gang.current_theme.bonus_items)
				var/obj/item/bonus_object = new bonus_item(owner.current)
				var/equipped = bonus_object.equip_to_best_slot(gangster_human)
				if(!equipped)
					to_chat(owner.current, "Your [bonus_object.name] has been placed at your feet.")
					bonus_object.forceMove(get_turf(gangster_human))
		if(starter_gangster)
			if(my_gang.current_theme.bonus_first_gangster_items)
				for(var/bonus_starter_item in my_gang.current_theme.bonus_first_gangster_items)
					var/obj/item/bonus_starter_object = new bonus_starter_item(owner.current)
					var/equipped = bonus_starter_object.equip_to_best_slot(gangster_human)
					if(!equipped)
						to_chat(owner.current, "Your [bonus_starter_object.name] has been placed at your feet.")
						bonus_starter_object.forceMove(get_turf(gangster_human))

/datum/antagonist/gang/ui_static_data(mob/user)
	var/list/data = list()
	data["gang_name"] = gang_name
	data["antag_name"] = name
	data["gang_objective"] = my_gang.current_theme.gang_objectives[type]

	var/list/clothes_we_can_wear = list()
	for(var/obj/item/accepted_item as anything in acceptable_clothes)
		clothes_we_can_wear |= initial(accepted_item.name)

	for(var/obj/item/free_item as anything in free_clothes)
		if(ispath(free_item, /obj/item/toy/crayon/spraycan))
			continue
		clothes_we_can_wear |= initial(free_item.name)

	data["gang_clothes"] = clothes_we_can_wear
	return data

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

/// Allow gangs to have custom naming schemes for their gangsters.
/datum/team/gang/proc/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/team/gang/roundend_report()
	var/list/report = list()
	report += "<span class='header'>[name]:</span>"
	if(!members.len)
		report += span_redtext("The family was wiped out!")
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
	name = "Induct via Secret Handshake"
	desc = "Teach new recruits the Secret Handshake to join."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "recruit"
	icon_icon = 'icons/obj/gang/actions.dmi'
	cooldown_time = 300
	/// The family antagonist datum of the "owner" of this action.
	var/datum/antagonist/gang/my_gang_datum

/datum/action/cooldown/spawn_induction_package/Activate(atom/target)
	if(!my_gang_datum)
		CRASH("[type] was created without a linked gang datum!")

	if(!ishuman(owner))
		return FALSE

	StartCooldown(10 SECONDS)
	offer_handshake()
	StartCooldown()
	return TRUE

/*
 * Equip a handshake slapper and offer it to people nearby.
 */
/datum/action/cooldown/spawn_induction_package/proc/offer_handshake()
	var/mob/living/carbon/human/human_owner = owner
	if(human_owner.stat != CONSCIOUS || human_owner.incapacitated())
		return FALSE

	var/obj/item/slapper/secret_handshake/secret_handshake_item = new(owner)
	if(owner.put_in_hands(secret_handshake_item))
		to_chat(owner, span_notice("You ready your secret handshake."))
	else
		qdel(secret_handshake_item)
		to_chat(owner, span_warning("You're incapable of performing a handshake in your current state."))
		return FALSE
	owner.visible_message(
		span_notice("[human_owner] is offering to induct people into the Family."),
		span_notice("You offer to induct people into the Family."),
		null,
		2,
		)
	if(human_owner.has_status_effect(STATUS_EFFECT_HANDSHAKE))
		return FALSE
	if(!(locate(/mob/living/carbon) in orange(1, owner)))
		owner.visible_message(
			span_danger("[human_owner] offers to induct people into the Family, but nobody was around."),
			span_warning("You offer to induct people into the Family, but nobody is around."),
			null,
			2,
			)
		return FALSE

	human_owner.apply_status_effect(STATUS_EFFECT_HANDSHAKE, secret_handshake_item)
	return TRUE

/datum/antagonist/gang/russian_mafia
	show_in_antagpanel = TRUE
	name = "\improper Mafioso"
	roundend_category = "The mafiosos"
	gang_name = "Mafia"
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
	gang_team_type = /datum/team/gang/russian_mafia

/datum/team/gang/russian_mafia/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Don [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/italian_mob
	show_in_antagpanel = TRUE
	name = "Mobster"
	roundend_category = "The mobsters"
	gang_name = "Mob"
	gang_id = "IM"
	acceptable_clothes = list(/obj/item/clothing/under/suit/checkered,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/neck/scarf/green,
		/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/suit/checkered,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Italian"
	gang_team_type = /datum/team/gang/italian_mob

/datum/team/gang/italian_mob/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Boss [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/tunnel_snakes
	show_in_antagpanel = TRUE
	name = "\improper Tunnel Snake"
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
	gang_team_type = /datum/team/gang/tunnel_snakes

/datum/team/gang/tunnel_snakes/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "King Cobra [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/henchmen
	show_in_antagpanel = TRUE
	name = "Monarch Henchmen"
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
	gang_team_type = /datum/team/gang/henchmen

/datum/team/gang/henchmen
	var/henchmen_count = 0

/datum/team/gang/henchmen/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	henchmen_count++
	gangster.current.fully_replace_character_name(gangster.current.real_name, "Number [henchmen_count]")

/datum/antagonist/gang/yakuza
	show_in_antagpanel = TRUE
	name = "\improper Tojo Clan Member"
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
	gang_team_type = /datum/team/gang/yakuza

/datum/team/gang/yakuza/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Patriarch [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/jackbros
	show_in_antagpanel = TRUE
	name = "\improper Jack Bro"
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
	gang_team_type = /datum/team/gang/jackbros

/datum/team/gang/jackbros/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "King Frost [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)


/datum/antagonist/gang/dutch
	show_in_antagpanel = TRUE
	name = "Dutch van der Linde Outlaw"
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
	gang_team_type = /datum/team/gang/dutch

/datum/team/gang/dutch/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Head Cowboy [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)


/datum/antagonist/gang/irs
	show_in_antagpanel = TRUE
	name = "\improper Internal Revenue Service Agent"
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
	gang_team_type = /datum/team/gang/irs

/datum/team/gang/irs/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Revenue Supervisor [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Revenue Agent [last_name.match]")

/datum/antagonist/gang/osi
	show_in_antagpanel = TRUE
	name = "\improper Office of Secret Intelligence Agent"
	roundend_category = "O.S.I. Agents"
	gang_name = "Office of Secret Intelligence"
	gang_id = "OSI"
	acceptable_clothes = list(/obj/item/clothing/suit/osi,
		/obj/item/clothing/under/costume/osi,
		/obj/item/clothing/glasses/osi)
	free_clothes = list(/obj/item/clothing/suit/osi,
		/obj/item/clothing/under/costume/osi,
		/obj/item/clothing/glasses/osi,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "OSI"
	gang_team_type = /datum/team/gang/osi

/datum/team/gang/osi/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "General [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Special Agent [last_name.match]")

/datum/antagonist/gang/tmc
	show_in_antagpanel = TRUE
	name = "\improper Lost M.C. Biker"
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
	gang_team_type = /datum/team/gang/tmc

/datum/team/gang/tmc/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "President [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/pg
	show_in_antagpanel = TRUE
	name = "\improper Powder Ganger"
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
	gang_team_type = /datum/team/gang/pg

/datum/team/gang/pg/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Head Convict [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)


/datum/antagonist/gang/driscoll
	show_in_antagpanel = TRUE
	name = "\improper O'Driscoll Gangster"
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
	gang_team_type = /datum/team/gang/driscoll

/datum/team/gang/driscoll/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Head Outlaw [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/deckers
	show_in_antagpanel = TRUE
	name = "\improper Decker"
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
	gang_team_type = /datum/team/gang/deckers

/datum/team/gang/deckers/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Master Hacker [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)


/datum/antagonist/gang/morningstar
	show_in_antagpanel = TRUE
	name = "\improper Morningstar Member"
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
	gang_team_type = /datum/team/gang/morningstar

/datum/team/gang/morningstar/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Chief Executive Officer [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/saints
	show_in_antagpanel = TRUE
	name = "\improper Third Street Saints Gangster"
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
	gang_team_type = /datum/team/gang/saints

/datum/team/gang/saints/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Boss [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)


/datum/antagonist/gang/phantom
	show_in_antagpanel = TRUE
	name = "\improper Phantom Thief"
	roundend_category = "Phantom Thieves"
	gang_name = "Phantom Thieves of Hearts"
	gang_id = "PT"
	acceptable_clothes = list(/obj/item/clothing/suit/phantom,
		/obj/item/clothing/under/costume/phantom,
		/obj/item/clothing/glasses/phantom,
		/obj/item/clothing/shoes/phantom)
	free_clothes = list(/obj/item/clothing/suit/phantom,
		/obj/item/clothing/under/costume/phantom,
		/obj/item/clothing/glasses/phantom,
		/obj/item/clothing/shoes/phantom,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "PhantomThieves"
	gang_team_type = /datum/team/gang/phantom

/datum/team/gang/phantom/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Joker [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/allies
	show_in_antagpanel = TRUE
	name = "\improper Allies G.I."
	roundend_category = "Allies"
	gang_name = "Allies"
	gang_id = "ALLIES"
	free_clothes = list(/obj/item/clothing/suit/allies,
		/obj/item/clothing/under/costume/allies,
		/obj/item/clothing/head/allies,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Allies"
	gang_team_type = /datum/team/gang/allies

/datum/team/gang/allies/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Commander [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Private [last_name.match]")

/datum/antagonist/gang/soviet
	show_in_antagpanel = TRUE
	name = "\improper Soviet Conscript"
	roundend_category = "Soviets"
	gang_name = "Soviets"
	gang_id = "SOV"
	free_clothes = list(/obj/item/clothing/suit/soviet,
		/obj/item/clothing/under/costume/soviet_families,
		/obj/item/clothing/head/ushanka/soviet,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "Soviets"
	gang_team_type = /datum/team/gang/soviet

/datum/team/gang/soviet/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Comrade General [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Conscript [last_name.match]")

/datum/antagonist/gang/yuri
	show_in_antagpanel = TRUE
	name = "\improper Yuri Initiate"
	roundend_category = "Yuri's Army"
	gang_name = "Yuri's Army"
	gang_id = "YR"
	free_clothes = list(/obj/item/clothing/suit/yuri,
		/obj/item/clothing/under/costume/yuri,
		/obj/item/clothing/head/yuri,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "YuriArmy"
	gang_team_type = /datum/team/gang/yuri

/datum/team/gang/yuri/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Initiate Prime [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Initiate [last_name.match]")

/datum/antagonist/gang/sybil_slickers
	show_in_antagpanel = TRUE
	name = "\improper Sybil Slicker"
	roundend_category = "Sybil Slickers"
	gang_name = "Sybil Slickers"
	gang_id = "SS"
	free_clothes = list(/obj/item/clothing/suit/sybil_slickers,
		/obj/item/clothing/under/costume/sybil_slickers,
		/obj/item/clothing/head/sybil_slickers,
		/obj/item/clothing/gloves/tackler/football,
		/obj/item/clothing/shoes/sybil_slickers,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "SybilSlickers"
	gang_team_type = /datum/team/gang/sybil_slickers

/datum/team/gang/sybil_slickers/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Sybil Coach [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)

/datum/antagonist/gang/basil_boys
	show_in_antagpanel = TRUE
	name = "\improper Basil Boy"
	roundend_category = "Basil Boys"
	gang_name = "Basil Boys"
	gang_id = "BB"
	free_clothes = list(/obj/item/clothing/suit/basil_boys,
		/obj/item/clothing/under/costume/basil_boys,
		/obj/item/clothing/head/basil_boys,
		/obj/item/clothing/gloves/tackler/football,
		/obj/item/clothing/shoes/basil_boys,
		/obj/item/toy/crayon/spraycan)
	antag_hud_name = "BasilBoys"
	gang_team_type = /datum/team/gang/basil_boys

/datum/team/gang/basil_boys/rename_gangster(datum/mind/gangster, original_name, starter_gangster)
	var/static/regex/last_name = new("\[^\\s-\]+$") //First word before whitespace or "-"
	last_name.Find(original_name)
	if(starter_gangster)
		gangster.current.fully_replace_character_name(gangster.current.real_name, "Basil Coach [last_name.match]")
	else
		gangster.current.fully_replace_character_name(gangster.current.real_name, original_name)
