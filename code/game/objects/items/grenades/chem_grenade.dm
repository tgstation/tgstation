/obj/item/grenade/chem_grenade
	name = "chemical grenade"
	desc = "A custom made grenade."
	icon_state = "chemg"
	inhand_icon_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	var/stage = GRENADE_EMPTY
	var/list/obj/item/reagent_containers/glass/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/glass/bottle)
	var/list/banned_containers = list(/obj/item/reagent_containers/glass/beaker/bluespace) //Containers to exclude from specific grenade subtypes
	var/affected_area = 3
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.
	var/casedesc = "This basic model accepts both beakers and bottles. It heats contents by 10 K upon ignition." // Appears when examining empty casings.
	var/obj/item/assembly/prox_sensor/landminemode = null

/obj/item/grenade/chem_grenade/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_WIRES)

/obj/item/grenade/chem_grenade/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.
	wires = new /datum/wires/explosive/chem_grenade(src)

/obj/item/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == GRENADE_READY) //show/hide the timer based on assembly state
	. = ..()
	if(user.can_see_reagents())
		if(beakers.len)
			. += span_notice("You scan the grenade and detect the following reagents:")
			for(var/obj/item/reagent_containers/glass/glass_beaker in beakers)
				for(var/datum/reagent/reagent in glass_beaker.reagents.reagent_list)
					. += span_notice("[reagent.volume] units of [reagent.name] in the [glass_beaker.name].")
			if(beakers.len == 1)
				. += span_notice("You detect no second beaker in the grenade.")
		else
			. += span_notice("You scan the grenade, but detect nothing.")
	else if(stage != GRENADE_READY && beakers.len)
		if(beakers.len == 2 && beakers[1].name == beakers[2].name)
			. += span_notice("You see two [beakers[1].name]s inside the grenade.")
		else
			for(var/obj/item/reagent_containers/glass/glass_beaker in beakers)
				. += span_notice("You see a [glass_beaker.name] inside the grenade.")

/obj/item/grenade/chem_grenade/attack_self(mob/user)
	if(stage == GRENADE_READY && !active)
		..()
	if(stage == GRENADE_WIRED)
		wires.interact(user)

