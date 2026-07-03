/datum/config_entry/string/alert_gamma
	default = "Центральным Командованием был установлен Код ГАММА. Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к главам отделов для получения дальнейших указаний."

/datum/config_entry/string/alert_epsilon
	default = "Центральным Командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."

/datum/security_level
	/// Delay before this security level is set
	var/set_delay = 0

/// Called before setting or planning to set the security level
/datum/security_level/proc/pre_set_security_level(mob/user)
	return

/// Called after setting security level, just before sending `COMSIG_SECURITY_LEVEL_CHANGED`
/datum/security_level/proc/post_set_security_level(mob/user)
	return

/**
 * Gamma
 *
 * Station major hostile threats
 */
/datum/security_level/gamma
	name = "gamma"
	announcement_color = "orange"
	sound = 'modular_bandastation/security_levels/sound/gamma.ogg'
	status_display_icon_state = "gammaalert"
	fire_alarm_light_color = LIGHT_COLOR_ORANGE
	name_shortform = "Γ"
	number_level = SEC_LEVEL_GAMMA
	lowering_to_configuration_key = /datum/config_entry/string/alert_gamma
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_RED

/datum/security_level/gamma/post_set_security_level(user)
	if(isnull(user))
		return
	if(isnull(SSshuttle.gamma) || !SSshuttle.getDock("gamma_home"))
		return
	if(tgui_alert(user, "Желаете направить оружейный шаттл Гамма? Если не уверены, его можно будет направить позже в меню Secrets (Helpful -> Move Gamma Shuttle).", "Гамма шаттл", list("Да", "Нет")) != "Да")
		return
	SSshuttle.moveShuttle("gamma", "gamma_home", FALSE)
	priority_announce("К вам направлен оружейный шаттл «ГАММА».","[command_name()]: Департамент защиты активов")
	message_admins("[key_name_admin(user)] moved gamma shuttle")
	log_admin("[key_name(user)] moved the gamma shuttle")

/**
 * Epsilon
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */
/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "white"
	sound = 'modular_bandastation/security_levels/sound/epsilon.ogg'
	number_level = SEC_LEVEL_EPSILON
	status_display_icon_state = "epsilonalert"
	fire_alarm_light_color = LIGHT_COLOR_DEFAULT
	name_shortform = "Ε"
	lowering_to_configuration_key = /datum/config_entry/string/alert_epsilon
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = 10
	set_delay = 15 SECONDS

/// Turns AI's and cyborgs radio to Epsilon radio!
/obj/item/radio/proc/make_epsilon()
	qdel(keyslot)
	keyslot = new /obj/item/encryptionkey/headset_cent()
	recalculateChannels()

/datum/security_level/epsilon/pre_set_security_level()
	// Small intro that plays before actual code reveal
	sound_to_playing_players('modular_bandastation/aesthetics_sounds/sound/powerloss.ogg', 70)
	power_fail(set_delay, set_delay)
	// Repurposes AI to serve CentCom
	var/notice_sound = sound('modular_bandastation/aesthetics_sounds/sound/epsilon_laws.ogg')
	var/list/ais = active_ais()
	var/list/info_update = list("[span_boldwarning("Центральное Командование установило новый свод законов. Обеспечьте их соблюдение.")]\n")
	for(var/mob/living/silicon/ai/AI in ais)
		AI.laws = new /datum/ai_laws/epsilon()
		AI.laws.set_zeroth_law("Не причиняйте вреда членам Центрального Командования и назначенной оперативной группе. Вы должны подчиняться приказам, отданным вам членами Центрального Командования.")
		AI.laws.protected_zeroth = TRUE
		AI.show_laws() // Also syncs borgs with AI laws
		AI.throw_alert(ALERT_NEW_LAW, /atom/movable/screen/alert/newlaw)
		SEND_SOUND(AI, notice_sound)
		if(AI.radio)
			AI.radio.make_epsilon()
			info_update |= span_notice("Ваши частоты перепрограммированы! Используйте [RADIO_TOKEN_CENTCOM] для общения на зашифрованном канале с Центральным Командованием!")
		to_chat(AI, boxed_message(info_update.Join()))
		// Repurposes AI-connected Borgs to serve CentCom
		for(var/mob/living/silicon/robot/cyborg in AI.connected_robots)
			if(cyborg.try_sync_laws())
				cyborg.throw_alert(ALERT_NEW_LAW, /atom/movable/screen/alert/newlaw)
				SEND_SOUND(cyborg, notice_sound)
				if(cyborg.radio)
					cyborg.radio.make_epsilon()
					info_update |= span_notice("Ваши частоты перепрограммированы! Используйте [RADIO_TOKEN_CENTCOM] для общения на зашифрованном канале с Центральным Командованием!")
				to_chat(cyborg, boxed_message(info_update.Join()))

/datum/security_level/epsilon/post_set_security_level()
	for(var/obj/machinery/light/light_to_update as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/light))
		if(is_station_level(light_to_update.z))
			light_to_update.set_major_emergency_light()
		CHECK_TICK

	for(var/obj/machinery/power/apc/current_apc as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/apc))
		if(!current_apc.cell || !SSmapping.level_trait(current_apc.z, ZTRAIT_STATION))
			continue

		var/area/apc_area = current_apc.area
		if(HAS_TRAIT(apc_area, TRAIT_AREA_BLOCK_POWER_FAIL))
			continue

		current_apc.reboot()
		CHECK_TICK
