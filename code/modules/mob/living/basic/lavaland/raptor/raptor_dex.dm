/obj/item/raptor_dex
	name = "RaptorDex"
	desc = "A device used to analyze lavaland raptors!"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "raptor_dex"
	item_flags = NOBLUDGEON
	/// Raptor scan data we have stored
	var/list/scan_data = list("raptor_scan" = FALSE)

/obj/item/raptor_dex/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RaptorDex")
		ui.open()

/obj/item/raptor_dex/ui_data(mob/user)
	return scan_data

/obj/item/raptor_dex/interact_with_atom(atom/attacked_atom, mob/living/user)
	if(!istype(attacked_atom, /mob/living/basic/raptor))
		return NONE

	var/mob/living/basic/raptor/my_raptor = attacked_atom
	var/datum/movespeed_modifier/intent_mod = my_raptor.get_move_intent_slowdown()

	scan_data = list()
	scan_data["raptor_scan"] = TRUE
	scan_data["raptor_image"] = icon2base64(icon(icon = my_raptor.icon, icon_state = my_raptor.icon_state, dir = SOUTH, frame = 1))
	scan_data["raptor_attack"] = my_raptor.melee_damage_lower
	scan_data["raptor_health"] = my_raptor.health
	scan_data["raptor_max_health"] = my_raptor.maxHealth
	scan_data["raptor_speed"] = my_raptor.speed + intent_mod?.multiplicative_slowdown
	scan_data["raptor_color"] = my_raptor.name
	scan_data["raptor_gender"] = my_raptor.gender
	scan_data["raptor_description"] = my_raptor.raptor_color.description

	var/happiness_percentage = my_raptor.ai_controller?.blackboard[BB_BASIC_HAPPINESS]
	var/obj/effect/overlay/happiness_overlay/display = new()
	display.set_hearts(happiness_percentage)
	display.pixel_y = ICON_SIZE_Y * 0.5
	scan_data["raptor_happiness"] = icon2base64(getFlatIcon(display, no_anim = TRUE))
	qdel(display)

	var/datum/raptor_inheritance/inherit = my_raptor.inherited_stats
	if(!isnull(inherit))
		scan_data["inherited_attack"] = inherit.attack_modifier
		scan_data["inherited_attack_max"] = RAPTOR_INHERIT_MAX_ATTACK
		scan_data["inherited_health"] = inherit.health_modifier
		scan_data["inherited_health_max"] = RAPTOR_INHERIT_MAX_HEALTH
		scan_data["inherited_speed"] = inherit.speed_modifier
		scan_data["inherited_speed_max"] = RAPTOR_INHERIT_MAX_SPEED
		scan_data["inherited_ability"] = inherit.ability_modifier
		scan_data["inherited_ability_max"] = RAPTOR_INHERIT_MAX_MODIFIER
		scan_data["inherited_growth"] = inherit.growth_modifier
		scan_data["inherited_growth_max"] = RAPTOR_INHERIT_MAX_MODIFIER

		scan_data["inherited_traits"] = list()
		for(var/index in inherit.personality_traits)
			scan_data["inherited_traits"] += GLOB.raptor_inherit_traits[index]

	playsound(src, 'sound/mobs/non-humanoids/orbie/orbie_send_out.ogg', 20)
	balloon_alert(my_raptor, "scanned")
	ui_interact(user)
	return ITEM_INTERACT_SUCCESS
