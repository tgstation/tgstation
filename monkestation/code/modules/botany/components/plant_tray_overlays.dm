/datum/component/plant_tray_overlay
	///our self growing state
	var/self_growing_state
	///our water state base
	var/base_water_state
	///our current water state
	var/current_water_state
	///the file we check for our overlays
	var/overlay_icon

	///pest overlay
	var/pest_overlay
	///harvest state
	var/harvest_overlay
	///our nutrient light
	var/nutrient_overlay

	///health overlay
	var/health_overlay
	///health color
	var/health_color

	///the visuals we have stored from the seed
	var/list/plant_visual_list = list()
	var/base_offset_x = 0
	var/base_offset_y = 0

	var/overlay_flags = NONE

	var/list/offsets = list()

/datum/component/plant_tray_overlay/Initialize(overlay_icon, self_growing_state, base_water_state, pest_overlay, harvest_overlay, nutriment_overlay, health_overlay, plant_x, plant_y, maximum_seeds = 1, offsets = list(list(0,0)))
	. = ..()
	src.overlay_icon = overlay_icon
	src.self_growing_state = self_growing_state
	src.base_water_state = base_water_state
	src.pest_overlay = pest_overlay
	src.harvest_overlay = harvest_overlay
	src.nutrient_overlay = nutrient_overlay
	src.health_overlay = health_overlay

	base_offset_x = plant_x
	base_offset_y = plant_y

	for(var/i = 1 to maximum_seeds)
		plant_visual_list["[i]"] = null

	src.offsets = offsets
/datum/component/plant_tray_overlay/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GROWING_WATER_UPDATE, PROC_REF(get_water_state))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(apply_overlays))
	RegisterSignal(parent, COMSIG_PLANT_SENDING_IMAGE, PROC_REF(update_plant))
	RegisterSignal(parent, COMSIG_PLANT_UPDATE_HEALTH_COLOR, PROC_REF(update_health_color))
	RegisterSignal(parent, COMSIG_WEEDS_UPDATE, PROC_REF(weed_update))
	RegisterSignal(parent, COMSIG_PEST_UPDATE, PROC_REF(pest_update))
	RegisterSignal(parent, COMSIG_TOXICITY_UPDATE, PROC_REF(toxic_update))
	RegisterSignal(parent, COMSIG_NUTRIENT_UPDATE, PROC_REF(nutrient_update))
	RegisterSignal(parent, COMSIG_GROWER_SET_HARVESTABLE, PROC_REF(update_harvestable))
	RegisterSignal(parent, REMOVE_PLANT_VISUALS, PROC_REF(remove_plant_visuals))


/datum/component/plant_tray_overlay/proc/get_water_state(datum/source, precent)
	SIGNAL_HANDLER

	if(!base_water_state)
		return
	switch(precent)
		if(0 to 20)
			current_water_state = "[base_water_state]5"
		if(21 to 40)
			current_water_state = "[base_water_state]4"
		if(40 to 60)
			current_water_state = "[base_water_state]3"
		if(61 to 80)
			current_water_state = "[base_water_state]2"
		if(81 to 100)
			current_water_state = "[base_water_state]1"
	overlay_flags |= SHOW_WATER

/datum/component/plant_tray_overlay/proc/update_plant(datum/source, mutable_appearance/plant, x = 0, y = 0, id)
	var/atom/movable/movable = parent
	var/mutable_appearance/visuals = plant_visual_list[id]
	if(visuals)
		plant_visual_list[id] = null
		qdel(visuals)
	if(!plant)
		movable.update_overlays()
		return

	visuals = new(plant)

	var/list/current_offsets = offsets[text2num(id)]

	visuals.layer = ABOVE_MOB_LAYER
	SET_PLANE_EXPLICIT(visuals, GAME_PLANE_FOV_HIDDEN, movable)
	if(current_offsets[2] > 0)
		visuals.layer -= 0.01

	var/plant_offset_x = x + base_offset_x + current_offsets[1]
	var/plant_offset_y = y + base_offset_y + current_offsets[2]

	visuals.pixel_x = plant_offset_x
	visuals.pixel_y = plant_offset_y

	plant_visual_list[id] = visuals

/datum/component/plant_tray_overlay/proc/apply_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER
	if(!overlay_icon)
		return

	if(overlay_flags & SHOW_WATER)
		overlays += mutable_appearance(overlay_icon, current_water_state, offset_spokesman = parent)

	if((overlay_flags & SHOW_PEST) || (overlay_flags & SHOW_TOXIC) || (overlay_flags & SHOW_WEED))
		overlays += mutable_appearance(overlay_icon, pest_overlay, offset_spokesman = parent)

	if(overlay_flags & SHOW_NUTRIENT)
		overlays += mutable_appearance(overlay_icon, nutrient_overlay, offset_spokesman = parent)

	if(overlay_flags & SHOW_HEALTH)
		var/mutable_appearance/health = mutable_appearance(overlay_icon, health_overlay, offset_spokesman = parent)
		health.color = health_color
		overlays += health

	if(overlay_flags & SHOW_HARVEST)
		overlays += mutable_appearance(overlay_icon, harvest_overlay, offset_spokesman = parent)

	for(var/item in plant_visual_list)
		if(!isnull(plant_visual_list[item]))
			overlays += plant_visual_list[item]

/datum/component/plant_tray_overlay/proc/update_health_color(datum/source, color)
	health_color = color
	if(health_overlay)
		overlay_flags |= SHOW_HEALTH

/datum/component/plant_tray_overlay/proc/weed_update(datum/source, amount)
	if(pest_overlay && amount >= 6)
		overlay_flags |= SHOW_WEED
	else
		overlay_flags &= ~SHOW_WEED

/datum/component/plant_tray_overlay/proc/pest_update(datum/source, amount)
	if(pest_overlay && amount >= 6)
		overlay_flags |= SHOW_PEST
	else
		overlay_flags &= ~SHOW_PEST

/datum/component/plant_tray_overlay/proc/toxic_update(datum/source, amount)
	if(pest_overlay && amount >= 40)
		overlay_flags |= SHOW_TOXIC
	else
		overlay_flags &= ~SHOW_TOXIC

/datum/component/plant_tray_overlay/proc/nutrient_update(datum/source, precent)
	if(nutrient_overlay && precent < 0.35)
		overlay_flags |= SHOW_NUTRIENT
	else
		overlay_flags &= ~SHOW_NUTRIENT

/datum/component/plant_tray_overlay/proc/update_harvestable(datum/soruce, harvestable)
	if(harvest_overlay && harvestable)
		overlay_flags |= SHOW_HARVEST
	else
		overlay_flags &= ~SHOW_HARVEST

/datum/component/plant_tray_overlay/proc/remove_plant_visuals(datum/source, id)
	plant_visual_list[id] = null
	var/atom/movable/movable = parent
	movable.update_appearance()
