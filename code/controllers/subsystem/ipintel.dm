SUBSYSTEM_DEF(ipintel)
	name = "XKeyScore"
	init_order = INIT_ORDER_XKEYSCORE
	flags = SS_NO_FIRE
	var/enabled = ZERO //disable at round start to avoid checking reconnects
	var/throttle = ZERO
	var/errors = ZERO

	var/list/cache = list()

/datum/controller/subsystem/ipintel/Initialize(timeofday, zlevel)
	enabled = 1
	. = ..()

