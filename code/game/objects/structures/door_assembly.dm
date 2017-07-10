/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/state = 0
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

/obj/structure/door_assembly/door_assembly_0
	name = "airlock assembly"
	airlock_type = /obj/machinery/door/airlock
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_com
	name = "command airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	typetext = "command"
	icontext = "com"
	glass_type = /obj/machinery/door/airlock/glass_command
	airlock_type = /obj/machinery/door/airlock/command
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_com/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_sec
	name = "security airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	typetext = "security"
	icontext = "sec"
	glass_type = /obj/machinery/door/airlock/glass_security
	airlock_type = /obj/machinery/door/airlock/security
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_sec/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_eng
	name = "engineering airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	typetext = "engineering"
	icontext = "eng"
	glass_type = /obj/machinery/door/airlock/glass_engineering
	airlock_type = /obj/machinery/door/airlock/engineering
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_eng/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_min
	name = "mining airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	typetext = "mining"
	icontext = "min"
	glass_type = /obj/machinery/door/airlock/glass_mining
	airlock_type = /obj/machinery/door/airlock/mining
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_min/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_atmo
	name = "atmospherics airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	typetext = "atmos"
	icontext = "atmo"
	glass_type = /obj/machinery/door/airlock/glass_atmos
	airlock_type = /obj/machinery/door/airlock/atmos
	anchored = TRUE
	state = 1

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
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_research/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_science
	name = "science airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	typetext = "science"
	icontext = "sci"
	glass_type = /obj/machinery/door/airlock/glass_science
	airlock_type = /obj/machinery/door/airlock/science
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_science/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_med
	name = "medical airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	typetext = "medical"
	icontext = "med"
	glass_type = /obj/machinery/door/airlock/glass_medical
	airlock_type = /obj/machinery/door/airlock/medical
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_med/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_mai
	name = "maintenance airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	typetext = "maintenance"
	icontext = "mai"
	glass_type = /obj/machinery/door/airlock/glass_maintenance
	airlock_type = /obj/machinery/door/airlock/maintenance
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_mai/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_ext
	name = "external airlock assembly"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	typetext = "external"
	icontext = "ext"
	glass_type = /obj/machinery/door/airlock/glass_external
	airlock_type = /obj/machinery/door/airlock/external
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_ext/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_fre
	name = "freezer airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	typetext = "freezer"
	icontext = "fre"
	airlock_type = /obj/machinery/door/airlock/freezer
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_hatch
	name = "airtight hatch assembly"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	typetext = "hatch"
	icontext = "hatch"
	airlock_type = /obj/machinery/door/airlock/hatch
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_mhatch
	name = "maintenance hatch assembly"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	typetext = "maintenance_hatch"
	icontext = "mhatch"
	airlock_type = /obj/machinery/door/airlock/maintenance_hatch
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_glass
	name = "glass airlock assembly"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/glass
	anchored = TRUE
	state = 1
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_gold
	name = "gold airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	airlock_type = /obj/machinery/door/airlock/gold
	anchored = TRUE
	state = 1
	mineral = "gold"

/obj/structure/door_assembly/door_assembly_silver
	name = "silver airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	airlock_type = /obj/machinery/door/airlock/silver
	anchored = TRUE
	state = 1
	mineral = "silver"

/obj/structure/door_assembly/door_assembly_diamond
	name = "diamond airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	airlock_type = /obj/machinery/door/airlock/diamond
	anchored = TRUE
	state = 1
	mineral = "diamond"

/obj/structure/door_assembly/door_assembly_uranium
	name = "uranium airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	airlock_type = /obj/machinery/door/airlock/uranium
	anchored = TRUE
	state = 1
	mineral = "uranium"

/obj/structure/door_assembly/door_assembly_plasma
	name = "plasma airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	airlock_type = /obj/machinery/door/airlock/plasma
	anchored = TRUE
	state = 1
	mineral = "plasma"

/obj/structure/door_assembly/door_assembly_clown
	name = "bananium airlock assembly"
	desc = "Honk"
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	airlock_type = /obj/machinery/door/airlock/clown
	anchored = TRUE
	state = 1
	mineral = "bananium"

