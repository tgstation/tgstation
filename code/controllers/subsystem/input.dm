SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set

	///what mobs are currently queued to click an atom. ran through every tick before movement input is processed.
	///list of lists of the form: list(list(clicking mob, atom being clicked, location, click control, click parameters))
	var/list/queued_clicks = list()
	///running average of how many clicks inputted by a player the server processes every second. used for the subsystem stat entry
	var/clicks_per_second = 0
	///count of how many clicks onto atoms have elapsed before being cleared by fire(). used to average with clicks_per_second.
	var/current_clicks = 0
	///acts like clicks_per_second but only counts the clicks actually processed by SSinput itself while clicks_per_second counts all clicks
	var/delayed_clicks_per_second = 0
	///running average of how many movement iterations from player input the server processes every second. used for the subsystem stat entry
	var/movements_per_second = 0

	///if for whatever reason clicks arent being executed fast enough set this to TRUE and all clicks will immediately execute
	var/FOR_ADMINS_IF_CLICKS_BROKE_immediately_execute_all_clicks = FALSE

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	macro_set = list(
	"Any" = "\"KeyDown \[\[*\]\]\"",
	"Any+UP" = "\"KeyUp \[\[*\]\]\"",
	"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
	"Tab" = "\".winset \\\"input.focus=true?map.focus=true input.background-color=[COLOR_INPUT_DISABLED]:input.focus=true input.background-color=[COLOR_INPUT_ENABLED]\\\"\"",
	"Escape" = "Reset-Held-Keys",
	)

// Badmins just wanna have fun ♪
/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to clients.len)
		var/client/user = clients[i]
		user.set_macros()

///queue a click from usr onto clicked_atom with the given mouse handling arguments. only works if usr is the player mob clicking.
/datum/controller/subsystem/input/proc/queue_click_from_usr(atom/clicked_atom, atom/location, control, params)
	if(control != "mapwindow.map" || !ismob(usr) || QDELING(usr) || QDELETED(clicked_atom))
		return FALSE

	//high priority because clicks should be as low latency as possible, deferring to the beginning of the next SSinput run should rarely delay
	//a click by more than a few milliseconds, but since the MC almost always resumes after every other sleeping proc this isnt guaranteed
	if(!TICK_CHECK_HIGH_PRIORITY || FOR_ADMINS_IF_CLICKS_BROKE_immediately_execute_all_clicks)
		clicked_atom.Click(location, control, params)//this is why it works via usr and not a passed in mob arg. atom/Click() assumes usr is correct
		current_clicks++
		return TRUE

	queued_clicks += list(list(usr, clicked_atom, location, control, params))

/datum/controller/subsystem/input/fire()
	var/moves_this_run = 0
	var/deferred_clicks_this_run = 0 //acts like current_clicks but doesnt count clicks that dont get processed by SSinput

	for(var/list/queued_click_list as anything in queued_clicks)
		process_click(queued_click_list)//clicks process before movement because their latency is more noticeable by players
		current_clicks++
		deferred_clicks_this_run++

	queued_clicks.Cut() //is ran all the way through every run, no exceptions

	for(var/mob/user as anything in GLOB.keyloop_list)
		moves_this_run += user.focus?.keyLoop(user.client)

	clicks_per_second = MC_AVG_SECONDS(clicks_per_second, current_clicks, wait TICKS)
	delayed_clicks_per_second = MC_AVG_SECONDS(delayed_clicks_per_second, deferred_clicks_this_run, wait TICKS)
	movements_per_second = MC_AVG_SECONDS(movements_per_second, moves_this_run, wait TICKS)

	current_clicks = 0

///processes a single click from the given list. used just for waitfor = FALSE so sleeps dont delay the entire subsystem.
/datum/controller/subsystem/input/proc/process_click(list/queued_click_list)
	set waitfor = FALSE

	var/mob/clicking_player_mob = queued_click_list[CLICKING_MOB_INDEX]
	var/atom/clicked_atom = queued_click_list[CLICKED_ATOM_INDEX]

	var/atom/location = queued_click_list[CLICK_LOCATION_INDEX]
	var/control = queued_click_list[CLICK_CONTROL_INDEX]
	var/params = queued_click_list[CLICK_PARAMETERS_INDEX]

	if(QDELETED(clicking_player_mob) || QDELETED(clicked_atom))
		return

	var/original_usr = usr
	usr = clicking_player_mob //atom/Click() relies on usr

	clicked_atom.Click(location, control, params)

	usr = original_usr

/datum/controller/subsystem/input/stat_entry(msg)
	. = ..()
	. += "M/S:[round(movements_per_second,0.01)] | C/S:[round(clicks_per_second,0.01)]([round(delayed_clicks_per_second,0.01)])"

