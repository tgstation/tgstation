///food effect applied by ice cream and frozen treats
/datum/status_effect/food/chilling
	alert_type = /atom/movable/screen/alert/status_effect/icecream_chilling //different path, so we sprite one state and not five.

/datum/status_effect/food/chilling/tick(seconds_between_ticks)
	var/minimum_temp = (BODYTEMP_HEAT_DAMAGE_LIMIT - 12 * strength)
	if(owner.bodytemperature >= minimum_temp)
		owner.adjust_bodytemperature(-2.75 * strength * seconds_between_ticks, min_temp = minimum_temp)

/atom/movable/screen/alert/status_effect/icecream_chilling
	desc = "Nothing beats a cup of ice cream during hot, plasma-floody day..."
	icon_state = "food_icecream"

