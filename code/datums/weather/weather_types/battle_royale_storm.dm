
GLOBAL_DATUM(storm_controller, /datum/storm_controller)

/datum/storm_controller
	var/area_consume_timer = 5 SECONDS
	///which list to pick from
	var/list/current_area_pick
	///outer areas, does not include space
	var/list/outer_areas = list()
	///middle areas
	var/list/middle_areas = list()
	///inner areas
	var/list/inner_areas = list()
	///how many lists it has left
	var/progression = 3
	///timer id to the next area consumption
	var/timerid
	///active weathers
	var/list/storms = list()

/datum/storm_controller/New()
	. = ..()
	//see bottom of file for these
	outer_areas = GLOB.externalareasstorm.Copy()
	middle_areas = GLOB.middleareastorm.Copy()
	inner_areas = GLOB.innerareastorm.Copy()
	//inner
	current_area_pick = outer_areas
	message_admins("Storm started.")
	send_to_playing_players("<span class='userdanger'>The storm has been created! It will consume the station from the outside in, so plan around it!</span>")
	consume_area(/area/space, repeat = FALSE)
	consume_area(/area/space/nearstation, repeat = TRUE) //start the storm

/datum/storm_controller/proc/consume_area(area/area_path, repeat = TRUE)
	var/datum/weather/royale_storm/storm = new(SSmapping.levels_by_trait(ZTRAIT_STATION))
	storms += storm
	storm.area_type = area_path
	//message_admins("Storm consuming [initial(area_path.name)].")
	storm.telegraph()
	if(repeat)
		if(!current_area_pick.len) //there was none left, don't try and take from an empty list
			return
		timerid = addtimer(CALLBACK(src, .proc/consume_area, pick_n_take(current_area_pick)), area_consume_timer)
		if(!current_area_pick.len) //we took the last one
			progression--
			switch(progression)
				if(2)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the entire outer station!</span>")
					area_consume_timer += 5 SECONDS //get a little slower
					current_area_pick = middle_areas
				if(1)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the majority of the station!</span>")
					current_area_pick = inner_areas
				if(0)
					send_to_playing_players("<span class='userdanger'>The storm has consumed the ENTIRE station!</span>")

///stops the storm.
/datum/storm_controller/proc/stop_storm()
	send_to_playing_players("<span class='userdanger'>The storm has been halted by centcom!</span>")
	if(timerid)
		deltimer(timerid)

///ends the storm.
/datum/storm_controller/proc/end_storm()
	for(var/datum/weather/storm as anything in storms)
		storm.wind_down()
	storms = null
	qdel(src)

/// these nuts?
/datum/weather/royale_storm
	name = "royale storm"
	desc = "A sick creation of the most ADHD ridden centcom scientists, used to force stationgoers to fight with the threat of being shredded by an artificial storm for entertainment."


	telegraph_duration = 1 SECONDS
	weather_overlay = "royale"
	perpetual = TRUE

	telegraph_message = null
	weather_message = null
	end_message = null

	target_trait = ZTRAIT_STATION

	immunity_type = "NOTHING KID"

/datum/weather/royale_storm/weather_act(mob/living/L)
	L.adjustFireLoss(15)
	if(L.stat == DEAD)
		to_chat(L, "<span class='userdanger'>You're torn apart from the violent forces in the storm!</span>")
		L.gib(TRUE)
	else
		to_chat(L, "<span class='userdanger'>You're badly burned by the storm!</span>")

