#define FAST_MOTOR_SPEED 1
#define AVERAGE_MOTOR_SPEED 2
#define SLOW_MOTOR_SPEED 3

/datum/wires/mulebot
	holder_type = /mob/living/simple_animal/bot/mulebot
	proper_name = "Mulebot"
	randomize = TRUE

/datum/wires/mulebot/New(atom/holder)
	wires = list(
		WIRE_POWER1, WIRE_POWER2,
		WIRE_AVOIDANCE, WIRE_LOADCHECK,
		WIRE_MOTOR1, WIRE_MOTOR2,
		WIRE_RX, WIRE_TX, WIRE_BEACON
	)
	..()

/datum/wires/mulebot/interactable(mob/user)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/bot/mulebot/mule = holder
	if(mule.bot_cover_flags & BOT_COVER_OPEN)
		return TRUE

/datum/wires/mulebot/on_cut(wire, mend)
	var/mob/living/simple_animal/bot/mulebot/mule = holder
	switch(wire)
		if(WIRE_MOTOR1, WIRE_MOTOR2)
			if(is_cut(WIRE_MOTOR1) && is_cut(WIRE_MOTOR2))
				ADD_TRAIT(mule, TRAIT_IMMOBILIZED, MOTOR_LACK_TRAIT)
			else
				REMOVE_TRAIT(mule, TRAIT_IMMOBILIZED, MOTOR_LACK_TRAIT)

			if(is_cut(WIRE_MOTOR1))
				mule.set_varspeed(FAST_MOTOR_SPEED)
			else if(is_cut(WIRE_MOTOR2))
				mule.set_varspeed(AVERAGE_MOTOR_SPEED)
			else
				mule.set_varspeed(SLOW_MOTOR_SPEED)

/datum/wires/mulebot/on_pulse(wire)
	var/mob/living/simple_animal/bot/mulebot/mule = holder
	if(!mule.has_power(TRUE))
		return //logically mulebots can't flash and beep if they don't have power.
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2)
			holder.visible_message(span_notice("[icon2html(mule, viewers(holder))] The charge light flickers."))
		if(WIRE_AVOIDANCE)
			holder.visible_message(span_notice("[icon2html(mule, viewers(holder))] The external warning lights flash briefly."))
			flick("[mule.base_icon]1", mule)
		if(WIRE_LOADCHECK)
			holder.visible_message(span_notice("[icon2html(mule, viewers(holder))] The load platform clunks."))
		if(WIRE_MOTOR1, WIRE_MOTOR2)
			holder.visible_message(span_notice("[icon2html(mule, viewers(holder))] The drive motor whines briefly."))
		else
			holder.visible_message(span_notice("[icon2html(mule, viewers(holder))] You hear a radio crackle."))

#undef FAST_MOTOR_SPEED
#undef AVERAGE_MOTOR_SPEED
#undef SLOW_MOTOR_SPEED
