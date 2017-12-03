/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	var/base_name = "airlock"
	var/mineral = null
	var/obj/item/electronics/airlock/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0 // 0 = glass can be installed. 1 = glass is already installed.
	var/created_name = null
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/previous_assembly = /obj/structure/door_assembly
	var/noglass = FALSE //airlocks with no glass version, also cannot be modified with sheets
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

/obj/structure/door_assembly/New()
	update_icon()
	update_name()
	..()

/obj/structure/door_assembly/door_assembly_public
	name = "public airlock assembly"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/public/glass
	airlock_type = /obj/machinery/door/airlock/public

/obj/structure/door_assembly/door_assembly_com
	name = "command airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	base_name = "command airlock"
	glass_type = /obj/machinery/door/airlock/glass_command
	airlock_type = /obj/machinery/door/airlock/command

/obj/structure/door_assembly/door_assembly_sec
	name = "security airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	base_name = "security airlock"
	glass_type = /obj/machinery/door/airlock/glass_security
	airlock_type = /obj/machinery/door/airlock/security

/obj/structure/door_assembly/door_assembly_eng
	name = "engineering airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	base_name = "engineering airlock"
	glass_type = /obj/machinery/door/airlock/glass_engineering
	airlock_type = /obj/machinery/door/airlock/engineering

/obj/structure/door_assembly/door_assembly_min
	name = "mining airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	base_name = "mining airlock"
	glass_type = /obj/machinery/door/airlock/glass_mining
	airlock_type = /obj/machinery/door/airlock/mining

/obj/structure/door_assembly/door_assembly_atmo
	name = "atmospherics airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	base_name = "atmospherics airlock"
	glass_type = /obj/machinery/door/airlock/glass_atmos
	airlock_type = /obj/machinery/door/airlock/atmos

/obj/structure/door_assembly/door_assembly_research
	name = "research airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	base_name = "research airlock"
	glass_type = /obj/machinery/door/airlock/glass_research
	airlock_type = /obj/machinery/door/airlock/research

/obj/structure/door_assembly/door_assembly_science
	name = "science airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	base_name = "science airlock"
	glass_type = /obj/machinery/door/airlock/glass_science
	airlock_type = /obj/machinery/door/airlock/science

/obj/structure/door_assembly/door_assembly_med
	name = "medical airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	base_name = "medical airlock"
	glass_type = /obj/machinery/door/airlock/glass_medical
	airlock_type = /obj/machinery/door/airlock/medical

/obj/structure/door_assembly/door_assembly_mai
	name = "maintenance airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	base_name = "maintenance airlock"
	glass_type = /obj/machinery/door/airlock/glass_maintenance
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

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	name = "high security airlock assembly"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	base_name = "high security airlock"
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/highsecurity
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 6

/obj/structure/door_assembly/door_assembly_vault
	name = "vault door assembly"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	base_name = "vault door"
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/vault
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 8

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
	glass_type = /obj/machinery/door/airlock/glass_virology
	airlock_type = /obj/machinery/door/airlock/virology

/obj/structure/door_assembly/door_assembly_centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/centcom
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
	airlock_type = /obj/machinery/door/airlock/clown
	mineral = "bananium"
	glass_type = /obj/machinery/door/airlock/clown/glass

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

