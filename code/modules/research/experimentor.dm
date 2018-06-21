//this is designed to replace the destructive analyzer

GLOBAL_LIST_INIT(critical_items,typecacheof(list(/obj/item/construction/rcd,/obj/item/grenade,/obj/item/aicard,/obj/item/storage/backpack/holding,/obj/item/slime_extract,/obj/item/onetankbomb,/obj/item/transfer_valve)))

/datum/experiment_type
	var/name = "Adminhelp"
	var/hidden = FALSE //Whether we should hide this from newly made experimentors
	var/list/experiments = list()
	var/list/item_results = list()

/datum/experiment_type/proc/get_valid_experiments(obj/machinery/rnd/experimentor/E,obj/item/O,bad_things_coeff,only_bad=FALSE)
	var/list/weighted_experiments = list()
	for(var/datum/experiment/EX in experiments)
		if(!EX.weight || !EX.can_perform(E,O))
			continue
		if(EX.is_bad)
			weighted_experiments[EX] = EX.weight / bad_things_coeff
		else if(!EX.is_bad && !only_bad)
			weighted_experiments[EX] = EX.weight
	return weighted_experiments

/obj/machinery/rnd/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	desc = "A \"replacement\" for the destructive analyzer with a slight tendency to catastrophically fail."
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	circuit = /obj/item/circuitboard/machine/experimentor
	verb_say = "beeps"
	var/recently_experimented = 0
	var/bad_thing_coeff = 0
	var/reset_time = 15
	var/list/item_reactions = list()
	var/list/experiments = list()

/obj/machinery/rnd/experimentor/RefreshParts()
	reset_time = initial(reset_time)
	bad_thing_coeff = initial(bad_thing_coeff)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		reset_time = max(1,reset_time - M.rating)
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		bad_thing_coeff += M.rating*4 //Boosted slightly
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		bad_thing_coeff += M.rating*2 //Ditto

/obj/machinery/rnd/experimentor/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM && istype(O))
		. = 1
		if(O.item_flags & ABSTRACT) //Yeah lets just stop this before it becomes a problem.
			return
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			return
		loaded_item = O
		to_chat(user, "<span class='notice'>You add [O] to the machine.</span>")
		flick("h_lathe_load", src)

/obj/machinery/rnd/experimentor/default_deconstruction_crowbar(obj/item/O)
	eject_item()
	. = ..(O)

/obj/machinery/rnd/experimentor/ui_interact(mob/user)
	var/list/dat = list("<center>")
	if(!linked_console)
		dat += "<b><a href='byond://?src=[REF(src)];function=search'>Scan for R&D Console</A></b>"
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]"

		dat += "<div>Available tests:"
		for(var/experiment in experiments)
			var/datum/experiment_type/E = experiments[experiment]
			dat += "<b><a href='byond://?src=[REF(src)];function=[experiment]'>[E.name]</A></b>"
		dat += "</div>"
		dat += "<b><a href='byond://?src=[REF(src)];function=eject'>Eject</A>"
		var/list/listin = techweb_item_boost_check(src)
		if(listin)
			var/list/output = list("<b><font color='purple'>Research Boost Data:</font></b>")
			var/list/res = list("<b><font color='blue'>Already researched:</font></b>")
			var/list/boosted = list("<b><font color='red'>Already boosted:</font></b>")
			for(var/node_id in listin)
				var/datum/techweb_node/N = get_techweb_node_by_id(node_id)
				var/str = "<b>[N.display_name]</b>: [listin[N]] points.</b>"
				if(SSresearch.science_tech.researched_nodes[N])
					res += str
				else if(SSresearch.science_tech.boosted_nodes[N])
					boosted += str
				if(SSresearch.science_tech.visible_nodes[N])	//JOY OF DISCOVERY!
					output += str
			output += boosted + res
			dat += output
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<a href='byond://?src=[REF(src)];function=refresh'>Refresh</A>"
	dat += "<a href='byond://?src=[REF(src)];close=1'>Close</A></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400, src)
	popup.set_content(dat.Join("<br>"))
	popup.open()
	onclose(user, "experimentor")

