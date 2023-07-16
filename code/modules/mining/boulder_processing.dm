/obj/machinery/bouldertech
	name = "bouldertech brand refining machine"
	desc = "You shouldn't be seeing this! And bouldertech isn't even a real company!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE
	idle_power_usage = 100 /// fuck if I know set this later

	/// What is the efficiency of minerals produced by the machine?
	var/refining_efficiency = 1
	/// How many boulders are we processing right now within our contents?
	var/boulders_processing = 0
	/// How many boulders can we process maximum?
	var/boulders_processing_max = 1
	

	/// Mats we look for?
	var/list/processed_materials = list(/datum/material/iron, /datum/material/glass)
	/// Silo link to it's materials list.
	var/datum/component/remote_materials/silo_materials

/obj/machinery/bouldertech/proc/breakdown_boulder(obj/item/boulder/chosen_boulder)
	//here we loop through the boulder's ores
	if(!silo_materials)
		return FALSE
	for(var/datum/material/possible_mat as anything in chosen_boulder.custom_materials)
		if(is_type_in_list(possible_mat, processed_materials))
			///Alright, screw it, just copy the ORM's smelt_ore proc wholesale.



/obj/machinery/bouldertech/brm
	name = "boulder retrieval matrix"
	desc = "A teleportation matrix used to retrieve boulders excavated by mining NODEs from ore vents."


/**
 * So, this should be probably handed in a more elegant way going forward, like a small TGUI prompt to select which boulder you want to pull from.
 * However, in the attempt to make this really, REALLY basic but functional until I can actually sit down and get this done we're going to just grab a random entry from the global list and work with it.
 */
/obj/machinery/bouldertech/brm/proc/collect_boulder()
	var/obj/item/random_boulder = pick(SSore_generation.available_boulders)
	if(!random_boulder)
		return FALSE
	random_boulder.Shake(duration = 1.5 SECONDS)
	//todo: Maybe add some kind of teleporation raster effect thing? filters? I can probably make something happen here...
	sleep(1.5 SECONDS)

	//todo:do the thing we do where we make sure the thing still exists and hasn't been deleted between the start of the recall and after.
	random_boulder.forceMove(drop_location())

	random_boulder.visible_message(span_warning("[random_boulder] suddenly appears!"))
	playsound(src, SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/bouldertech/brm/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	collect_boulder()

/obj/machinery/bouldertech/smelter
	name = "boulder smeltery"
	desc = "B-S for short. Accept boulders and refines metallic ores into sheets. Can be upgraded with stock parts or through gas inputs."

/obj/machinery/bouldertech/smelter/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(obj/item/boulder))
		var/obj/item/boulder/my_boulder = attacking_item
		my_boulder.forceMove(contents)
		visible_message(span_warning("[my_boulder] is smelted into metals?!"))
		breakdown_boulder(my_boulder)


/obj/machinery/bouldertech/refinery
	name = "boulder refinery"
	desc = "B-R for short. Accepts boulders and refines non-metallic ores into sheets. Can be upgraded with stock parts or through chemical inputs."

/obj/machinery/bouldertech/refinery/Initialize(mapload)
	. = ..()
	///We need a component like reaction chamber, but really it should be a simple demand, and then a more selective supply.
	///It only accepts water, lube, and maybe some third chem, and should output WHEN USED, industrial waste chem to the output. Do not use any chemicals if waste output is full.

/obj/machinery/bouldertech/refinery/RefreshParts()
	. = ..()
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		C += ((capacitor.tier - 1) * 0.1)
	power_saver = 1 - C
	for(var/datum/stock_part/servo/servo in component_parts)
		M += ((servo.tier - 1) * PART_CASH_OFFSET_AMOUNT)
	positive_cash_offset = M
	for(var/datum/stock_part/micro_laser/Laser in component_parts)
		L += ((Laser.tier - 1) * PART_CASH_OFFSET_AMOUNT)
	negative_cash_offset = L
	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		S += ((scanning_module.tier - 1) * 0.25)
	inaccuracy_percentage = (1.5 - S)

