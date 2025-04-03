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
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/reagent_scanner/on_activation()
	ADD_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, REF(src))

/obj/item/mod/module/reagent_scanner/on_deactivation(display_message = TRUE, deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, REF(src))

/obj/item/mod/module/reagent_scanner/advanced
	name = "MOD advanced reagent scanner module"
	desc = "An advanced module with all the features of research-oriented Nanotrasen HUDs, this is capable of scanning \
		the contents of containers and projecting the information in an easy-to-read format on the wearer's display. \
		It also contains a research scanner and an explosion sensor that gives details on nearby explosions. \
		No improvements have been made to allow it to detect flavors so that's still up to you."
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/on_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_RESEARCH_SCANNER, REF(src))
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, PROC_REF(sense_explosion))

/obj/item/mod/module/reagent_scanner/advanced/on_deactivation(display_message = TRUE, deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_RESEARCH_SCANNER, REF(src))
	UnregisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/obj/item/mod/module/reagent_scanner/advanced/proc/sense_explosion(datum/source, turf/epicenter,
	devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/turf/wearer_turf = get_turf(mod.wearer)
	if(!is_valid_z_level(wearer_turf, epicenter))
		return
	if(get_dist(epicenter, wearer_turf) > explosion_detection_dist)
		return
	to_chat(mod.wearer, span_notice("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]"))

///Anti-Gravity - Makes the user weightless.
/obj/item/mod/module/anomaly_locked/antigrav
	name = "MOD anti-gravity module"
	desc = "A module that uses a gravitational core to make the user completely weightless."
	icon_state = "antigrav"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.7
	incompatible_modules = list(/obj/item/mod/module/atrocinator, /obj/item/mod/module/anomaly_locked/antigrav)
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/anomaly_locked/antigrav/on_activation()
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	mod.wearer.AddElement(/datum/element/forced_gravity, 0)
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/on_deactivation(display_message = TRUE, deleting = FALSE)
	mod.wearer.RemoveElement(/datum/element/forced_gravity, 0)
	if(deleting)
		return
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/antigrav/prebuilt/locked
	core_removable = FALSE

///Teleporter - Lets the user teleport to a nearby location.
/obj/item/mod/module/anomaly_locked/teleporter
	name = "MOD teleporter module"
	desc = "A module that uses a bluespace core to let the user transport their particles elsewhere."
	icon_state = "teleporter"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 25
	cooldown_time = 4 SECONDS
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked/teleporter)
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/bluespace)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Time it takes to teleport
	var/teleport_time = 1 SECONDS
	/// Maximum turf range
	var/max_range = 9

/obj/item/mod/module/anomaly_locked/teleporter/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/turf/open/target_turf = get_turf(target)
	if(get_dist(target_turf, mod.wearer) > max_range)
		balloon_alert(mod.wearer, "too far!")
		return
	if(!istype(target_turf))
		balloon_alert(mod.wearer, "invalid target!")
		return
	if(target_turf.is_blocked_turf_ignore_climbable() || !los_check(mod.wearer, target, pass_args = PASSTABLE|PASSGLASS|PASSGRILLE|PASSMOB|PASSMACHINE|PASSSTRUCTURE|PASSFLAPS|PASSWINDOW))
		balloon_alert(mod.wearer, "blocked destination!")
		return
	// check early so we don't go through the whole loops
	if(!check_teleport_valid(mod.wearer, target_turf, channel = TELEPORT_CHANNEL_BLUESPACE, original_destination = target_turf))
		balloon_alert(mod.wearer, "something holds you back!")
		return
	balloon_alert(mod.wearer, "teleporting...")
	var/matrix/pre_matrix = matrix()
	pre_matrix.Scale(4, 0.25)
	var/matrix/post_matrix = matrix()
	post_matrix.Scale(0.25, 4)
	animate(mod.wearer, teleport_time, color = COLOR_CYAN, transform = pre_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_OUT)
	if(!do_after(mod.wearer, teleport_time, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		animate(mod.wearer, teleport_time*0.1, color = null, transform = post_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_IN)
		return
	animate(mod.wearer, teleport_time*0.1, color = null, transform = post_matrix.Multiply(mod.wearer.transform), easing = SINE_EASING|EASE_IN)
	if(!do_teleport(mod.wearer, target_turf, asoundin = 'sound/effects/phasein.ogg'))
		return
	drain_power(use_energy_cost)

/obj/item/mod/module/anomaly_locked/teleporter/prebuilt
	prebuilt = TRUE

/obj/item/mod/module/anomaly_locked/teleporter/prebuilt/locked
	core_removable = FALSE