/obj/item/grenade/chem_grenade/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/assembly) && stage == GRENADE_WIRED)
		wires.interact(user)
	if(item.tool_behaviour == TOOL_SCREWDRIVER)
		if(stage == GRENADE_WIRED)
			if(beakers.len)
				stage_change(GRENADE_READY)
				to_chat(user, span_notice("You lock the [initial(name)] assembly."))
				item.play_tool_sound(src, 25)
			else
				to_chat(user, span_warning("You need to add at least one beaker before locking the [initial(name)] assembly!"))
		else if(stage == GRENADE_READY)
			det_time = det_time == 50 ? 30 : 50 //toggle between 30 and 50
			if(landminemode)
				landminemode.time = det_time * 0.1 //overwrites the proxy sensor activation timer

			to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))
		else
			to_chat(user, span_warning("You need to add a wire!"))
		return
	else if(stage == GRENADE_WIRED && is_type_in_list(item, allowed_containers))
		. = TRUE //no afterattack
		if(is_type_in_list(item, banned_containers))
			to_chat(user, span_warning("[src] is too small to fit [item]!")) // this one hits home huh anon?
			return
		if(beakers.len == 2)
			to_chat(user, span_warning("[src] can not hold more containers!"))
			return
		else
			if(item.reagents.total_volume)
				if(!user.transferItemToLoc(item, src))
					return
				to_chat(user, span_notice("You add [item] to the [initial(name)] assembly."))
				beakers += item
				var/reagent_list = pretty_string_from_reagent_list(item.reagents)
				user.log_message("inserted [item] ([reagent_list]) into [src]", LOG_GAME)
			else
				to_chat(user, span_warning("[item] is empty!"))

	else if(stage == GRENADE_EMPTY && istype(item, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = item
		if (coil.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(GRENADE_WIRED)
			to_chat(user, span_notice("You rig the [initial(name)] assembly."))
		else
			to_chat(user, span_warning("You need one length of coil to wire the assembly!"))
			return

	else if(stage == GRENADE_READY && item.tool_behaviour == TOOL_WIRECUTTER && !active)
		stage_change(GRENADE_WIRED)
		to_chat(user, span_notice("You unlock the [initial(name)] assembly."))

	else if(stage == GRENADE_WIRED && item.tool_behaviour == TOOL_WRENCH)
		if(beakers.len)
			for(var/obj/beaker in beakers)
				beaker.forceMove(drop_location())
				if(!beaker.reagents)
					continue
				var/reagent_list = pretty_string_from_reagent_list(beaker.reagents)
				user.log_message("removed [beaker] ([reagent_list]) from [src]", LOG_GAME)
			beakers = list()
			to_chat(user, span_notice("You open the [initial(name)] assembly and remove the payload."))
			return
		wires.detach_assembly(wires.get_wire(1))
		new /obj/item/stack/cable_coil(get_turf(src), 1)
		stage_change(GRENADE_EMPTY)
		to_chat(user, span_notice("You remove the activation mechanism from the [initial(name)] assembly."))
	else
		return ..()

/obj/item/grenade/chem_grenade/proc/stage_change(N)
	if(N)
		stage = N
	if(stage == GRENADE_EMPTY)
		name = "[initial(name)] casing"
		desc = "A do it yourself [initial(name)]! [initial(casedesc)]"
		icon_state = initial(icon_state)
	else if(stage == GRENADE_WIRED)
		name = "unsecured [initial(name)]"
		desc = "An unsecured [initial(name)] assembly."
		icon_state = "[initial(icon_state)]_ass"
	else if(stage == GRENADE_READY)
		name = initial(name)
		desc = initial(desc)
		icon_state = "[initial(icon_state)]_locked"

/obj/item/grenade/chem_grenade/on_found(mob/finder)
	var/obj/item/assembly/assembly = wires.get_attached(wires.get_wire(1))
	assembly?.on_found(finder)

/obj/item/grenade/chem_grenade/log_grenade(mob/user)
	var/reagent_string = ""
	var/beaker_number = 1
	for(var/obj/exploded_beaker in beakers)
		if(!exploded_beaker.reagents)
			continue
		reagent_string += " ([exploded_beaker.name] [beaker_number++] : " + pretty_string_from_reagent_list(exploded_beaker.reagents.reagent_list) + ");"
	if(landminemode)
		log_bomber(user, "activated a proxy", src, "containing:[reagent_string]")
	else
		log_bomber(user, "primed a", src, "containing:[reagent_string]")

/obj/item/grenade/chem_grenade/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			if(landminemode)
				to_chat(user, span_warning("You prime [src], activating its proximity sensor."))
			else
				to_chat(user, span_warning("You prime [src]! [DisplayTimeText(det_time)]!"))
	playsound(src, 'sound/weapons/armbomb.ogg', volume, TRUE)
	icon_state = initial(icon_state) + "_active"
	if(landminemode)
		landminemode.activate()
		return
	active = TRUE
	addtimer(CALLBACK(src, .proc/detonate), isnull(delayoverride)? det_time : delayoverride)

/obj/item/grenade/chem_grenade/detonate(mob/living/lanced_by)
	if(stage != GRENADE_READY)
		return

	. = ..()
	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_containers/glass/glass_beaker in beakers)
		reactants += glass_beaker.reagents

	var/turf/detonation_turf = get_turf(src)

	if(!chem_splash(detonation_turf, affected_area, reactants, ignition_temp, threatscale) && !no_splash)
		playsound(src, 'sound/items/screwdriver2.ogg', 50, TRUE)
		if(beakers.len)
			for(var/obj/beaker as anything in beakers)
				beaker.forceMove(drop_location())
			beakers = list()
		stage_change(GRENADE_EMPTY)
		active = FALSE
		return
// logs from custom assemblies priming are handled by the wire component
	log_game("A grenade detonated at [AREACOORD(detonation_turf)]")

	update_mob()

	qdel(src)

//Large chem grenades accept slime cores and use the appropriately.
/obj/item/grenade/chem_grenade/large
	name = "large grenade"
	desc = "A custom made large grenade. Larger splash range and increased ignition temperature compared to basic grenades. Fits exotic and bluespace based containers."
	casedesc = "This casing affects a larger area than the basic model and can fit exotic containers, including slime cores and bluespace beakers. Heats contents by 25 K upon ignition."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/condiment, /obj/item/reagent_containers/food/drinks)
	banned_containers = list()
	affected_area = 5
	ignition_temp = 25 // Large grenades are slightly more effective at setting off heat-sensitive mixtures than smaller grenades.
	threatscale = 1.1 // 10% more effective.

/obj/item/grenade/chem_grenade/large/detonate(mob/living/lanced_by)
	if(stage != GRENADE_READY)
		return

	for(var/obj/item/slime_extract/slime_extract in beakers)
		if (!slime_extract.Uses)
			continue

		for(var/obj/item/reagent_containers/glass/glass_beaker in beakers)
			glass_beaker.reagents.trans_to(slime_extract, glass_beaker.reagents.total_volume)

		//If there is still a core (sometimes it's used up)
		//and there are reagents left, behave normally,
		//otherwise drop it on the ground for timed reactions like gold.

		if(!slime_extract)
			continue

		if(slime_extract.reagents && slime_extract.reagents.total_volume)
			for(var/obj/item/reagent_containers/glass/glass_beaker in beakers)
				slime_extract.reagents.trans_to(glass_beaker, slime_extract.reagents.total_volume)
		else
			slime_extract.forceMove(get_turf(src))
			no_splash = TRUE
	..()

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/grenade/chem_grenade/large/attackby(obj/item/item, mob/user, params)
	if(!istype(item, /obj/item/slime_extract) || stage != GRENADE_WIRED)
		return ..()

	if(!user.transferItemToLoc(item, src))
		return
	to_chat(user, span_notice("You add [item] to the [initial(name)] assembly."))
	beakers += item

/obj/item/grenade/chem_grenade/cryo // Intended for rare cryogenic mixes. Cools the area moderately upon detonation.
	name = "cryo grenade"
	desc = "A custom made cryogenic grenade. Rapidly cools contents upon ignition."
	casedesc = "Upon ignition, it rapidly cools contents by 100 K. Smaller splash range than regular casings."
	icon_state = "cryog"
	affected_area = 2
	ignition_temp = -100

/obj/item/grenade/chem_grenade/pyro // Intended for pyrotechnical mixes. Produces a small fire upon detonation, igniting potentially flammable mixtures.
	name = "pyro grenade"
	desc = "A custom made pyrotechnical grenade. Heats up contents upon ignition."
	casedesc = "Upon ignition, it rapidly heats contents by 500 K."
	icon_state = "pyrog"
	ignition_temp = 500 // This is enough to expose a hotspot.

/obj/item/grenade/chem_grenade/adv_release // Intended for weaker, but longer lasting effects. Could have some interesting uses.
	name = "advanced release grenade"
	desc = "A custom made advanced release grenade. It is able to be detonated more than once. Can be configured using a multitool."
	casedesc = "This casing is able to detonate more than once. Can be configured using a multitool."
	icon_state = "timeg"
	var/unit_spread = 10 // Amount of units per repeat. Can be altered with a multitool.

/obj/item/grenade/chem_grenade/adv_release/multitool_act(mob/living/user, obj/item/tool)
	if (active)
		return
	var/newspread = tgui_input_number(user, "Please enter a new spread amount", "Grenade Spread", 5, 100, 5)
	if(isnull(newspread))
		return
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	newspread = round(newspread)
	unit_spread = clamp(newspread, 5, 100)
	to_chat(user, span_notice("You set the time release to [unit_spread] units per detonation."))
	..()

/obj/item/grenade/chem_grenade/adv_release/detonate(mob/living/lanced_by)
	if(stage != GRENADE_READY)
		return

	var/total_volume = 0
	for(var/obj/item/reagent_containers/reagent_container in beakers)
		total_volume += reagent_container.reagents.total_volume
	if(!total_volume)
		qdel(src)
		return
	var/fraction = unit_spread/total_volume
	var/datum/reagents/reactants = new(unit_spread)
	reactants.my_atom = src
	for(var/obj/item/reagent_containers/reagent_container in beakers)
		reagent_container.reagents.trans_to(reactants, reagent_container.reagents.total_volume*fraction, threatscale, 1, 1)
	chem_splash(get_turf(src), affected_area, list(reactants), ignition_temp, threatscale)

	var/turf/detonated_turf = get_turf(src)
	addtimer(CALLBACK(src, .proc/detonate), det_time)
	log_game("A grenade detonated at [AREACOORD(detonated_turf)]")




//////////////////////////////
////// PREMADE GRENADES //////
//////////////////////////////

/obj/item/grenade/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of hull breaches."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/metalfoam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/aluminium, 30)
	beaker_two.reagents.add_reagent(/datum/reagent/foaming_agent, 10)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 10)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/smart_metal_foam
	name = "smart metal foam grenade"
	desc = "Used for emergency sealing of hull breaches, while keeping areas accessible."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/smart_metal_foam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/aluminium, 75)
	beaker_two.reagents.add_reagent(/datum/reagent/smart_foaming_agent, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/incendiary/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/stable_plasma, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/antiweed/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/toxin/plantbgone, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/cleaner/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/fluorosurfactant, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/water, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/space_cleaner, 10)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/ez_clean
	name = "cleaner grenade"
	desc = "Waffle Co.-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/ez_clean/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/fluorosurfactant, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/water, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/space_cleaner/ez_clean, 60) //ensures a  t h i c c  distribution

	beakers += beaker_one
	beakers += beaker_two



