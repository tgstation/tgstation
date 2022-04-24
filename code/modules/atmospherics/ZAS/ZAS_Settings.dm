/datum/zas_controller
	var/datum/pl_control/plc = new

	var/fire_consumption_rate = 0.25
	var/fire_consumption_rate_NAME = "Fire - Air Consumption Ratio"
	var/fire_consumption_rate_DESC = "Ratio of air removed and combusted per tick."

	var/fire_firelevel_multiplier = 25
	var/fire_firelevel_multiplier_NAME = "Fire - Firelevel Constant"
	var/fire_firelevel_multiplier_DESC = "Multiplied by the equation for firelevel, affects mainly the extingiushing of fires."

	//Note that this parameter and the phoron heat capacity have a significant impact on TTV yield.
	var/fire_fuel_energy_release = 866000 //J/mol. Adjusted to compensate for fire energy release being fixed, was 397000
	var/fire_fuel_energy_release_NAME = "Fire - Fuel energy release"
	var/fire_fuel_energy_release_DESC = "The energy in joule released when burning one mol of a burnable substance"


	var/IgnitionLevel = 0.5
	var/IgnitionLevel_DESC = "Determines point at which fire can ignite"

	var/airflow_lightest_pressure = 20
	var/airflow_lightest_pressure_NAME = "Airflow - Small Movement Threshold %"
	var/airflow_lightest_pressure_DESC = "Percent of 1 Atm. at which items with the small weight classes will move."

	var/airflow_light_pressure = 35
	var/airflow_light_pressure_NAME = "Airflow - Medium Movement Threshold %"
	var/airflow_light_pressure_DESC = "Percent of 1 Atm. at which items with the medium weight classes will move."

	var/airflow_medium_pressure = 50
	var/airflow_medium_pressure_NAME = "Airflow - Heavy Movement Threshold %"
	var/airflow_medium_pressure_DESC = "Percent of 1 Atm. at which items with the largest weight classes will move."

	var/airflow_heavy_pressure = 65
	var/airflow_heavy_pressure_NAME = "Airflow - Mob Movement Threshold %"
	var/airflow_heavy_pressure_DESC = "Percent of 1 Atm. at which mobs will move."

	var/airflow_dense_pressure = 85
	var/airflow_dense_pressure_NAME = "Airflow - Dense Movement Threshold %"
	var/airflow_dense_pressure_DESC = "Percent of 1 Atm. at which items with canisters and closets will move."

	var/airflow_stun_pressure = 60
	var/airflow_stun_pressure_NAME = "Airflow - Mob Stunning Threshold %"
	var/airflow_stun_pressure_DESC = "Percent of 1 Atm. at which mobs will be stunned by airflow."

	var/airflow_stun_cooldown = 60
	var/airflow_stun_cooldown_NAME = "Aiflow Stunning - Cooldown"
	var/airflow_stun_cooldown_DESC = "How long, in tenths of a second, to wait before stunning them again."

	var/airflow_stun = 1
	var/airflow_stun_NAME = "Airflow Impact - Stunning"
	var/airflow_stun_DESC = "How much a mob is stunned when hit by an object."

	var/airflow_damage = 3
	var/airflow_damage_NAME = "Airflow Impact - Damage"
	var/airflow_damage_DESC = "Damage from airflow impacts."

	var/airflow_speed_decay = 1.5
	var/airflow_speed_decay_NAME = "Airflow Speed Decay"
	var/airflow_speed_decay_DESC = "How rapidly the speed gained from airflow decays."

	var/airflow_delay = 30
	var/airflow_delay_NAME = "Airflow Retrigger Delay"
	var/airflow_delay_DESC = "Time in deciseconds before things can be moved by airflow again."

	var/airflow_mob_slowdown = 1
	var/airflow_mob_slowdown_NAME = "Airflow Slowdown"
	var/airflow_mob_slowdown_DESC = "Time in tenths of a second to add as a delay to each movement by a mob if they are fighting the pull of the airflow."

	var/connection_insulation = 1
	var/connection_insulation_NAME = "Connections - Insulation"
	var/connection_insulation_DESC = "Boolean, should doors forbid heat transfer?"

	var/connection_temperature_delta = 10
	var/connection_temperature_delta_NAME = "Connections - Temperature Difference"
	var/connection_temperature_delta_DESC = "The smallest temperature difference which will cause heat to travel through doors."
