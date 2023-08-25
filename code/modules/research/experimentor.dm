//this is designed to replace the destructive analyzer

//NEEDS MAJOR CODE CLEANUP

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6
#define SCANTYPE_DISCOVER 7

#define EFFECT_PROB_VERYLOW 20
#define EFFECT_PROB_LOW 35
#define EFFECT_PROB_MEDIUM 50
#define EFFECT_PROB_HIGH 75
#define EFFECT_PROB_VERYHIGH 95

#define FAIL 8
/obj/machinery/rnd/experimentor
	name = "\improper E.X.P.E.R.I-MENTOR"
	desc = "A \"replacement\" for the destructive analyzer with a slight tendency to catastrophically fail."
	icon = 'icons/obj/machines/experimentator.dmi'
	icon_state = "h_lathe"
	base_icon_state = "h_lathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	circuit = /obj/item/circuitboard/machine/experimentor
	var/recentlyExperimented = 0
	/// Weakref to the first ian we can find at init
	var/datum/weakref/tracked_ian_ref
	/// Weakref to the first runtime we can find at init
	var/datum/weakref/tracked_runtime_ref
	///Determines the probability of a malfunction.
	var/malfunction_probability_coeff = 0
	///Keeps track of how many times we've had a critical reaction
	var/malfunction_probability_coeff_modifier = 0
	var/resetTime = 15
	var/cloneMode = FALSE
	var/list/item_reactions
	var/static/list/valid_items //valid items for special reactions like transforming
	var/list/critical_items_typecache //items that can cause critical reactions

/obj/machinery/rnd/experimentor/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/rnd/experimentor/proc/valid_items()
	RETURN_TYPE(/list)

	if (isnull(valid_items))
		generate_valid_items_and_item_reactions()

	return valid_items

/obj/machinery/rnd/experimentor/proc/item_reactions()
	RETURN_TYPE(/list)

	if (isnull(item_reactions))
		generate_valid_items_and_item_reactions()

	return item_reactions

/obj/machinery/rnd/experimentor/proc/generate_valid_items_and_item_reactions()
	var/static/list/banned_typecache = typecacheof(list(
		/obj/item/stock_parts/cell/infinite,
		/obj/item/grenade/chem_grenade/tuberculosis
	))

	item_reactions = list()
	valid_items = list()

	for(var/I in typesof(/obj/item))
		if(ispath(I, /obj/item/relic))
			item_reactions["[I]"] = SCANTYPE_DISCOVER
		else
			item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)

		if(is_type_in_typecache(I, banned_typecache))
			continue

		if(ispath(I, /obj/item/stock_parts) || ispath(I, /obj/item/grenade/chem_grenade) || ispath(I, /obj/item/knife))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items["[I]"] += 15

		if(ispath(I, /obj/item/food))
			var/obj/item/tempCheck = I
			if(initial(tempCheck.icon_state) != null) //check it's an actual usable item, in a hacky way
				valid_items["[I]"] += rand(1,4)

/obj/machinery/rnd/experimentor/Initialize(mapload)
	. = ..()

	tracked_ian_ref = WEAKREF(locate(/mob/living/basic/pet/dog/corgi/ian) in GLOB.mob_living_list)
	tracked_runtime_ref = WEAKREF(locate(/mob/living/simple_animal/pet/cat/runtime) in GLOB.mob_living_list)

	critical_items_typecache = typecacheof(list(
		/obj/item/construction/rcd,
		/obj/item/grenade,
		/obj/item/aicard,
		/obj/item/storage/backpack/holding,
		/obj/item/slime_extract,
		/obj/item/onetankbomb,
		/obj/item/transfer_valve))

/obj/machinery/rnd/experimentor/RefreshParts()
	. = ..()
	malfunction_probability_coeff = malfunction_probability_coeff_modifier
	resetTime = initial(resetTime)
	for(var/datum/stock_part/servo/servo in component_parts)
		resetTime = max(1, resetTime - servo.tier)
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		malfunction_probability_coeff += scanning_module.tier * 2
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		malfunction_probability_coeff += micro_laser.tier

/obj/machinery/rnd/experimentor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Malfunction probability reduced by <b>[malfunction_probability_coeff]%</b>.<br>Cooldown interval between experiments at <b>[resetTime*0.1]</b> seconds.")

