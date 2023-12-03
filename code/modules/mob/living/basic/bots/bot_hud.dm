/mob/living/basic/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/icon_image = icon(icon, icon_state, dir)
	holder.pixel_y = icon_image.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/basic/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/our_icon = icon(icon, icon_state, dir)
	holder.pixel_y = our_icon.Height() - world.icon_size
	if(bot_mode_flags & BOT_MODE_ON)
		holder.icon_state = "hudstat"
		return
	if(stat != CONSCIOUS)
		holder.icon_state = "hudoffline"
		return
	holder.icon_state = "huddead2"

/mob/living/basic/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	var/image/holder = hud_list[DIAG_BOT_HUD]
	var/icon/icon_image = icon(icon, icon_state, dir)
	holder.pixel_y = icon_image.Height() - world.icon_size
	if(client) //If the bot is player controlled, it will not be following mode logic!
		holder.icon_state = "hudsentient"
		return

	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			holder.icon_state = "hudcalled"
		if(BOT_CLEANING, BOT_REPAIRING, BOT_HEALING) //Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			holder.icon_state = "hudworking"
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			holder.icon_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT) //STOP RIGHT THERE, CRIMINAL SCUM!
			holder.icon_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""
