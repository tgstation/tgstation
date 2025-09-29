/obj/structure/door_assembly/door_assembly_public
	name = "public airlock assembly"
	icon = 'icons/obj/doors/airlocks/public/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/public/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/public/glass
	airlock_type = /obj/machinery/door/airlock/public

/obj/structure/door_assembly/door_assembly_com
	name = "command airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	base_name = "command airlock"
	glass_type = /obj/machinery/door/airlock/command/glass
	airlock_type = /obj/machinery/door/airlock/command

/obj/structure/door_assembly/door_assembly_sec
	name = "security airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	base_name = "security airlock"
	glass_type = /obj/machinery/door/airlock/security/glass
	airlock_type = /obj/machinery/door/airlock/security

/obj/structure/door_assembly/door_assembly_eng
	name = "engineering airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	base_name = "engineering airlock"
	glass_type = /obj/machinery/door/airlock/engineering/glass
	airlock_type = /obj/machinery/door/airlock/engineering

/obj/structure/door_assembly/door_assembly_min
	name = "mining airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	base_name = "mining airlock"
	glass_type = /obj/machinery/door/airlock/mining/glass
	airlock_type = /obj/machinery/door/airlock/mining

/obj/structure/door_assembly/door_assembly_atmo
	name = "atmospherics airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	base_name = "atmospherics airlock"
	glass_type = /obj/machinery/door/airlock/atmos/glass
	airlock_type = /obj/machinery/door/airlock/atmos

/obj/structure/door_assembly/door_assembly_research
	name = "research airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	base_name = "research airlock"
	glass_type = /obj/machinery/door/airlock/research/glass
	airlock_type = /obj/machinery/door/airlock/research

/obj/structure/door_assembly/door_assembly_science
	name = "science airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	base_name = "science airlock"
	glass_type = /obj/machinery/door/airlock/science/glass
	airlock_type = /obj/machinery/door/airlock/science

/obj/structure/door_assembly/door_assembly_med
	name = "medical airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	base_name = "medical airlock"
	glass_type = /obj/machinery/door/airlock/medical/glass
	airlock_type = /obj/machinery/door/airlock/medical

/obj/structure/door_assembly/door_assembly_hydro
	name = "hydroponics airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/hydroponics.dmi'
	base_name = "hydroponics airlock"
	glass_type = /obj/machinery/door/airlock/hydroponics/glass
	airlock_type = /obj/machinery/door/airlock/hydroponics

/obj/structure/door_assembly/door_assembly_mai
	name = "maintenance airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	base_name = "maintenance airlock"
	glass_type = /obj/machinery/door/airlock/maintenance/glass
	airlock_type = /obj/machinery/door/airlock/maintenance

/obj/structure/door_assembly/door_assembly_extmai
	name = "external maintenance airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
	base_name = "external maintenance airlock"
	glass_type = /obj/machinery/door/airlock/maintenance/external/glass
	airlock_type = /obj/machinery/door/airlock/maintenance/external

/obj/structure/door_assembly/door_assembly_ext
	name = "external airlock assembly"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	base_name = "external airlock"
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/external/glass
	airlock_type = /obj/machinery/door/airlock/external

/obj/structure/door_assembly/door_assembly_fre
	name = "freezer airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	base_name = "freezer airlock"
	airlock_type = /obj/machinery/door/airlock/freezer
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_hatch
	name = "airtight hatch assembly"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	base_name = "airtight hatch"
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/hatch
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_mhatch
	name = "maintenance hatch assembly"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	base_name = "maintenance hatch"
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/maintenance_hatch
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_highsecurity
	name = "high security airlock assembly"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	base_name = "high security airlock"
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/highsecurity
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 4
	custom_materials = list(/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 4)

/obj/structure/door_assembly/door_assembly_vault
	name = "vault door assembly"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	base_name = "vault door"
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/vault
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 6
	custom_materials = list(/datum/material/alloy/plasteel = SHEET_MATERIAL_AMOUNT * 6)

/obj/structure/door_assembly/door_assembly_shuttle
	name = "shuttle airlock assembly"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	base_name = "shuttle airlock"
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/shuttle
	glass_type = /obj/machinery/door/airlock/shuttle/glass

/obj/structure/door_assembly/door_assembly_cult
	name = "cult airlock assembly"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	base_name = "cult airlock"
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/cult
	glass_type = /obj/machinery/door/airlock/cult/glass

/obj/structure/door_assembly/door_assembly_cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/cult/unruned
	glass_type = /obj/machinery/door/airlock/cult/unruned/glass

/obj/structure/door_assembly/door_assembly_viro
	name = "virology airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	base_name = "virology airlock"
	glass_type = /obj/machinery/door/airlock/virology/glass
	airlock_type = /obj/machinery/door/airlock/virology

/obj/structure/door_assembly/door_assembly_centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/centcom
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_grunge
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/grunge
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_gold
	name = "gold airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	base_name = "gold airlock"
	airlock_type = /obj/machinery/door/airlock/gold
	mineral = "gold"
	glass_type = /obj/machinery/door/airlock/gold/glass

