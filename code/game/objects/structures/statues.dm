/obj/structure/statue
	name = "statue"
	desc = "Placeholder. Yell at Firecage if you SOMEHOW see this."
	icon = 'icons/obj/statue.dmi'
	icon_state = ""
	density = TRUE
	anchored = FALSE
	max_integrity = 100
	CanAtmosPass = ATMOS_PASS_DENSITY
	/// Beauty component mood modifier
	var/impressiveness = 15
	/// Art component subtype added to this statue
	var/art_type = /datum/component/art
	/// Abstract root type
	var/abstract_type = /obj/structure/statue

/obj/structure/statue/Initialize()
	. = ..()
	AddComponent(art_type, impressiveness)
	INVOKE_ASYNC(src, /datum.proc/_AddComponent, list(/datum/component/beauty, impressiveness *  75))

/obj/structure/statue/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(default_unfasten_wrench(user, W))
			return
		if(W.tool_behaviour == TOOL_WELDER)
			if(!W.tool_start_check(user, amount=0))
				return FALSE

			user.visible_message("<span class='notice'>[user] is slicing apart the [name].</span>", \
								"<span class='notice'>You are slicing apart the [name]...</span>")
			if(W.use_tool(src, user, 40, volume=50))
				user.visible_message("<span class='notice'>[user] slices apart the [name].</span>", \
									"<span class='notice'>You slice apart the [name]!</span>")
				deconstruct(TRUE)
			return
	return ..()

/obj/structure/statue/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/amount_mod = disassembled ? 0 : -2
		for(var/mat in custom_materials)
			var/datum/material/custom_material = SSmaterials.GetMaterialRef(mat)
			var/amount = max(0,round(custom_materials[mat]/MINERAL_MATERIAL_AMOUNT) + amount_mod)
			if(amount > 0)
				new custom_material.sheet_type(drop_location(),amount)
	qdel(src)

//////////////////////////////////////STATUES/////////////////////////////////////////////////////////////
////////////////////////uranium///////////////////////////////////

/obj/structure/statue/uranium
	max_integrity = 300
	light_range = 2
	custom_materials = list(/datum/material/uranium=MINERAL_MATERIAL_AMOUNT*5)
	impressiveness = 25 // radiation makes an impression
	abstract_type = /obj/structure/statue/uranium

/obj/structure/statue/uranium/nuke
	name = "statue of a nuclear fission explosive"
	desc = "This is a grand statue of a Nuclear Explosive. It has a sickening green colour."
	icon_state = "nuke"

/obj/structure/statue/uranium/eng
	name = "Statue of an engineer"
	desc = "This statue has a sickening green colour."
	icon_state = "eng"

////////////////////////////plasma///////////////////////////////////////////////////////////////////////

/obj/structure/statue/plasma
	max_integrity = 200
	impressiveness = 20
	desc = "This statue is suitably made from plasma."
	custom_materials = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/plasma

/obj/structure/statue/plasma/scientist
	name = "statue of a scientist"
	icon_state = "sci"

/obj/structure/statue/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)


/obj/structure/statue/plasma/bullet_act(obj/projectile/Proj)
	var/burn = FALSE
	if(!(Proj.nodamage) && Proj.damage_type == BURN && !QDELETED(src))
		burn = TRUE
	if(burn)
		var/turf/T = get_turf(src)
		if(Proj.firer)
			message_admins("Plasma statue ignited by [ADMIN_LOOKUPFLW(Proj.firer)] in [ADMIN_VERBOSEJMP(T)]")
			log_game("Plasma statue ignited by [key_name(Proj.firer)] in [AREACOORD(T)]")
		else
			message_admins("Plasma statue ignited by [Proj]. No known firer, in [ADMIN_VERBOSEJMP(T)]")
			log_game("Plasma statue ignited by [Proj] in [AREACOORD(T)]. No known firer.")
		PlasmaBurn(2500)
	. = ..()

/obj/structure/statue/plasma/attackby(obj/item/W, mob/user, params)
	if(W.get_temperature() > 300 && !QDELETED(src))//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Plasma statue ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Plasma statue ignited by [key_name(user)] in [AREACOORD(T)]")
		ignite(W.get_temperature())
	else
		return ..()

