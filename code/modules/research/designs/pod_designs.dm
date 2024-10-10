/datum/design/board/pod
	name = "Pod Control module"
	desc = "Needed to create space pods."
	id = "pod_board"
	build_path = /obj/item/circuitboard/pod
	category = list(
		RND_CATEGORY_SPACE_POD,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_ENGINEERING

/datum/design/pod_runner
	name = "Pod Frame Runner"
	id = "podrunner"
	build_type = PODLATHE|MECHFAB
	build_path = /obj/item/pod_runner
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
	)
	construction_time = 15 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_CHASSIS,
	)

/datum/design/pod_equipment
	id = DESIGN_ID_IGNORE
	build_type = PODLATHE|MECHFAB
	construction_time = 5 SECONDS

/datum/design/pod_equipment/warpdrive
	name = "Bluespace Warp drive"
	id = "podwarpdrive"
	build_path = /obj/item/pod_equipment/warp_drive
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/bluespace=SHEET_MATERIAL_AMOUNT*2,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT/2,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_MISC,
	)

/datum/design/pod_equipment/thrusters
	name = "Pod Ion Thruster Array"
	id = "podthruster1"
	build_path = /obj/item/pod_equipment/thrusters/default
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*2.5,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_THRUSTERS,
	)

/datum/design/pod_equipment/thrusters/tier2
	name = "Pod Cesium-Ion Thruster Array"
	id = "podthruster2"
	build_path = /obj/item/pod_equipment/thrusters/fast
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*5,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*7,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3.5,
	)

/datum/design/pod_equipment/thrusters/tier3
	name = "Overtuned Pod Thruster Array"
	id = "podthruster3"
	build_path = /obj/item/pod_equipment/thrusters/blazer
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*8,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*4.5,
	)

/datum/design/pod_equipment/engine/light
	name = "Light Ion Engine"
	id = "podengine1"
	build_path = /obj/item/pod_equipment/engine/light
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*1,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*1,
	)

/datum/design/pod_equipment/engine
	name = "Ion Engine"
	id = "podengine2"
	build_path = /obj/item/pod_equipment/engine/default
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6.5,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*2.5,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*2.5,
	)
	construction_time = 7 SECONDS
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_ENGINE,
	)

/datum/design/pod_equipment/engine/tier3
	name = "Deuterium Engine"
	id = "podengine3"
	build_path = /obj/item/pod_equipment/engine/fast
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*7.5,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*2,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT*1,
	)

/datum/design/pod_equipment/engine/tier4
	name = "Improved Deuterium Engine"
	id = "podengine4"
	build_path = /obj/item/pod_equipment/engine/faster
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*9,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT*2,
	)

/datum/design/pod_equipment/sensors
	name = /obj/item/pod_equipment/sensors::name
	id = "podsensors"
	build_path = /obj/item/pod_equipment/sensors
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*2,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SENSORS,
	)

/datum/design/pod_equipment/sensors/meson
	name = /obj/item/pod_equipment/sensors/mesons::name
	id = "podsensorsmesons"
	build_path = /obj/item/pod_equipment/sensors/mesons
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT*1,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SENSORS,
	)

/datum/design/pod_equipment/sensors/nv
	name = /obj/item/pod_equipment/sensors/nightvision::name
	id = "podsensorsnightvision"
	build_path = /obj/item/pod_equipment/sensors/nightvision
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/gold=SHEET_MATERIAL_AMOUNT,
		/datum/material/uranium=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SENSORS,
	)

/datum/design/pod_equipment/comms
	name = /obj/item/pod_equipment/comms::name
	id = "podcomms"
	build_path = /obj/item/pod_equipment/comms
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_COMMS,
	)

/datum/design/pod_equipment/cargo_hold
	name = /obj/item/pod_equipment/cargo_hold::name
	id = "podcargohold"
	build_path = /obj/item/pod_equipment/cargo_hold
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*7.5,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*5,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY,
	)

/datum/design/pod_equipment/extraseats
	name = /obj/item/pod_equipment/extra_seats::name
	id = "podextraseats"
	build_path = /obj/item/pod_equipment/extra_seats
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*3,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY,
	)

/datum/design/pod_equipment/pinlock
	name = /obj/item/pod_equipment/lock/pin::name
	id = "podpinlock"
	build_path = /obj/item/pod_equipment/lock/pin
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*0.5,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY,
	)

/datum/design/pod_equipment/dnalock
	name = /obj/item/pod_equipment/lock/dna::name
	id = "poddnalock"
	build_path = /obj/item/pod_equipment/lock/dna
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*0.75,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*0.5,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY,
	)

/datum/design/pod_equipment/orehold
	name = /obj/item/pod_equipment/orestorage::name
	id = "podorehold"
	build_path = /obj/item/pod_equipment/orestorage
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*3,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_SECONDARY,
	)

/datum/design/pod_equipment/lgtplating
	name = /obj/item/pod_equipment/armor::name
	id = "podlgtplating"
	build_path = /obj/item/pod_equipment/armor
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_MISC,
	)

/datum/design/pod_equipment/podefficiency
	name = /obj/item/pod_equipment/efficiency::name
	id = "podefficiency"
	build_path = /obj/item/pod_equipment/efficiency
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT,
		/datum/material/gold=HALF_SHEET_MATERIAL_AMOUNT,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_MISC,
	)

/datum/design/pod_equipment/plasma_cutter
	name = /obj/item/pod_equipment/primary/projectile_weapon/energy/plasma_cutter::name
	id = "podplasmacutter"
	build_path = /obj/item/pod_equipment/primary/projectile_weapon/energy/plasma_cutter
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*3,
		/datum/material/plasma=SHEET_MATERIAL_AMOUNT*4,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*1,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)

/datum/design/pod_equipment/foamtool
	name = /obj/item/pod_equipment/primary/metalfoam::name
	id = "podfoamtool"
	build_path = /obj/item/pod_equipment/primary/metalfoam
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*6,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)


/datum/design/pod_equipment/drill
	name = /obj/item/pod_equipment/primary/drill::name
	id = "poddrill"
	build_path = /obj/item/pod_equipment/primary/drill
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*12,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)

/datum/design/pod_equipment/impactdrill
	name = /obj/item/pod_equipment/primary/drill/impact::name
	id = "podimpactdrill"
	build_path = /obj/item/pod_equipment/primary/drill
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*12,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*5,
		/datum/material/plasma=SHEET_MATERIAL_AMOUNT*5,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)

/datum/design/pod_equipment/improvedimpactdrill
	name = /obj/item/pod_equipment/primary/drill/impact/improved::name
	id = "improvedimpactdrill"
	build_path = /obj/item/pod_equipment/primary/drill/impact/improved
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*12,
		/datum/material/titanium=SHEET_MATERIAL_AMOUNT*8,
		/datum/material/diamond=SHEET_MATERIAL_AMOUNT*3,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)

/datum/design/pod_equipment/wildlifegun
	name = /obj/item/pod_equipment/primary/projectile_weapon/energy/wildlife::name
	id = "podwildlifegun"
	build_path = /obj/item/pod_equipment/primary/projectile_weapon/energy/wildlife
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*8,
		/datum/material/glass=SHEET_MATERIAL_AMOUNT,
		/datum/material/plasma=SHEET_MATERIAL_AMOUNT*2,
	)
	category = list(
		RND_CATEGORY_MECHFAB_SPACEPOD + RND_SUBCATEGORY_MECHFAB_POD_PRIMARY,
	)
