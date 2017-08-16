/*****************************Survival Pod********************************/
/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = TRUE

//Survival Capsule
/obj/item/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/survivalcapsule/proc/get_template()
	if(template)
		return
	template = SSmapping.shelter_templates[template_id]
	if(!template)
		throw EXCEPTION("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	to_chat(user, "This capsule has the [template.name] stored.")
	to_chat(user, template.description)

/obj/item/survivalcapsule/attack_self()
	//Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(!used)
		loc.visible_message("<span class='warning'>\The [src] begins to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				src.loc.visible_message("<span class='warning'>\The [src] doesn't have room to deploy! You need to clear a [width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(T.z != ZLEVEL_MINING && T.z != ZLEVEL_LAVALAND)//only report capsules away from the mining/lavaland level
			message_admins("[ADMIN_LOOKUPFLW(usr)] activated a bluespace capsule away from the mining level! [ADMIN_JMP(T)]")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [get_area(T)][COORD(T)]")
		template.load(deploy_location, centered = TRUE)
		new /obj/effect/particle_effect/smoke(get_turf(src))
		qdel(src)

/obj/item/survivalcapsule/luxury
	name = "luxury bluespace shelter capsule"
	desc = "An exorbitantly expensive luxury suite stored within a pocket of bluespace."
	origin_tech = "engineering=3;bluespace=4"
	template_id = "shelter_beta"

//Pod objects

//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/pod_window.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/wall/mineral/titanium/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod)

/obj/structure/window/reinforced/survival_pod
	name = "pod window"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "pwindow"

//Door
/obj/machinery/door/airlock/survival_pod
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	note_overlay_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod
	opacity = FALSE
	glass = TRUE
	var/expected_dir = SOUTH //we visually turn when shuttle rotated, but need to not turn for any other reason

/obj/machinery/door/airlock/survival_pod/setDir(direction)
	direction = expected_dir
	..()

/obj/machinery/door/airlock/survival_pod/shuttleRotate(rotation)
	expected_dir = angle2dir(rotation+dir2angle(dir))
	..()

/obj/machinery/door/airlock/survival_pod/vertical
	dir = EAST
	expected_dir = EAST

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	anchored = TRUE
	state = 1
	mineral = "glass"
	material = "glass"
	var/expected_dir = SOUTH

/obj/structure/door_assembly/door_assembly_pod/setDir(direction)
	direction = expected_dir
	..()

/obj/structure/door_assembly/door_assembly_pod/shuttleRotate(rotation)
	expected_dir = angle2dir(rotation+dir2angle(dir))
	..()

/obj/structure/door_assembly/door_assembly_pod/vertical
	dir = EAST
	expected_dir = EAST

//Windoor
/obj/machinery/door/window/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "windoor"
	base_state = "windoor"

//Table
/obj/structure/table/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "table"
	smooth = SMOOTH_FALSE

//Sleeper
/obj/machinery/sleeper/survival_pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "sleeper"

/obj/machinery/sleeper/survival_pod/update_icon()
	if(state_open)
		cut_overlays()
	else
		add_overlay("sleeper_cover")

//Computer
/obj/item/device/gps/computer
	name = "pod computer"
	icon_state = "pod_computer"
	icon = 'icons/obj/lavaland/pod_computer.dmi'
	anchored = TRUE
	density = TRUE
	pixel_y = -32

/obj/item/device/gps/computer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, W.usesound, 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the gps.</span>", \
						"<span class='notice'>You start to disassemble the gps...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20*W.toolspeed, target = src))
			new /obj/item/device/gps(loc)
			qdel(src)
		return
	return ..()

/obj/item/device/gps/computer/attack_hand(mob/user)
	attack_self(user)

//Bed
/obj/structure/bed/pod
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "bed"

//Survival Storage Unit
/obj/machinery/smartfridge/survival_pod
	name = "survival pod storage"
	desc = "A heated storage unit."
	icon_state = "donkvendor"
	icon = 'icons/obj/lavaland/donkvendor.dmi'
	icon_on = "donkvendor"
	icon_off = "donkvendor"
	light_range = 5
	light_power = 1.2
	light_color = "#DDFFD3"
	max_n_of_items = 10
	pixel_y = -4
	flags = NODECONSTRUCT
	var/empty = FALSE

/obj/machinery/smartfridge/survival_pod/Initialize(mapload)
	. = ..()
	if(empty)
		return
	for(var/i in 1 to 5)
		var/obj/item/reagent_containers/food/snacks/donkpocket/warm/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/device/instrument/guitar/G = new(src)
		load(G)

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	return isitem(O)

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."
	empty = TRUE

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = TRUE
	density = TRUE
	var/arbitraryatmosblockingvar = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/fans/deconstruct()
	if(!(flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	qdel(src)

/obj/structure/fans/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, W.usesound, 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the fan.</span>", \
						"<span class='notice'>You start to disassemble the fan...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20*W.toolspeed, target = src))
			deconstruct()
			return ..()

/obj/structure/fans/tiny
	name = "tiny fan"
	desc = "A tiny fan, releasing a thin gust of air."
	layer = ABOVE_NORMAL_TURF_LAYER
	density = FALSE
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/Initialize(mapload)
	. = ..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	var/turf/T = loc
	. = ..()
	T.air_update_turf(1)

//Inivisible, indestructible fans
/obj/structure/fans/tiny/invisible
	name = "air flow blocker"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_ABSTRACT

//Signs
/obj/structure/sign/mining
	name = "nanotrasen mining corps sign"
	desc = "A sign of relief for weary miners, and a warning for would-be competitors to Nanotrasen's mining claims."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "ntpod"

/obj/structure/sign/mining/survival
	name = "shelter sign"
	desc = "A high visibility sign designating a safe shelter."
	icon = 'icons/turf/walls/survival_pod_walls.dmi'
	icon_state = "survival"

//Fluff
/obj/structure/tubes
	icon_state = "tubes"
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	name = "tubes"
	anchored = TRUE
	layer = BELOW_MOB_LAYER
	density = FALSE

/obj/item/fakeartefact
	name = "expensive forgery"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	var/possible = list(/obj/item/ship_in_a_bottle,
						/obj/item/gun/energy/pulse,
						/obj/item/sleeping_carp_scroll,
						/obj/item/melee/supermatter_sword,
						/obj/item/shield/changeling,
						/obj/item/lava_staff,
						/obj/item/dash/energy_katana,
						/obj/item/hierophant_club,
						/obj/item/his_grace,
						/obj/item/gun/ballistic/minigun,
						/obj/item/gun/ballistic/automatic/l6_saw,
						/obj/item/gun/magic/staff/chaos,
						/obj/item/gun/magic/staff/spellblade,
						/obj/item/gun/magic/wand/death,
						/obj/item/gun/magic/wand/fireball,
						/obj/item/stack/telecrystal/twenty,
						/obj/item/nuke_core,
						/obj/item/phylactery,
						/obj/item/banhammer)

/obj/item/fakeartefact/Initialize()
	. = ..()
	var/obj/item/I = pick(possible)
	name = initial(I.name)
	icon = initial(I.icon)
	desc = initial(I.desc)
	icon_state = initial(I.icon_state)
	item_state = initial(I.item_state)