/obj/structure/statue/plasma/proc/PlasmaBurn(exposed_temperature)
	if(QDELETED(src))
		return
	if(custom_materials[/datum/material/plasma])
		var/plasma_amount = round(custom_materials[/datum/material/plasma]/MINERAL_MATERIAL_AMOUNT)
		atmos_spawn_air("plasma=[plasma_amount*10];TEMP=[exposed_temperature]")
	deconstruct(FALSE)

/obj/structure/statue/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

//////////////////////gold///////////////////////////////////////

/obj/structure/statue/gold
	max_integrity = 300
	impressiveness = 25
	desc = "This is a highly valuable statue made from gold."
	custom_materials = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/gold

/obj/structure/statue/gold/hos
	name = "statue of the head of security"
	icon_state = "hos"

/obj/structure/statue/gold/hop
	name = "statue of the head of personnel"
	icon_state = "hop"

/obj/structure/statue/gold/cmo
	name = "statue of the chief medical officer"
	icon_state = "cmo"

/obj/structure/statue/gold/ce
	name = "statue of the chief engineer"
	icon_state = "ce"

/obj/structure/statue/gold/rd
	name = "statue of the research director"
	icon_state = "rd"

//////////////////////////silver///////////////////////////////////////

/obj/structure/statue/silver
	max_integrity = 300
	impressiveness = 25
	desc = "This is a valuable statue made from silver."
	custom_materials = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/silver

/obj/structure/statue/silver/md
	name = "statue of a medical officer"
	icon_state = "md"

/obj/structure/statue/silver/janitor
	name = "statue of a janitor"
	icon_state = "jani"

/obj/structure/statue/silver/sec
	name = "statue of a security officer"
	icon_state = "sec"

/obj/structure/statue/silver/secborg
	name = "statue of a security cyborg"
	icon_state = "secborg"

/obj/structure/statue/silver/medborg
	name = "statue of a medical cyborg"
	icon_state = "medborg"

/////////////////////////diamond/////////////////////////////////////////

/obj/structure/statue/diamond
	max_integrity = 1000
	impressiveness = 50
	desc = "This is a very expensive diamond statue."
	custom_materials = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/diamond

/obj/structure/statue/diamond/captain
	name = "statue of THE captain."
	icon_state = "cap"

/obj/structure/statue/diamond/ai1
	name = "statue of the AI hologram."
	icon_state = "ai1"

/obj/structure/statue/diamond/ai2
	name = "statue of the AI core."
	icon_state = "ai2"

////////////////////////bananium///////////////////////////////////////

/obj/structure/statue/bananium
	max_integrity = 300
	impressiveness = 50
	desc = "A bananium statue with a small engraving:'HOOOOOOONK'."
	custom_materials = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/bananium

/obj/structure/statue/bananium/clown
	name = "statue of a clown"
	icon_state = "clown"

/////////////////////sandstone/////////////////////////////////////////

