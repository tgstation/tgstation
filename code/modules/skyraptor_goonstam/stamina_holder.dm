/// Pulled verbatim from Daedalus Dock.
/datum/stamina_container
	///Daddy?
	var/mob/living/parent
	///The maximum amount of stamina this container has
	var/maximum = 0
	var/maximum_original = 0 //used by the UI
	///How much stamina we have right now
	var/current = 0
	///The amount of stamina gained per second
	var/regen_rate = 10
	var/regen_rate_original = 10 //used by the UI
	///The difference between current and maximum stamina
	var/loss = 0
	var/loss_as_percent = 0
	///Are we regenerating right now?
	var/is_regenerating = TRUE
	///Every tick, remove this much stamina
	var/decrement = 0

	// these are applied to the regen rate and capacity every update.  key your modifiers appropriately!
	var/list/capmods = list()
	var/list/regmods = list()
	var/list/warnings = list()
	// key-value pairs of buff/debuff names and descriptions.  put big changes in major for tooltip; click will show both bufflist and majorbufflist.  empty descriptions won't show.
	var/list/bufflist = list()
	var/list/majorbufflist = list()

/datum/stamina_container/New(parent, maximum = STAMINA_MAX, regen_rate = STAMINA_REGEN)
	src.parent = parent
	src.maximum = maximum
	src.maximum_original = maximum
	src.regen_rate = regen_rate
	src.regen_rate_original = regen_rate
	src.current = maximum

/datum/stamina_container/Destroy()
	parent?.stamina = null
	parent = null
	STOP_PROCESSING(SSstamina, src)
	return ..()

/datum/stamina_container/process(delta_time)
	maximum = maximum_original
	regen_rate = regen_rate_original

	for(var/key in capmods)
		maximum += capmods[key]
	for(var/key in regmods)
		regen_rate += regmods[key]

	if(delta_time && is_regenerating)
		current = min(current + (regen_rate*delta_time), maximum)
	if(delta_time && decrement)
		current = max(current + (decrement*delta_time), 0)
	loss = maximum - current
	loss_as_percent = loss ? (loss == maximum ? 0 : loss / maximum * 100) : 0

	if(datum_flags & DF_ISPROCESSING)
		if(delta_time && current == maximum)
			STOP_PROCESSING(SSstamina, src)
	else if(!(current == maximum))
		START_PROCESSING(SSstamina, src)

	parent.update_stamina()

///Pause stamina regeneration for some period of time. Does not support doing this from multiple sources at once because I do not do that and I will add it later if I want to.
/datum/stamina_container/proc/pause(time)
	is_regenerating = FALSE
	addtimer(CALLBACK(src, PROC_REF(resume)), time)

///Stops stamina regeneration entirely until manually resumed.
/datum/stamina_container/proc/stop()
	is_regenerating = FALSE

///Resume stamina processing
/datum/stamina_container/proc/resume()
	is_regenerating = TRUE

///Adjust stamina by an amount.
/datum/stamina_container/proc/adjust(amt as num, forced)
	if(!amt)
		return
	///Our parent might want to fuck with these numbers
	var/modify = parent.pre_stamina_change(amt, forced)
	current = round(clamp(current + modify, 0, maximum), DAMAGE_PRECISION)
	process()
