/*
 * A camera console, or at least, an attempt at it. I'm trying to figure all
 * this out as I go along, as I have no experience in TGUI. 
 *
 * Heavily referenced from the Supermatter Monitoring program, as that also had
 * the 'list all -> details of one' format I was going for.
 */

// Begin screen-number defines.
#define SCREEN_HOME 0		//home screen
#define SCREEN_LIST 1		//camera list
#define SCREEN_INFO 2		//camera details
#define SCREEN_VIEW 3		//viewing feed
#define SCREEN_LOST 4		//feed disconnected (moved, cam cut, etc)
#define SCREEN_ERROR 5		//system error with ramclear button
#define SCREEN_WIPE 6		//system error mid-ramclear
#define SCREEN_CFG 7		//help and settings
#define SCREEN_REFR 8		//refreshing camera feed
//end screen number defines

//begin variable-specific defines
#define NOT_WATCHING 0				//we are not watching a camera
#define WATCHING 1					//we are watching a camera
#define WANT_TO_STOP_WATCHING 2		//we want to stop watching a camera
//end variable-specific defines


/datum/computer_file/program/camera_monitor
	filename = "cameramonitor"
	transfer_access = ACCESS_SECURITY	//security equipment locker access
	filedesc = "Camera Monitor"
	extended_desc = "A camera monitor for use with modular consoles, for the Warden on the move! Not compatible with tablet compuer hardware."	//Disclaimer: This statement does not endorse the Warden leaving the brig.
	program_icon_state = "cameras"		//huh, it exists
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_SYSTEMCONTROL
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	network_destination = "camera monitoring"
	available_on_ntnet = 1
	available_on_syndinet = 0
	size = 10
	tgui_id = "ntos_cameras"
	ui_x = 600
	ui_y = 400
	ui_header = "camera.gif"
	var/screen_number = SCREEN_HOME
	
	var/current_user		//used in break_watch() as a fallback
	
	//camera lists
	var/list/camera_list = list()		//basic list
	var/list/fiveoh = list()			//detailed list
	
	var/number_of_cameras = 0
	
	var/obj/machinery/camera/sel				//currently selected camera
	var/watching = NOT_WATCHING					//are we watching a camera?

	//what network do we want to filter?
	var/list/desired_networks = list("ss13","mine")			//default: main station cameras, and mining

	
	//used in motion checks.
	var/orig_x
	var/orig_y
	var/orig_z
	
	var/crash_reason = "null"		//used in system-error debugging code. yes i am aware that is a string that says 'null'.
	

/datum/computer_file/program/camera_monitor/run_program(mob/living/user)
	. = ..(user)
	screen_number = SCREEN_REFR
	generate_camera_list()
	watching = NOT_WATCHING
	sleep(10)		//intended to reduce bottlenecking from rapid-fire page loads
	screen_number = SCREEN_HOME

/datum/computer_file/program/camera_monitor/kill_program(forced = FALSE)
	sel = null					//reset the selected camera
	camera_list = null			//clear the camera list
	break_watch(usr, intentional = TRUE)		//kick the user off the camera, if they're on one
	..()

/datum/computer_file/program/camera_monitor/proc/force_error()					//debug proc, not called elsewhere
	var/debug_text = "Manually initiated crash"
	camera_error(usr, debug_text)

/datum/computer_file/program/camera_monitor/proc/generate_camera_list()
	camera_list = list()		//clear the list to avoid duplicates
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	fiveoh = list()
	

	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)		//create a basic list of eligible cameras first
		if ((is_station_level(C.z) || is_mining_level(C.z)) && C.c_tag)
			var/list/network_overlap = desired_networks & C.network
			if(network_overlap.len)			//if the desired networks and the camera's networks have at least one matching entry, add it
				camera_list.Add(C)

	camera_list = camera_sort(camera_list)						//sort eligible camera list
	
	for (var/obj/machinery/camera/C in camera_list)				//use sorted list to generate a detailed list
		var/area/A = get_area(C)
		if(A)
			fiveoh.Add(list(list(
			"camera_name" = C.c_tag,			//camera tag (E.g. "Bridge #1")
			"camera_status" = C.can_use(),		//Camera status (true == active)
			"camera_network" = C.network		//List of networks the camera is on
			)))
	
	if(!(sel in camera_list))
		sel = null
	
	number_of_cameras = camera_list.len

/datum/computer_file/program/camera_monitor/proc/set_desired_network(mob/living/user)		//set the user's desired network
	var/input = stripped_input(user, "Which network(s) would you like to filter? Separate networks with a comma (NO SPACES).\nFor example: 'SS13,Mine,Secret' will show cameras that are on any of the SS13, Mining or Secret networks.", "Set Network", "SS13")	//someone's going to nitpick about the lack of oxford comma here, i just know it.
	if(screen_number != SCREEN_CFG)		//Did the user not realise the window was open?
		return FALSE
	if(!input)
		to_chat(user, "<span class='warning'>The laptop flashes a message: \"No input found, cancelling.\"</span>")
		return FALSE
	var/list/tempnetwork = splittext(input, ",")
	if(tempnetwork.len < 1)
		to_chat(user, "<span class='warning'>The laptop flashes a message: \"No input found, cancelling.\"</span>")
		return FALSE
	for(var/i in tempnetwork)
		tempnetwork -= i
		tempnetwork += lowertext(i)
	
	//set our desired networks to whatever the user put in
	desired_networks = tempnetwork
	
	//RRRRRRRRRRRRRRELOAD!
	//... What, no Time Crisis fans here? Fine, reload the camera list.
	screen_number = SCREEN_REFR
	generate_camera_list()
	sleep(10)		//intended to reduce bottlenecking from rapid-fire page loads
	screen_number = SCREEN_CFG

