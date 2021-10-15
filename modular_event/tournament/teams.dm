GLOBAL_LIST_INIT_TYPED(tournament_teams, /datum/tournament_team, get_tournament_teams())

/// References a team in string/teams
/datum/tournament_team
	var/name
	var/toolbox_color
	var/list/roster = list()
	var/datum/outfit/outfit
	var/datum/outfit/camo_placeholder

/datum/tournament_team/proc/get_clients()
	var/list/clients = list()

	for (var/ckey in roster)
		var/client/client = GLOB.directory[ckey]
		if (istype(client))
			clients += client

	return clients

/proc/load_tournament_team(contents)
	var/datum/tournament_team/tournament_team = new

	var/list/data = json_decode(contents)
	if (!islist(data))
		return "Contents didn't return a list."

	var/name = data["name"]
	if (!istext(name))
		return "No name."
	tournament_team.name = name

	var/toolbox_color = data["toolbox_color"]
	if (!findtext(toolbox_color, GLOB.is_color))
		return "No toolbox_color provided."
	tournament_team.toolbox_color = toolbox_color

	var/list/roster = data["roster"]
	if (!islist(roster))
		return "No roster provided."

	for (var/key in roster)
		if (!istext(key))
			return "Invalid key in roster: [key]"

		tournament_team.roster += ckey(key)

	var/list/outfit_data = data["outfit"]
	if (!islist(outfit_data))
		return "No outfit provided."

	var/datum/outfit/outfit = new
	var/datum/outfit/camo_placeholder = new
	outfit.belt = text2path(outfit_data["belt"])
	if (outfit.belt)
		camo_placeholder.belt = /obj/item/storage/belt/chameleon
	outfit.ears = text2path(outfit_data["ears"])
	if (outfit.ears)
		camo_placeholder.ears = /obj/item/radio/headset/chameleon
	outfit.glasses = text2path(outfit_data["glasses"])
	if (outfit.glasses)
		camo_placeholder.glasses = /obj/item/clothing/glasses/chameleon
	outfit.gloves = text2path(outfit_data["gloves"])
	if (outfit.gloves)
		camo_placeholder.gloves = /obj/item/clothing/gloves/chameleon
	outfit.head = text2path(outfit_data["head"])
	if (outfit.head)
		camo_placeholder.head = /obj/item/clothing/head/chameleon
	outfit.mask = text2path(outfit_data["mask"])
	if (outfit.mask)
		camo_placeholder.mask = /obj/item/clothing/mask/chameleon
	outfit.neck = text2path(outfit_data["neck"])
	if (outfit.neck)
		camo_placeholder.neck = /obj/item/clothing/neck/chameleon
	outfit.shoes = text2path(outfit_data["shoes"])
	if (outfit.shoes)
		camo_placeholder.shoes = /obj/item/clothing/shoes/chameleon
	outfit.suit = text2path(outfit_data["suit"])
	if (outfit.suit)
		camo_placeholder.suit = /obj/item/clothing/suit/chameleon
	outfit.uniform = text2path(outfit_data["uniform"])
	if (outfit.uniform)
		camo_placeholder.uniform = /obj/item/clothing/under/chameleon

	tournament_team.camo_placeholder = camo_placeholder
	tournament_team.outfit = outfit

	return tournament_team

/proc/get_tournament_teams()
	var/list/tournament_teams = list()

	var/directory = "strings/teams/"
	for (var/team_filename in flist(directory))
		var/datum/tournament_team/tournament_team_result = load_tournament_team(file2text("[directory]/[team_filename]"))
		if (istype(tournament_team_result))
			tournament_teams[tournament_team_result.name] = tournament_team_result
		else
			log_game("FAILURE: Couldn't load [team_filename]: [tournament_team_result]")

	return tournament_teams
