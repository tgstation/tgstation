//Science modules for MODsuits

///Reagent Scanner - Lets the user scan reagents.
/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "A module based off research-oriented Nanotrasen HUDs, this is capable of scanning the contents of \
		containers and projecting the information in an easy-to-read format on the wearer's display. \
		It cannot detect flavors, so that's up to you."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/reagent_scanner/on_activation()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/on_deactivation()
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/advanced
	name = "MOD advanced reagent scanner module"
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/on_activation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner++
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/sense_explosion)

/obj/item/mod/module/reagent_scanner/advanced/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner--
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/obj/item/mod/module/reagent_scanner/advanced/proc/sense_explosion(datum/source, turf/epicenter,
	devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/turf/wearer_turf = get_turf(mod.wearer)
	if(wearer_turf.z != epicenter.z)
		return
	if(get_dist(epicenter, wearer_turf) > explosion_detection_dist)
		return
	to_chat(mod.wearer, span_notice("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]"))

///Anomaly Locked - Causes the module to not function without an anomaly.
/obj/item/mod/module/anomaly_locked
	name = "MOD anomaly locked module"
	desc = "A form of a module, locked behind an anomalous core to function."
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked)
	/// The core item the module runs off.
	var/obj/item/assembly/signaler/anomaly/core
	/// Accepted types of anomaly cores.
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/anomaly)
	/// If this one starts with a core in.
	var/prebuilt = FALSE

/obj/item/mod/module/anomaly_locked/Initialize(mapload)
	. = ..()
	if(!prebuilt || !length(accepted_anomalies))
		return
	var/core_path = pick(accepted_anomalies)
	core = new core_path(src)
	update_icon_state()

/obj/item/mod/module/anomaly_locked/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/mod/module/anomaly_locked/examine(mob/user)
	. = ..()
	if(!length(accepted_anomalies))
		return
	if(core)
		. += span_notice("There is a [core.name] installed in it. You could remove it with a <b>screwdriver</b>...")
	else
		var/list/core_list = list()
		for(var/path in accepted_anomalies)
			var/atom/core_path = path
			core_list += initial(core_path.name)
		. += span_notice("You need to insert \a [english_list(core_list, and_text = " or ")] for this module to function.")

/obj/item/mod/module/anomaly_locked/on_select()
	if(!core)
		balloon_alert(mod.wearer, "no core!")
		return
	return ..()

/obj/item/mod/module/anomaly_locked/on_process(delta_time)
	. = ..()
	if(!core)
		return FALSE

/obj/item/mod/module/anomaly_locked/on_active_process(delta_time)
	if(!core)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/attackby(obj/item/item, mob/living/user, params)
	if(item.type in accepted_anomalies)
		if(core)
			balloon_alert(user, "core already in!")
			return
		if(!user.transferItemToLoc(item, src))
			return
		core = item
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		update_icon_state()
	else
		return ..()

/obj/item/mod/module/anomaly_locked/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon_state()

/obj/item/mod/module/anomaly_locked/update_icon_state()
	icon_state = initial(icon_state) + (core ? "-core" : "")
	return ..()

///Anti-Gravity - Makes the user weightless.
/obj/item/mod/module/anomaly_locked/antigrav
	name = "MOD anti-gravity module"
	desc = "A module that uses a gravitational core to make the user completely weightless."
	icon_state = "antigrav"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CELL_DRAIN * 0.7
	cooldown_time = 0.5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)

/obj/item/mod/module/anomaly_locked/antigrav/on_activation()
	. = ..()
	if(!.)
		return
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	mod.wearer.AddElement(/datum/element/forced_gravity, 0)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.RemoveElement(/datum/element/forced_gravity, 0)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/prebuilt
	prebuilt = TRUE

///Teleporter - Lets the user teleport to a nearby location.
/obj/item/mod/module/anomaly_locked/teleporter
	name = "MOD teleporter module"
	desc = "A module that uses a bluespace core to let the user transport their particles elsewhere."
	icon_state = "teleporter"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	cooldown_time = 5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/bluespace)
	/// Time it takes to teleport
	var/teleport_time = 3 SECONDS

/obj/item/mod/module/anomaly_locked/teleporter/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/turf/open/target_turf = get_turf(target)
	if(!istype(target_turf) || target_turf.is_blocked_turf_ignore_climbable() || !(target_turf in view(mod.wearer)))
		balloon_alert(mod.wearer, "invalid target!")
		return
	balloon_alert(mod.wearer, "teleporting...")
	var/matrix/user_matrix = matrix(mod.wearer.transform)
	animate(mod.wearer, teleport_time, color = COLOR_CYAN, transform = user_matrix.Scale(4, 0.25), easing = EASE_OUT)
	if(!do_after(mod.wearer, teleport_time, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		animate(mod.wearer, teleport_time, color = null, transform = user_matrix.Scale(0.25, 4), easing = EASE_IN)
		return
	animate(mod.wearer, teleport_time*0.1, color = null, transform = user_matrix.Scale(0.25, 4), easing = EASE_IN)
	if(!do_teleport(mod.wearer, target_turf, asoundin = 'sound/effects/phasein.ogg'))
		return
	drain_power(use_power_cost)

/obj/item/mod/module/anomaly_locked/teleporter/prebuilt
	prebuilt = TRUE
