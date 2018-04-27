/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BODY_ZONE_CHEST

/obj/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice

	switch(icon_y)
		if(1 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					choice = BODY_ZONE_R_LEG
				if(17 to 22)
					choice = BODY_ZONE_L_LEG
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					choice = BODY_ZONE_R_ARM
				if(12 to 20)
					choice = BODY_ZONE_PRECISE_GROIN
				if(21 to 24)
					choice = BODY_ZONE_L_ARM
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					choice = BODY_ZONE_R_ARM
				if(12 to 20)
					choice = BODY_ZONE_CHEST
				if(21 to 24)
					choice = BODY_ZONE_L_ARM
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				choice = BODY_ZONE_HEAD
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							choice = BODY_ZONE_PRECISE_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							choice = BODY_ZONE_PRECISE_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							choice = BODY_ZONE_PRECISE_EYES

	return set_selected_zone(choice, usr)

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(isobserver(user))
		return

	if(choice != selecting)
		selecting = choice
		update_icon(usr)
	return TRUE

/obj/screen/zone_sel/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_gen.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/alien/update_icon(mob/user)
	cut_overlays()
	add_overlay(mutable_appearance('icons/mob/screen_alien.dmi', "[selecting]"))
	user.zone_selected = selecting

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'

