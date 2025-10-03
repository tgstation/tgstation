
///////////////////////////////////////////////////////////////////////////////
/obj/machinery/hydroponics/soil //Not actually hydroponics at all! Honk!
	name = "soil"
	desc = "A patch of dirt."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "soil"
	gender = PLURAL
	circuit = null
	density = FALSE
	use_power = NO_POWER_USE
	unwrenchable = FALSE
	self_sustaining_overlay_icon_state = null
	maxnutri = 15
	tray_flags = SOIL
	armor_type = /datum/armor/obj_soil
	//which type of sack to create when shovled.
	var/sack_type = /obj/item/soil_sack

/obj/machinery/hydroponics/soil/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/hydroponics/soil/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/hydroponics/soil/update_icon(updates=ALL)
	. = ..()
	if(self_sustaining)
		add_atom_colour(rgb(255, 175, 0), FIXED_COLOUR_PRIORITY)

/obj/machinery/hydroponics/soil/update_status_light_overlays()
	return // Has no lights

/obj/machinery/hydroponics/soil/attackby_secondary(obj/item/weapon, mob/user, list/modifiers, list/attack_modifiers)
	if(weapon.tool_behaviour != TOOL_SHOVEL) //Spades can still uproot plants on left click
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	balloon_alert(user, "digging up soil...")
	if(weapon.use_tool(src, user, 3 SECONDS, volume=50))
		balloon_alert(user, "bagged")
		new sack_type(loc, src) //The bag handles sucking up the soil, stopping processing and setting relevants stats.

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/hydroponics/soil/click_ctrl(mob/user)
	return CLICK_ACTION_BLOCKING //Soil has no electricity.

/obj/machinery/hydroponics/soil/on_deconstruction(disassembled)
	new /obj/item/stack/ore/glass(drop_location(), 3)

///called when a soil is plopped down on the ground.
/obj/machinery/hydroponics/soil/proc/on_place()
	return

/datum/armor/obj_soil
	melee = 80
	bullet = 100
	laser = 90
	fire = 70
	acid = 30
	bomb = 15

/////////////// Advanced Soils //////////////

/obj/machinery/hydroponics/soil/vermaculite
	name = "vermaculite growing medium"
	desc = "A plant bed made of light, expanded mineral granules.\n\nThe plant health benefits from the high degree of soil aeration is especially useful for when propagating grafts."
	icon_state = "soil_verm"
	maxnutri = 20
	maxwater =  150
	tray_flags = SOIL | MULTIGRAFT | GRAFT_MEDIUM
	sack_type = /obj/item/soil_sack/vermaculite

/obj/machinery/hydroponics/soil/gel
	name = "hydrogel beads"
	desc = "A plant bed made of superabsorbent polymer beads.\n\nThese types of water gel beads can hold onto an incredible amount of water and reduces evaporative losses to almost nothing."
	icon_state = "soil_gel"
	maxwater = 300
	tray_flags = SOIL | HYDROPONIC | SUPERWATER
	plant_offset_y = 2
	sack_type = /obj/item/soil_sack/gel

/obj/machinery/hydroponics/soil/coir
	name = "korta root coir"
	desc = "A type of traditional growing medium from Tizira.\n\nUsed by the natives as a resourceful way to cultivate seraka mushrooms using waste korta roots.\nMushrooms of all kinds thrive due to the high organic content enabling them to mature faster."
	icon_state = "soil_coir"
	maxnutri = 20
	tray_flags = SOIL | FAST_MUSHROOMS
	sack_type = /obj/item/soil_sack/coir

/obj/machinery/hydroponics/soil/worm
	name = "worm castings"
	desc = "A type of compost created when the humble worm dutifully works the soil.\n\nIt is packed with nutrients unlocked by said creatures digestive system. Give thanks to the worm!"
	icon_state = "soil_worm"
	maxnutri = 35
	maxwater = 200
	tray_flags = SOIL | WORM_HABITAT | SLOW_RELEASE
	plant_offset_y = 4
	sack_type = /obj/item/soil_sack/worm

/obj/machinery/hydroponics/soil/worm/on_place()
	. = ..()
	flick("soil_worm_wiggle", src)

/obj/machinery/hydroponics/soil/rich
	name = "rich soil"
	desc = "A rich patch of dirt, usually used in gardens."
	icon_state = "rich_soil"
	maxnutri = 20
	sack_type = /obj/item/soil_sack/rich

/////////////////// Soil Sacks ///////////////////////
/// Holder items that store the soils until deployed.
/obj/item/soil_sack
	name = "soil sack"
	desc = "A large plastic bag containing commercial garden soil. It is packed with sand, peat and manure. While you might not care much for such mixture, the plants have strange tastes."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "soil_sack"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	base_icon_state =  "soil_sack"
	force = 7
	throwforce = 17
	attack_speed = 1.2 SECONDS
	damtype = STAMINA
	block_sound = 'sound/effects/bodyfall/bodyfall1.ogg'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND
	resistance_flags = ACID_PROOF
	hitsound = 'sound/items/pillow/pillow_hit.ogg'
	drop_sound = 'sound/effects/footstep/woodbarefoot3.ogg' //could use better sounds in the future.
	throw_drop_sound = 'sound/effects/bodyfall/bodyfall3.ogg'
	custom_premium_price = PAYCHECK_CREW
	throw_range =  3
	throw_speed = 1
	slowdown = 1
	drag_slowdown = 1
	var/obj/machinery/hydroponics/soil/stored_soil = /obj/machinery/hydroponics/soil
	var/placement_sound = 'sound/effects/soil_plop.ogg'

