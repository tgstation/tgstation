//Security modules for MODsuits

///Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	. = ..()
	if(!.)
		return
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_held_item()
		if(!holding)
			balloon_alert(mod.wearer, "nothing to holster!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY)
			balloon_alert(mod.wearer, "it doesn't fit!")
			return
		if(mod.wearer.transferItemToLoc(holding, src, force = FALSE, silent = TRUE))
			holstered = holding
			balloon_alert(mod.wearer, "weapon holstered")
			playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
			drain_power(use_power_cost)
	else if(mod.wearer.put_in_active_hand(holstered, forced = FALSE, ignore_animation = TRUE))
		balloon_alert(mod.wearer, "weapon drawn")
		holstered = null
		playsound(src, 'sound/weapons/gun/revolver/empty.ogg', 100, TRUE)
		drain_power(use_power_cost)
	else
		balloon_alert(mod.wearer, "holster full!")

/obj/item/mod/module/holster/on_uninstall()
	if(holstered)
		holstered.forceMove(drop_location())
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

///Megaphone - Lets you speak loud.
/obj/item/mod/module/megaphone
	name = "MOD megaphone module"
	desc = "A microchip megaphone linked to a MODsuit, for very important purposes, like: loudness."
	module_type = MODULE_TOGGLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/megaphone)
	cooldown_time = 0.5 SECONDS
	/// List of spans we add to the speaker.
	var/list/voicespan = list(SPAN_COMMAND)

/obj/item/mod/module/megaphone/on_activation()
	. = ..()
	if(!.)
		return
	RegisterSignal(mod.wearer, COMSIG_MOB_SAY, .proc/handle_speech)

/obj/item/mod/module/megaphone/on_deactivation(display_message = TRUE)
	. = ..()
	if(!.)
		return
	UnregisterSignal(mod.wearer, COMSIG_MOB_SAY)

/obj/item/mod/module/megaphone/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= voicespan
	drain_power(use_power_cost)

///Criminal Capture - Lets you put people in transport bags.
/obj/item/mod/module/criminalcapture
	name = "MOD criminal capture module"
	desc = "The private security that had orders to take in people dead were quite \
		happy with their space-proofed suit, but for those who wanted to bring back \
		whomever their targets were still breathing needed a way to \"share\" the \
		space-proofing. And thus: criminal capture! Creates a prisoner transport bag \
		around the apprehended that has breathable atmos and even stabilizes critical \
		conditions."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/criminalcapture)
	cooldown_time = 0.5 SECONDS
	/// Max bag capacity.
	var/max_capacity = 3
	/// Time to capture a prisoner.
	var/capture_time = 1 SECONDS
	/// Time to pack a bodybag up.
	var/packup_time = 0.5 SECONDS
	/// List of our capture bags.
	var/list/criminal_capture_bags = list()

/obj/item/mod/module/criminalcapture/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_capacity)
		criminal_capture_bags += new /obj/structure/closet/body_bag/environmental/prisoner/pressurized(src)

/obj/item/mod/module/criminalcapture/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(isliving(target))
		var/mob/living/living_target = target
		var/turf/target_turf = get_turf(living_target)
		playsound(src, 'sound/items/zip.ogg', 25, TRUE)
		if(!do_after(mod.wearer, capture_time, target = living_target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		var/obj/structure/closet/body_bag/environmental/prisoner/dropped_bag = pop(criminal_capture_bags)
		dropped_bag.forceMove(target_turf)
		dropped_bag.close()
		living_target.forceMove(dropped_bag)
	else if(istype(target, /obj/structure/closet/body_bag/environmental/prisoner) || istype(target, /obj/item/bodybag/environmental/prisoner))
		var/obj/item/bodybag/environmental/prisoner/bag = target
		if(criminal_capture_bags.len >= max_capacity)
			balloon_alert(mod.wearer, "bag limit reached!")
			return
		playsound(src, 'sound/items/zip.ogg', 25, TRUE)
		if(!do_after(mod.wearer, packup_time, target = bag))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(criminal_capture_bags.len >= max_capacity)
			balloon_alert(mod.wearer, "bag limit reached!")
			return
		if(locate(/mob/living) in bag)
			balloon_alert(mod.wearer, "living creatures inside!")
			return
		if(istype(bag, /obj/item/bodybag/environmental/prisoner))
			bag = bag.deploy_bodybag(mod.wearer, get_turf(bag))
		var/obj/structure/closet/body_bag/environmental/prisoner/structure_bag = bag
		if(!structure_bag.opened)
			structure_bag.open(mod.wearer, force = TRUE)
		bag.forceMove(src)
		criminal_capture_bags += bag
		balloon_alert(mod.wearer, "bag stored")
	else
		balloon_alert(mod.wearer, "invalid target!")

///Mirage grenade dispenser - Dispenses grenades that copy the user's appearance.
/obj/item/mod/module/dispenser/mirage
	name = "MOD mirage grenade dispenser module"
	desc = "This module can create mirage grenades at the user's liking. These grenades create holographic copies of the user."
	cooldown_time = 20 SECONDS
	dispense_type = /obj/item/grenade/mirage

/obj/item/mod/module/dispenser/mirage/on_use()
	. = ..()
	if(!.)
		return
	var/obj/item/grenade/mirage/grenade = .
	grenade.arm_grenade(mod.wearer)

/obj/item/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a holographic copy of the user."
	icon_state = "delivery"
	inhand_icon_state = "flashbang"
	det_time = 3 SECONDS
	var/mob/living/thrower

/obj/item/grenade/mirage/arm_grenade(mob/user, delayoverride, msg, volume)
	. = ..()
	thrower = user

/obj/item/grenade/mirage/detonate(mob/living/lanced_by)
	. = ..()
	do_sparks(rand(3, 6), FALSE, src)
	if(thrower)
		var/mob/living/simple_animal/hostile/illusion/mirage/mirage = new(get_turf(src))
		mirage.Copy_Parent(thrower, 15 SECONDS)
	qdel(src)

///Projectile Dampener - Weakens projectiles in range.
/obj/item/mod/module/projectile_dampener
	name = "MOD projectile dampener module"
	desc = "Using technology from peaceborgs, this module weakens all projectiles in nearby range."
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/projectile_dampener)
	cooldown_time = 1.5 SECONDS
	/// Radius of the dampening field.
	var/field_radius = 2
	/// Damage multiplier on projectiles.
	var/damage_multiplier = 0.75
	/// Speed multiplier on projectiles, higher means slower.
	var/speed_multiplier = 2.5
	/// List of all tracked projectiles.
	var/list/tracked_projectiles = list()
	/// Effect image on projectiles.
	var/image/projectile_effect
	/// The dampening field
	var/datum/proximity_monitor/advanced/projectile_dampener/dampening_field

/obj/item/mod/module/projectile_dampener/Initialize(mapload)
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")

/obj/item/mod/module/projectile_dampener/on_activation()
	. = ..()
	if(!.)
		return
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	dampening_field = new(mod.wearer, field_radius, TRUE, src)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE, .proc/dampen_projectile)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE, .proc/release_projectile)

/obj/item/mod/module/projectile_dampener/on_deactivation(display_message)
	. = ..()
	if(!.)
		return
	QDEL_NULL(dampening_field)

/obj/item/mod/module/projectile_dampener/proc/dampen_projectile(datum/source, obj/projectile/projectile)
	projectile.damage *= damage_multiplier
	projectile.speed *= speed_multiplier
	projectile.add_overlay(projectile_effect)

/obj/item/mod/module/projectile_dampener/proc/release_projectile(datum/source, obj/projectile/projectile)
	projectile.damage /= damage_multiplier
	projectile.speed /= speed_multiplier
	projectile.cut_overlay(projectile_effect)

///Espionage -
/obj/item/mod/module/espionage
	name = "MOD espionage module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "espionage"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	. = ..()
	if(!.)
		return

/obj/item/mod/module/holster/on_uninstall()
	if(holstered)
		holstered.forceMove(drop_location())
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()