/obj/structure/door_assembly/door_assembly_silver
	name = "silver airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	base_name = "silver airlock"
	airlock_type = /obj/machinery/door/airlock/silver
	mineral = "silver"
	glass_type = /obj/machinery/door/airlock/silver/glass

/obj/structure/door_assembly/door_assembly_diamond
	name = "diamond airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	base_name = "diamond airlock"
	airlock_type = /obj/machinery/door/airlock/diamond
	mineral = "diamond"
	glass_type = /obj/machinery/door/airlock/diamond/glass

/obj/structure/door_assembly/door_assembly_uranium
	name = "uranium airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	base_name = "uranium airlock"
	airlock_type = /obj/machinery/door/airlock/uranium
	mineral = "uranium"
	glass_type = /obj/machinery/door/airlock/uranium/glass

/obj/structure/door_assembly/door_assembly_plasma
	name = "plasma airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	base_name = "plasma airlock"
	airlock_type = /obj/machinery/door/airlock/plasma
	mineral = "plasma"
	glass_type = /obj/machinery/door/airlock/plasma/glass

/obj/structure/door_assembly/door_assembly_bananium
	name = "bananium airlock assembly"
	desc = "Honk."
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	base_name = "bananium airlock"
	airlock_type = /obj/machinery/door/airlock/bananium
	mineral = "bananium"
	glass_type = /obj/machinery/door/airlock/bananium/glass

/obj/structure/door_assembly/door_assembly_sandstone
	name = "sandstone airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	base_name = "sandstone airlock"
	airlock_type = /obj/machinery/door/airlock/sandstone
	mineral = "sandstone"
	glass_type = /obj/machinery/door/airlock/sandstone/glass

/obj/structure/door_assembly/door_assembly_titanium
	name = "titanium airlock assembly"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	base_name = "shuttle airlock"
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/titanium/glass
	airlock_type = /obj/machinery/door/airlock/titanium
	mineral = "titanium"

/obj/structure/door_assembly/door_assembly_wood
	name = "wooden airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	base_name = "wooden airlock"
	airlock_type = /obj/machinery/door/airlock/wood
	mineral = "wood"
	glass_type = /obj/machinery/door/airlock/wood/glass

/obj/structure/door_assembly/door_assembly_bronze
	name = "bronze airlock assembly"
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	base_name = "bronze airlock"
	airlock_type = /obj/machinery/door/airlock/bronze
	noglass = TRUE
	material_type = /obj/item/stack/sheet/bronze
	custom_materials = list(/datum/material/bronze = SHEET_MATERIAL_AMOUNT * 4)

/obj/structure/door_assembly/door_assembly_bronze/seethru
	airlock_type = /obj/machinery/door/airlock/bronze/seethru

/obj/structure/door_assembly/door_assembly_material
	name = "airlock assembly"
	airlock_type = /obj/machinery/door/airlock/material
	glass_type = /obj/machinery/door/airlock/material/glass
	greyscale_config = /datum/greyscale_config/material_airlock
	nomineral = TRUE
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_AFFECT_STATISTICS

/obj/structure/door_assembly/multi_tile/door_assembly_public
	name = "large public airlock assembly"
	base_name = "large public airlock"

/obj/structure/door_assembly/multi_tile/door_assembly_tram
	name = "tram door assembly"
	icon = 'icons/obj/doors/airlocks/tram/tram.dmi'
	base_name = "tram door"
	overlays_file = 'icons/obj/doors/airlocks/tram/tram-overlays.dmi'
	glass_type = /obj/machinery/door/airlock/tram
	airlock_type = /obj/machinery/door/airlock/tram
	glass = FALSE
	noglass = TRUE
	mineral = "titanium"
	material_type = /obj/item/stack/sheet/mineral/titanium
	custom_materials = list(/datum/material/titanium = SHEET_MATERIAL_AMOUNT * 8)

/obj/structure/door_assembly/door_assembly_material/atom_deconstruct(disassembled = TRUE)
	var/turf/target_turf = get_turf(src)
	for(var/datum/material/material_datum as anything in custom_materials)
		var/material_count = FLOOR(custom_materials[material_datum] / SHEET_MATERIAL_AMOUNT, 1)
		if(!disassembled)
			material_count = rand(FLOOR(material_count/2, 1), material_count)
		new material_datum.sheet_type(target_turf, material_count)
	if(glass)
		if(disassembled)
			if(heat_proof_finished)
				new /obj/item/stack/sheet/rglass(target_turf)
			else
				new /obj/item/stack/sheet/glass(target_turf)
		else
			new /obj/item/shard(target_turf)

/obj/structure/door_assembly/door_assembly_material/finish_door()
	var/obj/machinery/door/airlock/door = ..()
	door.set_custom_materials(custom_materials)
	door.update_appearance()
	return door
