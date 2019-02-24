#define STATION_ENGINE_WARP_TIME_LIMIT 3000

/obj/item/engine_selector
	name = "engine selector beacon"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "blueprints"
	desc = "A beacon used by the station's Engineering department to warp in an engine of their choice."
	var/used = FALSE
	var/response_timer_id = null
	var/engine_turf //location of the enginewarp landmark
	var/datum/map_template/engine/template

/obj/item/engine_selector/Initialize()
	. = ..()
	response_timer_id = addtimer(CALLBACK(src, .proc/force_engine_placement), STATION_ENGINE_WARP_TIME_LIMIT)

/obj/item/engine_selector/attack_self(mob/user)
	if(used)
		to_chat(user, "An engine has already been warped onto the station!")
		return
	find_placement()
	generate_options(user)

/obj/item/engine_selector/proc/find_placement()
	if(GLOB.enginestart.len > 0)
		engine_turf = get_turf(pick(GLOB.enginestart))
	else
		CRASH("No valid engine markers for placement.")

/obj/item/engine_selector/proc/generate_options(mob/living/M)
	var/choice = input(M,"Which engine would you like to warp in?","Select an Engine") as null|anything in SSmapping.engine_templates
	if(!choice || !M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	used = TRUE
	template = SSmapping.engine_templates[choice]
	template.load(engine_turf, centered = TRUE)

/obj/item/engine_selector/proc/force_engine_placement()//place the engine after x minutes if nobody has actually bothered to place one
	if(!used)
		find_placement()
		var/spinthewheel = pick(SSmapping.engine_templates)
		template = SSmapping.engine_templates[spinthewheel]
		template.load(engine_turf, centered = TRUE)
		used = TRUE

//engine templates
/datum/map_template/engine
	name = "big bobg"
	var/engine_id = "yas"

/datum/map_template/engine/singularity
	name = "Singularity Containment Prefab"
	engine_id = "engine_singularity"
	mappath = "_maps/templates/engine_singularity.dmm"

/datum/map_template/engine/tesla
	name = "Tesla Containment Prefab"
	engine_id = "engine_tesla"
	mappath = "_maps/templates/engine_tesla.dmm"

/datum/map_template/engine/supermatter
	name = "Supermatter Containment Prefab"
	engine_id = "engine_supermatter"
	mappath = "_maps/templates/engine_supermatter.dmm"

/datum/map_template/engine/teg
	name = "TEG Prefab"
	engine_id = "engine_teg"
	mappath = "_maps/templates/engine_teg.dmm"


//landmark used to mark where to spawn the engine
/obj/effect/landmark/enginewarp
	name = "enginewarp location"
	icon_state = "blob_start"

/obj/effect/landmark/enginewarp/Initialize(mapload)
	..()
	GLOB.enginestart += loc
	return INITIALIZE_HINT_QDEL

#undef STATION_ENGINE_WARP_TIME_LIMIT