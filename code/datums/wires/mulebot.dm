/datum/wires/mulebot
	var/const/W_POWER1 = "power1"
	var/const/W_POWER2 = "power2"
	var/const/W_AVOIDANCE = "avoidance"
	var/const/W_LOADCHECK = "loadcheck"
	var/const/W_MOTOR1 = "motor1"
	var/const/W_MOTOR2 = "motor2"
	var/const/W_REMOTE_RX = "rx"
	var/const/W_REMOTE_TX = "tx"
	var/const/W_BEACON_RX = "beacon"

	holder_type = /mob/living/simple_animal/bot/mulebot
	randomize = TRUE

/datum/wires/mulebot/New(atom/holder)
	wires = list(
		W_POWER1, W_POWER2,
		W_AVOIDANCE, W_LOADCHECK,
		W_MOTOR1, W_MOTOR2,
		W_REMOTE_RX, W_REMOTE_TX, W_BEACON_RX
	)
	..()

/datum/wires/mulebot/interactable(mob/user)
	var/mob/living/simple_animal/bot/mulebot/M = holder
	if(M.open)
		return TRUE

/datum/wires/mulebot/on_pulse(wire)
	var/mob/living/simple_animal/bot/mulebot/M = holder
	switch(wire)
		if(W_POWER1, W_POWER2)
			holder.visible_message("<span class='notice'>\icon[M] The charge light flickers.</span>")
		if(W_AVOIDANCE)
			holder.visible_message("<span class='notice'>\icon[M] The external warning lights flash briefly.</span>")
		if(W_LOADCHECK)
			holder.visible_message("<span class='notice'>\icon[M] The load platform clunks.</span>")
		if(W_MOTOR1, W_MOTOR2)
			holder.visible_message("<span class='notice'>\icon[M] The drive motor whines briefly.</span>")
		else
			holder.visible_message("<span class='notice'>\icon[M] You hear a radio crackle.</span>")