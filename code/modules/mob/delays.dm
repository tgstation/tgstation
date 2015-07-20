//////////////////////////////////
// /vg/ MODULARIZED DELAYS - by N3X15
//////////////////////////////////

// Reduces duplicated code by quite a bit.
/datum/delay_controller
	// Delay clamps (for adminbus, effects)
	var/min_delay = 1
	var/max_delay = ARBITRARILY_LARGE_NUMBER //See setup.dm, 12

	var/next_allowed = 0

/datum/delay_controller/New(var/min,var/max)
	min_delay=min
	max_delay=max

/datum/delay_controller/proc/setDelay(var/delay)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/delay_controller/proc/setDelay() called tick#: [world.time]")
	next_allowed = world.time + Clamp(delay,min_delay,max_delay)

/datum/delay_controller/proc/addDelay(var/delay)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/delay_controller/proc/addDelay() called tick#: [world.time]")
	var/current_delay = max(0,next_allowed - world.time)
	setDelay(current_delay+delay)

// Proxy for delayNext*(), to reduce duplicated code.
/datum/delay_controller/proc/delayNext(var/delay, var/additive)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/delay_controller/proc/delayNext() called tick#: [world.time]")
	if(additive)
		addDelay(delay)
	else
		setDelay(delay)

/datum/delay_controller/proc/blocked()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/delay_controller/proc/blocked() called tick#: [world.time]")
	return next_allowed > world.time

// Constructor args are currently all the same, but placed here for ease of tuning.
/client // Yep, clients are snowflakes.
	// Walking speed is 7, as is grab speed.
	var/datum/delay_controller/move_delayer    = new (1,ARBITRARILY_LARGE_NUMBER) // /mob/delayNextMove()
/mob
	var/datum/delay_controller/click_delayer   = new (1,ARBITRARILY_LARGE_NUMBER) // (Handled in Click())
	var/datum/delay_controller/attack_delayer  = new (1,ARBITRARILY_LARGE_NUMBER) // delayNextAttack() See setup.dm, 12
	var/datum/delay_controller/special_delayer = new (1,ARBITRARILY_LARGE_NUMBER) // delayNextSpecial()

// Convenience procs.
/mob/proc/delayNextMove(var/delay, var/additive=0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/delayNextMove() called tick#: [world.time]")
	if(client)
		client.move_delayer.delayNext(delay,additive)

/mob/proc/delayNextAttack(var/delay, var/additive=0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/delayNextAttack() called tick#: [world.time]")
	attack_delayer.delayNext(delay,additive)

/mob/proc/delayNextSpecial(var/delay, var/additive=0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/delayNextSpecial() called tick#: [world.time]")
	special_delayer.delayNext(delay,additive)

/mob/proc/delayNext(var/types, var/delay, var/additive=0)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/proc/delayNext() called tick#: [world.time]")
	if(types & DELAY_MOVE) delayNextMove(delay,additive)
	if(types & DELAY_ATTACK) delayNextAttack(delay,additive)
	if(types & DELAY_SPECIAL) delayNextSpecial(delay,additive)
