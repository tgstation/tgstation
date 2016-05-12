var/datum/subsystem/ipintel/SSipintel

/datum/subsystem/ipintel
	name = "IP Intel"
	priority = -3
	var/enabled = 0 //disable at round start to avoid checking reconnects
	var/throttle = 0
	var/errors = 0

	var/list/cache = list()

/datum/subsystem/ipintel/New()
	NEW_SS_GLOBAL(SSipintel)

/datum/subsystem/ipintel/Initialize(timeofday, zlevel)
	enabled = 1
	. = ..()

