/obj/item/mod/module/baton_holster
	name = "MOD baton holster module"
	desc = "A module installed into the chest of a MODSuit, this allows you \
		to retrieve an inserted baton from the suit at will. Insert a baton \
		by using the module with the baton in hand. \
		Remove an inserted baton by using a wrench on the module while it is removed from the suit."
	icon_state = "holster"
	icon = 'monkestation/icons/obj/items/modsuit_modules.dmi'
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/baton_holster)
	module_type = MODULE_USABLE
	/// Ref to the baton
	var/obj/item/melee/baton/telescopic/contractor_baton/stored_batong
	/// If the baton is out or not
	var/deployed = FALSE

// doesn't give a shit if it's deployed or not
/obj/item/mod/module/baton_holster/on_select()
	on_use()
	SEND_SIGNAL(mod, COMSIG_MOD_MODULE_SELECTED, src)

/obj/item/mod/module/baton_holster/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!stored_batong)
		return
	balloon_alert(user, "[stored_batong] removed")
	stored_batong.forceMove(get_turf(src))
	stored_batong.holster = null
	stored_batong = null
	tool.play_tool_sound(src)

/obj/item/mod/module/baton_holster/Destroy()
	if(stored_batong)
		stored_batong.forceMove(get_turf(src))
		stored_batong.holster = null
		stored_batong = null
	. = ..()

/obj/item/mod/module/baton_holster/on_use()
	var/obj/item/held_item = mod.wearer.get_active_held_item()
	if(istype(held_item, /obj/item/melee/baton/telescopic/contractor_baton) && !stored_batong)
		balloon_alert(mod.wearer, "[held_item] inserted")
		held_item.forceMove(src)
		stored_batong = held_item
		stored_batong.holster = src
		return

	if(!deployed)
		deploy(mod.wearer)
	else
		undeploy(mod.wearer)

/obj/item/mod/module/baton_holster/proc/deploy(mob/living/user)
	if(!(stored_batong in src))
		return
	if(!user.put_in_hands(stored_batong))
		to_chat(user, span_warning("You need a free hand to hold [stored_batong]!"))
		return
	deployed = TRUE
	balloon_alert(user, "[stored_batong] deployed")

/obj/item/mod/module/baton_holster/proc/undeploy(mob/living/user)
	if(QDELETED(stored_batong))
		return
	stored_batong.forceMove(src)
	deployed = FALSE
	balloon_alert(user, "[stored_batong] retracted")

/obj/item/mod/module/baton_holster/preloaded

/obj/item/mod/module/baton_holster/preloaded/Initialize(mapload)
	. = ..()
	stored_batong = new/obj/item/melee/baton/telescopic/contractor_baton/upgraded(src)
	stored_batong.holster = src
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