GLOBAL_LIST_INIT(externalareasstorm, list(
	/area/hallway/secondary/entry,
	/area/solars/starboard/fore,
	/area/maintenance/solars/starboard/fore,
	/area/construction/mining/aux_base,
	/area/maintenance/starboard/fore,
	/area/security/checkpoint,
	/area/security/checkpoint/customs,
	/area/maintenance/disposal,
	/area/cargo/storage,
	/area/cargo/warehouse,
	/area/cargo/sorting,
	/area/security/checkpoint/supply,
	/area/security/prison,
	/area/security/prison/safe,
	/area/security/execution/education,
	/area/security/brig,
	/area/security/execution/transfer,
	/area/security/office,
	/area/command/heads_quarters/hos,
	/area/security/interrogation,
	/area/security/warden,
	/area/ai_monitored/security/armory,
	/area/security/range,
	/area/commons/fitness/recreation,
	/area/holodeck/rec_center,
	/area/solars/starboard/aft,
	/area/medical/psychology,
	/area/hallway/secondary/construction,
	/area/maintenance/solars/starboard/aft,
	/area/security/detectives_office/private_investigators_office,
	/area/service/theater/abandoned,
	/area/medical/virology,
	/area/medical/surgery,
	/area/medical/surgery/room_b,
	/area/command/heads_quarters/cmo,
	/area/medical/morgue,
	/area/maintenance/aft,
	/area/maintenance/port/aft,
	/area/security/checkpoint/customs/auxiliary,
	/area/hallway/secondary/exit/departure_lounge,
	/area/security/checkpoint/escape,
	/area/service/chapel/main,
	/area/service/chapel/office,
	/area/maintenance/solars/port/aft,
	/area/solars/port/aft,
	/area/service/library/abandoned,
	/area/science/storage,
	/area/science/mixing,
	/area/science/misc_lab,
	/area/science/research/abandoned,
	/area/maintenance/department/science,
	/area/science/misc_lab/range,
	/area/science/genetics,
	/area/service/abandoned_gambling_den,
	/area/maintenance/department/electrical,
	/area/engineering/main,
	/area/engineering/storage,
	/area/command/heads_quarters/ce,
	/area/security/checkpoint/engineering,
	/area/engineering/gravity_generator,
	/area/engineering/break_room,
	/area/engineering/storage_shared,
	/area/engineering/atmos,
	/area/maintenance/disposal/incinerator,
	/area/maintenance/solars/port/fore,
	/area/solars/port/fore,
	/area/engineering/atmos/upper,
	/area/maintenance/port/fore,
	/area/service/abandoned_gambling_den/secondary,
	/area/service/theater,
	/area/service/bar,
	/area/service/bar/atrium,
	/area/service/hydroponics/garden/abandoned,
	/area/service/electronic_marketing_den,
	/area/commons/vacant_room/office,
	/area/service/janitor,
	/area/commons/toilet/auxiliary))

GLOBAL_LIST_INIT(middleareastorm, list(
	/area/hallway/primary/port,
	/area/maintenance/port,
	/area/engineering/storage/tech,
	/area/commons/storage/primary,
	/area/service/hydroponics,
	/area/service/library,
	/area/commons/vacant_room/commissary,
	/area/science/xenobiology,
	/area/science/nanite,
	/area/science/genetics,
	/area/science/research,
	/area/science/server,
	/area/command/heads_quarters/rd,
	/area/science/robotics/lab,
	/area/science/robotics/mechbay,
	/area/science/lab,
	/area/security/checkpoint/science/research,
	/area/hallway/primary/aft,
	/area/medical/chemistry,
	/area/medical/pharmacy,
	/area/medical/medbay/central,
	/area/medical/treatment_center,
	/area/security/checkpoint/medical,
	/area/maintenance/starboard/aft,
	/area/commons/dorms,
	/area/commons/locker,
	/area/commons/toilet/restrooms,
	/area/maintenance/starboard,
	/area/security/courtroom,
	/area/service/lawoffice,
	/area/hallway/primary/starboard,
	/area/security/detectives_office,
	/area/cargo/miningoffice,
	/area/cargo/qm,
	/area/cargo/office,
	/area/hallway/primary/fore,
	/area/service/kitchen,
	/area/hallway/secondary/service))

GLOBAL_LIST_INIT(innerareastorm, list(
	/area/hallway/primary/central/aft,
	/area/hallway/primary/central/fore,
	/area/hallway/secondary/command,
	/area/ai_monitored/command/storage/eva,
	/area/command/gateway,
	/area/command/corporate_showroom,
	/area/command/heads_quarters/hop,
	/area/command/teleporter,
	/area/command/heads_quarters/captain/private,
	/area/command/heads_quarters/captain,
	/area/tcommsat/server,
	/area/tcommsat/computer,
	/area/command/heads_quarters/hop,
	/area/command/meeting_room/council,
	/area/command/bridge))
