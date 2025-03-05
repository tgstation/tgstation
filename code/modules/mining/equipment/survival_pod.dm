/*****************************Survival Pod********************************/
/area/misc/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	static_lighting = TRUE
	requires_power = FALSE
	default_gravity = STANDARD_GRAVITY
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	flags_1 = CAN_BE_DIRTY_1

//Survival Capsule
/obj/item/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	///The id we use to fetch the template datum
	var/template_id = "shelter_alpha"
	///The template datum we use to load the shelter
	var/datum/map_template/shelter/template
	///If true, this capsule is active and will deploy the area if conditions are met.
	var/used = FALSE
	///Will this capsule yeet mobs back once the area is deployed?
	var/yeet_back = TRUE

/obj/item/survivalcapsule/proc/get_template()
	if(template)
		return
	template = SSmapping.shelter_templates[template_id]
	if(!template)
		WARNING("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	. += "This capsule has the [template.name] stored."
	. += template.description

/obj/item/survivalcapsule/interact(mob/living/user)
	. = ..()
	if(.)
		return .

	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(used)
		return FALSE

	loc.visible_message(span_warning("[src] begins to shake. Stand back!"))
	used = TRUE
	addtimer(CALLBACK(src, PROC_REF(expand), user), 5 SECONDS)
	if(iscarbon(user))
		var/mob/living/carbon/carbon = user
		carbon.throw_mode_on(THROW_MODE_TOGGLE)
	return TRUE

/// Expands the capsule into a full shelter, placing the template at the item's location (NOT triggerer's location)
/obj/item/survivalcapsule/proc/expand(mob/triggerer)
	if(QDELETED(src))
		return

	var/turf/deploy_location = get_turf(src)
	var/status = template.check_deploy(deploy_location, src, get_ignore_flags())
	if(status != SHELTER_DEPLOY_ALLOWED)
		fail_feedback(status)
		used = FALSE
		return

	if(yeet_back)
		yote_nearby(deploy_location)
	template.load(deploy_location, centered = TRUE)
	trigger_admin_alert(triggerer, deploy_location)
	playsound(src, 'sound/effects/phasein.ogg', 100, TRUE)
	new /obj/effect/particle_effect/fluid/smoke(get_turf(src))
	qdel(src)

/// Returns a bitfield used to ignore some checks in template.check_deploy()
/obj/item/survivalcapsule/proc/get_ignore_flags()
	return NONE

///Returns a message including the reason why it couldn't be deployed
/obj/item/survivalcapsule/proc/fail_feedback(status)
	switch(status)
		if(SHELTER_DEPLOY_BAD_AREA)
			loc.visible_message(span_warning("[src] will not function in this area."))
		if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS, SHELTER_DEPLOY_OUTSIDE_MAP, SHELTER_DEPLOY_BANNED_OBJECTS)
			loc.visible_message(span_warning("[src] doesn't have room to deploy! You need to clear a [template.width]x[template.height] area!"))

/// Throws any mobs near the deployed location away from the item / shelter
/// Does some math to make closer mobs get thrown further
/obj/item/survivalcapsule/proc/yote_nearby(turf/deploy_location)
	var/width = template.width
	var/height = template.height
	var/base_x_throw_distance = ceil(width / 2)
	var/base_y_throw_distance = ceil(height / 2)
	for(var/mob/living/did_not_stand_back in range(loc, "[width]x[height]"))
		var/dir_to_center = get_dir(deploy_location, did_not_stand_back) || pick(GLOB.alldirs)
		// Aiming to throw the target just enough to get them out of the range of the shelter
		// IE: Stronger if they're closer, weaker if they're further away
		var/throw_dist = 0
		var/x_component = abs(did_not_stand_back.x - deploy_location.x)
		var/y_component = abs(did_not_stand_back.y - deploy_location.y)
		if(ISDIAGONALDIR(dir_to_center))
			throw_dist = ceil(sqrt(base_x_throw_distance ** 2 + base_y_throw_distance ** 2) - (sqrt(x_component ** 2 + y_component ** 2)))
		else if(dir_to_center & (NORTH|SOUTH))
			throw_dist = base_y_throw_distance - y_component + 1
		else if(dir_to_center & (EAST|WEST))
			throw_dist = base_x_throw_distance - x_component + 1

		did_not_stand_back.Paralyze(3 SECONDS)
		did_not_stand_back.Knockdown(6 SECONDS)
		did_not_stand_back.throw_at(
			target = get_edge_target_turf(did_not_stand_back, dir_to_center),
			range = throw_dist,
			speed = 3,
			force = MOVE_FORCE_VERY_STRONG,
		)

/// Logs if the capsule was triggered, by default only if it happened on non-lavaland
/obj/item/survivalcapsule/proc/trigger_admin_alert(mob/triggerer, turf/trigger_loc)
	//only report capsules away from the mining/lavaland level
	if(is_mining_level(trigger_loc.z))
		return

	message_admins("[ADMIN_LOOKUPFLW(triggerer)] activated a bluespace capsule away from the mining level! [ADMIN_VERBOSEJMP(trigger_loc)]")
	log_admin("[key_name(triggerer)] activated a bluespace capsule away from the mining level at [AREACOORD(trigger_loc)]")