/obj/item/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/teargas/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 60)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 40)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 40)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/facid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/facid/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 290)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 10)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 10)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 10)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 280)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/colorful
	name = "colorful grenade"
	desc = "Used for wide scale painting projects."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/colorful/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/colorful_reagent, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += beaker_one
	beakers += beaker_two

/obj/item/grenade/chem_grenade/glitter
	name = "generic glitter grenade"
	desc = "You shouldn't see this description."
	stage = GRENADE_READY
	var/glitter_type = /datum/reagent/glitter

/obj/item/grenade/chem_grenade/glitter/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/beaker_two = new(src)

	beaker_one.reagents.add_reagent(glitter_type, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 25)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 25)

	beakers += beaker_one
	beakers += beaker_two

/obj/item/grenade/chem_grenade/glitter/pink
	name = "pink glitter bomb"
	desc = "For that HOT glittery look."
	glitter_type = /datum/reagent/glitter/pink

/obj/item/grenade/chem_grenade/glitter/blue
	name = "blue glitter bomb"
	desc = "For that COOL glittery look."
	glitter_type = /datum/reagent/glitter/blue

/obj/item/grenade/chem_grenade/glitter/white
	name = "white glitter bomb"
	desc = "For that somnolent glittery look."
	glitter_type = /datum/reagent/glitter/white

