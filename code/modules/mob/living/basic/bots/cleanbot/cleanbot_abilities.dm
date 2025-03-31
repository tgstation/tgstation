/datum/action/cooldown/mob_cooldown/bot
	background_icon_state = "bg_tech_blue"
	overlay_icon_state = "bg_tech_blue_border"
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/mob_cooldown/bot/IsAvailable(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!isbot(owner))
		return TRUE
	var/mob/living/basic/bot/bot_owner = owner
	if((bot_owner.bot_mode_flags & BOT_MODE_ON))
		return TRUE
	if(feedback)
		bot_owner.balloon_alert(bot_owner, "power off!")
	return FALSE

/datum/action/cooldown/mob_cooldown/bot/foam
	name = "Foam"
	desc = "Spread foam all around you!"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "mfoam"
	cooldown_time = 20 SECONDS
	click_to_activate = FALSE
	///range of the foam to spread
	var/foam_range = 2

/datum/action/cooldown/mob_cooldown/bot/foam/Activate(mob/living/firer, atom/target)
	owner.visible_message(span_danger("[owner] whirs and bubbles violently, before releasing a plume of froth!"))
	var/datum/effect_system/fluid_spread/foam/foam = new
	foam.set_up(foam_range, holder = owner, location = owner.loc)
	foam.start()
	StartCooldown()
	return TRUE
