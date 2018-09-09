/datum/antagonist/gang
	name = "Family Member"
	roundend_category = "gangsters"
	var/gang_name = "Leet Like Jeff K"
	var/gang_id = "LLJK"
	var/datum/team/gang/my_gang
	var/list/acceptable_clothes = list()
	var/list/free_clothes = list()

/datum/antagonist/gang/get_team()
	return my_gang

/datum/antagonist/gang/proc/add_gang_points(var/points_to_add)
	if(my_gang)
		my_gang.adjust_points(points_to_add)

/datum/antagonist/gang/greet()
	to_chat(owner.current, "<B><font size=3 color=red>[gang_name] for life!</font></B>")
	to_chat(owner.current, "<B><font size=2 color=red>You're a member of the [gang_name] now!<br>Tag turf with a spraycan, wear your group's colors, and sell anything exportable on the Black Market at the Gang Signup Point!</font></B>")

/datum/antagonist/gang/red
	name = "San Fierro Triad"
	roundend_category = "San Fierro Triad gangsters"
	gang_name = "San Fierro Triad"
	gang_id = "SFT"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/neck/scarf/red,
							/obj/item/clothing/suit/jacket/letterman_red,
							/obj/item/clothing/under/color/red,
							/obj/item/clothing/mask/bandana/red)
	free_clothes = list(/obj/item/clothing/suit/jacket/letterman_red,
						/obj/item/clothing/under/color/red,
						/obj/item/toy/crayon/spraycan)

/datum/antagonist/gang/purple
	name = "Ballas"
	roundend_category = "Ballas gangsters"
	gang_name = "Ballas"
	gang_id = "B"
	acceptable_clothes = list(/obj/item/clothing/head/soft/purple,
							/obj/item/clothing/under/color/lightpurple,
							/obj/item/clothing/neck/scarf/purple,
							/obj/item/clothing/head/beanie/purple,
							/obj/item/clothing/suit/apron/purple_bartender,
							/obj/item/clothing/mask/bandana/skull)
	free_clothes = list(/obj/item/clothing/head/beanie/purple,
						/obj/item/clothing/under/color/lightpurple,
						/obj/item/toy/crayon/spraycan)

/datum/antagonist/gang/green
	name = "Grove Street Families"
	roundend_category = "Grove Street Families gangsters"
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

/datum/team/gang
	var/points = 0
	var/gang_id = "LLJK"
	var/list/acceptable_clothes = list()
	var/list/free_clothes = list()

/datum/team/gang/proc/adjust_points(var/points_to_adjust)
	points += points_to_adjust

/datum/team/gang/roundend_report()
	return "<div class='panel redborder'><br></div>"