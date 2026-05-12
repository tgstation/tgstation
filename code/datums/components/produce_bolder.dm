/datum/component/boulder_producer
	var/next_boulder_time = 0
	var/production_interval = 30 SECONDS
	var/boulder_type = /obj/item/stack/ore/glass/basalt
	var/boulder_amount = 1
	var/require_owner = FALSE
	var/production_message = "Boulder appears!"

/datum/component/boulder_producer/Initialize(
	interval = 30 SECONDS,
	boulder_path = /obj/item/stack/ore/glass/basalt,
	amount = 1,
	needs_owner = FALSE,
	message = "Boulder appears!"
)
	production_interval = interval
	boulder_type = boulder_path
	boulder_amount = amount
	require_owner = needs_owner
	production_message = message
	START_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/boulder_producer/process(seconds_per_tick)
	if(world.time < next_boulder_time)
		return
	if(require_owner)
		var/atom/movable/AM = parent
		if(!AM.loc || !isliving(AM.loc))
			return

	var/atom/A = parent
	var/turf/T = get_turf(A)
	if(T)
		var/obj/item/stack/ore/boulder = new boulder_type(T)
		boulder.amount = boulder_amount
		if(production_message)
			A.visible_message(span_notice("[production_message]"))
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)

	next_boulder_time = world.time + production_interval
