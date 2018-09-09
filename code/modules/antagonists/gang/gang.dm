/datum/antagonist/gang
	name = "Gangster"
	roundend_category = "gang bangers"
	var/gang_name = "Tunnel Snakes"
	var/gang_id = "TS"
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
	to_chat(owner.current, "<B><font size=2 color=red>You're a member of the [gang_name] gang now!<br>Tag turf with a spraycan, wear your gang's colors, and sell narcotics and guns at the Gang Point!</font></B>")

/datum/antagonist/gang/red
	name = "San Fierro Triad"
	roundend_category = "San Fierro Triad gangsters"
	gang_name = "San Fierro Triad"
	gang_id = "SFT"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/under/color/red)
	free_clothes = list(/obj/item/clothing/head/soft/red,
						/obj/item/clothing/under/color/red)

/datum/antagonist/gang/purple
	name = "Ballas"
	roundend_category = "Ballas gangsters"
	gang_name = "Ballas"
	gang_id = "B"
	acceptable_clothes = list(/obj/item/clothing/head/soft/purple,
							/obj/item/clothing/under/color/lightpurple)
	free_clothes = list(/obj/item/clothing/head/soft/purple,
						/obj/item/clothing/under/color/lightpurple)

/datum/antagonist/gang/green
	name = "Grove Street Families"
	roundend_category = "Grove Street Families gangsters"
	gang_name = "Grove Street Families"
	gang_id = "GSF"
	acceptable_clothes = list(/obj/item/clothing/head/soft/green,
							/obj/item/clothing/under/color/darkgreen)
	free_clothes = list(/obj/item/clothing/head/soft/green,
						/obj/item/clothing/under/color/darkgreen)

/datum/team/gang
	var/points = 0
	var/gang_id = "LLJK"
	var/list/acceptable_clothes = list()
	var/list/free_clothes = list()

/datum/team/gang/proc/adjust_points(var/points_to_adjust)
	points += points_to_adjust

/datum/team/gang/roundend_report()
	return "<div class='panel redborder'><br></div>"