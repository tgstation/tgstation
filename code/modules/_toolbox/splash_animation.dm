/turf/closed/indestructible/splashscreen
	name = "Toolbox Station 13"
	layer = FLY_LAYER
	icon = 'icons/oldschool/splashscreen.dmi'
	icon_state = "main"
	var/image/overlay_lamp_on
	var/image/overlay_darkness1
	var/image/overlay_darkness2
	var/image/overlay_shadow
	var/image/overlay_cigar

	var/animating = 1
	var/ticks = 0

	var/cigar = 0
	var/cigar_ticks = 0
	var/next_cigar = 0

	var/state = 0
	var/flicker = 0
	var/flicker_ticks = 0
	var/flicker_stage1 = 0
	var/flicker_stage2 = 0
	var/flicker_stage3 = 0
	var/next_flicker = 0
	var/flicker_length = 0
	var/viewer_check_tick = 50

/turf/closed/indestructible/splashscreen/New()
	..()
	overlay_lamp_on = image(icon, icon_state = "none")
	overlay_darkness1 = image(icon, icon_state = "darkness1")
	overlay_darkness2 = image(icon, icon_state = "darkness2")
	overlay_shadow = image(icon, icon_state = "shadow")
	overlay_cigar = image(icon, icon_state = "none")
	update_overlays()
	do_anim()

/turf/closed/indestructible/splashscreen/proc/update_overlays()
	overlays.Cut()
	overlays += overlay_cigar
	overlays += overlay_lamp_on
	overlays += overlay_shadow
	overlays += overlay_darkness1
	overlays += overlay_darkness2

/turf/closed/indestructible/splashscreen/proc/do_anim()
	spawn(0)
		while(animating)
			viewer_check_tick--
			var/hasviewers = 0
			if(viewer_check_tick <= 0)
				viewer_check_tick = initial(viewer_check_tick)
				for(var/mob/dead/new_player/P in GLOB.player_list)
					hasviewers = 1
					break
			if(hasviewers)
				///////////////////////
				// Flicker Animation

				if (!flicker && ticks > next_flicker)
					flicker = 1
					flicker_ticks = 0
					flicker_stage1 = rand(6,10)
					flicker_stage2 = rand(1,3)
					flicker_stage3 = rand(3,5)
					flicker_length = flicker_stage1 + flicker_stage2 + flicker_stage3
					next_flicker = ticks + flicker_length + rand(10,150)

				if (flicker)
					if (flicker_ticks in 0 to flicker_stage1-1)
						state = 1
					else if (flicker_ticks in flicker_stage1 to flicker_stage1+flicker_stage2-1)
						state = 0
					else if (flicker_ticks in flicker_stage1+flicker_stage2 to flicker_stage1+flicker_stage2+flicker_stage3-1)
						state = 1

					flicker_ticks++

					if (flicker_ticks >= flicker_length)
						flicker_ticks = 0
						flicker = 0
						state = 0


					state_updated()

				///////////////////////
				// Cigar Animation

				if (!cigar && ticks > next_cigar)
					cigar = 1
					cigar_ticks = 0
					next_cigar = ticks + 12 + rand(10,50)

				if (cigar)
					overlay_cigar.icon_state = "cigar[round(cigar_ticks/2)]"
					cigar_ticks++

					if (cigar_ticks >= 12)
						overlay_cigar.icon_state = "none"
						cigar = 0
						cigar_ticks = 0

				/////////////////////

				update_overlays()
				ticks++
			sleep(1)

/turf/closed/indestructible/splashscreen/proc/state_updated()
	if (state)
		overlay_lamp_on.icon_state = "lamp_on"
		overlay_darkness1.icon_state = "none"
		overlay_darkness2.icon_state = "none"
	else
		overlay_lamp_on.icon_state = "none"
		overlay_darkness1.icon_state = "darkness1"
		overlay_darkness2.icon_state = "darkness2"