/obj/structure/door_assembly/door_assembly_sandstone
	name = "sandstone airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	airlock_type = /obj/machinery/door/airlock/sandstone
	anchored = TRUE
	state = 1
	mineral = "sandstone"

/obj/structure/door_assembly/door_assembly_titanium
	name = "titanium airlock assembly"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	typetext = "titanium"
	icontext = "titanium"
	glass_type = /obj/machinery/door/airlock/glass_titanium
	airlock_type = /obj/machinery/door/airlock/titanium
	anchored = TRUE
	state = 1
	mineral = "titanium"

/obj/structure/door_assembly/door_assembly_titanium/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	name = "high security airlock assembly"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	typetext = "highsecurity"
	icontext = "highsec"
	airlock_type = /obj/machinery/door/airlock/highsecurity
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_vault
	name = "vault door assembly"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	typetext = "vault"
	icontext = "vault"
	airlock_type = /obj/machinery/door/airlock/vault
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_shuttle
	name = "shuttle airlock assembly"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	typetext = "shuttle"
	icontext = "shuttle"
	airlock_type = /obj/machinery/door/airlock/shuttle
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_cult
	name = "cult airlock assembly"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
	typetext = "cult"
	icontext = "cult"
	airlock_type = /obj/machinery/door/airlock/cult
	anchored = TRUE
	state = 1

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
	anchored = TRUE
	state = 1
	mineral = "wood"

/obj/structure/door_assembly/door_assembly_viro
	name = "virology airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	typetext = "virology"
	icontext = "viro"
	glass_type = /obj/machinery/door/airlock/glass_virology
	airlock_type = /obj/machinery/door/airlock/virology
	anchored = TRUE
	state = 1

/obj/structure/door_assembly/door_assembly_viro/glass
	mineral = "glass"
	material = "glass"

