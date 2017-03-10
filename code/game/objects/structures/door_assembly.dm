/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	anchored = TRUE
	density = 1
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 50
	var/mineral = null
	var/typetext = ""
	var/icontext = ""
	var/obj/item/weapon/electronics/airlock/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/created_name = null
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/material = null //icon state logic

/obj/structure/door_assembly/New()
	update_icon()
	..()

/obj/structure/door_assembly/Destroy()
	QDEL_NULL(electronics)
	return ..()

/obj/structure/door_assembly/door_assembly_0
	airlock_type = /obj/machinery/door/airlock

/obj/structure/door_assembly/door_assembly_com
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	typetext = "command"
	icontext = "com"
	glass_type = /obj/machinery/door/airlock/glass_command
	airlock_type = /obj/machinery/door/airlock/command

/obj/structure/door_assembly/door_assembly_com/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_sec
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	typetext = "security"
	icontext = "sec"
	glass_type = /obj/machinery/door/airlock/glass_security
	airlock_type = /obj/machinery/door/airlock/security

/obj/structure/door_assembly/door_assembly_sec/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_eng
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	typetext = "engineering"
	icontext = "eng"
	glass_type = /obj/machinery/door/airlock/glass_engineering
	airlock_type = /obj/machinery/door/airlock/engineering

/obj/structure/door_assembly/door_assembly_eng/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_min
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	typetext = "mining"
	icontext = "min"
	glass_type = /obj/machinery/door/airlock/glass_mining
	airlock_type = /obj/machinery/door/airlock/mining

/obj/structure/door_assembly/door_assembly_min/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_atmo
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	typetext = "atmos"
	icontext = "atmo"
	glass_type = /obj/machinery/door/airlock/glass_atmos
	airlock_type = /obj/machinery/door/airlock/atmos

/obj/structure/door_assembly/door_assembly_atmo/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_research
	name = "research airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	typetext = "research"
	icontext = "res"
	glass_type = /obj/machinery/door/airlock/glass_research
	airlock_type = /obj/machinery/door/airlock/research

/obj/structure/door_assembly/door_assembly_research/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_science
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	typetext = "science"
	icontext = "sci"
	glass_type = /obj/machinery/door/airlock/glass_science
	airlock_type = /obj/machinery/door/airlock/science

/obj/structure/door_assembly/door_assembly_science/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_med
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	typetext = "medical"
	icontext = "med"
	glass_type = /obj/machinery/door/airlock/glass_medical
	airlock_type = /obj/machinery/door/airlock/medical

/obj/structure/door_assembly/door_assembly_med/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_mai
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	typetext = "maintenance"
	icontext = "mai"
	glass_type = /obj/machinery/door/airlock/glass_maintenance
	airlock_type = /obj/machinery/door/airlock/maintenance

/obj/structure/door_assembly/door_assembly_mai/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_ext
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	typetext = "external"
	icontext = "ext"
	glass_type = /obj/machinery/door/airlock/glass_external
	airlock_type = /obj/machinery/door/airlock/external

/obj/structure/door_assembly/door_assembly_ext/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_fre
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	typetext = "freezer"
	icontext = "fre"
	airlock_type = /obj/machinery/door/airlock/freezer

/obj/structure/door_assembly/door_assembly_hatch
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	typetext = "hatch"
	icontext = "hatch"
	airlock_type = /obj/machinery/door/airlock/hatch

/obj/structure/door_assembly/door_assembly_mhatch
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	typetext = "maintenance_hatch"
	icontext = "mhatch"
	airlock_type = /obj/machinery/door/airlock/maintenance_hatch

/obj/structure/door_assembly/door_assembly_glass
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_gold
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	airlock_type = /obj/machinery/door/airlock/gold
	mineral = "gold"

/obj/structure/door_assembly/door_assembly_silver
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	airlock_type = /obj/machinery/door/airlock/silver
	mineral = "silver"

/obj/structure/door_assembly/door_assembly_diamond
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	airlock_type = /obj/machinery/door/airlock/diamond
	mineral = "diamond"

/obj/structure/door_assembly/door_assembly_uranium
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	airlock_type = /obj/machinery/door/airlock/uranium
	mineral = "uranium"