/obj/machinery/rnd/experimentor/proc/checkCircumstances(obj/item/O)
	//snowflake check to only take "made" bombs
	if(istype(O, /obj/item/transfer_valve))
		var/obj/item/transfer_valve/T = O
		if(!T.tank_one || !T.tank_two || !T.attached_device)
			return FALSE
	return TRUE

/obj/machinery/rnd/experimentor/Insert_Item(obj/item/O, mob/living/user)
	if(!user.combat_mode)
		. = 1
		if(!is_insertion_ready(user))
			return
		if(!user.transferItemToLoc(O, src))
			return
		loaded_item = O
		to_chat(user, span_notice("You add [O] to the machine."))
		flick("h_lathe_load", src)

/obj/machinery/rnd/experimentor/default_deconstruction_crowbar(obj/item/O)
	ejectItem()
	. = ..(O)

/obj/machinery/rnd/experimentor/ui_interact(mob/user)
	var/list/dat = list("<center>")
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]"

		dat += "<div>Available tests:"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_POKE]'>Poke</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_IRRADIATE];'>Irradiate</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_GAS]'>Gas</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_HEAT]'>Burn</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_COLD]'>Freeze</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_OBLITERATE]'>Destroy</A></b></div>"
		if(istype(loaded_item,/obj/item/relic))
			dat += "<b><a href='byond://?src=[REF(src)];item=[REF(loaded_item)];function=[SCANTYPE_DISCOVER]'>Discover</A></b>"
		dat += "<b><a href='byond://?src=[REF(src)];function=eject'>Eject</A>"
		var/list/listin = techweb_item_boost_check(src)
		if(listin)
			var/list/output = list("<b><font color='purple'>Research Boost Data:</font></b>")
			var/list/res = list("<b><font color='blue'>Already researched:</font></b>")
			var/list/boosted = list("<b><font color='red'>Already boosted:</font></b>")
			for(var/node_id in listin)
				var/datum/techweb_node/N = SSresearch.techweb_node_by_id(node_id)
				var/str = "<b>[N.display_name]</b>: [listin[N]] points.</b>"
				if(SSresearch.science_tech.researched_nodes[N.id])
					res += str
				else if(SSresearch.science_tech.boosted_nodes[N.id])
					boosted += str
				if(SSresearch.science_tech.visible_nodes[N.id]) //JOY OF DISCOVERY!
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
	var/obj/item/process = locate(href_list["item"]) in src

	if(href_list["close"])
		usr << browse(null, "window=experimentor")
		return
	else if(scantype == "eject")
		ejectItem()
	else if(scantype == "refresh")
		updateUsrDialog()
	else
		if(recentlyExperimented)
			to_chat(usr, span_warning("[src] has been used too recently!"))
		else if(!loaded_item)
			to_chat(usr, span_warning("[src] is not currently loaded!"))
		else if(!process || process != loaded_item) //Interface exploit protection (such as hrefs or swapping items with interface set to old item)
			to_chat(usr, span_danger("Interface failure detected in [src]. Please try again."))
		else
			var/dotype
			if(text2num(scantype) == SCANTYPE_DISCOVER)
				dotype = SCANTYPE_DISCOVER
			else
				dotype = matchReaction(process,scantype)
			experiment(dotype,process)
			use_power(750)
			if(dotype != FAIL)
				var/list/nodes = techweb_item_boost_check(process)
				var/picked = pick_weight(nodes) //This should work.
				stored_research.boost_with_item(SSresearch.techweb_node_by_id(picked), process.type)
	updateUsrDialog()

/obj/machinery/rnd/experimentor/proc/matchReaction(matching,reaction)
	var/obj/item/D = matching
	if(D)
		var/list/item_reactions = item_reactions()
		if(item_reactions.Find("[D.type]"))
			var/tor = item_reactions["[D.type]"]
			if(tor == text2num(reaction))
				return tor
			else
				return FAIL
		else
			return FAIL
	else
		return FAIL

/obj/machinery/rnd/experimentor/proc/ejectItem(delete=FALSE)
	if(loaded_item)
		if(cloneMode)
			visible_message(span_notice("A duplicate [loaded_item] pops out!"))
			var/type_to_make = loaded_item.type
			new type_to_make(get_turf(pick(oview(1,src))))
			cloneMode = FALSE
			return
		var/turf/dropturf = get_turf(pick(view(1,src)))
		if(!dropturf) //Failsafe to prevent the object being lost in the void forever.
			dropturf = drop_location()
		loaded_item.forceMove(dropturf)
		if(delete)
			qdel(loaded_item)
		loaded_item = null