/obj/structure/door_assembly/door_assembly_centcom
	typetext = "centcom"
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	icontext = "ele"
	airlock_type = /obj/machinery/door/airlock/centcom
	anchored = TRUE
	state = 1

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
			var/has_solid = FALSE
			var/has_glass = FALSE
			switch(icontype)
				if("Public")
					icon = 'icons/obj/doors/airlocks/station/public.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = ""
					icontext = ""
					has_solid = TRUE
					has_glass = TRUE
				if("Public2")
					icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
					typetext = ""
					icontext = ""
					has_solid = TRUE
					has_glass = TRUE
				if("Engineering")
					icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "engineering"
					icontext = "eng"
					has_solid = TRUE
					has_glass = TRUE
				if("Atmospherics")
					icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "atmos"
					icontext = "atmo"
					has_solid = TRUE
					has_glass = TRUE
				if("Security")
					icon = 'icons/obj/doors/airlocks/station/security.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "security"
					icontext = "sec"
					has_solid = TRUE
					has_glass = TRUE
				if("Command")
					icon = 'icons/obj/doors/airlocks/station/command.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "command"
					icontext = "com"
					has_solid = TRUE
					has_glass = TRUE
				if("Medical")
					icon = 'icons/obj/doors/airlocks/station/medical.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "medical"
					icontext = "med"
					has_solid = TRUE
					has_glass = TRUE
				if("Research")
					icon = 'icons/obj/doors/airlocks/station/research.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "research"
					icontext = "res"
					has_solid = TRUE
					has_glass = TRUE
				if("Science")
					icon = 'icons/obj/doors/airlocks/station/science.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "research"
					icontext = "res"
					has_solid = TRUE
					has_glass = TRUE
				if("Mining")
					icon = 'icons/obj/doors/airlocks/station/mining.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "mining"
					icontext = "min"
					has_solid = TRUE
					has_glass = TRUE
				if("Maintenance")
					icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
					overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
					typetext = "maintenance"
					icontext = "mai"
					has_solid = TRUE
					has_glass = FALSE
				if("External")
					icon = 'icons/obj/doors/airlocks/external/external.dmi'
					overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
					typetext = "external"
					icontext = "ext"
					has_solid = TRUE
					has_glass = FALSE
				if("High Security")
					icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
					overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
					typetext = "highsecurity"
					icontext = "highsec"
					has_solid = TRUE
					has_glass = FALSE
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

	else if(istype(W, /obj/item/weapon/weldingtool) && !anchored )
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			user.visible_message("<span class='warning'>[user] disassembles the airlock assembly.</span>", \
								"You start to disassemble the airlock assembly...")
			playsound(src.loc, 'sound/items/welder2.ogg', 50, 1)

			if(do_after(user, 40*W.toolspeed, target = src))
				if( !WT.isOn() )
					return
				to_chat(user, "<span class='notice'>You disassemble the airlock assembly.</span>")
				deconstruct(TRUE)

	else if(istype(W, /obj/item/weapon/wrench))
		if(!anchored )
			var/door_check = 1
			for(var/obj/machinery/door/D in loc)
				if(!D.sub_door)
					door_check = 0
					break

			if(door_check)
				playsound(src.loc, W.usesound, 100, 1)
				user.visible_message("[user] secures the airlock assembly to the floor.", \
									 "<span class='notice'>You start to secure the airlock assembly to the floor...</span>", \
									 "<span class='italics'>You hear wrenching.</span>")

				if(do_after(user, 40*W.toolspeed, target = src))
					if( src.anchored )
						return
					to_chat(user, "<span class='notice'>You secure the airlock assembly.</span>")
					src.name = "secured airlock assembly"
					src.anchored = TRUE
			else
				to_chat(user, "There is another door here!")

		else
			playsound(src.loc, W.usesound, 100, 1)
			user.visible_message("[user] unsecures the airlock assembly from the floor.", \
								 "<span class='notice'>You start to unsecure the airlock assembly from the floor...</span>", \
								 "<span class='italics'>You hear wrenching.</span>")
			if(do_after(user, 40*W.toolspeed, target = src))
				if(!anchored )
					return
				to_chat(user, "<span class='notice'>You unsecure the airlock assembly.</span>")
				name = "airlock assembly"
				anchored = FALSE

	else if(istype(W, /obj/item/stack/cable_coil) && state == 0 && anchored )
		var/obj/item/stack/cable_coil/C = W
		if (C.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of cable to wire the airlock assembly!</span>")
			return
		user.visible_message("[user] wires the airlock assembly.", \
							"<span class='notice'>You start to wire the airlock assembly...</span>")
		if(do_after(user, 40, target = src))
			if(C.get_amount() < 1 || state != 0) return
			C.use(1)
			src.state = 1
			to_chat(user, "<span class='notice'>You wire the airlock assembly.</span>")
			src.name = "wired airlock assembly"

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1 )
		playsound(src.loc, W.usesound, 100, 1)
		user.visible_message("[user] cuts the wires from the airlock assembly.", \
							"<span class='notice'>You start to cut the wires from the airlock assembly...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if( src.state != 1 )
				return
			to_chat(user, "<span class='notice'>You cut the wires from the airlock assembly.</span>")
			new/obj/item/stack/cable_coil(get_turf(user), 1)
			src.state = 0
			src.name = "secured airlock assembly"

	else if(istype(W, /obj/item/weapon/electronics/airlock) && state == 1 )
		playsound(src.loc, W.usesound, 100, 1)
		user.visible_message("[user] installs the electronics into the airlock assembly.", \
							"<span class='notice'>You start to install electronics into the airlock assembly...</span>")
		if(do_after(user, 40, target = src))
			if( src.state != 1 )
				return
			if(!user.drop_item())
				return

			W.loc = src
			to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
			src.state = 2
			src.name = "near finished airlock assembly"
			src.electronics = W


	else if(istype(W, /obj/item/weapon/crowbar) && state == 2 )
		playsound(src.loc, W.usesound, 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
								"<span class='notice'>You start to remove electronics from the airlock assembly...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if( src.state != 2 )
				return
			to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
			src.state = 1
			src.name = "wired airlock assembly"
			var/obj/item/weapon/electronics/airlock/ae
			if (!electronics)
				ae = new/obj/item/weapon/electronics/airlock( src.loc )
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	else if(istype(W, /obj/item/stack/sheet) && !mineral)
		var/obj/item/stack/sheet/G = W
		if(G)
			if(G.get_amount() >= 1)
				if(istype(G, /obj/item/stack/sheet/rglass) || istype(G, /obj/item/stack/sheet/glass))
					playsound(src.loc, 'sound/items/crowbar.ogg', 100, 1)
					user.visible_message("[user] adds [G.name] to the airlock assembly.", \
										"<span class='notice'>You start to install [G.name] into the airlock assembly...</span>")
					if(do_after(user, 40, target = src))
						if(G.get_amount() < 1 || mineral) return
						if (G.type == /obj/item/stack/sheet/rglass)
							to_chat(user, "<span class='notice'>You install reinforced glass windows into the airlock assembly.</span>")
							heat_proof_finished = 1 //reinforced glass makes the airlock heat-proof
							name = "near finished heat-proofed window airlock assembly"
						else
							to_chat(user, "<span class='notice'>You install regular glass windows into the airlock assembly.</span>")
							name = "near finished window airlock assembly"
						G.use(1)
						mineral = "glass"
						material = "glass"
						//This list contains the airlock paintjobs that have a glass version:
						if(icontext in list("eng", "atmo", "sec", "com", "med", "res", "min"))
							src.airlock_type = text2path("/obj/machinery/door/airlock/[typetext]")
							src.glass_type = text2path("/obj/machinery/door/airlock/glass_[typetext]")
						else
							//This airlock is default or does not have a glass version, so we revert to the default glass airlock. |- Ricotez
							airlock_type = /obj/machinery/door/airlock
							glass_type = /obj/machinery/door/airlock/glass
							typetext = ""
							icontext = ""
				else if(istype(G, /obj/item/stack/sheet/mineral))
					var/M = G.sheettype
					if(G.get_amount() >= 2)
						playsound(src.loc, 'sound/items/crowbar.ogg', 100, 1)
						user.visible_message("[user] adds [G.name] to the airlock assembly.", \
										 "<span class='notice'>You start to install [G.name] into the airlock assembly...</span>")
						if(do_after(user, 40, target = src))
							if(G.get_amount() < 2 || mineral) return
							to_chat(user, "<span class='notice'>You install [M] plating into the airlock assembly.</span>")
							G.use(2)
							mineral = "[M]"
							name = "near finished [M] airlock assembly"
							airlock_type = text2path ("/obj/machinery/door/airlock/[M]")
							glass_type = /obj/machinery/door/airlock/glass

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 )
		playsound(src.loc, W.usesound, 100, 1)
		user.visible_message("[user] finishes the airlock.", \
							 "<span class='notice'>You start finishing the airlock...</span>")

		if(do_after(user, 40*W.toolspeed, target = src))
			if(src.loc && state == 2)
				to_chat(user, "<span class='notice'>You finish the airlock.</span>")
				var/obj/machinery/door/airlock/door
				if(mineral == "glass")
					door = new src.glass_type( src.loc )
				else
					door = new src.airlock_type( src.loc )
				//door.req_access = src.req_access
				door.electronics = src.electronics
				door.heat_proof = src.heat_proof_finished
				if(src.electronics.one_access)
					door.req_one_access = src.electronics.accesses
				else
					door.req_access = src.electronics.accesses
				if(created_name)
					door.name = created_name
				src.electronics.loc = door
				qdel(src)
	else
		return ..()
	update_icon()

/obj/structure/door_assembly/update_icon()
	cut_overlays()
	if(!material)
		add_overlay(get_airlock_overlay("fill_construction", icon))
	else
		add_overlay(get_airlock_overlay("[material]_construction", overlays_file))
	add_overlay(get_airlock_overlay("panel_c[state+1]", overlays_file))


/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		var/turf/T = get_turf(src)
		var/metal_amt = 4
		if(!disassembled)
			metal_amt = rand(2,4)
		new /obj/item/stack/sheet/metal(T, metal_amt)
		if(mineral)
			if (mineral == "glass")
				if(disassembled)
					if (heat_proof_finished)
						new /obj/item/stack/sheet/rglass(T)
					else
						new /obj/item/stack/sheet/glass(T)
				else
					new /obj/item/weapon/shard(T)
			else
				var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
				new mineral_path(T, 2)
	qdel(src)
