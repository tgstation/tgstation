//Security modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CELL_DRAIN * 2
	use_power_cost = DEFAULT_CELL_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, .proc/unstealth)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/on_unarmed_attack)
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), .proc/unstealth)
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation()
	. = ..()
	if(!.)
		return
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	on_deactivation()

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The draw on the power cell has been reduced drastically, \
		making this perfect for activities like standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CELL_DRAIN
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	cooldown_time = 3 SECONDS

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
	use_power_cost = DEFAULT_CELL_DRAIN * 0.5
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
		if(!istype(holding) || holding.atom_size > ITEM_SIZE_BULKY)
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
