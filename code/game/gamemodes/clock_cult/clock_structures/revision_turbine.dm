//Revision Turbine: Increases max wisdom by 20. Regenerates one wisdom per five seconds.
/obj/structure/destructible/clockwork/revision_turbine
	name = "revision turbine"
	desc = "A metal plate clamped in place by three crystals. It sporadically emits a sound similar to a whisper."
	clockwork_desc = "A link to the ancient archives of the City of Cogs that constantly pores over ancient scripture. Increases maximum wisdom and slowly generates it."
	icon_state = "tinkerers_daemon"
	active_icon = "tinkerers_daemon"
	inactive_icon = "tinkerers_daemon"
	unanchored_icon = "tinkerers_daemon_unwrenched"
	construction_value = 20
	break_message = "<span class='warning'>The plate tumbles free as its structure comes apart!</span>"
	max_integrity = 100
	obj_integrity = 100
	debris = list(/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/small = 6, \
	/obj/item/clockwork/component/replicant_alloy/replication_plate = 1)
	var/wisdom_cycle = 0

/obj/structure/destructible/clockwork/revision_turbine/Initialize()
	..()
	GLOB.max_clockwork_wisdom += 20
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/revision_turbine/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	GLOB.max_clockwork_wisdom -= 20
	return ..()

/obj/structure/destructible/clockwork/revision_turbine/process()
	wisdom_cycle++
	if(wisdom_cycle >= revision_turbine_wisdom_regen)
		adjust_clockwork_wisdom(1)
		wisdom_cycle = 0
