#define DEFAULT_MIN_BOMBER_ALIVE_TIME 30

#define RC_STATE_DISABLED 0
#define RC_STATE_ENABLED 1

// MARK: Controller

/datum/controller/subsystem/explosions
	var/raider_controller_state = RC_STATE_DISABLED
	var/minimum_bomber_alive_time =	DEFAULT_MIN_BOMBER_ALIVE_TIME

ADMIN_VERB(manage_raider_controller, R_ADMIN, "Raider Controller", "Manages anti-raider system", ADMIN_CATEGORY_DEBUG)
	var/controller_category = tgui_input_list(user, "Что хотите изменить?", "Выбирай...", list("Требуемое время игры", "Режим работы"))
	switch(controller_category)
		if("Требуемое время игры")
			SSexplosions.minimum_bomber_alive_time = tgui_input_number(user, "Сколько часов нужно отыграть?", "Выбирай..", SSexplosions.minimum_bomber_alive_time, 1000, 1)
		if("Режим работы")
			var/new_state = tgui_input_list(user, "Какой режим?", "Выбирай...", list("Отключить", "Включить"), SSexplosions.raider_controller_state)
			switch(new_state)
				if("Отключить")
					SSexplosions.raider_controller_state = RC_STATE_DISABLED
				if("Включить")
					SSexplosions.raider_controller_state = RC_STATE_ENABLED
		else
			return

// MARK: Basic explosions

/datum/controller/subsystem/explosions/explode(atom/origin, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flame_range = null, flash_range = null, adminlog = TRUE, ignorecap = FALSE, silent = FALSE, smoke = FALSE, protect_epicenter = FALSE, atom/explosion_cause = null, explosion_direction = 0, explosion_arc = 360)
	if(SSexplosions.raider_controller_state == RC_STATE_DISABLED)
		return ..()

	// By default it's user
	var/mob/user_mob = usr

	var/client/who_did_it

	// If user is a mob, we try to get their client
	if(ismob(user_mob))
		who_did_it = user_mob.client

	// If we don't get a client, we try an alternative way to identify it through fingerprints
	if(!who_did_it)
		explosion_cause = explosion_cause ? explosion_cause : origin

		if(!explosion_cause)
			return ..()
		if(!explosion_cause.fingerprintslast)
			return ..()

		who_did_it = GLOB.directory[explosion_cause.fingerprintslast]

		// If we still don't get it, we abort
		if(!who_did_it)
			return ..()

	if((who_did_it.get_exp_living(pure_numeric = TRUE) / 60) < SSexplosions.minimum_bomber_alive_time)
		message_admins("Время игры вызвавшего взрыв игрока [who_did_it] ([who_did_it.get_exp_living()]) ниже установленного предела. Применён дополнительный кап. Оригинальный взрыв имел размер (Devast: [devastation_range], Heavy: [heavy_impact_range], Light: [light_impact_range], Flame: [flame_range], Flash: [flash_range])")
		log_game("Время игры вызвавшего взрыв игрока [who_did_it] ([who_did_it.get_exp_living()]) ниже установленного предела. Применён дополнительный кап. Оригинальный взрыв имел размер (Devast: [devastation_range], Heavy: [heavy_impact_range], Light: [light_impact_range], Flame: [flame_range], Flash: [flash_range])")
		devastation_range = min(0, devastation_range)
		heavy_impact_range = min(1, heavy_impact_range)
		light_impact_range = min(4, light_impact_range)

	return ..()
