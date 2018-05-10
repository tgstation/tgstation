/*
 * A camera console, or at least, an attempt at it. I'm trying to figure all
 * this out as I go along, as I have no experience in TGUI. 
 *
 * Heavily referenced from the Supermatter Monitoring program, as that also had
 * the 'list all -> details of one' format I was going for.
 *
 * TODO TODO TODO
 * - Make users able to filter only certain cameras (e.g. engineering)
 */

// Begin screen-number defines.
#define SCREEN_HOME 0
#define SCREEN_LIST 1
#define SCREEN_INFO 2
#define SCREEN_VIEW 3
#define SCREEN_LOST 4
#define SCREEN_ERROR 5
#define SCREEN_WIPE 6
//end screen number defines

//begin variable-specific defines
#define NOT_WATCHING 0				//we are not watching a camera
#define WATCHING 1					//we are watching a camera
#define WANT_TO_STOP_WATCHING 2		//we want to stop watching a camera


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
	ui_header = "alarm_green.gif"		//PLACEHOLDER
	var/screen_number = SCREEN_HOME		//debugging stuff
	
	var/current_user		//used in break_watch() as a fallback
	
	//camera lists
	var/list/camera_list	//basic list
	var/list/fiveoh			//detailed list
	
	var/obj/machinery/camera/sel			//currently selected camera
	var/watching = NOT_WATCHING					//are we watching a camera?

	
	//used in motion checks.
	var/orig_x
	var/orig_y
	var/orig_z
	

/datum/computer_file/program/camera_monitor/run_program(mob/living/user)
	. = ..(user)
	generate_camera_list()
	watching = NOT_WATCHING
	screen_number = SCREEN_HOME

/datum/computer_file/program/camera_monitor/kill_program(forced = FALSE)
	sel = null
	camera_list = null
	break_watch(usr, intentional = TRUE)
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
	
	for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)		//generate a list of cameras on station or mining Z level
		if ((is_station_level(C.z) || is_mining_level(C.z)))
			camera_list.Add(C)

	camera_list = camera_sort(camera_list)						//sort eligible camera list
	
	for (var/obj/machinery/camera/C in camera_list)				//use sorted list to generate a list of camera details
		var/area/A = get_area(C)
		if(A)
			fiveoh.Add(list(list(
			"camera_name" = C.c_tag,
			"camera_status" = C.can_use(),
			"camera_ref" = REF(C)								//unused, but retained for debug purposes
			)))
	
	if(!(sel in camera_list))
		sel = null

/datum/computer_file/program/camera_monitor/proc/start_watch(mob/living/user, target_camera)
	current_user = user
	var/obj/machinery/camera/C = target_camera
	
	if(watching == WANT_TO_STOP_WATCHING)
		watching = NOT_WATCHING
		return TRUE
	
	if(C)
		var/camera_fail = FALSE
		if(!C.can_use() || user.eye_blind || user.incapacitated() || !in_range(computer, user))
			camera_fail = TRUE
		
		if(camera_fail)
			break_watch(usr)
			return FALSE
			
		if((computer.loc.x != orig_x) || (computer.loc.y != orig_y) || (computer.loc.z != orig_z))
			watching = WANT_TO_STOP_WATCHING
			break_watch(usr)

		if((screen_number != SCREEN_VIEW) && (screen_number != SCREEN_LOST))		//Something went wrong...
			camera_error(usr,"Viewing camera outside 'viewing camera' screen")

		if(watching == NOT_WATCHING)
			watching = WATCHING
			user.reset_perspective(C)
			user.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
			user.clear_fullscreen("flash", 5)
		
		addtimer(CALLBACK(src, .proc/start_watch, user, sel), 5)
	else
		break_watch()

/datum/computer_file/program/camera_monitor/proc/break_watch(mob/living/user, intentional)
	if(isnull(user))		//checks to suppress runtiming while using consoles/laptops on tables, etc.
		if(isnull(current_user))
			user = usr		
		else
			user = current_user

	user.reset_perspective(null)
	if(!intentional)		//the user did not disconnect, so show the disconnect notif.
		screen_number = SCREEN_LOST
	
/datum/computer_file/program/camera_monitor/proc/camera_error(mob/living/user, reason)
	screen_number = SCREEN_ERROR
	watching = WANT_TO_STOP_WATCHING
	stack_trace("Fatal error in mobile camera system: \"[reason]\". User: [user]. Location: ([user.x], [user.y], [user.z]).")
	break_watch(usr, intentional = TRUE)		//also called in ramclear screen

/datum/computer_file/program/camera_monitor/ui_data()
	var/list/data = get_header_data()
	
	if(istype(sel))		//only if we have a selected camera - avoid runtimes, etc
		data["active"] = sel.can_use()
		data["location_x"] = sel.x
		data["location_y"] = sel.y
		data["location_z"] = sel.z		//there's gotta be a better way to do that.
		data["networks"] = sel.network
		data["name"] = sel.c_tag
		data["area"] = get_area(sel)
		data["ref"] = REF(sel)
	data["screen"] = screen_number
	data["cameras"] = fiveoh

	return data

/datum/computer_file/program/camera_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("PRG_home")
			if(watching == WATCHING)			//exit the callback loop
				watching = WANT_TO_STOP_WATCHING
			break_watch(usr, intentional = TRUE)
			sel = null
			screen_number = SCREEN_HOME
			return TRUE
		if("PRG_F5")
			generate_camera_list()
			return TRUE
		if("PRG_list")
			sel = null
			screen_number = SCREEN_LIST
		if("PRG_details")
			var/new_ctag = params["target"]
			for (var/obj/machinery/camera/C in GLOB.cameranet.cameras)
				if(C.c_tag == new_ctag)
					sel = C
			
			if(isnull(sel))
				camera_error(reason = "Selected camera is null")
			screen_number = SCREEN_INFO
			return TRUE
		if("PRG_viewfeed")
			orig_x = computer.loc.x
			orig_y = computer.loc.y
			orig_z = computer.loc.z
			screen_number = SCREEN_VIEW
			start_watch(usr, target_camera = sel)
			return TRUE
		if("PRG_ramclear")			//An error has occurred. Wipe volatile data.
			screen_number = SCREEN_WIPE
			orig_x = null
			orig_y = null
			orig_z = null
			sel = null
			break_watch(usr, intentional = TRUE)		//redundancy
			if(fiveoh)
				fiveoh = list()
			camera_list = list()
			sleep(10)
			screen_number = SCREEN_HOME


//Syndicate version: No restrictions, larger size
/datum/computer_file/program/camera_monitor/pirated
	filename = "cameramonitor_x64_NoCD_TEAM_SYDEWYNDER"		//is this authentic enough?
	transfer_access = null
	filedesc = "NTNet Camera Monitor - TEAM SYDEWYNDER"
	extended_desc = "TEAM SYDEWYNDER PROUDLY PRESENTS: Here is the working version of the NTNet Camera Monitoring Console! Provided for you by TEAM SYDEWYNDER, free of access restrictions, as a big FUCK YOU! to Nanotrasen! Incompatible with tablet hardware."			//seriously, is this authentic enough?
	available_on_ntnet = 0
	available_on_syndinet = 1
	size = 18			//have fun downloading THAT on your stock NIC!