/obj/structure/door_assembly/door_assembly_plasma
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	airlock_type = /obj/machinery/door/airlock/plasma
	mineral = "plasma"

/obj/structure/door_assembly/door_assembly_clown
	desc = "Honk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	airlock_type = /obj/machinery/door/airlock/clown
	mineral = "bananium"

/obj/structure/door_assembly/door_assembly_sandstone
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	airlock_type = /obj/machinery/door/airlock/sandstone
	mineral = "sandstone"

/obj/structure/door_assembly/door_assembly_titanium
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	typetext = "titanium"
	icontext = "titanium"
	glass_type = /obj/machinery/door/airlock/glass_titanium
	airlock_type = /obj/machinery/door/airlock/titanium
	mineral = "titanium"

/obj/structure/door_assembly/door_assembly_titanium/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	typetext = "highsecurity"
	icontext = "highsec"
	airlock_type = /obj/machinery/door/airlock/highsecurity

/obj/structure/door_assembly/door_assembly_vault
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	typetext = "vault"
	icontext = "vault"
	airlock_type = /obj/machinery/door/airlock/vault

/obj/structure/door_assembly/door_assembly_shuttle
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	typetext = "shuttle"
	icontext = "shuttle"
	airlock_type = /obj/machinery/door/airlock/shuttle

/obj/structure/door_assembly/door_assembly_cult
	name = "cult airlock assembly"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
	typetext = "cult"
	icontext = "cult"
	airlock_type = /obj/machinery/door/airlock/cult

/obj/structure/door_assembly/door_assembly_cult/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/overlays.dmi'

/obj/structure/door_assembly/door_assembly_cult/unruned/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_wood
	name = "wooden airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	airlock_type = /obj/machinery/door/airlock/wood
	mineral = "wood"

/obj/structure/door_assembly/door_assembly_viro
	name = "virology airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	typetext = "virology"
	icontext = "viro"
	glass_type = /obj/machinery/door/airlock/glass_virology
	airlock_type = /obj/machinery/door/airlock/virology

/obj/structure/door_assembly/door_assembly_viro/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_centcom
	typetext = "centcom"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	icontext = "ele"
	airlock_type = /obj/machinery/door/airlock/centcom

