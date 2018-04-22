// For the convenience of knowing what exactly is wrong.
#define P_ATTACH_ERROR_CLEAR				1
#define P_ATTACH_ERROR_TOOBIG				2
#define P_ATTACH_ERROR_ALREADY_ATTACHED		4

#define P_LOCKTYPE_CODE						1
#define P_LOCKTYPE_DNA						2

#define P_TOGGLE_LIGHTS						1
#define P_TOGGLE_HUDLOCK					2
#define P_TOGGLE_ENVAIR						4
#define P_TOGGLE_SOR						8 //stop on reverse

/obj/pod

	proc/GetOccupants(var/exclude_pilot = 0)
		var/list/occupants = list()
		for(var/mob/living/carbon/human/H in src)
			if(pilot && exclude_pilot)
				if(H == pilot)
					continue
			occupants += H
		return occupants

	proc/CreateEnvironment(var/volume = 200)
		var/datum/gas_mixture/air = new()
		air.temperature = T20C
		air.volume = volume
		/*air.oxygen = (O2STANDARD * volume) / (R_IDEAL_GAS_EQUATION * air.temperature)
		air.nitrogen = (N2STANDARD * volume) / (R_IDEAL_GAS_EQUATION * air.temperature)*/
		air.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
		air.gases[/datum/gas/oxygen][MOLES] = O2STANDARD * air.volume / (R_IDEAL_GAS_EQUATION * air.temperature)
		air.gases[/datum/gas/nitrogen][MOLES] = N2STANDARD * air.volume / (R_IDEAL_GAS_EQUATION * air.temperature)
		return air

	proc/HasTraction()
		var/list/providers = list(/turf, /obj/structure/grille, /obj/structure/lattice)
		for(var/path in providers)
			for(var/atom/A in bounds(1))
				if(istype(A,/turf/open/space))
					continue
				if(istype(A, path))
					return 1

		return 0

	proc/GetCanister()
		return new /obj/machinery/portable_atmospherics/canister/air(src)

	proc/GetPowercell()
		return new /obj/item/stock_parts/cell/high(src)

	// This has to happen because byond's lists interact weird with bitflags. (I know why, but its stupid either way, gib enums plox)
	proc/Hardpoint2Text(var/hardpoint = 0)
		switch(hardpoint)
			if(P_HARDPOINT_ENGINE)
				return "engine"
			if(P_HARDPOINT_SHIELD)
				return "shield"
			if(P_HARDPOINT_PRIMARY_ATTACHMENT)
				return "primary"
			if(P_HARDPOINT_SECONDARY_ATTACHMENT)
				return "secondary"
			if(P_HARDPOINT_SENSOR)
				return "sensor"
			if(P_HARDPOINT_CARGO_HOLD)
				return "cargo"
			if(P_HARDPOINT_ARMOR)
				return "armor"
		return 0

	proc/Text2Hardpoint(var/text)
		switch(text)
			if("engine")
				return P_HARDPOINT_ENGINE
			if("shield")
				return P_HARDPOINT_SHIELD
			if("primary")
				return P_HARDPOINT_PRIMARY_ATTACHMENT
			if("secondary")
				return P_HARDPOINT_SECONDARY_ATTACHMENT
			if("sensor")
				return P_HARDPOINT_SENSOR
			if("cargo")
				return P_HARDPOINT_CARGO_HOLD
			if("armor")
				return P_HARDPOINT_ARMOR

	proc/GetHardpoints()
		var/list/hardpoints =  list("engine",
									"shield",
									"armor",
									"primary",
									"secondary",
									"sensor",
									"cargo")
		return hardpoints

	proc/GetEnvironment()
		return CreateEnvironment(200)

	proc/GetSeats()
		return 0

	proc/HasOpenSeat()
		return seats > length(GetOccupants(1))

	proc/IsHardpointAvailable(var/hardpoint)
		if(GetAttachmentOnHardpoint(hardpoint))
			return 0
		return 1

	// Takes in either the bitflag or the GetHardpoints() name.
	proc/GetAttachmentOnHardpoint(var/hardpoint = 0)
		if(istext(hardpoint))
			hardpoint = Text2Hardpoint(hardpoint)
		for(var/obj/item/pod_attachment/attachment in attachments)
			if(attachment.hardpoint_slot == hardpoint)
				return attachment

	proc/CanAttach(var/obj/item/pod_attachment/attachment)
		if(attachment.attached_to)
			return 0
		if(IsHardpointAvailable(attachment.hardpoint_slot))
			if(attachment.minimum_pod_size[1] <= size[1] && attachment.minimum_pod_size[2] <= size[2])
				return P_ATTACH_ERROR_CLEAR
			else
				return P_ATTACH_ERROR_TOOBIG
		else
			return P_ATTACH_ERROR_ALREADY_ATTACHED
		return 0

	proc/UsePower(var/amount = 0)
		if(!power_source)
			return 0
		return power_source.use(amount)

	proc/HasPower(var/amount = 0)
		if(!power_source)
			return 0
		if(power_source.charge < amount)
			return 0
		return 1

	proc/AddPower(var/amount = 0)
		if(!power_source)
			return 0
		return power_source.give(amount)

	proc/GetArmor()
		return new /obj/item/pod_attachment/armor/light(src)

	proc/GetEngine()
		return new /obj/item/pod_attachment/engine/plasma(src)

	proc/GetAdditionalAttachments()
		return list(new /obj/item/pod_attachment/cargo/small(src))

	proc/GetClickTypeFromList(var/list/modifiers = list())
		var/click_type = P_ATTACHMENT_KEYBIND_SINGLE
		if(modifiers["shift"] && modifiers["ctrl"])
			click_type = P_ATTACHMENT_KEYBIND_CTRLSHIFT
		else if(modifiers["middle"])
			click_type = P_ATTACHMENT_KEYBIND_MIDDLE
		else if(modifiers["shift"])
			click_type = P_ATTACHMENT_KEYBIND_SHIFT
		else if(modifiers["alt"])
			click_type = P_ATTACHMENT_KEYBIND_ALT
		else if(modifiers["ctrl"])
			click_type = P_ATTACHMENT_KEYBIND_CTRL

		return click_type

	proc/PrintSystemNotice(var/message = "")
		if(pilot)
			to_chat(pilot,"\icon[src] <font color='green'><b>\[[src.name]\]</b> states, \"[message]\"</font>")

	proc/PrintSystemAlert(var/message = "")
		if(pilot)
			to_chat(pilot,"\icon[src] <font color='red'><b>\[[src.name]\]</b> states, \"[message]\"</font>")

	proc/GetAttachments()
		var/list/attachments = list()
		for(var/obj/item/pod_attachment/attachment in contents)
			attachments += attachment
		return attachments

	proc/GetIterators()
		return list(inertial_drift_iterator, equalize_air_iterator, process_attachments_iterator, pod_damage_iterator)

	proc/GetLockType(var/_lock)
		if(!_lock)
			return 0

		if(istext(_lock))
			return P_LOCKTYPE_DNA
		else
			return P_LOCKTYPE_CODE

		return 0

	proc/CanOpenPod(var/mob/living/carbon/human/H)
		if(!H)
			return 0

		if(!length(locks))
			return 1

		if(emagged)
			return 1

		// Check all DNA locks first before trying code locks.
		var/dna_found = 0
		for(var/lock in locks)
			if(dna_found)	break
			if(GetLockType(lock) == P_LOCKTYPE_DNA)
				if(H.dna)
					if(H.dna.unique_enzymes == lock)
						dna_found = 1

		if(dna_found)
			return 1
		else
			var/code = input(H, "Please enter the code.", "Security") as num
			if(!(code in locks))
				to_chat(H,"<span class='warning'>Invalid code.</span>")
				H << sound('sound/machines/buzz-two.ogg', volume = 100)
				return 0

		return 1

	// Gets the turfs to side of the pod, adjusts for 2x2.
	proc/GetDirectionalTurfs(var/d)
		var/turf/location = get_turf(src)

		var/dual = (size[1] > 1 && size[2] > 1)

		if(dual)
			switch(d)
				if(NORTH)
					location = locate(location.x, location.y + size[2] - 1, location.z)
				if(SOUTH)
					location = locate(location.x, location.y, location.z)
				if(EAST)
					location = locate(location.x + size[1] - 1, location.y, location.z)
				if(WEST)
					location = locate(location.x, location.y, location.z)

		var/turf/target_turf = get_step(location, d)

		var/turf/second_location
		if(dual)
			second_location = get_step(location, turn(d, ((d == NORTH) || (d == WEST)) ? -90 : 90))

		var/list/turfs = list(target_turf)
		if(second_location)
			turfs += get_step(target_turf, turn(d, ((d == NORTH) || (d == WEST)) ? -90 : 90))
		return turfs

	proc/GetDirectionalTurfsUnderPod(var/d)
		var/list/turfs = GetDirectionalTurfs(d)
		var/list/under = list()

		for(var/turf/T in turfs)
			under += get_step(T, turn(d, 180))

		return under

	proc/GetTurfsUnderPod()
		var/list/turfs = list()
		for(var/_x = 0; _x < size[1]; _x++)
			for(var/_y = 0; _y < size[2]; _y++)
				turfs += locate(x + _x, y + _y, z)

		return turfs

	proc/Toggle(var/bf)
		if(toggles & bf)
			toggles &= ~bf
		else
			toggles |= bf
