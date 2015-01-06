//this is designed to replace the destructive analyzer

#define SCANTYPE_POKE 1
#define SCANTYPE_IRRADIATE 2
#define SCANTYPE_GAS 3
#define SCANTYPE_HEAT 4
#define SCANTYPE_COLD 5
#define SCANTYPE_OBLITERATE 6

#define EFFECT_PROB_VERYLOW 10
#define EFFECT_PROB_LOW 20
#define EFFECT_PROB_MEDIUM 45
#define EFFECT_PROB_HIGH 65
#define EFFECT_PROB_VERYHIGH 85

#define FAIL 7
/obj/machinery/r_n_d/experimentor
	name = "E.X.P.E.R.I-MENTOR"
	icon = 'icons/obj/machines/heavy_lathe.dmi'
	icon_state = "h_lathe"
	density = 1
	anchored = 1
	use_power = 1
	var/obj/item/loaded_item = null
	///
	var/badThingCoeff = 0
	var/resetTime = 15
	var/list/item_reactions = list()
	var/list/valid_items = list()

/obj/machinery/r_n_d/experimentor/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list

/obj/machinery/r_n_d/experimentor/proc/SetTypeReactions()
	for(var/I in typesof(/obj/item))
		item_reactions["[I]"] = pick(SCANTYPE_POKE,SCANTYPE_IRRADIATE,SCANTYPE_GAS,SCANTYPE_HEAT,SCANTYPE_COLD,SCANTYPE_OBLITERATE)
		if(ispath(I,/obj/item/weapon/reagent_containers/food) || ispath(I,/obj/item/weapon/stock_parts) || ispath(I,/obj/item/weapon/grenade/chem_grenade) || ispath(I,/obj/item/weapon/kitchen))
			var/obj/item/tempCheck = new I()
			if(tempCheck.icon_state != null) //check it's an actual usable item, in a hacky way
				valid_items += I
			qdel(tempCheck)


/obj/machinery/r_n_d/experimentor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/experimentor(src)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	SetTypeReactions()
	RefreshParts()

/obj/machinery/r_n_d/experimentor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		if(resetTime > 0 && (resetTime - M.rating) >= 1)
			resetTime -= M.rating
	for(var/obj/item/weapon/stock_parts/scanning_module/M in component_parts)
		badThingCoeff += M.rating*2
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		badThingCoeff += M.rating

/obj/machinery/r_n_d/experimentor/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (istype(O, /obj/item/weapon/screwdriver))
		if (!panel_open)
			panel_open = 1
			if(linked_console)
				linked_console.linked_destroy = null
				linked_console = null
			icon_state = "h_lathe_maint"
			user << "<span class='notice'>You open the maintenance hatch of [src].</span>"
		else
			panel_open = 0
			icon_state = "h_lathe"
			user << "<span class='notice'>You close the maintenance hatch of [src].</span>"
		return
	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				I.loc = src.loc
			del(src)
			return 1
		else
			user << "<span class='warning'>You can't load the [src.name] while it's opened.</span>"
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "<span class='warning'>The [src] must be linked to an R&D console first!</span>"
		return
	if (busy)
		user << "<span class='warning'>The [src] is busy right now.</span>"
		return
	if (istype(O, /obj/item) && !loaded_item)
		if(!O.origin_tech)
			user << "<span class='warning'>This doesn't seem to have a tech origin!</span>"
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			user << "<span class='warning'>You cannot experiment on this item!</span>"
			return
		if(O.reliability < 90 && O.crit_fail == 0)
			usr << "<span class='warning'>Item is neither reliable enough or broken enough to learn from.</span>"
			return
		busy = 1
		loaded_item = O
		user.drop_item()
		O.loc = src
		user << "<span class='notice'>You add the [O.name] to the machine!</span>"
		flick("h_lathe_load", src)
		spawn(15)
			icon_state = "h_lathe_wloop"
	return


