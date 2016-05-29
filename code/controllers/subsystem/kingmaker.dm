#define STRATEGY_TRAITORMODE "strategy_traitormode"
#define STRATEGY_PEACEFUL "stategy_peaceful"

var/datum/subsystem/kingmaker/SSkingmaker

/datum/subsystem/kingmaker
	name = "Kingmaker"
	priority = 0

	var/strategy

/datum/subsystem/kingmaker/New()
	NEW_SS_GLOBAL(SSkingmaker)

/datum/subsystem/kingmaker/Initialize(timeofday, zlevel)
	if(zlevel)
		return ..()
	strategy = STRATEGY_TRAITORMODE // maybe able to pick it later
	. = ..()

/datum/subsystem/kingmaker/stat_entry()
	..("Strategy:[strategy]")

/datum/subsystem/kingmaker/proc/coronate()
	switch(strategy)
		if(STRATEGY_TRAITORMODE)
			setup_traitormode()
		if(STRATEGY_PEACEFUL)
			setup_peaceful()

/datum/subsystem/kingmaker/proc/setup_traitormode()
	// TODO work out how the fuck the scaling coefficient actually works
	var/num_traitors = Clamp(number_ready(), 1, 3)

	var/pref_flag = ROLE_TRAITOR
	var/list/candidates = get_player_minds_for_role(pref_flag, 0)

	var/list/traitors = list()
	while(candidates.len && (traitors.len < num_traitors))
		var/datum/mind/mind = pop(candidates)
		var/datum/antag/traitor/D = new
		if(D.on_gain(mind))
			traitors += mind

/datum/subsystem/kingmaker/proc/setup_peaceful()
	// No one is made an antagonist in peaceful mode, we're all friends here.
	return
