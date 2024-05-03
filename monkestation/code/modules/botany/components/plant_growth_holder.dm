/datum/component/growth_information
	///how much we have grown % wise
	var/growth_precent = 0
	///our age
	var/age = 0
	///how many growth cycles we have gone through
	var/growth_cycle = 0
	///can we be harvested multiple times?
	var/repeated_harvest = FALSE
	///has a bee visited us recently
	var/pollinated = FALSE
	///our current health value
	var/health_value
	///our modifier to yield
	var/yield_modifier = 1
	///the mutable appearance we have created
	var/mutable_appearance/current_looks
	///our current planter host
	var/atom/movable/planter
	///our current plant state
	var/plant_state
	///how much lifespan is lost to repeated harvest
	var/repeated_harvest_value = 0
	var/planter_id

/datum/component/growth_information/Initialize(planter, id)
	. = ..()
	src.planter = planter
	planter_id = id

	RegisterSignal(parent, COMSIG_PLANT_CHANGE_PLANTER, PROC_REF(change_planter))
	RegisterSignal(parent, COMSIG_PLANT_GROWTH_PROCESS, PROC_REF(process_growth))
	RegisterSignal(parent, COMSIG_PLANT_BUILD_IMAGE, PROC_REF(update_plant_visuals))
	RegisterSignal(parent, COMSIG_ADJUST_PLANT_HEALTH, PROC_REF(adjust_health))
	RegisterSignal(parent, COMSIG_PLANT_TRY_HARVEST, PROC_REF(try_harvest))
	RegisterSignal(parent, COMSIG_PLANT_TRY_SECATEUR, PROC_REF(try_secateur))
	RegisterSignal(parent, COMSIG_PLANT_TRY_POLLINATE, PROC_REF(try_pollinate))

	var/obj/item/seeds/seed = parent
	if(seed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		repeated_harvest = TRUE

	health_value = seed.endurance * 3

/datum/component/growth_information/proc/update_plant_visuals(datum/source)
	var/obj/item/seeds/seed = parent
	update_growth_information()
	var/t_growthstate = clamp(round(((growth_cycle / (seed.harvest_age * (1.01 ** -seed.maturation))) * 10) * seed.growthstages, 1),1, seed.growthstages)

	if(!current_looks)
		current_looks = mutable_appearance(seed.growing_icon, "[seed.icon_grow][t_growthstate]", offset_spokesman = planter)

	current_looks.icon_state =  "[seed.icon_grow][t_growthstate]"

	if(pollinated)
		planter.particles = new /particles/pollen
	else
		planter.particles = null

	if((plant_state == HYDROTRAY_PLANT_HARVESTABLE) && seed.icon_harvest)
		current_looks.icon_state = seed.icon_harvest

	if(plant_state == HYDROTRAY_PLANT_DEAD)
		current_looks.icon_state = seed.icon_dead
	SEND_SIGNAL(planter, COMSIG_PLANT_SENDING_IMAGE, current_looks, 0, seed.plant_icon_offset, planter_id)

/datum/component/growth_information/proc/process_growth(datum/source, datum/reagents/planter_reagents, bio_boosted)
	var/obj/item/seeds/seed = parent
	growth_cycle++
	var/growth_mult = (1.01 ** -seed.maturation)

	//Checks if a self sustaining tray is fully grown and fully "functional" (corpse flowers require a specific age to produce miasma)
	if(!(age > max(seed.maturation, seed.production) && (growth_cycle >= seed.harvest_age * growth_mult)))
		age++

	if(age > (seed.lifespan + repeated_harvest_value) && !bio_boosted)
		adjust_health(src, -rand(1, 5))

	for(var/datum/reagent/reagent as anything in planter_reagents.reagent_list)
		reagent.on_plant_apply(parent)

	update_plant_visuals()

/datum/component/growth_information/proc/update_growth_information()
	var/obj/item/seeds/seed = parent
	var/growth_mult = (1.01 ** -seed.maturation)
	var/growth_cycles_needed = round(seed.harvest_age * growth_mult)
	if(growth_cycles_needed == 0)
		growth_precent = 100
	else
		growth_precent = round((growth_cycle / growth_cycles_needed) * 100)

	plant_state = HYDROTRAY_PLANT_GROWING

	if(growth_precent >= 100)
		plant_state = HYDROTRAY_PLANT_HARVESTABLE
		SEND_SIGNAL(planter, COMSIG_GROWER_SET_HARVESTABLE, TRUE)

	if(health_value <= 0)
		plant_state = HYDROTRAY_PLANT_DEAD
		SEND_SIGNAL(planter, COMSIG_GROWER_SET_HARVESTABLE, FALSE)

/datum/component/growth_information/proc/change_planter(datum/source, atom/movable/new_planter, id)
	planter = new_planter
	planter_id = id

/datum/component/growth_information/proc/adjust_health(datum/source, amount)
	if(plant_state == HYDROTRAY_PLANT_DEAD)
		update_and_send_health_color()
		return
	var/obj/item/seeds/seed = parent
	health_value = clamp(health_value + amount, 0, seed.endurance * 3)

	update_and_send_health_color()

/datum/component/growth_information/proc/update_and_send_health_color()
	var/obj/item/seeds/seed = parent
	var/health_color
	if(health_value < (seed.endurance * 0.9))
		health_color = "#FF3300"
	else if(health_value < (seed.endurance * 1.5))
		health_color = "#FFFF00"
	else if(health_value < (seed.endurance * 2.1))
		health_color = "#99FF66"
	else
		health_color = "#66FFFA"

	SEND_SIGNAL(planter, COMSIG_PLANT_UPDATE_HEALTH_COLOR, health_color)

/datum/component/growth_information/proc/try_harvest(datum/source, mob/user)
	if(plant_state == HYDROTRAY_PLANT_DEAD)
		var/obj/item/seeds/seed = parent
		var/atom/movable/to_send = planter
		qdel(current_looks)
		SEND_SIGNAL(planter, COMSIG_PLANT_SENDING_IMAGE, current_looks, 0, seed.plant_icon_offset, planter_id)
		SEND_SIGNAL(planter, COMSIG_GROWER_SET_HARVESTABLE, FALSE)
		planter = null
		SEND_SIGNAL(to_send, COMSIG_REMOVE_PLANT, planter_id)
		planter_id = null
		return

	if(plant_state != HYDROTRAY_PLANT_HARVESTABLE)
		return

	var/obj/item/seeds/seed = parent

	if(seed.get_gene(/datum/plant_gene/trait/repeated_harvest))
		repeated_harvest = TRUE

	seed.harvest(user)
	if(repeated_harvest)
		growth_cycle = 0
		repeated_harvest_value += (seed.lifespan * 0.1) //20% of lifespan is added to the value so that it won't start dying right away
		update_plant_visuals()
		SEND_SIGNAL(planter, COMSIG_GROWER_SET_HARVESTABLE, FALSE)
		return
	var/atom/movable/to_send = planter
	qdel(current_looks)
	SEND_SIGNAL(planter, COMSIG_PLANT_SENDING_IMAGE, current_looks, 0, seed.plant_icon_offset, planter_id)
	SEND_SIGNAL(planter, COMSIG_GROWER_SET_HARVESTABLE, FALSE)
	planter = null
	SEND_SIGNAL(to_send, COMSIG_REMOVE_PLANT, planter_id)
	planter_id = null

/datum/component/growth_information/proc/try_secateur(datum/source, mob/user)
	if(plant_state != HYDROTRAY_PLANT_HARVESTABLE)
		return
	var/obj/item/seeds/seed = parent
	if(seed.grafted)
		return

	user.visible_message(span_notice("[user] grafts off a limb from [seed.plantname]."), span_notice("You carefully graft off a portion of [seed.plantname]."))
	var/obj/item/graft/snip = seed.create_graft()

	if(!snip)
		return // The plant did not return a graft.

	snip.forceMove(planter.drop_location())
	seed.grafted = TRUE
	adjust_health(src, -5)

/datum/component/growth_information/proc/try_pollinate(datum/source, atom/movable/planter, time)
	pollinated = TRUE
	addtimer(VARSET_CALLBACK(src, pollinated, FALSE), time)
