/// Security level is gamma.
#define SEC_LEVEL_GAMMA 4
/// Security level is epsilon.
#define SEC_LEVEL_EPSILON 5

//
/datum/config_entry/string/alert_gamma
	default = "Центральным Командованием был установлен Код Гамма. Служба безопасности должна быть полностью вооружена. Гражданский персонал обязан немедленно обратиться к Главам отделов для получения дальнейших указаний."
/datum/config_entry/string/alert_epsilon
	default = "Центральным командованием был установлен код ЭПСИЛОН. Все контракты расторгнуты."
//

/**
 * Gamma
 *
 * Station major hostile threats
 */

/datum/security_level/gamma
	name = "gamma"
	announcement_color = "orange"
	sound = 'modular_bandastation/security_levels/sound/new_siren.ogg'
	status_display_icon_state = "gammaalert"
	fire_alarm_light_color = LIGHT_COLOR_ORANGE
	number_level = SEC_LEVEL_GAMMA
	elevating_to_configuration_key = /datum/config_entry/string/alert_gamma
	shuttle_call_time_mod = ALERT_COEFF_RED

/**
 * Epsilon
 *
 * Station is not longer under the Central Command and to be destroyed by Death Squad (Or maybe not)
 */

/datum/security_level/epsilon
	name = "epsilon"
	announcement_color = "purple"
	sound = 'modular_bandastation/security_levels/sound/epsilon.ogg'
	number_level = SEC_LEVEL_EPSILON
	status_display_icon_state = "epsilonalert"
	fire_alarm_light_color = LIGHT_COLOR_BLOOD_MAGIC
	elevating_to_configuration_key = /datum/config_entry/string/alert_epsilon
	shuttle_call_time_mod = 10

#undef SEC_LEVEL_GAMMA
#undef SEC_LEVEL_EPSILON