//Non-default pods

/obj/item/survivalcapsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace."
	template_id = "shelter_beta"

/obj/item/survivalcapsule/luxuryelite
	name = "luxury elite bar capsule"
	desc = "A luxury bar in a capsule. Bartender required and not included."
	template_id = "shelter_charlie"

/obj/item/survivalcapsule/bathroom
	name = "emergency relief capsule"
	desc = "Provides vital emergency support to employees who are caught short in the field."
	template_id = "shelter_toilet"

//Pod objects

//Window
/obj/structure/window/reinforced/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/pod_window.dmi'
	icon_state = "pod_window-0"
	base_icon_state = "pod_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_SURVIVAL_TITANIUM_POD
	canSmoothWith = SMOOTH_GROUP_SURVIVAL_TITANIUM_POD

/obj/structure/window/reinforced/survival_pod
	name = "pod window"
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "pwindow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/survival_pod/spawner, 0)

//Door
/obj/machinery/door/airlock/survival_pod
	name = "Airlock"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod
	smoothing_groups = SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_SURVIVAL_TITANIUM_POD

/obj/machinery/door/airlock/survival_pod/glass
	opacity = FALSE
	glass = TRUE

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	base_name = "pod airlock"
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	glass_type = /obj/machinery/door/airlock/survival_pod/glass

//Windoor
/obj/machinery/door/window/survival_pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "windoor"
	base_state = "windoor"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/door/window/survival_pod/left, 0)

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "table"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "sleeper"
	base_icon_state = "sleeper"

/obj/machinery/sleeper/survival_pod/update_overlays()
	. = ..()
	if(!state_open)
		. += "sleeper_cover"

//Lifeform Stasis Unit
/obj/machinery/stasis/survival_pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	buckle_lying = 270

//Computer
/obj/item/gps/computer
	name = "pod computer"
	icon = 'icons/obj/mining_zones/pod_computer.dmi'
	icon_state = "pod_computer"
	anchored = TRUE
	density = TRUE
	pixel_y = -32

/obj/item/gps/computer/wrench_act(mob/living/user, obj/item/I)
	..()

	user.visible_message(span_warning("[user] disassembles [src]."),
		span_notice("You start to disassemble [src]..."), span_hear("You hear clanking and banging noises."))
	if(I.use_tool(src, user, 20, volume=50))
		new /obj/item/gps(loc)
		qdel(src)
	return TRUE

/obj/item/gps/computer/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	attack_self(user)

//Bed
/obj/structure/bed/pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "bed"

/obj/structure/bed/double/pod
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	icon_state = "bed_double"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/mining_zones/donkvendor.dmi'
	base_build_path = /obj/machinery/smartfridge/survival_pod
	light_range = 5
	light_power = 1.2
	light_color = COLOR_VERY_PALE_LIME_GREEN
	max_n_of_items = 10
	pixel_y = -4

/obj/machinery/smartfridge/survival_pod/welder_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/smartfridge/survival_pod/wrench_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/smartfridge/survival_pod/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/smartfridge/survival_pod/crowbar_act(mob/living/user, obj/item/tool)
	return NONE

/obj/machinery/smartfridge/survival_pod/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/machinery/smartfridge/survival_pod/preloaded/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 5)
		var/obj/item/food/donkpocket/warm/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/storage/dice/D = new(src)
		load(D)
	else
		var/obj/item/instrument/guitar/G = new(src)
		load(G)

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	return isitem(O)

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/mining_zones/survival_pod.dmi'
	name = "tubes"
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	density = FALSE

/obj/item/fakeartefact
	name = "expensive forgery"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	var/static/possible = list(
		/obj/item/ship_in_a_bottle,
		/obj/item/gun/energy/pulse,
		/obj/item/book/granter/martial/carp,
		/obj/item/melee/supermatter_sword,
		/obj/item/shield/changeling,
		/obj/item/lava_staff,
		/obj/item/energy_katana,
		/obj/item/hierophant_club,
		/obj/item/his_grace,
		/obj/item/gun/energy/minigun,
		/obj/item/gun/ballistic/automatic/l6_saw,
		/obj/item/gun/magic/staff/chaos,
		/obj/item/gun/magic/staff/spellblade,
		/obj/item/gun/magic/wand/death,
		/obj/item/gun/magic/wand/fireball,
		/obj/item/stack/telecrystal/twenty,
		/obj/item/nuke_core,
		/obj/item/banhammer,
	)

/obj/item/fakeartefact/Initialize(mapload)
	. = ..()
	var/obj/item/I = pick(possible)
	name = initial(I.name)
	icon = initial(I.icon)
	desc = initial(I.desc)
	icon_state = initial(I.icon_state)
	inhand_icon_state = initial(I.inhand_icon_state)
	lefthand_file = initial(I.lefthand_file)
	righthand_file = initial(I.righthand_file)
	cut_overlays() //to get rid of the big blue x