/obj/machinery/r_n_d/experimentor/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = "<center>"
	if(!linked_console)
		dat += "<b><a href='byond://?src=\ref[src];function=search'>Scan for R&D Console</A></b><br>"
	if(loaded_item)
		dat += "<b>Loaded Item:</b> [loaded_item]<br>"
		dat += "<b>Technology</b>:<br>"
		var/list/D = ConvertReqString2List(loaded_item.origin_tech)
		for(var/T in D)
			dat += "[T]<br>"
		dat += "<br><br>Available tests:"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_POKE]'>Poke</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_IRRADIATE];'>Irradiate</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_GAS]'>Gas</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_HEAT]'>Burn</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_COLD]'>Freeze</A></b>"
		dat += "<br><b><a href='byond://?src=\ref[src];item=\ref[loaded_item];function=[SCANTYPE_OBLITERATE]'>Destroy</A></b><br>"
		dat += "<br><b><a href='byond://?src=\ref[src];function=eject'>Eject</A>"
	else
		dat += "<b>Nothing loaded.</b>"
	dat += "<br><a href='byond://?src=\ref[src];function=close'>Close</A><br></center>"
	var/datum/browser/popup = new(user, "experimentor","Experimentor", 700, 400, src)
	popup.set_content(dat)
	popup.open()
	onclose(user, "experimentor")


/obj/machinery/r_n_d/experimentor/proc/matchReaction(var/matching,var/reaction)
	var/obj/item/D = matching
	if(D)
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

/obj/machinery/r_n_d/experimentor/proc/ejectItem(var/delete=FALSE)
	loaded_item.loc = src.loc
	if(delete)
		qdel(loaded_item)
	loaded_item = null

