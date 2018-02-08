//this is designed to replace the destructive analyzer

GLOBAL_LIST_INIT(critical_items,typecacheof(/obj/item/construction/rcd,/obj/item/grenade,/obj/item/device/aicard,/obj/item/storage/backpack/holding,/obj/item/slime_extract,/obj/item/device/onetankbomb,/obj/item/device/transfer_valve))

/datum/experiment_type
	var/name = "Adminhelp"
	var/hidden = FALSE //Whether we should hide this from newly made experimentors
	var/list/experiments = list()
	var/list/item_results = list()

/datum/experiment_type/proc/get_valid_experiments(obj/item/O,bad_things_coeff)
	var/list/weighted_experiments = list()
	for(var/datum/experiment/E in experiments)
		if(!E.can_perform(O) || !E.weight)
			return
		if(E.is_bad && bad_things_coeff < E.weight)
			weighted_experiments[E] = E.weight - bad_things_coeff
		else if(!E.is_bad)
			weighted_experiments[E] = E.weight
	return weighted_experiments

/obj/machinery/rnd/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	desc = "A \"replacement\" for the deconstructive analyzer with a slight tendency to catastrophically fail."
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

/*/obj/machinery/rnd/experimentor/proc/SetTypeReactions()
	var/probWeight = 0
	for(var/I in typesof(/obj/item))
		if(istype(I, /obj/item/relic))
			item_reactions["[I]"] = SCANTYPE_DISCOVER
		else
			item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		if(ispath(I, /obj/item/stock_parts) || ispath(I, /obj/item/grenade/chem_grenade) || ispath(I, /obj/item/kitchen))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += 15
				valid_items += I
				probWeight++

		if(ispath(I, /obj/item/reagent_containers/food))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items += rand(1,max(2,35-probWeight))
				valid_items += I

		if(ispath(I, /obj/item/construction/rcd) || ispath(I, /obj/item/grenade) || ispath(I, /obj/item/device/aicard) || ispath(I, /obj/item/storage/backpack/holding) || ispath(I, /obj/item/slime_extract) || ispath(I, /obj/item/device/onetankbomb) || ispath(I, /obj/item/device/transfer_valve))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null)
				critical_items += I*/

/obj/machinery/rnd/experimentor/RefreshParts()
	reset_time = initial(reset_time)
	bad_thing_coeff = initial(bad_thing_coeff)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		reset_time = max(1,reset_time - M.rating)
	for(var/obj/item/stock_parts/scanning_module/M in component_parts)
		bad_thing_coeff += M.rating*4 //Boosted slightly
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		bad_thing_coeff += M.rating*2 //Ditto

/obj/machinery/rnd/experimentor/proc/checkCircumstances(obj/item/O)
	//snowflake check to only take "made" bombs
	if(istype(O, /obj/item/device/transfer_valve))
		var/obj/item/device/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two || !T.attached_device)
			return FALSE
	return TRUE

/obj/machinery/rnd/experimentor/Insert_Item(obj/item/O, mob/user)
	if(user.a_intent != INTENT_HARM && istype(O))
		. = 1
		if(O.flags_1 & ABSTRACT_1) //Yeah lets just stop this before it becomes a problem.
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

/obj/machinery/rnd/experimentor/attack_hand(mob/user)
	user.set_machine(src)
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
			/*if(dotype != FAIL)
				var/list/datum/techweb_node/nodes = techweb_item_boost_check(process)
				var/picked = pickweight(nodes)		//This should work.
				if(linked_console)
					linked_console.stored_research.boost_with_path(picked, process.type)*/
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
			for(var/datum/experiment/type in typesof(/datum/experiment))
				if(!initial(type.weight))
					continue
				var/datum/experiment/EX = new type()
				EX.init()
				web.all_experiments[type] = EX
				if(!EX.experiment_type)
					continue
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

	if(experiments[type])
		var/list/possible_experiments = experiments[type].get_valid_experiments(loaded_item,bad_thing_coeff)
		var/datum/experiment/picked = pickweight(possible_experiments)
		var/datum/techweb/web = linked_console.stored_research

		success = picked.perform(src,loaded_item)
		use_power(picked.power_use)
		picked.gather_data(src,web,success)

	if(!success)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='warning'>[loaded_item] [a], and [b], the experiment was a failure.</span>")

	addtimer(CALLBACK(src, .proc/reset_exp), reset_time)
	return success

