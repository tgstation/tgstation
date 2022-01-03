//Medical modules for MODsuits

#define HEALTH_SCAN "Health"
#define WOUND_SCAN "Wound"
#define CHEM_SCAN "Chemical"

///Health Analyzer - Gives the user a ranged health analyzer and their health status in the panel.
/obj/item/mod/module/health_analyzer
	name = "MOD health analyzer module"
	desc = "A module installed into the glove of the suit. This is a high-tech biological scanning suite, \
		allowing the user indepth information on the vitals and injuries of others even at a distance, \
		all with the flick of the wrist. Data is displayed in a convenient package on HUD in the helmet, \
		but it's up to you to do something with it."
	icon_state = "health"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/health_analyzer)
	cooldown_time = 0.5 SECONDS
	tgui_id = "health_analyzer"
	var/mode = HEALTH_SCAN
	var/static/list/modes = list(HEALTH_SCAN, WOUND_SCAN, CHEM_SCAN)
	var/perceived_threat_level

/obj/item/mod/module/health_analyzer/add_ui_data()
	. = ..()
	.["userhealth"] = mod.wearer ? mod.wearer.health : 0
	.["userbrute"] = mod.wearer ? mod.wearer.getBruteLoss() : 0
	.["userburn"] = mod.wearer ? mod.wearer.getFireLoss() : 0
	.["usertoxin"] = mod.wearer ? mod.wearer.getToxLoss() : 0
	.["useroxy"] = mod.wearer ? mod.wearer.getOxyLoss() : 0

/obj/item/mod/module/health_analyzer/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	switch(mode)
		if(HEALTH_SCAN)
			healthscan(mod.wearer, target)
		if(WOUND_SCAN)
			woundscan(mod.wearer, target)
		if(CHEM_SCAN)
			chemscan(mod.wearer, target)
	drain_power(use_power_cost)

/obj/item/mod/module/health_analyzer/get_configuration()
	. = ..()
	.["mode"] = add_ui_configuration("Scan Mode", "list", mode, modes)

/obj/item/mod/module/health_analyzer/configure_edit(key, value)
	switch(key)
		if("mode")
			mode = value

#undef HEALTH_SCAN
#undef WOUND_SCAN
#undef CHEM_SCAN

///Quick Carry - Lets the user carry bodies quicker.
/obj/item/mod/module/quick_carry
	name = "MOD quick carry module"
	desc = "A suite of advanced servos, redirecting power from the suit's arms to help carry the wounded; \
		or simply for fun. However, Nanotrasen has locked the module's ability to assist in hand-to-hand combat."
	icon_state = "carry"
	complexity = 1
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/quick_carry, /obj/item/mod/module/constructor)

/obj/item/mod/module/quick_carry/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_CARRY, MOD_TRAIT)

/obj/item/mod/module/quick_carry/advanced
	name = "MOD advanced quick carry module"
	removable = FALSE
	complexity = 0

/obj/item/mod/module/quick_carry/on_suit_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

/obj/item/mod/module/quick_carry/on_suit_deactivation()
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICKER_CARRY, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_FASTMED, MOD_TRAIT)

///Injector - Gives the suit an extendable large-capacity piercing syringe.
/obj/item/mod/module/injector
	name = "MOD injector module"
	desc = "A module installed into the wrist of the suit, this functions as a high-capacity syringe, \
		with a tip fine enough to locate the emergency injection ports on any suit of armor, \
		penetrating it with ease. Even yours."
	icon_state = "injector"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.3
	device = /obj/item/reagent_containers/syringe/mod
	incompatible_modules = list(/obj/item/mod/module/injector)
	cooldown_time = 0.5 SECONDS

/obj/item/reagent_containers/syringe/mod
	name = "MOD injector syringe"
	desc = "A high-capacity syringe, with a tip fine enough to locate \
		the emergency injection ports on any suit of armor, penetrating it with ease. Even yours."
	icon_state = "mod_0"
	base_icon_state = "mod"
	amount_per_transfer_from_this = 30
	possible_transfer_amounts = list(5, 10, 15, 20, 30)
	volume = 30
	inject_flags = INJECT_CHECK_PENETRATE_THICK

///Organ Thrower - Lets you shoot organs, immediately replacing them if the target has the organ manipulation surgery.
/obj/item/mod/module/organ_thrower
	name = "MOD organ thrower module"
	desc = "A device recovered from a crashed Interdyne Pharmaceuticals vessel, \
		this module has been unearthed for better or for worse. \
		It's an arm-mounted device utilizing technology similar to modern-day part replacers, \
		capable of storing and inserting organs into open patients. \
		It's recommended by the DeForest Medical Corporation to not inform patients it has been used."
	icon_state = "organ_thrower"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/organ_thrower, /obj/item/mod/module/microwave_beam)
	cooldown_time = 0.5 SECONDS
	var/max_organs = 5
	var/organ_list = list()

/obj/item/mod/module/organ_thrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(istype(target, /obj/item/organ))
		if(!wearer_human.Adjacent(target))
			return
		var/atom/movable/organ = target
		if(length(organ_list) >= max_organs)
			balloon_alert(mod.wearer, "too many organs!")
			return
		organ_list += organ
		organ.forceMove(src)
		balloon_alert(mod.wearer, "picked up [organ]")
		playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
		drain_power(use_power_cost)
		return
	if(!length(organ_list))
		return
	var/atom/movable/fired_organ = pop(organ_list)
	var/obj/projectile/organ/projectile = new /obj/projectile/organ(mod.wearer.loc, fired_organ)
	projectile.preparePixelProjectile(target, mod.wearer)
	projectile.firer = mod.wearer
	playsound(src, 'sound/mecha/hydraulic.ogg', 25, TRUE)
	INVOKE_ASYNC(projectile, /obj/projectile.proc/fire)
	drain_power(use_power_cost)

/obj/projectile/organ
	name = "organ"
	damage = 0
	nodamage = TRUE
	hitsound = 'sound/effects/attackblob.ogg'
	hitsound_wall = 'sound/effects/attackblob.ogg'
	var/obj/item/organ/organ

/obj/projectile/organ/Initialize(mapload, obj/item/stored_organ)
	. = ..()
	if(!stored_organ)
		return INITIALIZE_HINT_QDEL
	appearance = stored_organ.appearance
	stored_organ.forceMove(src)
	organ = stored_organ

/obj/projectile/organ/Destroy()
	organ = null
	return ..()

/obj/projectile/organ/on_hit(atom/target)
	. = ..()
	if(!ishuman(target))
		organ.forceMove(drop_location())
		organ = null
		return
	var/mob/living/carbon/human/organ_receiver = target
	var/succeed = FALSE
	if(organ_receiver.surgeries.len)
		for(var/datum/surgery/procedure as anything in organ_receiver.surgeries)
			if(procedure.location != organ.zone)
				continue
			if(!istype(procedure, /datum/surgery/organ_manipulation))
				continue
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			if(!istype(surgery_step, /datum/surgery_step/manipulate_organs))
				continue
			succeed = TRUE
			break
	if(succeed)
		var/list/organs_to_boot_out = organ_receiver.getorganslot(organ.slot)
		for(var/obj/item/organ/organ_evacced as anything in organs_to_boot_out)
			if(organ_evacced.organ_flags & ORGAN_UNREMOVABLE)
				continue
			organ_evacced.Remove(target)
			organ_evacced.forceMove(get_turf(target))
		organ.Insert(target)
	else
		organ.forceMove(drop_location())
	organ = null
