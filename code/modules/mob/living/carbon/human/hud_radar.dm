
/*

Radar-related things

*/

/mob/living/carbon/human/proc/close_radar()
	radar_open = 0
	for(var/obj/screen/x in client.screen)
		if( (x.name == "radar" && x.icon == 'radar.dmi') || (x in radar_blips) )
			client.screen -= x
			del(x)

	place_radar_closed()

/mob/living/carbon/human/proc/place_radar_closed()
	var/obj/screen/closedradar = new()
	closedradar.icon = 'radar.dmi'
	closedradar.icon_state = "radarclosed"
	closedradar.screen_loc = "WEST,NORTH-1"
	closedradar.name = "radar closed"
	client.screen += closedradar

/mob/living/carbon/human/proc/start_radar()

	for(var/obj/screen/x in client.screen)
		if(x.name == "radar closed" && x.icon == 'radar.dmi')
			client.screen -= x
			del(x)

	var/obj/screen/cornerA = new()
	cornerA.icon = 'radar.dmi'
	cornerA.icon_state = "radar(1,1)"
	cornerA.screen_loc = "WEST,NORTH-2"
	cornerA.name = "radar"

	var/obj/screen/cornerB = new()
	cornerB.icon = 'radar.dmi'
	cornerB.icon_state = "radar(2,1)"
	cornerB.screen_loc = "WEST+1,NORTH-2"
	cornerB.name = "radar"

	var/obj/screen/cornerC = new()
	cornerC.icon = 'radar.dmi'
	cornerC.icon_state = "radar(1,2)"
	cornerC.screen_loc = "WEST,NORTH-1"
	cornerC.name = "radar"

	var/obj/screen/cornerD = new()
	cornerD.icon = 'radar.dmi'
	cornerD.icon_state = "radar(2,2)"
	cornerD.screen_loc = "WEST+1,NORTH-1"
	cornerD.name = "radar"

	client.screen += cornerA
	client.screen += cornerB
	client.screen += cornerC
	client.screen += cornerD

	radar_open = 1

	while(radar_open && (RADAR in augmentations))
		update_radar()
		sleep(6)

/mob/living/carbon/human/proc/update_radar()

	if(!client) return
	var/list/found_targets = list()

	var/max_dist = 29 // 29 tiles is the max distance

	// If the mob is inside a turf, set the center to the object they're in
	var/atom/distance_ref = src
	if(!isturf(src.loc))
		distance_ref = loc

	// Clear the radar_blips cache
	for(var/x in radar_blips)
		client.screen -= x
		del(x)
	radar_blips = list()

	var/starting_px = 3
	var/starting_py = 3

	for(var/mob/living/M in orange(max_dist, distance_ref))
		if(M.stat == 2) continue
		found_targets.Add(M)

	for(var/obj/effect/critter/C in orange(max_dist, distance_ref))
		if(!C.alive) continue
		found_targets.Add(C)

	for(var/obj/mecha/M in orange(max_dist, distance_ref))
		if(!M.occupant) continue
		found_targets.Add(M)

	for(var/obj/structure/closet/C in orange(max_dist, distance_ref))
		for(var/mob/living/M in C.contents)
			if(M.stat == 2) continue
			found_targets.Add(M)

	// Loop through all living mobs in a range.
	for(var/atom/A in found_targets)

		var/a_x = A.x
		var/a_y = A.y

		if(!isturf(A.loc))
			a_x = A.loc.x
			a_y = A.loc.y

		var/blip_x = max_dist + (-( distance_ref.x-a_x ) ) + starting_px
		var/blip_y = max_dist + (-( distance_ref.y-a_y ) ) + starting_py
		var/obj/screen/blip = new()
		blip.icon = 'radar.dmi'
		blip.name = "Blip"
		blip.layer = 21
		blip.screen_loc = "WEST:[blip_x-1],NORTH-2:[blip_y-1]" // offset -1 because the center of the blip is not at the bottomleft corner (14)

		if(istype(A, /mob/living))
			var/mob/living/M = A
			if(ishuman(M))
				if(M:wear_id)
					var/job = M:wear_id:GetJobName()
					if(job == "Security Officer")
						blip.icon_state = "secblip"
						blip.name = "Security Officer"
					else if(job == "Captain" || job == "Research Director" || job == "Chief Engineer" || job == "Chief Medical Officer" || job == "Head of Security" || job == "Head of Personnel")
						blip.icon_state = "headblip"
						blip.name = "Station Head"
					else
						blip.icon_state = "civblip"
						blip.name = "Civilian"
				else
					blip.icon_state = "civblip"
					blip.name = "Civilian"

			else if(issilicon(M))
				blip.icon_state = "roboblip"
				blip.name = "Robotic Organism"

			else
				blip.icon_state = "unknownblip"
				blip.name = "Unknown Organism"

		else if(istype(A, /obj/effect/critter))
			blip.icon_state = "unknownblip"
			blip.name = "Unknown Organism"

		else if(istype(A, /obj/mecha))
			blip.icon_state = "roboblip"
			blip.name = "Robotic Organism"

		radar_blips.Add(blip)
		client.screen += blip