/obj/item/grenade/chem_grenade/clf3
	name = "clf3 grenade"
	desc = "BURN!-brand foaming clf3. In a special applicator for rapid purging of wide areas."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/clf3/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/fluorosurfactant, 250)
	beaker_one.reagents.add_reagent(/datum/reagent/clf3, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/water, 250)
	beaker_two.reagents.add_reagent(/datum/reagent/clf3, 50)

	beakers += beaker_one
	beakers += beaker_two

/obj/item/grenade/chem_grenade/bioterrorfoam
	name = "Bio terror foam grenade"
	desc = "Tiger Cooperative chemical foam grenade. Causes temporary irration, blindness, confusion, mutism, and mutations to carbon based life forms. Contains additional spore toxin."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/bioterrorfoam/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/cryptobiolin, 75)
	beaker_one.reagents.add_reagent(/datum/reagent/water, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/toxin/spore, 75)
	beaker_one.reagents.add_reagent(/datum/reagent/toxin/itching_powder, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/fluorosurfactant, 150)
	beaker_two.reagents.add_reagent(/datum/reagent/toxin/mutagen, 150)
	beakers += beaker_one
	beakers += beaker_two

/obj/item/grenade/chem_grenade/tuberculosis
	name = "Fungal tuberculosis grenade"
	desc = "WARNING: GRENADE WILL RELEASE DEADLY SPORES CONTAINING ACTIVE AGENTS. SEAL SUIT AND AIRFLOW BEFORE USE."
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/tuberculosis/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/phosphorus, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/fungalspores, 200)
	beaker_two.reagents.add_reagent(/datum/reagent/blood, 250)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 50)

	beakers += beaker_one
	beakers += beaker_two

/obj/item/grenade/chem_grenade/holy
	name = "holy hand grenade"
	desc = "A vessel of concentrated religious might."
	icon_state = "holy_grenade"
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/holy/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/meta/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/meta/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 150)
	beaker_two.reagents.add_reagent(/datum/reagent/water/holywater, 150)

	beakers += beaker_one
	beakers += beaker_two