/obj/machinery/rnd/experimentor/proc/throwSmoke(turf/where)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = where)
	smoke.start()


/obj/machinery/rnd/experimentor/proc/experiment(exp,obj/item/exp_on)
	recentlyExperimented = 1
	icon_state = "[base_icon_state]_wloop"
	var/chosenchem
	var/criticalReaction = is_type_in_typecache(exp_on,  critical_items_typecache)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message(span_notice("[src] prods at [exp_on] with mechanical arms."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_notice("[exp_on] is gripped in just the right way, enhancing its focus."))
			malfunction_probability_coeff_modifier++
			RefreshParts() //recalculate malfunction_probability_coeff
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src] malfunctions and destroys [exp_on], lashing its arms out at nearby people!"))
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_CHEST))
				investigate_log("Experimentor dealt minor brute to [m].", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions!"))
			exp = SCANTYPE_OBLITERATE
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			visible_message(span_danger("[src] malfunctions, throwing the [exp_on]!"))
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				investigate_log("Experimentor has thrown [loaded_item] at [key_name(target)]", INVESTIGATE_EXPERIMENTOR)
				ejectItem()
				if(throwing)
					throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message(span_danger("[src] reflects radioactive rays at [exp_on]!"))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_notice("[exp_on] has activated an unknown subroutine!"))
			cloneMode = TRUE
			investigate_log("Experimentor has made a clone of [exp_on]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src] malfunctions, melting [exp_on] and leaking radiation!"))
			radiation_pulse(src, max_range = 6, threshold = 0.3)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, spewing toxic waste!"))
			for(var/turf/T in oview(1, src))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH) && !(locate(/obj/effect/decal/cleanable/greenglow) in T))
						var/obj/effect/decal/cleanable/reagentdecal = new/obj/effect/decal/cleanable/greenglow(T)
						reagentdecal.reagents.add_reagent(/datum/reagent/uranium/radium, 7)
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			var/savedName = "[exp_on]"
			ejectItem(TRUE)
			var/newPath = text2path(pick_weight(valid_items()))
			loaded_item = new newPath(src)
			visible_message(span_warning("[src] malfunctions, transforming [savedName] into [loaded_item]!"))
			investigate_log("Experimentor has transformed [savedName] into [loaded_item]", INVESTIGATE_EXPERIMENTOR)
			if(istype(loaded_item, /obj/item/grenade/chem_grenade))
				var/obj/item/grenade/chem_grenade/CG = loaded_item
				CG.detonate()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message(span_warning("[src] fills its chamber with gas, [exp_on] included."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_notice("[exp_on] achieves the perfect mix!"))
			new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src] destroys [exp_on], leaking dangerous gas!"))
			chosenchem = pick(/datum/reagent/carbon,/datum/reagent/uranium/radium,/datum/reagent/toxin,/datum/reagent/consumable/condensedcapsaicin,/datum/reagent/drug/mushroomhallucinogen,/datum/reagent/drug/space_drugs,/datum/reagent/consumable/ethanol,/datum/reagent/consumable/ethanol/beepsky_smash)
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(chosenchem , 50)
			investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src]'s chemical chamber has sprung a leak!"))
			chosenchem = pick(/datum/reagent/mutationtoxin/classic,/datum/reagent/cyborg_mutation_nanomachines,/datum/reagent/toxin/acid)
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(chosenchem , 50)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
			warn_admins(usr, "[chosenchem] smoke")
			investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, spewing harmless gas."))
			throwSmoke(loc)
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			visible_message(span_warning("[src] melts [exp_on], ionizing the air around it!"))
			empulse(loc, 4, 6)
			investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message(span_notice("[src] raises [exp_on]'s temperature."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s emergency coolant system gives off a small ding!"))
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
			var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1,src))))
			chosenchem = pick(/datum/reagent/toxin/plasma,/datum/reagent/consumable/capsaicin,/datum/reagent/consumable/ethanol)
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			var/turf/start = get_turf(src)
			var/mob/M = locate(/mob/living) in view(src, 3)
			var/turf/MT = get_turf(M)
			if(MT)
				visible_message(span_danger("[src] dangerously overheats, launching a flaming fuel orb!"))
				investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [M]!", INVESTIGATE_EXPERIMENTOR)
				var/obj/projectile/magic/fireball/FB = new /obj/projectile/magic/fireball(start)
				FB.preparePixelProjectile(MT, start)
				FB.fire()
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_danger("[src] malfunctions, melting [exp_on] and releasing a burst of flame!"))
			explosion(src, devastation_range = -1, flame_range = 2, adminlog = FALSE)
			investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, melting [exp_on] and leaking hot air!"))
			var/datum/gas_mixture/env = loc.return_air()
			if(env)
				var/heat_capacity = max(env.heat_capacity(), 1)
				env.temperature = min((env.temperature * heat_capacity + 100000) / heat_capacity, 1000)
			air_update_turf(FALSE, FALSE)
			investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, activating its emergency coolant systems!"))
			throwSmoke(loc)
			for(var/mob/living/m in oview(1, src))
				m.apply_damage(5, BURN, pick(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_CHEST))
				investigate_log("Experimentor has dealt minor burn damage to [key_name(m)]", INVESTIGATE_EXPERIMENTOR)
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message(span_notice("[src] lowers [exp_on]'s temperature."))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s emergency coolant system gives off a small ding!"))
			var/obj/item/reagent_containers/cup/glass/coffee/C = new /obj/item/reagent_containers/cup/glass/coffee(get_turf(pick(oview(1,src))))
			playsound(src, 'sound/machines/ding.ogg', 50, TRUE) //Ding! Your death coffee is ready!
			chosenchem = pick(/datum/reagent/uranium,/datum/reagent/consumable/frostoil,/datum/reagent/medicine/ephedrine)
			C.reagents.remove_any(25)
			C.reagents.add_reagent(chosenchem , 50)
			C.name = "Cup of Suspicious Liquid"
			C.desc = "It has a large hazard symbol printed on the side in fading ink."
			investigate_log("Experimentor has made a cup of [chosenchem] coffee.", INVESTIGATE_EXPERIMENTOR)
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!"))
			var/datum/reagents/tmp_holder = new/datum/reagents(50)
			tmp_holder.my_atom = src
			tmp_holder.add_reagent(/datum/reagent/consumable/frostoil, 50)
			investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
			var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
			smoke.set_up(0, holder = src, location = src, carry = tmp_holder, silent = TRUE)
			playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
			smoke.start()
			qdel(tmp_holder)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, shattering [exp_on] and leaking cold air!"))
			var/datum/gas_mixture/env = loc.return_air()
			if(env)
				var/heat_capacity = max(env.heat_capacity(), 1)
				env.temperature = max((env.temperature * heat_capacity - 75000) / heat_capacity, TCMB)
			air_update_turf(FALSE, FALSE)
			investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-malfunction_probability_coeff))
			visible_message(span_warning("[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!"))
			var/datum/effect_system/fluid_spread/smoke/smoke = new
			smoke.set_up(0, holder = src, location = loc)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message(span_warning("[exp_on] activates the crushing mechanism, [exp_on] is destroyed!"))
		if(prob(EFFECT_PROB_LOW) && criticalReaction)
			visible_message(span_warning("[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!"))
			new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1,src))))
		else if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff))
			visible_message(span_danger("[src]'s crusher goes way too many levels too high, crushing right through space-time!"))
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					AM.throw_at(src,10,1)
		else if(prob(EFFECT_PROB_LOW-malfunction_probability_coeff))
			visible_message(span_danger("[src]'s crusher goes one level too high, crushing right into space-time!"))
			playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
			investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)
			var/list/throwAt = list()
			for(var/atom/movable/AM in oview(7,src))
				if(!AM.anchored)
					throwAt.Add(AM)
			for(var/counter in 1 to throwAt.len)
				var/atom/movable/cast = throwAt[counter]
				cast.throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders","honks")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message(span_warning("[exp_on] [a], and [b], the experiment was a failure."))

	if(exp == SCANTYPE_DISCOVER)
		visible_message(span_notice("[src] scans the [exp_on], revealing its true nature!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 3, -1)
		var/obj/item/relic/R = loaded_item
		R.reveal()
		investigate_log("Experimentor has revealed a relic with [span_danger("[R.realProc]")] effect.", INVESTIGATE_EXPERIMENTOR)
		ejectItem()

	//Global reactions
	if(prob(EFFECT_PROB_VERYLOW-malfunction_probability_coeff) && loaded_item)
		var/globalMalf = rand(1,100)
		if(globalMalf < 15)
			visible_message(span_warning("[src]'s onboard detection system has malfunctioned!"))
			item_reactions()["[exp_on.type]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
			ejectItem()
		if(globalMalf > 16 && globalMalf < 35)
			visible_message(span_warning("[src] melts [exp_on], ian-izing the air around it!"))
			throwSmoke(loc)
			var/mob/living/tracked_ian = tracked_ian_ref?.resolve()
			if(tracked_ian)
				throwSmoke(tracked_ian.loc)
				tracked_ian.forceMove(loc)
				investigate_log("Experimentor has stolen Ian!", INVESTIGATE_EXPERIMENTOR) //...if anyone ever fixes it...
			else
				new /mob/living/basic/pet/dog/corgi(loc)
				investigate_log("Experimentor has spawned a new corgi.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 36 && globalMalf < 50)
			visible_message(span_warning("Experimentor draws the life essence of those nearby!"))
			for(var/mob/living/m in view(4,src))
				to_chat(m, span_danger("You feel your flesh being torn from you, mists of blood drifting to [src]!"))
				m.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
				investigate_log("Experimentor has taken 50 brute a blood sacrifice from [m]", INVESTIGATE_EXPERIMENTOR)
		if(globalMalf > 51 && globalMalf < 75)
			visible_message(span_warning("[src] encounters a run-time error!"))
			throwSmoke(loc)
			var/mob/living/tracked_runtime = tracked_runtime_ref?.resolve()
			if(tracked_runtime)
				throwSmoke(tracked_runtime.loc)
				tracked_runtime.forceMove(drop_location())
				investigate_log("Experimentor has stolen Runtime!", INVESTIGATE_EXPERIMENTOR)
			else
				new /mob/living/simple_animal/pet/cat(loc)
				investigate_log("Experimentor failed to steal runtime, and instead spawned a new cat.", INVESTIGATE_EXPERIMENTOR)
			ejectItem(TRUE)
		if(globalMalf > 76 && globalMalf < 98)
			visible_message(span_warning("[src] begins to smoke and hiss, shaking violently!"))
			use_power(500000)
			investigate_log("Experimentor has drained power from its APC", INVESTIGATE_EXPERIMENTOR)
		if(globalMalf == 99)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(boom)), 50)
		if(globalMalf == 100)
			visible_message(span_warning("[src] begins to glow and vibrate. It's going to blow!"))
			addtimer(CALLBACK(src, PROC_REF(honk)), 50)

	addtimer(CALLBACK(src, PROC_REF(reset_exp)), resetTime)

/obj/machinery/rnd/experimentor/proc/boom()
	explosion(src, devastation_range = 1, heavy_impact_range = 5, light_impact_range = 10, flash_range = 5, adminlog = TRUE)

/obj/machinery/rnd/experimentor/proc/honk()
	playsound(src, 'sound/items/bikehorn.ogg', 500)
	new /obj/item/grown/bananapeel(loc)

/obj/machinery/rnd/experimentor/proc/reset_exp()
	update_appearance()
	recentlyExperimented = FALSE

/obj/machinery/rnd/experimentor/update_icon_state()
	icon_state = base_icon_state
	return ..()

/obj/machinery/rnd/experimentor/proc/warn_admins(user, ReactionName)
	var/turf/T = get_turf(user)
	message_admins("Experimentor reaction: [ReactionName] generated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(T)]")
	log_game("Experimentor reaction: [ReactionName] generated by [key_name(user)] in [AREACOORD(T)]")

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE
#undef SCANTYPE_DISCOVER

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL


//////////////////////////////////SPECIAL ITEMS////////////////////////////////////////

/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold? Maybe Research & Development could find out."
	icon = 'icons/obj/assemblies/assemblies.dmi'
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc
	var/reset_timer = 60
	COOLDOWN_DECLARE(cooldown)

/obj/item/relic/Initialize(mapload)
	. = ..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","illegal tech","weapon")]"


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	name = realName
	reset_timer = rand(reset_timer, reset_timer * 5)
	realProc = pick(PROC_REF(teleport), PROC_REF(explode), PROC_REF(rapidDupe), PROC_REF(petSpray), PROC_REF(flash), PROC_REF(clean), PROC_REF(corgicannon))

/obj/item/relic/attack_self(mob/user)
	if(!revealed)
		to_chat(user, span_notice("You aren't quite sure what this is. Maybe R&D knows what to do with it?"))
		return
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_warning("[src] does not react!"))
		return
	if(loc != user)
		return
	COOLDOWN_START(src, cooldown, reset_timer)
	call(src,realProc)(user)

//////////////// RELIC PROCS /////////////////////////////

/obj/item/relic/proc/throwSmoke(turf/where)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(0, holder = src, location = get_turf(where))
	smoke.start()

/obj/item/relic/proc/corgicannon(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/mob/living/basic/pet/dog/corgi/sad_corgi = new(get_turf(user))
	sad_corgi.throw_at(pick(oview(10,user)), 10, rand(3,8), callback = CALLBACK(src, PROC_REF(throwSmoke), sad_corgi))
	warn_admins(user, "Corgi Cannon", 0)

/obj/item/relic/proc/clean(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/chem_grenade/cleaner/CL = new/obj/item/grenade/chem_grenade/cleaner(get_turf(user))
	CL.detonate()
	qdel(CL)
	warn_admins(user, "Foam", 0)

/obj/item/relic/proc/flash(mob/user)
	playsound(src, SFX_SPARKS, rand(25,50), TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/obj/item/grenade/flashbang/CB = new/obj/item/grenade/flashbang(user.loc)
	CB.detonate()
	warn_admins(user, "Flash")

/obj/item/relic/proc/petSpray(mob/user)
	var/message = span_danger("[src] begins to shake, and in the distance the sound of rampaging animals arises!")
	visible_message(message)
	to_chat(user, message)

	var/static/list/valid_animals = list(
		/mob/living/basic/bear,
		/mob/living/basic/bee,
		/mob/living/basic/butterfly,
		/mob/living/basic/carp,
		/mob/living/basic/crab,
		/mob/living/basic/lizard,
		/mob/living/basic/mouse,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/basic/pet/dog/pug,
		/mob/living/basic/pet/fox,
		/mob/living/simple_animal/parrot/natural,
		/mob/living/simple_animal/pet/cat,
	)
	for(var/counter in 1 to rand(1, 25))
		var/mobType = pick(valid_animals)
		new mobType(get_turf(src))

	warn_admins(user, "Mass Mob Spawn")
	if(prob(60))
		to_chat(user, span_warning("[src] falls apart!"))
		qdel(src)

/obj/item/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	for(var/counter in 1 to rand(5,10))
		var/obj/item/relic/R = new type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes += R
		R.throw_at(pick(oview(7,get_turf(src))),10,1)

	QDEL_LIST_IN(dupes, rand(10, 100))
	warn_admins(user, "Rapid duplicator", 0)

/obj/item/relic/proc/explode(mob/user)
	to_chat(user, span_danger("[src] begins to heat up!"))
	addtimer(CALLBACK(src, PROC_REF(do_explode), user), rand(35, 100))

/obj/item/relic/proc/do_explode(mob/user)
	if(loc == user)
		visible_message(span_notice("\The [src]'s top opens, releasing a powerful blast!"))
		explosion(src, heavy_impact_range = rand(1,5), light_impact_range = rand(1,5), flame_range = 2, flash_range = rand(1,5), adminlog = TRUE)
		warn_admins(user, "Explosion")
		qdel(src) //Comment this line to produce a light grenade (the bomb that keeps on exploding when used)!!

/obj/item/relic/proc/teleport(mob/user)
	to_chat(user, span_notice("[src] begins to vibrate!"))
	addtimer(CALLBACK(src, PROC_REF(do_the_teleport), user), rand(10, 30))

/obj/item/relic/proc/do_the_teleport(mob/user)
	var/turf/userturf = get_turf(user)
	if(loc == user && !is_centcom_level(userturf.z)) //Because Nuke Ops bringing this back on their shuttle, then looting the ERT area is 2fun4you!
		visible_message(span_notice("[src] twists and bends, relocating itself!"))
		throwSmoke(userturf)
		do_teleport(user, userturf, 8, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
		throwSmoke(get_turf(user))
		warn_admins(user, "Teleport", 0)

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in [AREACOORD(T)]"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
