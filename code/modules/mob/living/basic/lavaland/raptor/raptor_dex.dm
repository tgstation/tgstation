/obj/item/raptor_dex
	name = "raptor Dex"
	desc = "A device used to analyze lavaland raptors!"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "raptor_dex"
	item_flags = NOBLUDGEON
	///current raptor we are analyzing
	var/datum/weakref/raptor

/obj/item/raptor_dex/ui_interact(mob/user, datum/tgui/ui)
	if(isnull(raptor?.resolve()))
		balloon_alert(user, "no specimen data!")
		return TRUE

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RaptorDex")
		ui.open()

/obj/item/raptor_dex/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/raptor/my_raptor = raptor.resolve()

	data["raptor_image"] = icon2base64(getFlatIcon(image(icon = my_raptor.icon, icon_state = my_raptor.icon_state)))
	data["raptor_attack"] = my_raptor.melee_damage_lower
	data["raptor_health"] = my_raptor.maxHealth
	data["raptor_speed"] = my_raptor.speed
	data["raptor_color"] = my_raptor.name
	data["raptor_gender"] = my_raptor.gender
	data["raptor_description"] = my_raptor.dex_description

	var/happiness_percentage = my_raptor.ai_controller?.blackboard[BB_BASIC_HAPPINESS]
	var/obj/effect/overlay/happiness_overlay/display = new
	display.set_hearts(happiness_percentage)
	display.pixel_y = world.icon_size * 0.5
	data["raptor_happiness"] = icon2base64(getFlatIcon(display))
	qdel(display)

	var/datum/raptor_inheritance/inherit = my_raptor.inherited_stats
	if(isnull(inherit))
		return data

	data["inherited_attack"] = inherit.attack_modifier
	data["inherited_attack_max"] = RAPTOR_INHERIT_MAX_ATTACK
	data["inherited_health"] = inherit.health_modifier
	data["inherited_health_max"] = RAPTOR_INHERIT_MAX_HEALTH

	data["inherited_traits"] = list()
	for(var/index in inherit.inherit_traits)
		data["inherited_traits"] += GLOB.raptor_inherit_traits[index]
	return data


/obj/item/raptor_dex/interact_with_atom(atom/attacked_atom, mob/living/user)
	if(!istype(attacked_atom, /mob/living/basic/raptor))
		return NONE

	raptor = WEAKREF(attacked_atom)
	playsound(src, 'sound/items/orbie_send_out.ogg', 20)
	balloon_alert(user, "scanned")
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS
