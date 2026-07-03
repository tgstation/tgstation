// TODO: Закинуть коммит на ТГ.
/mob/living/basic
	var/icon_resting

/mob/living/basic/update_resting()
	. = ..()
	if(!icon_resting)
		return
	if(stat == DEAD)
		return
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/update_icon_state()
	. = ..()
	if(!icon_resting)
		return
	if (resting)
		icon_state = icon_resting // Like "[icon_living]_rest"
		return
	icon_state = initial(icon_state)
