GLOBAL_VAR_INIT(Thunder_Dome_War_Time, 0)
GLOBAL_LIST_EMPTY(Thunder_Dome_War_Time_Specials)

#define THUNDERDOMEMINX 162
#define THUNDERDOMEMAXX 176
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
		var/highest_y = 0
		var/thunderdome_z = 0
		for(var/turf/T in TDOME)
			if(T.x >= THUNDERDOMEMINX && T.x <= THUNDERDOMEMAXX)
				thunderdometurfs += T
			if(!highest_y)
				highest_y = T.y
			if(T.y > highest_y)
				highest_y = T.y
			if(!thunderdome_z)
				thunderdome_z = T.z
		if(!thunderdometurfs.len)
			return
		var/turf/specialcenter = locate(THUNDERDOMEMINX+round((THUNDERDOMEMAXX-THUNDERDOMEMINX)/2,1),highest_y+2,thunderdome_z)
		var/list/specialturfs = list(specialcenter)
		var/list/specialbackupturfs = list()
		var/additional = 1
		while(additional <= 7)
			var/turf/T1 = locate(specialcenter.x+additional,specialcenter.y,specialcenter.z)
			specialturfs += T1
			var/turf/T2 = locate(specialcenter.x+(additional*-1),specialcenter.y,specialcenter.z)
			specialturfs += T2
			additional++
		var/thepwhitelist = get_pwhitelist()
		to_chat(world,"<font size='5'><B>ITS THUNDERDOME TIME</B></font>")
		while(GLOB.Thunder_Dome_War_Time)
			var/list/deathsquads = list()
			var/list/perseus = list()
			for(var/client/C in GLOB.clients)
				if(!istype(C.mob,/mob/dead/observer) && !istype(C.mob,/mob/living))
					continue
				var/respawnclient = 0
				if(!istype(C.mob,/mob/living/carbon/human))
					respawnclient = 1
				else
					var/mob/living/carbon/human/H = C.mob
					if(H.health <= 0)
						respawnclient = 1
				if(C.mob.mind)
					if(C.mob.mind in GLOB.Thunder_Dome_War_Time_Specials)
						continue
					if(C.mob.mind.special_role != "Thunder Dome War")
						respawnclient = 1
				else
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
					var/perccheck = is_pwhitelisted(C.ckey,thepwhitelist)
					if(perccheck && (specialturfs.len || specialbackupturfs.len))
						perseus[C] = perccheck
					else
						deathsquads += C
			for(var/client/C in perseus)
				if(perseus[C])
					var/mob/living/carbon/human/H = new()
					C.prefs.copy_to(H)
					H.dna.update_dna_identity()
					H.sync_mind()
					var/turf/T
					if(specialturfs.len)
						T = specialturfs[1]
						specialturfs -= T
						specialbackupturfs += T
					else if(specialbackupturfs.len)
						T = pick(specialbackupturfs)
					H.forceMove(T)
					H.ckey = C.ckey
					if(!(H.mind in GLOB.Thunder_Dome_War_Time_Specials))
						GLOB.Thunder_Dome_War_Time_Specials += H.mind
					var/outfitdatum = /datum/outfit/perseus/fullkit
					if(copytext(perseus[C],1,2) == "2")
						outfitdatum = /datum/outfit/perseus/commander/fullkit
					var/datum/outfit/perseus/P = new outfitdatum()
					H.equipOutfit(P)
					H.dir = SOUTH
			for(var/client/C in deathsquads)
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

