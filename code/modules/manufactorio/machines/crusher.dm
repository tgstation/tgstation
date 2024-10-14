/obj/machinery/power/manufacturing/crusher //todo make it work for other stuff
	name = "manufacturing crusher"
	desc = "Crushes any item put into it, boulders and such. Materials below a sheet are stored in the machine."
	icon_state = "crusher"
	circuit = /obj/item/circuitboard/machine/manucrusher
	/// power used to crush
	var/crush_cost = 3 KILO WATTS
	/// how much can we hold
	var/capacity = 5
	/// withheld output because output is either blocked or full
	var/atom/movable/withholding
	/// list of held mats
	var/list/obj/item/stack/held_mats = list()

/obj/machinery/power/manufacturing/crusher/update_overlays()
	. = ..()
	. += generate_io_overlays(dir, COLOR_ORANGE) // OUT - stuff in it
	. += generate_io_overlays(REVERSE_DIR(dir), COLOR_MODERATE_BLUE) // IN - to crush

/obj/machinery/power/manufacturing/crusher/Destroy()
	. = ..()
	QDEL_NULL(withholding)

/obj/machinery/power/manufacturing/crusher/atom_destruction(damage_flag)
	withholding?.Move(drop_location())
	return ..()

/obj/machinery/power/manufacturing/crusher/receive_resource(obj/receiving, atom/from, receive_dir)
	if(istype(receiving, /obj/item/stack/ore) || receiving.resistance_flags & INDESTRUCTIBLE || !isitem(receiving) || surplus() < crush_cost  || receive_dir != REVERSE_DIR(dir))
		return MANUFACTURING_FAIL
	if(length(contents - circuit) >= capacity && may_merge_in_contents_and_do_so(receiving))
		return MANUFACTURING_FAIL_FULL
	receiving.Move(src, get_dir(receiving, src))
	START_PROCESSING(SSmanufacturing, src)
	return MANUFACTURING_SUCCESS

/obj/machinery/power/manufacturing/crusher/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == withholding)
		withholding = null

/obj/machinery/power/manufacturing/crusher/process(seconds_per_tick) //noot functional
	if(!isnull(withholding) && !send_resource(withholding, dir))
		return
	for(var/material in held_mats)
		if(held_mats[material] >= 1)
			var/new_amount = floor(held_mats[material])
			held_mats[material] -= new_amount
			if(held_mats[material] <= 0)
				held_mats -= material
			withholding = new material(null, new_amount)
			return
	var/list/poor_saps = contents - circuit
	if(!length(poor_saps))
		return PROCESS_KILL
	if(surplus() < crush_cost)
		return
	var/obj/victim = poor_saps[length(poor_saps)]
	if(istype(victim)) //todo handling for other things
		if(!length(victim.custom_materials))
			add_load(crush_cost)
			victim.atom_destruction()
		for(var/obj/object in victim.contents+victim)
			for(var/datum/material/possible_mat as anything in object.custom_materials)
				var/quantity = object.custom_materials[possible_mat]
				object.set_custom_materials(object.custom_materials.Copy() - possible_mat, 1)
				var/type_to_use = istype(victim, /obj/item/boulder) ? possible_mat.ore_type : possible_mat.sheet_type
				if(quantity < SHEET_MATERIAL_AMOUNT)
					if(!(type_to_use in held_mats))
						held_mats[type_to_use] = quantity / SHEET_MATERIAL_AMOUNT
						continue
					held_mats[type_to_use] += quantity / SHEET_MATERIAL_AMOUNT
					continue
				var/obj/item/stack/sheet/new_item = new type_to_use(src, quantity / SHEET_MATERIAL_AMOUNT)
				if(!send_resource(new_item, dir))
					withholding = new_item
					return
	else if(isliving(victim))
		var/mob/living/poor_sap = victim
		poor_sap.adjustBruteLoss(95, TRUE)
		if(!send_resource(poor_sap, dir))
			withholding = poor_sap
			return