/*
#define EFFECT_PROB_VERYLOW 10
#define EFFECT_PROB_LOW 20
#define EFFECT_PROB_MEDIUM 45
#define EFFECT_PROB_HIGH 65
#define EFFECT_PROB_VERYHIGH 85
*/
/obj/machinery/r_n_d/experimentor/proc/experiment(var/exp,var/obj/item/exp_on)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_POKE)
		visible_message("<span class='notice'>[src] prods at [exp_on] with mechanical arms.</span>")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions and destroys [exp_on], lashing it's arms out at nearby people!.</span>")
			for(var/mob/living/m in oview(1))
				m.apply_damage(15,"brute",pick("head","chest","groin"))
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions!.</span>")
			exp = SCANTYPE_OBLITERATE
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, throwing the [exp_on]!.</span>")
			var/mob/living/target = locate(/mob/living) in oview(7,src)
			if(target)
				var/obj/item/throwing = loaded_item
				ejectItem()
				throwing.throw_at(target, 10, 1)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_IRRADIATE)
		visible_message("<span class='notice'>[src] reflects radioactive rays at [exp_on]!</span>")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, melting [exp_on] and leaking radiation!.</span>")
			for(var/mob/living/m in oview(1))
				m.apply_effect(25,IRRADIATE)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, spewing toxic waste!.</span>")
			for(var/turf/T in oview(1))
				if(!T.density)
					if(prob(EFFECT_PROB_VERYHIGH))
						new /obj/effect/decal/cleanable/greenglow(T)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, transforming the [exp_on]!.</span>")
			ejectItem(TRUE)
			var/newPath = pick(valid_items)
			loaded_item = new newPath(src)
			if(istype(loaded_item,/obj/item/weapon/grenade/chem_grenade))
				var/obj/item/weapon/grenade/chem_grenade/CG = loaded_item
				CG.prime()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_GAS)
		visible_message("<span class='notice'>[src] fills it's chamber with gas, [exp_on] included.</span>")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src] destroys [exp_on], leaking dangerous gas!.</span>")
			var/list/chems = list("carbon","radium","toxin","condensedcapsaicin","mushroomhallucinogen","space_drugs","ethanol","beepskysmash")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent(pick(chems), 50)
			var/datum/effect/effect/system/chem_smoke_spread/smoke = new
			smoke.set_up(R, 1, 0, src, 0, silent = 1)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			R.delete()
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, spewing harmless gas!.</span>")
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(1,0, src.loc, 0)
			smoke.start()
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='notice'>[src] melts [exp_on], ionizing the air around it!.</span>")
			empulse(src.loc, 8, 10)
			ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_HEAT)
		visible_message("<span class='notice'>[src] raises [exp_on]'s temperature.</span>")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, melting [exp_on] and releasing a burst of flame!.</span>")
			explosion(src.loc, -1, 0, 0, 0, 0, flame_range = 2)
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, melting [exp_on] and leaking hot air!.</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = min((removed.temperature*heat_capacity + 100000)/heat_capacity, 1000)
			env.merge(removed)
			air_update_turf()
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, activating it's emergency coolant systems!.</span>")
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(1,0, src.loc, 0)
			smoke.start()
			for(var/mob/living/m in oview(1))
				m.apply_damage(5,"burn",pick("head","chest","groin"))
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_COLD)
		visible_message("<span class='notice'>[src] lowers [exp_on]'s temperature.</span>")
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!</span>")
			var/datum/reagents/R = new/datum/reagents(50)
			R.my_atom = src
			R.add_reagent("frostoil", 50)
			var/datum/effect/effect/system/chem_smoke_spread/smoke = new
			smoke.set_up(R, 1, 0, src, 0, silent = 1)
			playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			R.delete()
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, shattering [exp_on] and leaking cold air!.</span>")
			var/datum/gas_mixture/env = src.loc.return_air()
			var/transfer_moles = 0.25 * env.total_moles()
			var/datum/gas_mixture/removed = env.remove(transfer_moles)
			if(removed)
				var/heat_capacity = removed.heat_capacity()
				if(heat_capacity == 0 || heat_capacity == null)
					heat_capacity = 1
				removed.temperature = (removed.temperature*heat_capacity - 75000)/heat_capacity
			env.merge(removed)
			air_update_turf()
			ejectItem(TRUE)
		else if(prob(EFFECT_PROB_MEDIUM-badThingCoeff))
			visible_message("<span class='notice'>[src] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!.</span>")
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(1,0, src.loc, 0)
			smoke.start()
			ejectItem()
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == SCANTYPE_OBLITERATE)
		visible_message("<span class='notice'>[exp_on] activates the crushing mechanism, [exp_on] is destroyed!</span>")
		if(linked_console.linked_lathe)
			linked_console.linked_lathe.m_amount += min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (exp_on.m_amt))
			linked_console.linked_lathe.g_amount += min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (exp_on.g_amt))
		if(prob(EFFECT_PROB_VERYLOW-badThingCoeff))
			visible_message("<span class='notice'>[src]'s crusher goes way too many levels too high, crushing right through space-time!</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			var/list/throwAt = list()
			for(var/i in oview(7,src))
				if(istype(i,/obj/item) || istype(i,/mob/living))
					throwAt.Add(i)
			var/counter
			for(counter = 1, counter < throwAt.len, ++counter)
				var/cast = throwAt[counter]
				cast:throw_at(src,10,1)
		else if(prob(EFFECT_PROB_LOW-badThingCoeff))
			visible_message("<span class='notice'>[src]'s crusher goes one level too high, crushing right into space-time!.</span>")
			playsound(src.loc, 'sound/effects/supermatter.ogg', 50, 1, -3)
			var/list/oViewStuff = oview(7,src)
			var/list/throwAt = list()
			for(var/i in oViewStuff)
				if(istype(i,/obj/item) || istype(i,/mob/living))
					throwAt.Add(i)
			var/counter
			for(counter = 1, counter < throwAt.len, ++counter)
				var/cast = throwAt[counter]
				cast:throw_at(pick(throwAt),10,1)
		ejectItem(TRUE)
	////////////////////////////////////////////////////////////////////////////////////////////////
	if(exp == FAIL)
		var/a = pick("rumbles","shakes","vibrates","shudders")
		var/b = pick("crushes","spins","viscerates","smashes","insults")
		visible_message("<span class='notice'>[exp_on] [a], and [b], the experiment was a failiure!</span>")

	spawn(resetTime)
		icon_state = "h_lathe"
		busy = 0

/obj/machinery/r_n_d/experimentor/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)

	var/scantype = href_list["function"]
	var/obj/item/process = locate(href_list["item"]) in src

	if(scantype == "close")
		usr << browse(null, "window=experimentor")
	else if(scantype == "search")
		var/obj/machinery/computer/rdconsole/D = locate(/obj/machinery/computer/rdconsole) in oview(3,src)
		if(D)
			linked_console = D
	else if(scantype == "eject")
		ejectItem()
	else
		var/dotype = matchReaction(process,scantype)
		experiment(dotype,process)
		use_power(750)
		if(dotype != FAIL)
			if(process.origin_tech)
				var/list/temp_tech = ConvertReqString2List(process.origin_tech)
				for(var/T in temp_tech)
					linked_console.files.UpdateTech(T, temp_tech[T])
				linked_console.files.UpdateDesigns(process,process.type)
	if(scantype != "close")
		src.updateUsrDialog()
	return

#undef SCANTYPE_POKE
#undef SCANTYPE_IRRADIATE
#undef SCANTYPE_GAS
#undef SCANTYPE_HEAT
#undef SCANTYPE_COLD
#undef SCANTYPE_OBLITERATE

#undef EFFECT_PROB_VERYLOW
#undef EFFECT_PROB_LOW
#undef EFFECT_PROB_MEDIUM
#undef EFFECT_PROB_HIGH
#undef EFFECT_PROB_VERYHIGH

#undef FAIL