/obj/structure/door_assembly/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter the name for the door.", src.name, src.created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t

	else if(istype(W, /obj/item/weapon/airlock_painter)) // |- Ricotez
	//INFORMATION ABOUT ADDING A NEW AIRLOCK TO THE PAINT LIST:
	//If your airlock has a regular version, add it to the list with regular versions.
	//If your airlock has a glass version, add it to the list with glass versions.
	//Don't forget to also set has_solid and has_glass to the proper value.
	//Do NOT add your airlock to a list if it does not have a version for that list,
	//	or you will get broken icons.
		var/obj/item/weapon/airlock_painter/WT = W
		if(WT.can_use(user))
			var/icontype
			var/optionlist
			if(mineral && mineral == "glass")
				//These airlocks have a glass version.
				optionlist = list("Public", "Public2", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Science", "Mining")
			else
				//These airlocks have a regular version.
				optionlist = list("Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Science", "Mining", "Maintenance", "External", "High Security")


			icontype = input(user, "Please select a paintjob for this airlock.") in optionlist
			if((!in_range(src, usr) && src.loc != usr) || !WT.use(user))
				return
			var/has_solid = 0
			var/has_glass = 0
			switch(icontype)
				if("Public")
					icon = 'icons/obj/doors/airlocks/station/public.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = ""
					icontext = ""
					has_solid = 1
					has_glass = 1
				if("Public2")
					icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
					typetext = ""
					icontext = ""
					has_solid = 1
					has_glass = 1
				if("Engineering")
					icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "engineering"
					icontext = "eng"
					has_solid = 1
					has_glass = 1
				if("Atmospherics")
					icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "atmos"
					icontext = "atmo"
					has_solid = 1
					has_glass = 1
				if("Security")
					icon = 'icons/obj/doors/airlocks/station/security.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "security"
					icontext = "sec"
					has_solid = 1
					has_glass = 1
				if("Command")
					icon = 'icons/obj/doors/airlocks/station/command.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "command"
					icontext = "com"
					has_solid = 1
					has_glass = 1
				if("Medical")
					icon = 'icons/obj/doors/airlocks/station/medical.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "medical"
					icontext = "med"
					has_solid = 1
					has_glass = 1
				if("Research")
					icon = 'icons/obj/doors/airlocks/station/research.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "research"
					icontext = "res"
					has_solid = 1
					has_glass = 1
				if("Science")
					icon = 'icons/obj/doors/airlocks/station/science.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "research"
					icontext = "res"
					has_solid = 1
					has_glass = 1
				if("Mining")
					icon = 'icons/obj/doors/airlocks/station/mining.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "mining"
					icontext = "min"
					has_solid = 1
					has_glass = 1
				if("Maintenance")
					icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "maintenance"
					icontext = "mai"
					has_solid = 1
					has_glass = 0
				if("External")
					icon = 'icons/obj/doors/airlocks/external/external.dmi'
					overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
					typetext = "external"
					icontext = "ext"
					has_solid = 1
					has_glass = 0
				if("High Security")
					icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
					overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
					typetext = "highsecurity"
					icontext = "highsec"
					has_solid = 1
					has_glass = 0
			if(has_solid)
				airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
			else
				airlock_type = /obj/machinery/door/airlock

			if(has_glass)
				glass_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
			else
				glass_type = /obj/machinery/door/airlock/glass

			if(mineral && mineral != "glass")
				mineral = null //I know this is stupid, but until we change glass to a boolean it's how this code works.
			to_chat(user, "<span class='notice'>You change the paintjob on the airlock assembly.</span>")

CONSTRUCTION_BLUEPRINT(/obj/structure/door_assembly)
	return newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/stack/sheet/metal
			required_amount_to_construct = 4
			one_per_turf = 1
			on_floor = 1
		},
		/datum/construction_state/last{
			required_type_to_construct = /obj/item/weapon/wrench
			required_type_to_deconstruct = /obj/item/weapon/weldingtool
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "securing"
			deconstruction_message = "disassembling"
			examine_message = "It's not bolted in"
			anchored = 0
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/stack/cable_coil
			required_amount_to_construct = 1
			required_type_to_deconstruct = /obj/item/weapon/wrench
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "wiring"
			deconstruction_message = "unsecuring"
			examine_message = "It's unwired"
			anchored = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/electronics/airlock
			required_amount_to_construct = 1
			required_type_to_deconstruct = /obj/item/weapon/wirecutters
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "installing the electronics into"
			deconstruction_message = "cutting the wires from"
			examine_message = "It's missing its circuitry"
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/stack/sheet
			required_amount_to_construct = 2
			required_type_to_deconstruct = /obj/item/weapon/crowbar
			construction_delay = 40
			deconstruction_delay = 40
			construction_sound = 'sound/items/Crowbar.ogg'
			construction_message = "adding the finish to"
			deconstruction_message = "removing the electronics from"
			examine_message = "It's missing a finishing cover"
			damage_reachable = 1
		},
		/datum/construction_state/last{
			required_type_to_construct = /obj/item/weapon/screwdriver
			required_type_to_deconstruct = /obj/item/weapon/crowbar
			required_type_to_repair = /obj/item/weapon/weldingtool
			construction_delay = 40
			deconstruction_delay = 40
			repair_delay = 40
			construction_message = "completing"
			deconstruction_message = "removing the finish from"
			examine_message = "It has a bunch of loose screws"
		}
	)
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/metal

/obj/structure/door_assembly/ConstructionChecks(state_started_id, constructing, obj/item/I, mob/user, skip)
	. = ..()
	if(!. || skip)
		return
	switch(state_started_id)
		if(AIRLOCK_ASSEMBLY_UNSECURED)
			if(constructing)
				for(var/obj/machinery/door/D in loc)
					if(!D.sub_door)
						to_chat(user, "<span class='warning'>There is another door here!</span>")
						return FALSE
		if(AIRLOCK_ASSEMBLY_ELECTRONICS)
			var/static/list/valid_subtypes = typecacheof(list(/obj/item/stack/sheet/rglass, /obj/item/stack/sheet/glass, /obj/item/stack/sheet/mineral))
			if(!is_type_in_typecache(I, valid_subtypes))
				to_chat(user, "<span class='warning'>This material cannot be used as a finish!</span>")
				return FALSE
		if(0)
			//disallow if broken
			if(obj_integrity <= integrity_failure)
				to_chat(user, "<span class='warning'>[src] is too damaged to complete!</span>")
				return FALSE