/obj/machinery/rnd/experimentor/proc/reset_exp()
	update_icon()
	recently_experimented = FALSE

/obj/machinery/rnd/experimentor/update_icon()
	icon_state = "h_lathe"

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_COORDJMP(T)]",0,1)
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in ([T.x],[T.y],[T.z])")

//////////////////////////////////SPECIAL ITEMS////////////////////////////////////////

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc
	var/cooldownMax = 60
	var/cooldown

/obj/item/relic/Initialize()
	. = ..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","illegal tech","weapon")]"


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	name = realName
	cooldownMax = rand(60,300)
	realProc = pick("teleport","explode","rapidDupe","petSpray","flash","clean","corgicannon")

/obj/item/relic/attack_self(mob/user)
	if(revealed)
		if(cooldown)
			to_chat(user, "<span class='warning'>[src] does not react!</span>")
			return
		else if(loc == user)
			cooldown = TRUE
			call(src,realProc)(user)
			addtimer(CALLBACK(src, .proc/cd), cooldownMax)
	else
		to_chat(user, "<span class='notice'>You aren't quite sure what to do with this yet.</span>")

/obj/item/relic/proc/cd()
	cooldown = FALSE

//////////////// RELIC PROCS /////////////////////////////

/obj/item/relic/proc/throwSmoke(turf/where)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, get_turf(where))
	smoke.start()

/obj/item/relic/proc/corgicannon(mob/user)
	playsound(src, "sparks", rand(25,50), 1)
	var/mob/living/simple_animal/pet/dog/corgi/C = new/mob/living/simple_animal/pet/dog/corgi(get_turf(user))
	C.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, .throwSmoke, C))
	warn_admins(user, "Corgi Cannon", 0)

/obj/item/relic/proc/clean(mob/user)
	playsound(src, "sparks", rand(25,50), 1)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.prime()
	warn_admins(user, "Smoke", 0)

/obj/item/relic/proc/flash(mob/user)
	playsound(src, "sparks", rand(25,50), 1)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(user.loc)
	CB.prime()
	warn_admins(user, "Flash")

/obj/item/relic/proc/petSpray(mob/user)
	var/message = "<span class='danger'>[src] begins to shake, and in the distance the sound of rampaging animals arises!</span>"
	visible_message(message)
	to_chat(user, message)
	var/animals = rand(1,25)
	var/counter
	var/list/valid_animals = list(/mob/living/simple_animal/parrot, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/dog/corgi, /mob/living/simple_animal/crab, /mob/living/simple_animal/pet/fox, /mob/living/simple_animal/hostile/lizard, /mob/living/simple_animal/mouse, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/poison/bees, /mob/living/simple_animal/hostile/carp)
	for(counter = 1; counter < animals; counter++)
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))
	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		to_chat(user, "<span class='warning'>[src] falls apart!</span>")
		qdel(src)

/obj/item/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(5,10)
	for(counter = 1; counter < max; counter++)
		var/obj/item/relic/R = new type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes |= R
		R.throw_at(pick(oview(7,get_turf(src))),10,1)
	counter = 0
	QDEL_LIST_IN(dupes, rand(10, 100))
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/relic/proc/explode(mob/user)
	to_chat(user, "<span class='danger'>[src] begins to heat up!</span>")
	addtimer(CALLBACK(src, .proc/do_explode, user), rand(35, 100))

/obj/item/relic/proc/do_explode(mob/user)
	if(loc == user)
		visible_message("<span class='notice'>\The [src]'s top opens, releasing a powerful blast!</span>")
		explosion(user.loc, 0, rand(1,5), rand(1,5), rand(1,5), rand(1,5), flame_range = 2)
		warn_admins(user, "Explosion")
		qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/teleport(mob/user)
	to_chat(user, "<span class='notice'>[src] begins to vibrate!</span>")
	addtimer(CALLBACK(src, .proc/do_the_teleport, user), rand(10, 30))

/obj/item/relic/proc/do_the_teleport(mob/user)
	var/turf/userturf = get_turf(user)
	if(loc == user && !is_centcom_level(userturf.z)) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
		visible_message("<span class='notice'>[src] twists and bends, relocating itself!</span>")
		throwSmoke(userturf)
		do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg')
		throwSmoke(get_turf(user))
		warn_admins(user, "Teleport", 0)

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