/obj/structure/statue/sandstone
	max_integrity = 50
	impressiveness = 15
	custom_materials = list(/datum/material/sandstone=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/sandstone

/obj/structure/statue/sandstone/assistant
	name = "statue of an assistant"
	desc = "A cheap statue of sandstone for a greyshirt."
	icon_state = "assist"


/obj/structure/statue/sandstone/venus //call me when we add marble i guess
	name = "statue of a pure maiden"
	desc = "An ancient marble statue. The subject is depicted with a floor-length braid and is wielding a toolbox. By Jove, it's easily the most gorgeous depiction of a woman you've ever seen. The artist must truly be a master of his craft. Shame about the broken arm, though."
	icon = 'icons/obj/statuelarge.dmi'
	icon_state = "venus"

/////////////////////snow/////////////////////////////////////////

/obj/structure/statue/snow
	max_integrity = 50
	custom_materials = list(/datum/material/snow=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/snow

/obj/structure/statue/snow/snowman
	name = "snowman"
	desc = "Several lumps of snow put together to form a snowman."
	icon_state = "snowman"

/obj/structure/statue/snow/snowlegion
    name = "snowlegion"
    desc = "Looks like that weird kid with the tiger plushie has been round here again."
    icon_state = "snowlegion"

///////////////////////////////bronze///////////////////////////////////

/obj/structure/statue/bronze
	custom_materials = list(/datum/material/bronze=MINERAL_MATERIAL_AMOUNT*5)
	abstract_type = /obj/structure/statue/bronze

/obj/structure/statue/bronze/marx
	name = "\improper Karl Marx bust"
	desc = "A bust depicting a certain 19th century economist. You get the feeling a specter is haunting the station."
	icon_state = "marx"
	art_type = /datum/component/art/rev

///////////Elder Atmosian///////////////////////////////////////////

/obj/structure/statue/elder_atmosian
	name = "Elder Atmosian"
	desc = "A statue of an Elder Atmosian, capable of bending the laws of thermodynamics to their will"
	icon_state = "eng"
	//material_drop_type = /obj/item/stack/sheet/mineral/metal_hydrogen
	max_integrity = 1000
	impressiveness = 100

/obj/item/chisel
	name = "chisel"
	desc = "breaking and making art since 4000 BC"
	icon = 'icons/obj/statue.dmi'
	icon_state = "chisel"
	inhand_icon_state = "screwdriver_nuke"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=75)
	attack_verb_continuous = list("stabs")
	attack_verb_simple = list("stab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg')
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound =  'sound/items/handling/screwdriver_pickup.ogg'
	item_flags = EYE_STAB
	sharpness = SHARP_POINTY

	/// Block we're currently carving in
	var/obj/structure/carving_block/prepared_block
	/// The thing it will look like
	var/atom/movable/current_target
	/// Currently chosen preset statue type
	var/current_preset_type
	/// If tracked user moves we stop sculpting
	var/mob/living/tracked_user
	/// Currently sculpting
	var/sculpting = FALSE
/*
 Hit the block to start
 Point with the chisel at the target to choose what to sculpt or hit block to choose from preset statue types.
 Hit block again to start sculpting.
 Moving interrupts
*/
/obj/item/chisel/pre_attack(atom/A, mob/living/user, params)
	. = ..()
	if(sculpting)
		return
	if(istype(A,/obj/structure/carving_block))
		if(A == prepared_block && (current_target || current_preset_type))
			start_sculpting(user)
		else if(!prepared_block)
			set_block(A,user)
		else if(A == prepared_block)
			show_generic_statues_prompt(user)
		return TRUE
	else if(prepared_block) //We're aiming at something next to us with block prepared
		set_target(A,user)
		return TRUE

// We aim at something distant.
/obj/item/chisel/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag && !sculpting && prepared_block && ismovable(target))
		set_target(target,user)

/obj/item/chisel/proc/start_sculpting(user)
	sculpting = TRUE
	if(do_after(user,30 SECONDS, target = prepared_block))
		if(!QDELETED(prepared_block))
			create_statue()
	sculpting = FALSE

/obj/item/chisel/proc/set_block(obj/structure/carving_block/B,mob/living/user)
	prepared_block = B
	tracked_user = user
	RegisterSignal(tracked_user,COMSIG_MOVABLE_MOVED,.proc/break_sculpting)
	to_chat(user,"<span class='notice'>You prepare to work on [B].</span>")

/obj/item/chisel/dropped(mob/user, silent)
	. = ..()
	break_sculpting()

/obj/item/chisel/proc/break_sculpting()
	SIGNAL_HANDLER
	sculpting = FALSE
	prepared_block = null
	current_target = null
	current_preset_type = null
	if(tracked_user)
		UnregisterSignal(tracked_user,COMSIG_MOVABLE_MOVED)
		tracked_user = null

/obj/item/chisel/proc/set_target(atom/movable/target,mob/living/user)
	if(!is_viable_target(target))
		to_chat(user,"You won't be able to carve that.")
		return
	current_target = target
	to_chat(user,"<span class='notice'>You decide to sculpt [prepared_block] into [current_target].</span>")

/obj/item/chisel/proc/create_statue()
	if(current_preset_type)
		var/obj/structure/statue/preset_statue = new current_preset_type(get_turf(prepared_block))
		preset_statue.set_custom_materials(prepared_block.custom_materials)
		QDEL_NULL(prepared_block)
	else if(!QDELETED(current_target))
		var/obj/structure/statue/custom/new_statue = new(get_turf(prepared_block))
		new_statue.set_visuals(current_target)
		new_statue.set_custom_materials(prepared_block.custom_materials)
		new_statue.name = "statue of [current_target]"
		new_statue.desc = "statue depicting [current_target]"
		QDEL_NULL(prepared_block)
	current_target = null
	current_preset_type = null


/obj/item/chisel/proc/show_generic_statues_prompt(mob/living/user)
	var/list/choices = list()
	for(var/statue_path in prepared_block.get_possible_statues())
		var/obj/structure/statue/S = statue_path
		choices[statue_path] = image(icon=initial(S.icon),icon_state=initial(S.icon_state))
	var/choice = show_radial_menu(user, prepared_block , choices, require_near = TRUE)
	if(choice)
		current_preset_type = choice
		var/obj/structure/statue/S = choice
		to_chat(user,"<span class='notice'>You decide to sculpt [prepared_block] into [initial(S.name)].</span>")
		current_target = null

/obj/item/chisel/proc/is_viable_target(atom/movable/AM)
	//Only things on turfs
	if(!isturf(AM.loc))
		return FALSE
	//No big icon things
	var/icon/thing_icon = icon(AM.icon, AM.icon_state)
	if(thing_icon.Height() != world.icon_size || thing_icon.Width() != world.icon_size)
		return FALSE
	return TRUE

/obj/structure/carving_block
	name = "block"
	desc = "ready for sculpting."
	icon = 'icons/obj/statue.dmi'
	icon_state = "block"
	material_flags = MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS | MATERIAL_ADD_PREFIX
	density = TRUE

	//Table of required materials for each non-abstract statue type
	var/static/list/statue_costs

/// Returns a list of preset statues carvable from this block depending on the custom materials
/obj/structure/carving_block/proc/get_possible_statues()
	. = list()
	if(!statue_costs)
		statue_costs = build_statue_cost_table()
	statue_loop:
		for(var/statue_path in statue_costs)
			var/list/carving_cost = statue_costs[statue_path]
			for(var/required_material in carving_cost)
				if(!custom_materials[required_material] || custom_materials[required_material] < carving_cost[required_material])
					continue statue_loop
			. += statue_path

/obj/structure/carving_block/proc/build_statue_cost_table()
	. = list()
	for(var/statue_type in subtypesof(/obj/structure/statue) - /obj/structure/statue/custom)
		var/obj/structure/statue/S = new statue_type()
		if(!S.icon_state || S.abstract_type == S.type || !S.custom_materials)
			continue
		.[S.type] = S.custom_materials
		qdel(S)


/obj/structure/statue/custom
	name = "custom statue"
	icon_state = "base"
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	appearance_flags = TILE_BOUND | PIXEL_SCALE | KEEP_TOGETHER //Added keep together in case targets has weird layering
	material_flags = MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	/// primary statue overlay
	var/mutable_appearance/content_ma

	var/list/bump_saturation = list(1,0,0, 0,1,0, 0,0,1, 0,0.1,0)

/obj/structure/statue/custom/proc/set_visuals(atom/movable/model)
	content_ma = new
	content_ma.appearance = model.appearance
	content_ma.pixel_x = 0
	content_ma.pixel_y = 0
	content_ma.alpha = 255
	content_ma.color = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0)) //strip color
	//var/static/list/bump_saturation = list(hh,hs,hv, sh,ss,sv, vh,vs,vv, ch,cs,cv)
	content_ma.filters = filter(type="color",color=bump_saturation,space=FILTER_COLOR_HSV)
	update_icon()

/obj/structure/statue/custom/proc/refresh_visual()
	content_ma.filters = filter(type="color",color=bump_saturation,space=FILTER_COLOR_HSV)
	update_icon()

/obj/structure/statue/custom/update_overlays()
	. = ..()
	if(content_ma)
		. += content_ma
