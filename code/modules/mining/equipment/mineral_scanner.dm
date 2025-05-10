/**********************Mining Scanners**********************/
/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations."
	name = "manual mining scanner"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "manual_mining"
	inhand_icon_state = "analyzer"
	worn_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	/// The cooldown between scans.
	var/cooldown = 35
	/// Current time until the next scan can be performed.
	var/current_cooldown = 0

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user), scanner = src)

//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/closed/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. This one has an extended range."
	name = "advanced automatic mining scanner"
	icon_state = "advmining0"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	/// The cooldown between scans.
	var/cooldown = 35
	/// Current time until the next scan can be performed.
	var/current_cooldown = 0
	/// The range of the scanner in tiles.
	var/range = 7

//get no effects from the t-ray scanner, which auto-shuts off.
/obj/item/t_scanner/adv_mining_scanner/cyborg_unequip(mob/user)
	return

/obj/item/t_scanner/adv_mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	toggle_on()

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations."
	icon_state = "mining0"
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range, src)

/proc/mineral_scan_pulse(turf/T, range = world.view, obj/item/scanner)
	var/list/minerals = list()
	var/vents_nearby = FALSE
	var/undiscovered = FALSE
	var/radar_volume = 30
	for(var/turf/closed/mineral/mineral in  RANGE_TURFS(range, T))
		if(mineral.scan_state)
			minerals += mineral
	for(var/obj/structure/ore_vent/vent in range(range, T))
		if(!vents_nearby && (!vent.discovered || !vent.tapped))
			vents_nearby = TRUE
			if(vent.discovered)
				undiscovered = TRUE
		var/potential_volume = 80 - (get_dist(scanner, vent) * 10)
		radar_volume = max(potential_volume, radar_volume)
		vent.add_mineral_overlays()

	if(LAZYLEN(minerals))
		for(var/turf/closed/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

	if(vents_nearby && scanner)
		if(undiscovered)
			playsound(scanner, 'sound/machines/radar-ping.ogg', radar_volume, FALSE)
		else
			playsound(scanner, 'sound/machines/sonar-ping.ogg', radar_volume, FALSE)
		scanner.balloon_alert_to_viewers("ore vent nearby")
		scanner.spasm_animation(1.5 SECONDS)

/obj/effect/temp_visual/mining_overlay
	plane = HIGH_GAME_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = 0 //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 35
	pixel_x = -224
	pixel_y = -224
	/// What animation easing to use when we create the ore overlay on rock walls/ore vents.
	var/easing_style = EASE_IN

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = easing_style)

/obj/effect/temp_visual/mining_overlay/vent
	icon = 'icons/effects/vent_overlays.dmi'
	icon_state = "unknown"
	duration = 45
	pixel_x = 0
	pixel_y = 0
	easing_style = CIRCULAR_EASING|EASE_IN
