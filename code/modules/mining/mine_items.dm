/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light emitter"
	anchored = 1
	invisibility = 101
	var/set_luminosity = 8
	var/set_cap = 0

/obj/effect/light_emitter/New()
	..()
	SetLuminosity(set_luminosity, set_cap)

/**********************Miner Lockers**************************/

/obj/structure/closet/wardrobe/miner
	name = "mining wardrobe"
	icon_door = "mixed"

/obj/structure/closet/wardrobe/miner/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/backpack/dufflebag(src)
	new /obj/item/weapon/storage/backpack/explorer(src)
	new /obj/item/weapon/storage/backpack/satchel/explorer(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/under/rank/miner/lavaland(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/gloves/color/black(src)

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	new /obj/item/stack/sheet/mineral/sandbags(src, 5)
	new /obj/item/weapon/storage/box/emptysandbags(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe/mini(src)
	new /obj/item/device/radio/headset/headset_cargo/mining(src)
	new /obj/item/device/flashlight/seclite(src)
	new /obj/item/weapon/storage/bag/plants(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/device/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/weapon/gun/energy/kinetic_accelerator(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/weapon/survivalcapsule(src)
	new /obj/item/device/assault_pod/mining(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	circuit = /obj/item/weapon/circuitboard/computer/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away;landing_zone_dock"
	no_destination_swap = 1
	var/global/list/dumb_rev_heads = list()

/obj/machinery/computer/shuttle/mining/attack_hand(mob/user)
	if(user.z == ZLEVEL_STATION && user.mind && (user.mind in ticker.mode.head_revolutionaries) && !(user.mind in dumb_rev_heads))
		user << "<span class='warning'>You get a feeling that leaving the station might be a REALLY dumb idea...</span>"
		dumb_rev_heads += user.mind
		return
	..()

/*********************Pickaxe & Drills**************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 15
	throwforce = 10
	item_state = "pickaxe"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL=2000) //one sheet, but where can you make them?
	var/digspeed = 40
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	origin_tech = "materials=2;engineering=3"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/weapon/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	force = 10
	throwforce = 7
	slot_flags = SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=1000)

/obj/item/weapon/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),50,1)

/obj/item/weapon/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	item_state = "spickaxe"
	digspeed = 20 //mines faster than a normal pickaxe, bought from mining vendor
	origin_tech = "materials=3;engineering=4"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	force = 17

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 14
	origin_tech = "materials=5;engineering=4"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	force = 19

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	slot_flags = SLOT_BELT
	digspeed = 25 //available from roundstart, faster than a pickaxe.
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=2;engineering=3"
	desc = "An electric mining drill for the especially scrawny."

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 7
	origin_tech = "materials=6;powerstorage=4;engineering=4"
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/weapon/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	digspeed = 7

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. extremely fast mining, laughs at puny walls
	origin_tech = "materials=6;powerstorage=4;engineering=5;magnets=4"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8
	var/digspeed = 20
	throwforce = 4
	item_state = "shovel"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=50)
	origin_tech = "materials=2;engineering=2"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")
	sharpness = IS_SHARP

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/weapon/emptysandbag
	name = "empty sandbag"
	desc = "A bag to be filled with sand."
	icon = 'icons/obj/items.dmi'
	icon_state = "sandbag"
	w_class = WEIGHT_CLASS_TINY

/obj/item/weapon/emptysandbag/attackby(obj/item/W, mob/user, params)
	if(istype(W,/obj/item/weapon/ore/glass))
		user << "<span class='notice'>You fill the sandbag.</span>"
		var/obj/item/stack/sheet/mineral/sandbags/I = new /obj/item/stack/sheet/mineral/sandbags
		user.unEquip(src)
		user.put_in_hands(I)
		qdel(W)
		qdel(src)
		return
	else
		return ..()

/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "miningcar"

/*****************************Survival Pod********************************/


/area/survivalpod
	name = "\improper Emergency Shelter"
	icon_state = "away"
	requires_power = 0
	has_gravity = 1

/obj/item/weapon/survivalcapsule
	name = "bluespace shelter capsule"
	desc = "An emergency shelter stored within a pocket of bluespace."
	icon_state = "capsule"
	icon = 'icons/obj/mining.dmi'
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "engineering=3;bluespace=3"
	var/template_id = "shelter_alpha"
	var/datum/map_template/shelter/template
	var/used = FALSE

/obj/item/weapon/survivalcapsule/proc/get_template()
	if(template)
		return
	template = shelter_templates[template_id]
	if(!template)
		throw EXCEPTION("Shelter template ([template_id]) not found!")
		qdel(src)

/obj/item/weapon/survivalcapsule/Destroy()
	template = null // without this, capsules would be one use. per round.
	. = ..()

/obj/item/weapon/survivalcapsule/examine(mob/user)
	. = ..()
	get_template()
	user << "This capsule has the [template.name] stored."
	user << template.description

/obj/item/weapon/survivalcapsule/attack_self()
	// Can't grab when capsule is New() because templates aren't loaded then
	get_template()
	if(used == FALSE)
		src.loc.visible_message("<span class='warning'>\The [src] begins \
			to shake. Stand back!</span>")
		used = TRUE
		sleep(50)
		var/turf/deploy_location = get_turf(src)
		var/status = template.check_deploy(deploy_location)
		switch(status)
			if(SHELTER_DEPLOY_BAD_AREA)
				src.loc.visible_message("<span class='warning'>\The [src] \
				will not function in this area.</span>")
			if(SHELTER_DEPLOY_BAD_TURFS, SHELTER_DEPLOY_ANCHORED_OBJECTS)
				var/width = template.width
				var/height = template.height
				src.loc.visible_message("<span class='warning'>\The [src] \
				doesn't have room to deploy! You need to clear a \
				[width]x[height] area!</span>")

		if(status != SHELTER_DEPLOY_ALLOWED)
			used = FALSE
			return

		playsound(get_turf(src), 'sound/effects/phasein.ogg', 100, 1)

		var/turf/T = deploy_location
		if(T.z != ZLEVEL_MINING && T.z != ZLEVEL_LAVALAND)//only report capsules away from the mining/lavaland level
			message_admins("[key_name_admin(usr)] (<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) activated a bluespace capsule away from the mining level! (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			log_admin("[key_name(usr)] activated a bluespace capsule away from the mining level at [T.x], [T.y], [T.z]")
		template.load(deploy_location, centered = TRUE)
		PoolOrNew(/obj/effect/particle_effect/smoke, get_turf(src))
		qdel(src)



//Pod turfs and objects


//Window
/obj/structure/window/shuttle/survival_pod
	name = "pod window"
	icon = 'icons/obj/smooth_structures/pod_window.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/closed/wall/shuttle/survival, /obj/machinery/door/airlock/survival_pod, /obj/structure/window/shuttle/survival_pod)

//Door
/obj/machinery/door/airlock/survival_pod
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/survival/horizontal/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/horizontal/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod
	opacity = 0
	glass = 1

/obj/machinery/door/airlock/survival_pod/vertical
	icon = 'icons/obj/doors/airlocks/survival/vertical/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/vertical/survival_overlays.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_pod/vertical

/obj/structure/door_assembly/door_assembly_pod
	name = "pod airlock assembly"
	icon = 'icons/obj/doors/airlocks/survival/horizontal/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/horizontal/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod
	anchored = 1
	state = 1
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_pod/vertical
	icon = 'icons/obj/doors/airlocks/survival/vertical/survival.dmi'
	overlays_file = 'icons/obj/doors/airlocks/survival/vertical/survival_overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/survival_pod/vertical

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
	anchored = 1
	density = 1
	pixel_y = -32

/obj/item/device/gps/computer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, W.usesound, 50, 1)
		user.visible_message("<span class='warning'>[user] disassembles the gps.</span>", \
						"<span class='notice'>You start to disassemble the gps...</span>", "You hear clanking and banging noises.")
		if(do_after(user, 20*W.toolspeed, target = src))
			new /obj/item/device/gps(src.loc)
			qdel(src)
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
	luminosity = 8
	max_n_of_items = 10
	pixel_y = -4
	flags = NODECONSTRUCT

/obj/machinery/smartfridge/survival_pod/empty
	name = "dusty survival pod storage"
	desc = "A heated storage unit. This one's seen better days."

/obj/machinery/smartfridge/survival_pod/empty/New()
	return()

/obj/machinery/smartfridge/survival_pod/accept_check(obj/item/O)
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/survival_pod/New()
	..()
	for(var/i in 1 to 5)
		var/obj/item/weapon/reagent_containers/food/snacks/donkpocket/warm/W = new(src)
		load(W)
	if(prob(50))
		var/obj/item/weapon/storage/pill_bottle/dice/D = new(src)
		load(D)
	else
		var/obj/item/device/instrument/guitar/G = new(src)
		load(G)

//Fans
/obj/structure/fans
	icon = 'icons/obj/lavaland/survival_pod.dmi'
	icon_state = "fans"
	name = "environmental regulation system"
	desc = "A large machine releasing a constant gust of air."
	anchored = 1
	density = 1
	var/arbitraryatmosblockingvar = TRUE
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 5
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/fans/deconstruct()
	if(!(flags & NODECONSTRUCT))
		if(buildstacktype)
			new buildstacktype(loc,buildstackamount)
	qdel(src)

/obj/structure/fans/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
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
	density = 0
	icon_state = "fan_tiny"
	buildstackamount = 2

/obj/structure/fans/New(loc)
	..()
	air_update_turf(1)

/obj/structure/fans/Destroy()
	var/turf/T = loc
	. = ..()
	T.air_update_turf(1)


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
	anchored = 1
	layer = BELOW_MOB_LAYER
	density = 0

///Mining Base////

/area/shuttle/auxillary_base
	name = "Auxillary Base"
	luminosity = 0 //Lighting gets lost when it lands anyway

/obj/machinery/computer/shuttle/auxillary_base
	name = "auxillary base management console"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	shuttleId = "colony_drop"
	desc = "Allows a deployable expedition base to be dropped from the station to a designated mining location. It can also \
interface with the mining shuttle at the landing site if a mobile beacon is also deployed."
	var/launch_warning = TRUE

	req_one_access = list(access_cargo, access_construction, access_heads)
	possible_destinations = null
	clockwork = TRUE
	var/obj/item/device/gps/internal/base/locator

/obj/machinery/computer/shuttle/auxillary_base/New(location, obj/item/weapon/circuitboard/computer/shuttle/C)
	..()
	locator = new /obj/item/device/gps/internal/base(src)

/obj/machinery/computer/shuttle/auxillary_base/Topic(href, href_list)
	if(href_list["move"])
		if(z != ZLEVEL_STATION && shuttleId == "colony_drop")
			usr << "<span class='warning'>You can't move the base again!</span>"
			return 0
		if(launch_warning)
			say("<span class='danger'>Launch sequence activated! Prepare for drop!</span>")
			playsound(loc, 'sound/machines/warning-buzzer.ogg', 70, 0)
			launch_warning = FALSE
	..()



/obj/machinery/computer/shuttle/auxillary_base/onShuttleMove(turf/T1, rotation)
	..()
	if(z == ZLEVEL_MINING) //Avoids double logging and landing on other Z-levels due to badminnery
		feedback_add_details("colonies_dropped", "[x]|[y]|[z]") //Number of times a base has been dropped!

/obj/machinery/computer/shuttle/auxillary_base/proc/set_mining_mode()
	if(z == ZLEVEL_MINING) //The console switches to controlling the mining shuttle once landed.
		req_access = list()
		shuttleId = "mining" //The base can only be dropped once, so this gives the console a new purpose.
		possible_destinations = "mining_home;mining_away;landing_zone_dock"

/obj/item/device/assault_pod/mining
	name = "Landing Field Designator"
	icon_state = "gangtool-purple"
	item_state = "electronic"
	icon = 'icons/obj/device.dmi'
	desc = "Deploy to designate the landing zone of the auxillary base."
	w_class = WEIGHT_CLASS_SMALL
	shuttle_id = "colony_drop"
	var/setting = FALSE
	var/no_restrictions = FALSE //Badmin variable to let you drop the colony ANYWHERE.

/obj/item/device/assault_pod/mining/attack_self(mob/living/user)
	if(setting)
		return
	var/turf/T = get_turf(user)
	var/obj/docking_port/mobile/auxillary_base/base_dock = locate(/obj/docking_port/mobile/auxillary_base) in SSshuttle.mobile
	if(!base_dock) //Not all maps have an Aux base. This object is useless in that case.
		user << "<span class='warning'>This station is not equipped with an auxillary base. Please contact your Nanotrasen contractor.</span>"
		return
	if(!no_restrictions)
		if(T.z != ZLEVEL_MINING)
			user << "Wouldn't do much good dropping a mining base away from the mining area!"
			return
		var/colony_radius = max(width, height)*0.5
		var/list/area_counter = get_areas_in_range(colony_radius, T)
		if(area_counter.len > 1) //Avoid smashing ruins unless you are inside a really big one
			user << "Unable to acquire a targeting lock. Find an area clear of stuctures or entirely within one."
			return

	user << "<span class='notice'>You begin setting the landing zone parameters...</span>"
	setting = TRUE
	if(!do_after(user, 50, target = user)) //You get a few seconds to cancel if you do not want to drop there.
		setting = FALSE
		return

	var/area/A = get_area(T)

	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = "colony_drop(\ref[src])"
	landing_zone.name = "Landing Zone ([T.x], [T.y])"
	landing_zone.dwidth = base_dock.dwidth
	landing_zone.dheight = base_dock.dheight
	landing_zone.width = base_dock.width
	landing_zone.height = base_dock.height
	landing_zone.setDir(base_dock.dir)
	landing_zone.turf_type = T.type
	landing_zone.area_type = A.type

	for(var/obj/machinery/computer/shuttle/S in machines)
		if(S.shuttleId == shuttle_id)
			S.possible_destinations += "[landing_zone.id];"

//Serves as a nice mechanic to people get ready for the launch.
	minor_announce("Auxiliary base landing zone coordinates locked in for [get_area(user)]. Launch command now available!")
	user << "<span class='notice'>Landing zone set.</span>"

	qdel(src)

/obj/item/device/assault_pod/mining/unrestricted
	name = "omni-locational landing field designator"
	desc = "Allows the deployment of the mining base ANYWHERE. Use with caution."
	no_restrictions = TRUE


/obj/docking_port/mobile/auxillary_base
	name = "auxillary base"
	id = "colony_drop"
	//Reminder to map-makers to set these values equal to the size of your base.
	dheight = 4
	dwidth = 4
	width = 9
	height = 9
	var/anti_spam_cd = 0


/obj/structure/mining_shuttle_beacon
	name = "mining shuttle beacon"
	desc = "A bluespace beacon calibrated to mark a landing spot for the mining shuttle when deployed near the auxillary mining base."
	anchored = 0
	density = 0
	var/shuttle_ID = "landing_zone_dock"
	icon = 'icons/obj/objects.dmi'
	icon_state = "miningbeacon"
	var/obj/docking_port/stationary/Mport //Linked docking port for the mining shuttle
	pressure_resistance = 200 //So it does not get blown into lava.
	var/anti_spam_cd = 0 //The linking process might be a bit intensive, so this here to prevent over use.
	var/console_range = 15 //Wifi range of the beacon to find the aux base console

/obj/structure/mining_shuttle_beacon/attack_hand(mob/user)
	if(anchored)
		user << "<span class='warning'>Landing zone already set.</span>"
		return

	if(anti_spam_cd)
		user << "<span class='warning'>[src] is currently recalibrating. Please wait.</span>"
		return

	anti_spam_cd = 1
	addtimer(CALLBACK(src, .proc/clear_cooldown), 100)

	var/turf/landing_spot = get_turf(src)

	if(landing_spot.z != ZLEVEL_MINING)
		user << "<span class='warning'>This device is only to be used in a mining zone.</span>"
		return
	var/obj/machinery/computer/shuttle/auxillary_base/aux_base_console = locate(/obj/machinery/computer/shuttle/auxillary_base) in machines
	if(!aux_base_console || get_dist(landing_spot, aux_base_console) > console_range)
		user << "<span class='warning'>The auxillary base's console must be within [console_range] meters in order to interface.</span>"
		return //Needs to be near the base to serve as its dock and configure it to control the mining shuttle.

//Mining shuttles may not be created equal, so we find the map's shuttle dock and size accordingly.


	for(var/S in SSshuttle.stationary)
		var/obj/docking_port/stationary/SM = S //SM is declared outside so it can be checked for null
		if(SM.id == "mining_home" || SM.id == "mining_away")

			var/area/A = get_area(landing_spot)

			Mport = new(landing_spot)
			Mport.id = "landing_zone_dock"
			Mport.name = "auxillary base landing site"
			Mport.dwidth = SM.dwidth
			Mport.dheight = SM.dheight
			Mport.width = SM.width
			Mport.height = SM.height
			Mport.setDir(dir)
			Mport.turf_type = landing_spot.type
			Mport.area_type = A.type

			break
	if(!Mport)
		user << "<span class='warning'>This station is not equipped with an approprite mining shuttle. Please contact Nanotrasen Support.</span>"
		return
	var/search_radius = max(Mport.width, Mport.height)*0.5
	var/list/landing_areas = get_areas_in_range(search_radius, landing_spot)
	for(var/area/shuttle/auxillary_base/AB in landing_areas) //You land NEAR the base, not IN it.
		user << "<span class='warning'>The mining shuttle must not land within the mining base itself.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return
	var/obj/docking_port/mobile/mining_shuttle
	for(var/S in SSshuttle.mobile)
		var/obj/docking_port/mobile/MS = S
		if(MS.id != "mining")
			continue
		mining_shuttle = MS

	if(!mining_shuttle) //Not having a mining shuttle is a map issue
		user << "<span class='warning'>No mining shuttle signal detected. Please contact Nanotrasen Support.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return

	if(!mining_shuttle.canDock(Mport))
		user << "<span class='warning'>Unable to secure a valid docking zone. Please try again in an open area near, but not within the aux. mining base.</span>"
		SSshuttle.stationary.Remove(Mport)
		qdel(Mport)
		return

	aux_base_console.set_mining_mode() //Lets the colony park the shuttle there, now that it has a dock.
	user << "<span class='notice'>Mining shuttle calibration successful! Shuttle interface available at base console.</span>"
	anchored = 1 //Locks in place to mark the landing zone.
	playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)

/obj/structure/mining_shuttle_beacon/proc/clear_cooldown()
	anti_spam_cd = 0

/obj/structure/mining_shuttle_beacon/attack_robot(mob/user)
	return (attack_hand(user)) //So borgies can help