/obj/structure/door_assembly/examine(mob/user)
	..()
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				to_chat(user, "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>")
			else
				to_chat(user, "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			to_chat(user, "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>")
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			to_chat(user, "<span class='notice'>The circuit is <b>connected loosely</b> to its slot, but the maintenance panel is <i>unscrewed and open</i>.</span>")
	if(!mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly. There are <i>empty</i> slots for glass windows and mineral covers.</span>")
	else if(!mineral && glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly. There are <i>empty</i> slots for mineral covers.</span>")
	else if(mineral && !glass && !noglass)
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly. There are <i>empty</i> slots for glass windows.</span>")
	else
		to_chat(user, "<span class='notice'>There is a small <i>paper</i> placard on the assembly.</span>")

/obj/structure/door_assembly/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		var/t = stripped_input(user, "Enter the name for the door.", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t

	else if(istype(W, /obj/item/weldingtool) && (mineral || glass || !anchored ))
		var/obj/item/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(src, 'sound/items/welder2.ogg', 50, 1)
			if(mineral)
				var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				user.visible_message("[user] welds the [mineral] plating off the airlock assembly.", "You start to weld the [mineral] plating off the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the [mineral] plating off.</span>")
					new mineral_path(loc, 2)
					var/obj/structure/door_assembly/PA = new previous_assembly(loc)
					transfer_assembly_vars(src, PA)

			else if(glass)
				user.visible_message("[user] welds the glass panel out of the airlock assembly.", "You start to weld the glass panel out of the airlock assembly...")
				if(do_after(user, 40 * WT.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You weld the glass panel out.</span>")
					if(heat_proof_finished)
						new /obj/item/stack/sheet/rglass(get_turf(src))
						heat_proof_finished = 0
					else
						new /obj/item/stack/sheet/glass(get_turf(src))
					glass = 0
			else if(!anchored)
				user.visible_message("<span class='warning'>[user] disassembles the airlock assembly.</span>", \
									"You start to disassemble the airlock assembly...")
				if(do_after(user, 40*W.toolspeed, target = src))
					if(!WT.isOn())
						return
					to_chat(user, "<span class='notice'>You disassemble the airlock assembly.</span>")
					deconstruct(TRUE)

	else if(istype(W, /obj/item/wrench))
		if(!anchored )
			var/door_check = 1
			for(var/obj/machinery/door/D in loc)
				if(!D.sub_door)
					door_check = 0
					break

			if(door_check)
				playsound(src, W.usesound, 100, 1)
				user.visible_message("[user] secures the airlock assembly to the floor.", \
									 "<span class='notice'>You start to secure the airlock assembly to the floor...</span>", \
									 "<span class='italics'>You hear wrenching.</span>")

				if(do_after(user, 40*W.toolspeed, target = src))
					if(anchored)
						return
					to_chat(user, "<span class='notice'>You secure the airlock assembly.</span>")
					name = "secured airlock assembly"
					anchored = TRUE
			else
				to_chat(user, "There is another door here!")

		else
			playsound(src, W.usesound, 100, 1)
			user.visible_message("[user] unsecures the airlock assembly from the floor.", \
								 "<span class='notice'>You start to unsecure the airlock assembly from the floor...</span>", \
								 "<span class='italics'>You hear wrenching.</span>")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(!anchored )
					return
				to_chat(user, "<span class='notice'>You unsecure the airlock assembly.</span>")
				name = "airlock assembly"
				anchored = FALSE

	else if(istype(W, /obj/item/stack/cable_coil) && state == AIRLOCK_ASSEMBLY_NEEDS_WIRES && anchored )
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of cable to wire the airlock assembly!</span>")
			return
		user.visible_message("[user] wires the airlock assembly.", \
							"<span class='notice'>You start to wire the airlock assembly...</span>")
		if(do_after(user, 40, target = src))
			if(C.get_amount() < 1 || state != AIRLOCK_ASSEMBLY_NEEDS_WIRES)
				return
			C.use(1)
			state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
			to_chat(user, "<span class='notice'>You wire the airlock assembly.</span>")
			name = "wired airlock assembly"

	else if(istype(W, /obj/item/wirecutters) && state == AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS )
		playsound(src, W.usesound, 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", \
							"<span class='notice'>You start to cut the wires from the airlock assembly...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if(state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
				return
			to_chat(user, "<span class='notice'>You cut the wires from the airlock assembly.</span>")
			new/obj/item/stack/cable_coil(get_turf(user), 1)
			state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
			name = "secured airlock assembly"

	else if(istype(W, /obj/item/electronics/airlock) && state == AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS )
		playsound(src, W.usesound, 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", \
							"<span class='notice'>You start to install electronics into the airlock assembly...</span>")
		if(do_after(user, 40, target = src))
			if( state != AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS )
				return
			if(!user.transferItemToLoc(W, src))
				return

			to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
			state = AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER
			name = "near finished airlock assembly"
			electronics = W


	else if(istype(W, /obj/item/crowbar) && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		playsound(src, W.usesound, 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
								"<span class='notice'>You start to remove electronics from the airlock assembly...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if(state != AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
				return
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
			state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
			name = "wired airlock assembly"
			var/obj/item/electronics/airlock/ae
			if (!electronics)
				ae = new/obj/item/electronics/airlock( loc )
			else
				ae = electronics
				electronics = null
				ae.forceMove(src.loc)

	else if(istype(W, /obj/item/stack/sheet) && (!glass || !mineral))
		var/obj/item/stack/sheet/G = W
		if(G)
			if(G.get_amount() >= 1)
				if(!noglass)
					if(!glass)
						if(istype(G, /obj/item/stack/sheet/rglass) || istype(G, /obj/item/stack/sheet/glass))
							playsound(src, 'sound/items/crowbar.ogg', 100, 1)
							user.visible_message("[user] adds [G.name] to the airlock assembly.", \
												"<span class='notice'>You start to install [G.name] into the airlock assembly...</span>")
							if(do_after(user, 40, target = src))
								if(G.get_amount() < 1 || glass)
									return
								if(G.type == /obj/item/stack/sheet/rglass)
									to_chat(user, "<span class='notice'>You install [G.name] windows into the airlock assembly.</span>")
									heat_proof_finished = 1 //reinforced glass makes the airlock heat-proof
									name = "near finished heat-proofed window airlock assembly"
								else
									to_chat(user, "<span class='notice'>You install regular glass windows into the airlock assembly.</span>")
									name = "near finished window airlock assembly"
								G.use(1)
								glass = TRUE
					if(!mineral)
						if(istype(G, /obj/item/stack/sheet/mineral) && G.sheettype)
							var/M = G.sheettype
							if(G.get_amount() >= 2)
								playsound(src, 'sound/items/crowbar.ogg', 100, 1)
								user.visible_message("[user] adds [G.name] to the airlock assembly.", \
												 "<span class='notice'>You start to install [G.name] into the airlock assembly...</span>")
								if(do_after(user, 40, target = src))
									if(G.get_amount() < 2 || mineral)
										return
									to_chat(user, "<span class='notice'>You install [M] plating into the airlock assembly.</span>")
									G.use(2)
									var/mineralassembly = text2path("/obj/structure/door_assembly/door_assembly_[M]")
									var/obj/structure/door_assembly/MA = new mineralassembly(loc)
									transfer_assembly_vars(src, MA, TRUE)
							else
								to_chat(user, "<span class='warning'>You need at least two sheets add a mineral cover!</span>")
					else
						to_chat(user, "<span class='warning'>You cannot add [G] to [src]!</span>")
				else
					to_chat(user, "<span class='warning'>You cannot add [G] to [src]!</span>")

	else if(istype(W, /obj/item/screwdriver) && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER )
		playsound(src, W.usesound, 100, 1)
		user.visible_message("[user] finishes the airlock.", \
							 "<span class='notice'>You start finishing the airlock...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if(loc && state == AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
				to_chat(user, "<span class='notice'>You finish the airlock.</span>")
				var/obj/machinery/door/airlock/door
				if(glass)
					door = new glass_type( loc )
				else
					door = new airlock_type( loc )
				door.setDir(dir)
				//door.req_access = req_access
				door.electronics = electronics
				door.heat_proof = heat_proof_finished
				if(electronics.one_access)
					door.req_one_access = electronics.accesses
				else
					door.req_access = electronics.accesses
				if(created_name)
					door.name = created_name
				else
					door.name = base_name
				door.previous_airlock = previous_assembly
				electronics.forceMove(door)
				qdel(src)
	else
		return ..()
	update_name()
	update_icon()

/obj/structure/door_assembly/update_icon()
	cut_overlays()
	if(!glass)
		add_overlay(get_airlock_overlay("fill_construction", icon))
	else if(glass)
		add_overlay(get_airlock_overlay("glass_construction", overlays_file))
	add_overlay(get_airlock_overlay("panel_c[state+1]", overlays_file))

/obj/structure/door_assembly/proc/update_name()
	name = ""
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				name = "secured "
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			name = "wired "
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass ? "window " : ""][base_name] assembly"

/obj/structure/door_assembly/proc/transfer_assembly_vars(obj/structure/door_assembly/source, obj/structure/door_assembly/target, previous = FALSE)
	target.glass = source.glass
	target.heat_proof_finished = source.heat_proof_finished
	target.created_name = source.created_name
	target.state = source.state
	target.anchored = source.anchored
	if(previous)
		target.previous_assembly = source.type
	if(electronics)
		target.electronics = source.electronics
		source.electronics.forceMove(target)
	target.update_icon()
	target.update_name()
	qdel(source)

/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(!disassembled)
			material_amt = rand(2,4)
		new material_type(T, material_amt)
		if(glass)
			if(disassembled)
				if(heat_proof_finished)
					new /obj/item/stack/sheet/rglass(T)
				else
					new /obj/item/stack/sheet/glass(T)
			else
				new /obj/item/shard(T)
		if(mineral)
			var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
			new mineral_path(T, 2)
	qdel(src)