/obj/machinery/rnd/experimentor/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]

	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	if(scantype == "search")
		link_to_rnd()
	else if(scantype == "eject")
		eject_item()
	else if(scantype == "refresh")
		updateUsrDialog()
	else
		if(recently_experimented)
			to_chat(usr, "<span class='warning'>[src] has been used too recently!</span>")
		else if(!loaded_item)
			to_chat(usr, "<span class='warning'>[src] is not currently loaded!</span>")
		else
			var/experiment_type = text2path(scantype)
			perform_experiment(experiment_type)
	updateUsrDialog()

/obj/machinery/rnd/experimentor/proc/link_to_rnd()
	var/obj/machinery/computer/rdconsole/D = locate(/obj/machinery/computer/rdconsole) in oview(3,src)
	if(D)
		linked_console = D
		var/datum/techweb/web = D.stored_research

		experiments = list()
		if(!web.all_experiment_types.len)
			for(var/type in typesof(/datum/experiment_type) - /datum/experiment_type)
				web.all_experiment_types[type] = new type()
			for(var/type in typesof(/datum/experiment))
				var/datum/experiment/EX = new type()
				if(!EX.experiment_type)
					continue
				EX.init()
				web.all_experiments[type] = EX
				for(var/extype in typesof(EX.experiment_type))
					var/datum/experiment_type/E = web.all_experiment_types[extype]
					if(E)
						E.experiments += EX
		for(var/extype in web.all_experiment_types)
			var/datum/experiment_type/E = web.all_experiment_types[extype]
			if(!E.hidden)
				experiments[extype] = E

/obj/machinery/rnd/experimentor/proc/eject_item()
	if(loaded_item)
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = drop_location()
		loaded_item.forceMove(dropturf)
		loaded_item = null

/obj/machinery/rnd/experimentor/proc/destroy_item()
	if(!loaded_item || loaded_item.resistance_flags & INDESTRUCTIBLE)
		return
	if(linked_console.linked_lathe)
		GET_COMPONENT_FROM(linked_materials, /datum/component/material_container, linked_console.linked_lathe)
		for(var/material in loaded_item.materials)
			linked_materials.insert_amount( min((linked_materials.max_amount - linked_materials.total_amount), (loaded_item.materials[material])), material)
	QDEL_NULL(loaded_item)

/obj/machinery/rnd/experimentor/proc/throw_smoke(turf/T,radius=0)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(radius, T)
	smoke.start()

/obj/machinery/rnd/experimentor/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Force Experiment"] = "?_src_=vars;[HrefToken()];forceexperiment=[REF(src)]"

/obj/machinery/rnd/experimentor/proc/perform_experiment(type)
	var/success = FALSE

	if(!linked_console || !type)
		return FALSE

	recently_experimented = 1
	icon_state = "h_lathe_wloop"

	var/loaded_type = loaded_item.type
	var/datum/techweb/web = linked_console.stored_research
	var/list/datum/techweb_node/nodes = techweb_item_boost_check(loaded_item)
	var/datum/experiment/picked
	if(ispath(type,/datum/experiment) && web.all_experiments[type])
		picked = web.all_experiments[type]
	if(experiments[type])
		var/datum/experiment_type/chosen = experiments[type]
		var/list/possible_experiments = chosen.get_valid_experiments(src,loaded_item,bad_thing_coeff)
		picked = pickweight(possible_experiments)

	if(picked)
		success = picked.perform(src,loaded_item)
		use_power(picked.power_use)
		picked.gather_data(src,web,success)
		if(picked.allow_boost)
			web.boost_with_path(pickweight(nodes), loaded_type)

	addtimer(CALLBACK(src, .proc/reset_exp), reset_time)
	return success

/obj/machinery/rnd/experimentor/proc/reset_exp()
	update_icon()
	recently_experimented = FALSE

/obj/machinery/rnd/experimentor/update_icon()
	icon_state = "h_lathe"

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(T)]")
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in [AREACOORD(T)]")
