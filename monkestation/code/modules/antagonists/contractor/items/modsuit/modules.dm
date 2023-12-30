/obj/item/mod/module/baton_holster
	name = "MOD baton holster module"
	desc = "A module installed into the chest of a MODSuit, this allows you \
		to retrieve an inserted baton from the suit at will. Insert a baton \
		by using the module with the baton in hand. \
		Remove an inserted baton by using a wrench on the module while it is removed from the suit."
	icon_state = "holster"
	icon = 'monkestation/icons/obj/items/modsuit_modules.dmi'
	module_type = MODULE_ACTIVE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/melee/baton/telescopic/contractor_baton
	incompatible_modules = list(/obj/item/mod/module/baton_holster)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Have they sacrificed a baton to actually be able to use this?
	var/eaten_baton = FALSE

/obj/item/mod/module/baton_holster/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/melee/baton/telescopic/contractor_baton) || eaten_baton)
		return
	balloon_alert(user, "[attacking_item] inserted")
	eaten_baton = TRUE
	for(var/obj/item/melee/baton/telescopic/contractor_baton/device_baton as anything in src)
		for(var/obj/item/baton_upgrade/original_upgrade in attacking_item)
			var/obj/item/baton_upgrade/new_upgrade = new original_upgrade.type(device_baton)
			device_baton.add_upgrade(new_upgrade)
		for(var/obj/item/restraints/handcuffs/cable/baton_cuffs in attacking_item)
			baton_cuffs.forceMove(device_baton)
	qdel(attacking_item) //TEST CUFFS

/obj/item/mod/module/baton_holster/on_activation()
	if(!eaten_baton)
		balloon_alert(mod.wearer, "no baton inserted")
		return
	return ..()

/obj/item/mod/module/baton_holster/preloaded
	eaten_baton = TRUE
	device = /obj/item/melee/baton/telescopic/contractor_baton

/obj/item/mod/module/baton_holster/preloaded/upgraded
	device = /obj/item/melee/baton/telescopic/contractor_baton/upgraded

/obj/item/mod/module/chameleon/contractor // zero complexity module to match pre-TGification
	complexity = 0

//making this slow you down this will most likely not get used, might rework this
/obj/item/mod/module/armor_booster/contractor // Much flatter distribution because contractor suit gets a shitton of armor already
	armor_mod = /datum/armor/mod_module_armor_booster_contractor
	speed_added = -0.3
	desc = "An embedded set of armor plates, allowing the suit's already extremely high protection \
		to be increased further. However, the plating, while deployed, will slow down the user \
		and make the suit unable to vacuum seal so this extra armor provides zero ability for extravehicular activity while deployed."

/datum/armor/mod_module_armor_booster_contractor
	melee = 20
	bullet = 20
	laser = 20
	energy = 20

/// Non-deathtrap contractor springlock module
/obj/item/mod/module/springlock/contractor
	name = "MOD magnetic deployment module"
	desc = "A much more modern version of a springlock system. \
	This is a module that uses magnets to speed up the deployment and retraction time of your MODsuit."
	complexity = 0 //we have fast deploy already, we dont need this to cost anything

/obj/item/mod/module/springlock/contractor/on_suit_activation() // This module is actually *not* a death trap
	return

/obj/item/mod/module/springlock/contractor/on_suit_deactivation(deleting = FALSE)
	return

/// SCORPION - hook a target into baton range quickly and non-lethally
/obj/item/mod/module/scorpion_hook
	name = "MOD SCORPION hook module"
	desc = "A module installed in the wrist of a MODSuit, this highly \
			illegal module uses a hardlight hook to forcefully pull \
			a target towards you at high speed, knocking them down and \
			partially exhausting them."
	icon = 'monkestation/icons/obj/guns/magic.dmi'
	icon_state = "contractor_hook"
	incompatible_modules = list(/obj/item/mod/module/scorpion_hook)
	module_type = MODULE_ACTIVE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/gun/magic/hook/contractor
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