/obj/structure/door_assembly/OnConstruction(state_id, mob/user, obj/item/used)
	switch(state_id)
		if(AIRLOCK_ASSEMBLY_PLATED)
			heat_proof_finished = istype(used, /obj/item/stack/sheet/rglass)
			if(heat_proof_finished || istype(used, /obj/item/stack/sheet/glass))
				mineral = "glass"
				material = "glass"

				//This list contains the airlock paintjobs that have a glass version:
				if(icontext in list("eng", "atmo", "sec", "com", "med", "res", "min"))
					airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
					glass_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
				else
					//This airlock is default or does not have a glass version, so we revert to the default glass airlock. |- Ricotez
					airlock_type = /obj/machinery/door/airlock
					glass_type = /obj/machinery/door/airlock/glass
					typetext = ""
					icontext = ""

			else if(istype(used, /obj/item/stack/sheet/mineral))
				var/obj/item/stack/sheet/G = used
				var/M = G.sheettype
				mineral = "[M]"
				name = "near finished [M] airlock assembly"
				airlock_type = text2path ("/obj/machinery/door/airlock/[M]")
				glass_type = /obj/machinery/door/airlock/glass
			else
				stack_trace("door_assembly construction: How the hell did we get here? Blame Cyberboss!")
		if(AIRLOCK_ASSEMBLY_ELECTRONICS)
			electronics = used
			user.transferItemToLoc(used, src)
			. = TRUE
		if(0)	//locked in, create airlock
			var/obj/machinery/door/airlock/door

			if(mineral == "glass")
				door = new glass_type(loc)
			else
				door = new airlock_type(loc)

			door.heat_proof = heat_proof_finished
			if(electronics.one_access)
				door.req_one_access = electronics.accesses
			else
				door.req_access = electronics.accesses

			electronics.forceMove(door)
			door.electronics = electronics
			electronics = null

			if(created_name)
				door.name = created_name

			qdel(src)
			return
	update_icon()

/obj/structure/door_assembly/OnDeconstruction(state_id, mob/user, obj/item/created, forced)
	switch(state_id)
		if(AIRLOCK_ASSEMBLY_WIRED)
			if(electronics)
				if(!forced)
					electronics.forceMove(get_turf(src))
				else
					qdel(electronics)
				electronics = null
			. = TRUE
		if(AIRLOCK_ASSEMBLY_ELECTRONICS)
			var/T = get_turf(src)
			if (mineral == "glass")
				if(!forced)
					if (heat_proof_finished)
						new /obj/item/stack/sheet/rglass(T, 2)
					else
						new /obj/item/stack/sheet/glass(T, 2)
				else
					new /obj/item/weapon/shard(T, 2)
			else if(!forced)
				var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new mineral_path(T, 2)
			mineral = null
			. = TRUE
	update_icon()

/obj/structure/door_assembly/examine(mob/user)
	..()
	if(mineral)
		to_chat(user, "It has a [mineral] finish.")

/obj/structure/door_assembly/update_icon()
	cut_overlays()
	if(!material)
		add_overlay(get_airlock_overlay("fill_construction", icon))
	else
		add_overlay(get_airlock_overlay("[material]_construction", overlays_file))
	var/state
	switch(current_construction_state.id)
		if(AIRLOCK_ASSEMBLY_UNSECURED)
			state = 1
		if(AIRLOCK_ASSEMBLY_SECURED)
			state = 1
		if(AIRLOCK_ASSEMBLY_WIRED)
			state = 2
		if(AIRLOCK_ASSEMBLY_ELECTRONICS)
			state = 3
		if(AIRLOCK_ASSEMBLY_PLATED)
			state = 3
	add_overlay(get_airlock_overlay("panel_c[state]", overlays_file))