/obj/item/soil_sack/Initialize(mapload, obj/machinery/hydroponics/soil/outside_soil)
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier = 2, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))

	if(outside_soil)
		stored_soil = outside_soil
		stored_soil.remove_plant()
		stored_soil.forceMove(src)
		STOP_PROCESSING(SSmachines, stored_soil)
		animate(src, 100 MILLISECONDS, pixel_z = 4, easing = QUAD_EASING | EASE_OUT)
		animate(time = 100 MILLISECONDS, pixel_z = 0, easing = QUAD_EASING | EASE_IN)
		animate(time = 250 MILLISECONDS, pixel_x = rand(-6, 6), pixel_y = rand(-4, 4), flags = ANIMATION_PARALLEL)

/obj/item/soil_sack/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isopenturf(interacting_with) || isgroundlessturf(interacting_with))
		return ..()

	if(locate(/obj/machinery/hydroponics/soil) in interacting_with)
		to_chat(user, span_alert("There is already a bed of soil there!"))
		return ITEM_INTERACT_BLOCKING

	if(!do_after(user, 1 SECONDS, interacting_with))
		return ITEM_INTERACT_BLOCKING

	if(ispath(stored_soil))
		stored_soil = new stored_soil(src)
		stored_soil.reagents.add_reagent(/datum/reagent/plantnutriment/eznutriment, stored_soil.maxnutri / 2)
		stored_soil.waterlevel = stored_soil.maxwater
	else
		START_PROCESSING(SSmachines, stored_soil)


	stored_soil.forceMove(interacting_with)
	playsound(stored_soil, placement_sound, 65, vary = TRUE)
	stored_soil.on_place()
	qdel(src)
	return ITEM_INTERACT_SUCCESS

///Remove slowdown and add block chance when wielded.
/obj/item/soil_sack/proc/on_wield()
	slowdown = 0
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_equipment_speed_mods()
	block_chance = 25
	inhand_icon_state = "[base_icon_state]_w"

///Reapply slowdown and remove block chance when unwielded.
/obj/item/soil_sack/proc/on_unwield()
	slowdown = initial(slowdown)
	if(ismob(loc))
		var/mob/wearer = loc
		wearer.update_equipment_speed_mods()
	block_chance = initial(block_chance)
	inhand_icon_state = base_icon_state


/obj/item/soil_sack/vermaculite
	name = "NT vermaculite sack"
	desc = "A sack of expanded mineral granules that can be used as soilless growing medium.\n\nYou like to think of it a bag of rocky popcorn that lets the roots breathe."
	icon_state = "soil_sack_verm"
	base_icon_state = "soil_sack_verm"
	custom_premium_price = PAYCHECK_CREW * 2
	stored_soil = /obj/machinery/hydroponics/soil/vermaculite
	slowdown = 0

/obj/item/soil_sack/gel
	name = "hydrogel bead sack"
	desc = "A sack of space age superabsorbent gel beads! You wonder how shipping them prehydrated would ever make business sense..."
	icon_state = "soil_sack_gel"
	base_icon_state = "soil_sack_gel"
	custom_premium_price = PAYCHECK_CREW * 2
	placement_sound = 'sound/effects/meatslap.ogg'
	stored_soil = /obj/machinery/hydroponics/soil/gel

/obj/item/soil_sack/coir
	name = "#1™ korta coir sack"
	desc = "A sack of Tiziran korta root coir. The fiberous roots are composted until they separate into individual fibres.\n\nProvides an excellent food source for saprotrophic mushrooms and helps hold onto water in the hot Tizirian climate."
	icon_state = "soil_sack_coir"
	base_icon_state = "soil_sack_coir"
	custom_premium_price = PAYCHECK_CREW * 3
	stored_soil = /obj/machinery/hydroponics/soil/coir

/obj/item/soil_sack/worm
	name = "worm castings sack"
	desc = "A sack of vermicompost, also known as worm castings.\n\nThis invertebrate manure not only contains plant nutrients and undigested organic matter, it also harbours a rich flora of beneficial microorganisms."
	icon_state = "soil_sack_worm"
	base_icon_state = "soil_sack_worm"
	custom_premium_price = PAYCHECK_CREW * 4
	stored_soil = /obj/machinery/hydroponics/soil/worm

/obj/item/soil_sack/rich
	name = "rich soil sack"
	desc = "A sack of rich black soil.\nAs your gaze falls upon it, you feel a bit more connected to the land."
	custom_premium_price = PAYCHECK_CREW * 1.5
	stored_soil = /obj/machinery/hydroponics/soil/rich
