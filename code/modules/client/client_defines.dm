
/client
		//////////////////////
		//BLACK MAGIC THINGS//
		//////////////////////
	parent_type = /datum/client_base
	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = CONTROL_FREAK_ALL

	preload_rsc = PRELOAD_RSC

/datum/client_base/vv_edit_var(var_name, var_value)
	var/static/list/banned_client_base_edits = list("ckey", "key", "computer_id", "byond_version", "address", "mob", "gender", "connection")
	return !(var_name in banned_client_base_edits) && ..()

/datum/client_base
	//sumfuk in voodoo shit right here
	//tl;dr real clients will populate these fields for us
	//READONLY
	var/ckey
	var/key
	var/computer_id
	var/byond_version
	var/address
	var/connection
	var/gender
	var/inactivity
	var/mob/mob

	//writable
	var/color
	var/view
	var/dir
	var/pixel_x
	var/pixel_y
	var/pixel_z
	var/show_popup_menus
	var/list/verbs
	var/list/images
	var/list/screen
	var/atom/eye
	//end voodoo

		////////////////
		//ADMIN THINGS//
		////////////////
	var/datum/admins/holder = null
	var/datum/click_intercept = null // Needs to implement InterceptClickOn(user,params,atom) proc
	var/AI_Interact		= 0

	var/jobbancache = null //Used to cache this client's jobbans to save on DB queries
	var/last_message	= "" //Contains the last message sent by this client - used to protect against copy-paste spamming.
	var/last_message_count = 0 //contins a number of how many times a message identical to last_message was sent.
	var/ircreplyamount = 0

		/////////
		//OTHER//
		/////////
	var/datum/preferences/prefs = null
	var/move_delay		= 1
	var/moving			= null

	var/area			= null

		///////////////
		//SOUND STUFF//
		///////////////
	var/ambience_playing= null
	var/played			= 0
		////////////
		//SECURITY//
		////////////

		////////////////////////////////////
		//things that require the database//
		////////////////////////////////////
	var/player_age = -1	//Used to determine how old the account is - in days.
	var/player_join_date = null //Date that this account was first seen in the server
	var/related_accounts_ip = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_cid = "Requires database"	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/account_join_date = null	//Date of byond account creation in ISO 8601 format
	var/account_age = -1	//Age of byond account in days

	var/obj/screen/click_catcher/void

	// Used by html_interface module.
	var/hi_last_pos

	var/ip_intel = "Disabled"

	//datum that controls the displaying and hiding of tooltips
	var/datum/tooltip/tooltips

	var/lastping = 0
	var/avgping = 0
	var/connection_time //world.time they connected
	var/connection_realtime //world.realtime they connected
	var/connection_timeofday //world.timeofday they connected

	var/inprefs = FALSE
	var/list/topiclimiter

	var/datum/chatOutput/chatOutput

	var/list/credits //lazy list of all credit object bound to this client
	
	//ASSET CACHE

	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

	//AUTOCLICK

	var/list/atom/selected_target[2]
	var/obj/item/active_mousedown_item = null
	var/mouseParams = ""
	var/mouseLocation = null
	var/mouseObject = null
	var/mouseControlObject = null

	//ADMIN HELP

	var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
	var/datum/admin_help/current_ticket	//the current ticket the (usually) not-admin client is dealing with

	//PARALLAX

	var/list/parallax_layers
	var/list/parallax_layers_cached
	var/atom/movable/movingmob
	var/turf/previous_turf
	var/dont_animate_parallax //world.time of when we can state animate()ing parallax again
	var/last_parallax_shift //world.time of last update
	var/parallax_throttle = 0 //ds between updates
	var/parallax_movedir = 0
	var/parallax_layers_max = 3
	var/parallax_animate_timer