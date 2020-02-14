/datum/antagonist/gang
	name = "Family Member"
	roundend_category = "gangsters"
	var/gang_name = "Leet Like Jeff K"
	var/gang_id = "LLJK"
	var/datum/team/gang/my_gang
	var/list/acceptable_clothes = list()
	var/list/free_clothes = list()
	var/datum/action/cooldown/spawn_induction_package/SIP = new()

/datum/antagonist/gang/apply_innate_effects(mob/living/mob_override)
	..()
	SIP.Grant(owner.current)
	SIP.my_gang_datum = src


/datum/antagonist/gang/remove_innate_effects(mob/living/mob_override)
	SIP.Remove(owner.current)
	..()


/datum/antagonist/gang/get_team()
	return my_gang

/datum/antagonist/gang/proc/add_gang_points(var/points_to_add)
	if(my_gang)
		my_gang.adjust_points(points_to_add)

/datum/antagonist/gang/greet()
	to_chat(owner.current, "<B><font size=3 color=red>[gang_name] for life!</font></B>")
	to_chat(owner.current, "<B><font size=2 color=red>You're a member of the [gang_name] now!<br>Tag turf with a spraycan, wear your group's colors, and recruit more gangsters with the Induction Packages!</font></B>")
	to_chat(owner.current, "<B><font size=4 color=red>Don't fuck with non-gangsters unless they fuck with you first.</font></B>")
	to_chat(owner.current, "<B><font size=4 color=red>Don't blow shit up or make the station uninhabitable.</font></B>")

/datum/antagonist/gang/red
	name = "San Fierro Triad"
	roundend_category = "San Fierro Triad gangsters"
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
							/obj/item/clothing/mask/bandana/skull,
							/obj/item/clothing/under/suit/green)
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

/datum/antagonist/gang/russian_mafia
	name = "Russian Mafia"
	roundend_category = "Russian mafiosos"
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

/datum/antagonist/gang/italian_mob
	name = "Italian Mob"
	roundend_category = "Italian mobsters"
	gang_name = "Italian Mob"
	gang_id = "IM"
	acceptable_clothes = list(/obj/item/clothing/under/suit/checkered,
							/obj/item/clothing/head/fedora,
							/obj/item/clothing/neck/scarf/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/head/fedora,
						/obj/item/clothing/under/suit/checkered,
						/obj/item/toy/crayon/spraycan)

/datum/antagonist/gang/tunnel_snakes
	name = "Tunnel Snakes"
	roundend_category = "Tunnel snakes"
	gang_name = "Tunnel Snakes"
	gang_id = "TS"
	acceptable_clothes = list(/obj/item/clothing/under/pants/classicjeans,
							/obj/item/clothing/suit/jacket,
							/obj/item/clothing/mask/bandana/skull)
	free_clothes = list(/obj/item/clothing/suit/jacket,
						/obj/item/clothing/under/pants/classicjeans,
						/obj/item/toy/crayon/spraycan)

/datum/antagonist/gang/vagos
	name = "Los Santos Vagos"
	roundend_category = "Los Santos Vagos gangsters"
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

/datum/antagonist/gang/henchmen
	name = "Monarch Crew"
	roundend_category = "Monarch henchmen"
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

/datum/antagonist/gang/yakuza
	name = "Tojo Clan"
	roundend_category = "Yakuza"
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

/datum/antagonist/gang/jackbros
	name = "Jack Bros"
	roundend_category = "Hee-hos"
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




/datum/team/gang
	var/points = 0
	var/gang_id = "LLJK"
	var/list/acceptable_clothes = list()
	var/list/free_clothes = list()

/datum/team/gang/proc/adjust_points(var/points_to_adjust)
	points += points_to_adjust

/datum/team/gang/roundend_report()
	return "<div class='panel redborder'><br></div>"

/datum/action/cooldown/spawn_induction_package
	name = "Create Induction Package"
	desc = "Generate an induction package for your family."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "recruit"
	icon_icon = 'icons/obj/gang/actions.dmi'
	cooldown_time = 300
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

	var/datum/game_mode/gang/mode = SSticker.mode
	var/lowest_gang_count = my_gang_datum.my_gang.members.len
	for(var/datum/team/gang/TT in mode.gangs)
		var/alive_gangsters = 0
		for(var/datum/mind/gangers in TT.members)
			if(ishuman(gangers) && gangers.current.client && !gangers.current.stat)
				alive_gangsters++
		if(alive_gangsters)
			if(TT != my_gang_datum.my_gang)
				if(alive_gangsters < lowest_gang_count)
					lowest_gang_count = alive_gangsters
	if(my_gang_datum.my_gang.members.len >= (lowest_gang_count + mode.gang_balance_cap))
		to_chat(H, "Your gang is pretty packed right now. You don't need more members just yet.")
		return FALSE
	to_chat(H, "You pull an induction package from your pockets and place it on the ground.")
	var/obj/item/gang_induction_package/GP = new(get_turf(H))
	GP.name = "[my_gang_datum.name] Signup Package"
	GP.gang_to_use = my_gang_datum.type
	GP.team_to_use = my_gang_datum.my_gang
	StartCooldown()
	return TRUE
