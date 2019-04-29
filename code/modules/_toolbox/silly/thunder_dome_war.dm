GLOBAL_VAR_INIT(Thunder_Dome_War_Time, 0)

/proc/Thunder_Dome_War()
	if(!GLOB)
		return 0
	if(GLOB.Thunder_Dome_War_Time)
		GLOB.Thunder_Dome_War_Time = 0
		return 0
	if(!SSticker)
		return 0
	if(SSticker.current_state != GAME_STATE_FINISHED)
		if(GLOB.Thunder_Dome_War_Time)
			GLOB.Thunder_Dome_War_Time = 0
		return 0
	GLOB.Thunder_Dome_War_Time = 1
	. = 1
	spawn(0)
		var/list/thunderdometurfs = list()
		var/area/tdome/arena/TDOME = locate()
		for(var/turf/T in TDOME)
			if(T.x >= 162 && T.x <= 176)
				thunderdometurfs += T
		if(!thunderdometurfs.len)
			return
		to_chat(world,"<font size='5'><B>ITS THUNDERDOME TIME</B></font>")
		while(GLOB.Thunder_Dome_War_Time)
			for(var/client/C in GLOB.clients)
				if(!istype(C.mob,/mob/dead/observer) && !istype(C.mob,/mob/living))
					continue
				var/respawnclient = 0
				if(C.mob.mind)
					if(C.mob.mind.special_role != "Thunder Dome War")
						respawnclient = 1
				else
					respawnclient = 1
				if(!istype(C.mob,/mob/living/carbon/human))
					respawnclient = 1
				else
					var/mob/living/carbon/human/H = C.mob
					if(H.health <= 0)
						respawnclient = 1
				if(respawnclient)
					var/mob/living/oldmob
					if(istype(C.mob,/mob/living))
						oldmob = C.mob
						C.mob.ghostize(0)
					if(oldmob)
						if(istype(oldmob,/mob/living/carbon/human))
							var/mob/living/carbon/human/oldhuman = oldmob
							for(var/obj/item/I in oldhuman)
								oldhuman.dropItemToGround(I)
							oldhuman.regenerate_icons()
						spawn(0)
							if(oldmob.mind && oldmob.mind.special_role == "Thunder Dome War" )
								qdel(oldmob)
					var/mob/living/carbon/human/H = new()
					H.real_name = C.key
					H.sync_mind()
					H.mind.special_role = "Thunder Dome War"
					var/datum/outfit/death_commando/theoutfit = new()
					theoutfit.backpack_contents.Remove(/obj/item/grenade/plastic/x4)
					H.equipOutfit(theoutfit)
					H.forceMove(pick(thunderdometurfs))
					if(!H.get_active_held_item())
						H.swap_hand()
					H.ckey = C.ckey
					CHECK_TICK
			sleep(5)
