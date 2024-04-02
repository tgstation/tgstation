/obj/item/raptor_dex
	name = "raptor Dex"
	desc = "A device used to analyze lavaland raptors!"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "raptor_dex"
	item_flags = NOBLUDGEON
	///current raptor we are analyzing
	var/datum/weakref/raptor

/obj/item/raptor_dex/attack_self(mob/user)
	. = ..()
	if(.)
		return TRUE
	if(isnull(raptor?.resolve()))
		balloon_alert(user, "no specimen data!")
		return TRUE

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RaptorDex")
		ui.open()

/obj/item/raptor_dex/ui_static_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/mining/raptor/my_raptor = raptor.resolve()
	data["raptor_image"] = icon2base64(getFlatIcon(image(icon = my_raptor.icon, icon_state = my_raptor.icon_state, no_anim=TRUE)))
	data["raptor_attack"] = my_raptor.attack
	data["raptor_health"] = my_raptor.maxHealth
	data["raptor_speed"] = my_raptor.speed
	var/datum/raptor_inheritance/inherit = my_raptor.inherited_stats
	if(isnull(inherit))
		return data
	data["inherited_attack"] = inherit.attack_modifier
	data["inherited_health"] = inherit.health_modifier
	data["inherited_traits"] = inherit.inherit_traits
	return data


/obj/item/raptor_dex/afterattack(atom/attacked_atom, mob/living/user, proximity)
	. = ..()

	if(!proximity)
		return

	. |= AFTERATTACK_PROCESSED_ITEM

	if(!istype(attacked_atom, /mob/living/basic/mining/raptor))
		balloon_alert(user, "cant be analyzed!")
		return

	raptor = WEAKREF(raptor)
