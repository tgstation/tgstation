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

/obj/item/mod/module/megaphone/on_deactivation()
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
		criminal_capture_bags += new /obj/structure/closet/body_bag/environmental/prisoner(src)

/obj/item/mod/module/criminalcapture/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(isliving(target))
		var/turf/target_turf = get_turf(target)
		if(!do_after(mod.wearer, capture_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(!mod.wearer.Adjacent(target))
			return
		var/obj/structure/closet/body_bag/environmental/prisoner/dropped_bag = pop(criminal_capture_bags)
		dropped_bag.forceMove(target_turf)
		target.forceMove(dropped_bag)
	else if(istype(target, /obj/structure/closet/body_bag/environmental/prisoner) || istype(target, /obj/item/bodybag/environmental/prisoner))
		var/obj/item/bodybag/environmental/prisoner/bag = target
		if(criminal_capture_bags.len >= max_capacity)
			balloon_alert(mod.wearer, "bag limit reached!")
			return
		if(!do_after(mod.wearer, packup_time, target = bag))
			balloon_alert(mod.wearer, "interrupted!")
			return
		if(criminal_capture_bags.len >= max_capacity)
			balloon_alert(mod.wearer, "bag limit reached!")
			return
		if(locate(/mob/living) in bag)
			balloon_alert(mod.wearer, "living creatures inside!")
			return
		if(!mod.wearer.Adjacent(target))
			return
		if(istype(bag, /obj/item/bodybag/environmental/prisoner))
			bag = bag.deploy_bodybag(mod.wearer, get_turf(bag))
		var/obj/structure/closet/body_bag/environmental/prisoner/structure_bag = bag
		if(!structure_bag.opened)
			structure_bag.open(mod.wearer, force = TRUE)
		bag.forceMove(src)
		criminal_capture_bags += bag
