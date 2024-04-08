/obj/machinery/computer/pod/var/looping_time = FALSE

/obj/machinery/mass_driver/cargo_driver
	name = "Cargo Driver"
	id = MASSDRIVER_CARGO

/obj/machinery/mass_driver/cargo_driver/drive(amount)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	use_power(active_power_usage)
	var/O_limit
	var/atom/target = get_edge_target_turf(src, dir)
	for(var/atom/movable/O in loc)
		if(!O.anchored || ismecha(O)) //Mechs need their launch platforms.
			if(ismob(O))
				if(isliving(O))
					audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
					break
				else
					continue
			O_limit++
			if(O_limit >= 20)
				audible_message(span_notice("[src] lets out a screech, it doesn't seem to be able to handle the load."))
				break
			use_power(active_power_usage)
			O.throw_at(target, get_dist(src, target) + 4, power)
			if(length(SSmapping.levels_by_trait(ZTRAIT_OSHAN)))
				addtimer(CALLBACK(O, TYPE_PROC_REF(/atom/movable, attempt_map_sell)), 4 SECONDS / power)
	flick("mass_driver1", src)

/atom/movable/proc/attempt_map_sell()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/presale_points = D.account_balance

	var/list/contents_self = list()
	contents_self += src
	contents_self += src.contents

	if(!GLOB.exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""

	var/datum/export_report/ex = new

	var/export_categories = EXPORT_CARGO
	export_categories |= EXPORT_EMAG
	export_categories |= EXPORT_CONTRABAND

	for(var/atom/movable/AM in contents_self)
		if(iscameramob(AM))
			continue
		if(AM.anchored)
			continue
		export_item_and_contents(AM, export_categories, dry_run = TRUE, external_report = ex)

	if(ex.exported_atoms)
		ex.exported_atoms += "." //ugh

	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex)
		if(!export_text)
			continue

		msg += export_text + "\n"
		D.adjust_money(ex.total_value[E])

	SSeconomy.export_total += (D.account_balance - presale_points)
	SSshuttle.centcom_message = msg

	var/list/deletors = list()
	for(var/atom/movable/listed_atom in ex.exported_atoms_source)
		if(isliving(listed_atom))
			continue
		if(listed_atom in contents_self)
			deletors += listed_atom
			contents_self -= listed_atom

	var/obj/effect/oshan_launch_point/cargo/picked_point = pick(GLOB.cargo_launch_points)
	var/turf/edge_turf = get_edge_target_turf(picked_point, picked_point.map_edge_direction)

	if(length(contents_self))
		var/obj/structure/closet/cardboard/new_crate = new(edge_turf)

		for(var/atom/movable/moved_atom in contents_self)
			moved_atom.forceMove(new_crate)
			contents_self -= moved_atom

		new_crate.throw_at(picked_point, get_dist(edge_turf, picked_point) + 4, 2)

	for(var/atom/movable/thing in deletors)
		if(!QDELETED(thing))
			qdel(thing)
