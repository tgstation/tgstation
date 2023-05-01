/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	///The maximum amount of stamina this container has
	var/maximum = 0
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = 10
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Every tick, remove this much stamina
	var/decrement = 0
	///when we restart our stamina regen
	var/start_stamina_regen = 0

/datum/stamina_container/New(parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	src.parent = parent
	src.maximum = maximum
	src.regen_rate = regen_rate
	src.current = maximum

/datum/stamina_container/Destroy()
	parent?.stamina = null
	parent = null
	STOP_PROCESSING(SSstamina, src)
	return ..()

/datum/stamina_container/proc/update(seconds_per_tick)
	if(start_stamina_regen < world.time)
		return

	if(seconds_per_tick)
		current = min(current + (regen_rate*seconds_per_tick), maximum)
	if(seconds_per_tick && decrement)
		current = max(current + (-decrement*seconds_per_tick), 0)
	loss = maximum - current
	loss_as_percent = loss ? (loss == maximum ? 0 : loss / maximum * 100) : 0

	if(datum_flags & DF_ISPROCESSING)
		if(seconds_per_tick && current == maximum)
			STOP_PROCESSING(SSstamina, src)
	else if(!(current == maximum))
		START_PROCESSING(SSstamina, src)

	parent.on_stamina_update()

///Pause stamina regeneration for some period of time. Does not support doing this from multiple sources at once because I do not do that and I will add it later if I want to.
/datum/stamina_container/proc/pause(time)
	start_stamina_regen = world.time + time

///Adjust stamina by an amount.
/datum/stamina_container/proc/adjust(amt as num, forced)
	if(!amt)
		return
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	update()
	if((amt < 0))
		pause(STAMINA_REGEN_TIME)