/datum/computer_file/program/camera_monitor/proc/start_watch(mob/living/user, target_camera)
	current_user = user
	var/obj/machinery/camera/C = target_camera
	
	if(watching == WANT_TO_STOP_WATCHING)
		watching = NOT_WATCHING
		return TRUE
	
	if(C)
		var/camera_fail = FALSE
		if(!C.can_use() || user.eye_blind || user.incapacitated() || !in_range(computer, user))		//camera deactivated, user blinded, user incapacitated, user walked away
			camera_fail = TRUE
		
		if(camera_fail)
			break_watch(usr)
			return FALSE
			
		if((computer.loc.x != orig_x) || (computer.loc.y != orig_y) || (computer.loc.z != orig_z))		//if the laptop moved, kill the feed
			watching = WANT_TO_STOP_WATCHING
			break_watch(usr)

		if((screen_number != SCREEN_VIEW) && (screen_number != SCREEN_LOST))		//Something went wrong...
			camera_error(usr,"Viewing camera outside 'viewing camera' screen")

		if(watching == NOT_WATCHING)
			watching = WATCHING
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			user.clear_fullscreen("flash", 5)
		
		addtimer(CALLBACK(src, .proc/start_watch, user, sel), 5)		//check the above twice a second
	else
		break_watch()

/datum/computer_file/program/camera_monitor/proc/break_watch(mob/living/user, intentional)
	if(isnull(user))				//checks to suppress runtiming while using consoles/laptops on tables, etc.
		if(isnull(current_user))
			user = usr		
		else
			user = current_user

	user.reset_perspective(null)
	if(!intentional)				//the user did not initiate the disconnect, so show the disconnect notif.
		screen_number = SCREEN_LOST
	
/datum/computer_file/program/camera_monitor/proc/camera_error(mob/living/user, reason)
	crash_reason = reason
	screen_number = SCREEN_ERROR
	watching = WANT_TO_STOP_WATCHING
	stack_trace("Fatal error in mobile camera system: \"[reason]\". User: [user]. Location: ([user.x], [user.y], [user.z]).")		//log it
	break_watch(usr, intentional = TRUE)		//also called in ramclear screen

/datum/computer_file/program/camera_monitor/ui_data()
	var/list/data = get_header_data()
	
	if(istype(sel))		//only if we have a selected camera - avoid runtimes, etc
		data["active"] = sel.can_use()
		data["location_x"] = sel.x
		data["location_y"] = sel.y
		data["location_z"] = sel.z		//there's gotta be a better way to do this - used to display a camera's coords
		data["networks"] = sel.network
		data["name"] = sel.c_tag
		data["area"] = get_area(sel)
		data["ref"] = REF(sel)			//unused
	data["screen"] = screen_number
	data["cameras"] = fiveoh
	data["number_of_cameras"] = number_of_cameras
	data["network_setting"] = desired_networks
	data["debug_message"] = crash_reason		//system-error screen debugging

	return data

/datum/computer_file/program/camera_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("PRG_home")			//Home button
			if(watching == WATCHING)					//exit the callback loop
				watching = WANT_TO_STOP_WATCHING
			break_watch(usr, intentional = TRUE)
			sel = null
			screen_number = SCREEN_HOME
			return TRUE
		if("PRG_F5")			//Refresh camera list
			var/last_screen = screen_number
			screen_number = SCREEN_REFR
			generate_camera_list()
			sleep(10)			//reduce botlenecking due to rapid page loads
			screen_number = last_screen
			return TRUE
		if("PRG_list")			//List cameras
			if(watching == WATCHING)
				watching = WANT_TO_STOP_WATCHING
			break_watch(usr, intentional = TRUE)
			sel = null
			screen_number = SCREEN_LIST
			return TRUE
		if("PRG_details")			//Camera details
			var/new_ctag = params["target"]
			for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
				if(C.c_tag == new_ctag)
					sel = C
			
			if(isnull(sel))
				camera_error(reason = "Selected camera is null")
			screen_number = SCREEN_INFO
			return TRUE
		if("PRG_viewfeed")			//View camera feed
			orig_x = computer.loc.x
			orig_y = computer.loc.y
			orig_z = computer.loc.z
			screen_number = SCREEN_VIEW
			start_watch(usr, target_camera = sel)
			return TRUE
		if("PRG_ramclear")				//An error has occurred. Wipe volatile data.
			screen_number = SCREEN_WIPE
			orig_x = null
			orig_y = null
			orig_z = null
			sel = null
			desired_networks = list("ss13","mine")
			break_watch(usr, intentional = TRUE)		//redundancy
			if(fiveoh)
				fiveoh = list()
			camera_list = list()
			sleep(10)
			screen_number = SCREEN_HOME
			return TRUE
		if("PRG_settings")			//Settings menu
			screen_number = SCREEN_CFG
			return TRUE
		if("PRG_setnet")			//Set desired network
			set_desired_network(usr)
			generate_camera_list()





//Syndicate version: No restrictions, larger size
/datum/computer_file/program/camera_monitor/pirated
	filename = "cameramonitor_x64_NoCD_TEAM_SYDEWYNDER"		//is this authentic enough?
	transfer_access = null
	filedesc = "NTNet Camera Monitor - TEAM SYDEWYNDER"
	extended_desc = "TEAM SYDEWYNDER PROUDLY PRESENTS: Here is the working version of the NTNet Camera Monitoring Console! Provided for you by TEAM SYDEWYNDER, free of access restrictions, as a big FUCK YOU! to Nanotrasen! Incompatible with tablet hardware."			//seriously, is this authentic enough?
	available_on_ntnet = 0
	available_on_syndinet = 1
	size = 18			//have fun downloading THAT on your stock NIC!
