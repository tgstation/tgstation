/*
В этом блоке указываются примеры для указания позиций для спавна мобов, джобок и структур. Сохранено не тронуты для примера по каждому пункту

// Pets
/datum/area_spawn/markus
	target_areas = list(/area/station/cargo/sorting, /area/station/cargo/storage, /area/station/cargo/office, /area/station/command/heads_quarters/qm)
	desired_atom = /mob/living/basic/pet/dog/markus

/datum/area_spawn/bumbles
	target_areas = list(/area/station/service/hydroponics, /area/station/service/hydroponics/upper)
	desired_atom = /mob/living/basic/pet/bumbles

// Structures
/datum/area_spawn/gbp_machine
	target_areas = list(/area/station/cargo/lobby, /area/station/cargo/boutique, /area/station/construction/storage_wing, /area/station/hallway/primary/port)   // lmao imagine map standardization
	desired_atom = /obj/machinery/gbp_redemption
	mode = AREA_SPAWN_MODE_HUG_WALL

// Wall mounts. Use sparingly as walls are prime real estate
/datum/area_spawn/posialert_robotics
	target_areas = list(/area/station/science/robotics, /area/station/science/robotics/lab)
	desired_atom = /obj/machinery/posialert
	mode = AREA_SPAWN_MODE_MOUNT_WALL

// Job spawners
/datum/area_spawn/barber_landmark
	target_areas = list(/area/station/service/salon, /area/station/hallway/secondary/service)
	desired_atom = /obj/effect/landmark/start/barber

/datum/area_spawn/corrections_officer_landmark
	desired_atom = /obj/effect/landmark/start/corrections_officer
	target_areas = list(/area/station/security/brig, /area/station/security/prison/)

/datum/area_spawn/telecomms_specialist_landmark
	target_areas = list(
		/area/station/tcommsat/computer,
		/area/station/engineering/lobby,
		/area/station/engineering/break_room,
	)
	desired_atom = /obj/effect/landmark/start/telecomms_specialist
*/

// Этот блок - пример для создания новой зоны, так как автомаппару ТРЕБУЕТСЯ, чтобы у каждого турфа была привязка к зоне
