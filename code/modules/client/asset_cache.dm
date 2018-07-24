/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//When passively preloading assets, how many to send at once? Too high creates noticable lag where as too low can flood the client's cache with "verify" files
#define ASSET_CACHE_PRELOAD_CONCURRENT 3

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(SSassets.cache[asset_name], asset_name)
	if(!verify)
		client.cache += asset_name
		return 1

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	for(var/asset in unreceived)
		if (asset in SSassets.cache)
			client << browse_rsc(SSassets.cache[asset], asset)

	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += unreceived
		return 1

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	var/concurrent_tracker = 1
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file, files[file])
		if (concurrent_tracker >= ASSET_CACHE_PRELOAD_CONCURRENT)
			concurrent_tracker = 1
			send_asset(client, file)
		else
			concurrent_tracker++
			send_asset(client, file, verify=FALSE)

		stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSassets.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(var/file)
	return "asset.[md5(fcopy_rsc(file))]"


//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
GLOBAL_LIST_EMPTY(asset_datums)

//get an assetdatum or make a new one
/proc/get_asset_datum(var/type)
	return GLOB.asset_datums[type] || new type()

/datum/asset
	var/_abstract = /datum/asset

/datum/asset/New()
	GLOB.asset_datums[type] = src
	register()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return


//If you don't need anything complicated.
/datum/asset/simple
	_abstract = /datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


// For registering or sending multiple others at once
/datum/asset/group
	_abstract = /datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		A.send(C)


// spritesheet implementation - coalesces various icons into a single .png file
// and uses CSS to select icons out of that file - saves on transferring some
// 1400-odd individual PNG files
#define SPR_SIZE 1
#define SPR_IDX 2
#define SPRSZ_COUNT 1
#define SPRSZ_ICON 2
#define SPRSZ_STRIPPED 3

/datum/asset/spritesheet
	_abstract = /datum/asset/spritesheet
	var/name
	var/list/sizes = list()    // "32x32" -> list(10, icon/normal, icon/stripped)
	var/list/sprites = list()  // "foo_bar" -> list("32x32", 5)
	var/verify = FALSE

/datum/asset/spritesheet/register()
	if (!name)
		CRASH("spritesheet [type] cannot register without a name")
	ensure_stripped()

	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	text2file(generate_css(), fname)
	register_asset(res_name, file(fname))

	for(var/size_id in sizes)
		var/size = sizes[size_id]
		register_asset("[name]_[size_id].png", size[SPRSZ_STRIPPED])

/datum/asset/spritesheet/send(client/C)
	if (!name)
		return
	var/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	send_asset_list(C, all, verify)

/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if (size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		var/error = rustg_dmi_strip_metadata(fname)
		if(length(error))
			stack_trace("Failed to strip [name]_[size_id].png: [error]")
		size[SPRSZ_STRIPPED] = icon(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background:url('[name]_[size_id].png') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/icon/tiny = size[SPRSZ_ICON]
		var/icon/big = size[SPRSZ_STRIPPED]
		var/per_line = big.Width() / tiny.Width()
		var/x = (idx % per_line) * tiny.Width()
		var/y = round(idx / per_line) * tiny.Height()

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/datum/asset/spritesheet/proc/Insert(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	I = icon(I, icon_state=icon_state, dir=dir, frame=frame, moving=moving)
	if (!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		size[SPRSZ_STRIPPED] = null
		sheet.Insert(I, icon_state=sprite_name)
		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

/datum/asset/spritesheet/proc/InsertAll(prefix, icon/I, list/directions)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]-" : ""
			Insert("[prefix][prefix2][icon_state_name]", I, icon_state=icon_state_name, dir=direction)

/datum/asset/spritesheet/proc/css_tag()
	return {"<link rel="stylesheet" href="spritesheet_[name].css" />"}

/datum/asset/spritesheet/proc/icon_tag(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"<span class="[name][size_id] [sprite_name]"></span>"}

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED


/datum/asset/spritesheet/simple
	_abstract = /datum/asset/spritesheet/simple
	var/list/assets

/datum/asset/spritesheet/simple/register()
	for (var/key in assets)
		Insert(key, assets[key])
	..()

//Generates assets based on iconstates of a single icon
/datum/asset/simple/icon_states
	_abstract = /datum/asset/simple/icon_states
	var/icon
	var/list/directions = list(SOUTH)
	var/frame = 1
	var/movement_states = FALSE

	var/prefix = "default" //asset_name = "[prefix].[icon_state_name].png"
	var/generic_icon_names = FALSE //generate icon filenames using generate_asset_name() instead the above format

	verify = FALSE

/datum/asset/simple/icon_states/register(_icon = icon)
	for(var/icon_state_name in icon_states(_icon))
		for(var/direction in directions)
			var/asset = icon(_icon, icon_state_name, direction, frame, movement_states)
			if (!asset)
				continue
			asset = fcopy_rsc(asset) //dedupe
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]." : ""
			var/asset_name = sanitize_filename("[prefix].[prefix2][icon_state_name].png")
			if (generic_icon_names)
				asset_name = "[generate_asset_name(asset)].png"

			register_asset(asset_name, asset)

/datum/asset/simple/icon_states/multiple_icons
	_abstract = /datum/asset/simple/icon_states/multiple_icons
	var/list/icons

/datum/asset/simple/icon_states/multiple_icons/register()
	for(var/i in icons)
		..(i)


//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/tgui
	assets = list(
		"tgui.css"	= 'tgui/assets/tgui.css',
		"tgui.js"	= 'tgui/assets/tgui.js',
		"font-awesome.min.css" = 'tgui/assets/font-awesome.min.css',
		"fontawesome-webfont.eot" = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.woff2" = 'tgui/assets/fonts/fontawesome-webfont.woff2',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"fontawesome-webfont.ttf" = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.svg" = 'tgui/assets/fonts/fontawesome-webfont.svg'
	)

/datum/asset/simple/headers
	assets = list(
		"alarm_green.gif" 			= 'icons/program_icons/alarm_green.gif',
		"alarm_red.gif" 			= 'icons/program_icons/alarm_red.gif',
		"batt_5.gif" 				= 'icons/program_icons/batt_5.gif',
		"batt_20.gif" 				= 'icons/program_icons/batt_20.gif',
		"batt_40.gif" 				= 'icons/program_icons/batt_40.gif',
		"batt_60.gif" 				= 'icons/program_icons/batt_60.gif',
		"batt_80.gif" 				= 'icons/program_icons/batt_80.gif',
		"batt_100.gif" 				= 'icons/program_icons/batt_100.gif',
		"charging.gif" 				= 'icons/program_icons/charging.gif',
		"downloader_finished.gif" 	= 'icons/program_icons/downloader_finished.gif',
		"downloader_running.gif" 	= 'icons/program_icons/downloader_running.gif',
		"ntnrc_idle.gif"			= 'icons/program_icons/ntnrc_idle.gif',
		"ntnrc_new.gif"				= 'icons/program_icons/ntnrc_new.gif',
		"power_norm.gif"			= 'icons/program_icons/power_norm.gif',
		"power_warn.gif"			= 'icons/program_icons/power_warn.gif',
		"sig_high.gif" 				= 'icons/program_icons/sig_high.gif',
		"sig_low.gif" 				= 'icons/program_icons/sig_low.gif',
		"sig_lan.gif" 				= 'icons/program_icons/sig_lan.gif',
		"sig_none.gif" 				= 'icons/program_icons/sig_none.gif',
		"smmon_0.gif" 				= 'icons/program_icons/smmon_0.gif',
		"smmon_1.gif" 				= 'icons/program_icons/smmon_1.gif',
		"smmon_2.gif" 				= 'icons/program_icons/smmon_2.gif',
		"smmon_3.gif" 				= 'icons/program_icons/smmon_3.gif',
		"smmon_4.gif" 				= 'icons/program_icons/smmon_4.gif',
		"smmon_5.gif" 				= 'icons/program_icons/smmon_5.gif',
		"smmon_6.gif" 				= 'icons/program_icons/smmon_6.gif'
	)

/datum/asset/spritesheet/simple/pda
	name = "pda"
	assets = list(
		"atmos"			= 'icons/pda_icons/pda_atmos.png',
		"back"			= 'icons/pda_icons/pda_back.png',
		"bell"			= 'icons/pda_icons/pda_bell.png',
		"blank"			= 'icons/pda_icons/pda_blank.png',
		"boom"			= 'icons/pda_icons/pda_boom.png',
		"bucket"		= 'icons/pda_icons/pda_bucket.png',
		"medbot"		= 'icons/pda_icons/pda_medbot.png',
		"floorbot"		= 'icons/pda_icons/pda_floorbot.png',
		"cleanbot"		= 'icons/pda_icons/pda_cleanbot.png',
		"crate"			= 'icons/pda_icons/pda_crate.png',
		"cuffs"			= 'icons/pda_icons/pda_cuffs.png',
		"eject"			= 'icons/pda_icons/pda_eject.png',
		"flashlight"	= 'icons/pda_icons/pda_flashlight.png',
		"honk"			= 'icons/pda_icons/pda_honk.png',
		"mail"			= 'icons/pda_icons/pda_mail.png',
		"medical"		= 'icons/pda_icons/pda_medical.png',
		"menu"			= 'icons/pda_icons/pda_menu.png',
		"mule"			= 'icons/pda_icons/pda_mule.png',
		"notes"			= 'icons/pda_icons/pda_notes.png',
		"power"			= 'icons/pda_icons/pda_power.png',
		"rdoor"			= 'icons/pda_icons/pda_rdoor.png',
		"reagent"		= 'icons/pda_icons/pda_reagent.png',
		"refresh"		= 'icons/pda_icons/pda_refresh.png',
		"scanner"		= 'icons/pda_icons/pda_scanner.png',
		"signaler"		= 'icons/pda_icons/pda_signaler.png',
		"status"		= 'icons/pda_icons/pda_status.png',
		"dronephone"	= 'icons/pda_icons/pda_dronephone.png'
	)

/datum/asset/spritesheet/simple/paper
	name = "paper"
	assets = list(
		"stamp-clown" = 'icons/stamp_icons/large_stamp-clown.png',
		"stamp-deny" = 'icons/stamp_icons/large_stamp-deny.png',
		"stamp-ok" = 'icons/stamp_icons/large_stamp-ok.png',
		"stamp-hop" = 'icons/stamp_icons/large_stamp-hop.png',
		"stamp-cmo" = 'icons/stamp_icons/large_stamp-cmo.png',
		"stamp-ce" = 'icons/stamp_icons/large_stamp-ce.png',
		"stamp-hos" = 'icons/stamp_icons/large_stamp-hos.png',
		"stamp-rd" = 'icons/stamp_icons/large_stamp-rd.png',
		"stamp-cap" = 'icons/stamp_icons/large_stamp-cap.png',
		"stamp-qm" = 'icons/stamp_icons/large_stamp-qm.png',
		"stamp-law" = 'icons/stamp_icons/large_stamp-law.png'
	)

/datum/asset/simple/IRV
	assets = list(
		"jquery-ui.custom-core-widgit-mouse-sortable-min.js" = 'html/IRV/jquery-ui.custom-core-widgit-mouse-sortable-min.js',
	)

/datum/asset/group/IRV
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/IRV
	)

/datum/asset/simple/changelog
	assets = list(
		"88x31.png" = 'html/88x31.png',
		"bug-minus.png" = 'html/bug-minus.png',
		"cross-circle.png" = 'html/cross-circle.png',
		"hard-hat-exclamation.png" = 'html/hard-hat-exclamation.png',
		"image-minus.png" = 'html/image-minus.png',
		"image-plus.png" = 'html/image-plus.png',
		"music-minus.png" = 'html/music-minus.png',
		"music-plus.png" = 'html/music-plus.png',
		"tick-circle.png" = 'html/tick-circle.png',
		"wrench-screwdriver.png" = 'html/wrench-screwdriver.png',
		"spell-check.png" = 'html/spell-check.png',
		"burn-exclamation.png" = 'html/burn-exclamation.png',
		"chevron.png" = 'html/chevron.png',
		"chevron-expand.png" = 'html/chevron-expand.png',
		"scales.png" = 'html/scales.png',
		"coding.png" = 'html/coding.png',
		"ban.png" = 'html/ban.png',
		"chrome-wrench.png" = 'html/chrome-wrench.png',
		"changelog.css" = 'html/changelog.css'
	)

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/spritesheet/goonchat
	)

/datum/asset/simple/jquery
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"errorHandler.js"          = 'code/modules/goonchat/browserassets/js/errorHandler.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot"  = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'tgui/assets/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"font-awesome.css"	       = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
	)

/datum/asset/spritesheet/goonchat
	name = "chat"

/datum/asset/spritesheet/goonchat/register()
	InsertAll("emoji", 'icons/emoji.dmi')

	// pre-loading all lanugage icons also helps to avoid meta
	InsertAll("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/path in typesof(/datum/language))
		var/datum/language/L = path
		var/icon = initial(L.icon)
		if (icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			Insert("language-[icon_state]", icon, icon_state=icon_state)

	..()

/datum/asset/simple/permissions
	assets = list(
		"padlock.png"	= 'html/padlock.png'
	)

//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in typesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()

/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/register()
	for (var/each in list('icons/obj/atmospherics/pipes/pipe_item.dmi', 'icons/obj/atmospherics/pipes/disposal.dmi', 'icons/obj/atmospherics/pipes/transit_tube.dmi'))
		InsertAll("", each, GLOB.alldirs)
	..()

// Representative icons for each research design
/datum/asset/spritesheet/research_designs
	name = "design"

/datum/asset/spritesheet/research_designs/register()
	for (var/path in subtypesof(/datum/design))
		var/datum/design/D = path

		// construct the icon and slap it into the resource cache
		var/atom/item = initial(D.build_path)
		if (!ispath(item, /atom))
			// biogenerator outputs to beakers by default
			if (initial(D.build_type) & BIOGENERATOR)
				item = /obj/item/reagent_containers/glass/beaker/large
			else
				continue  // shouldn't happen, but just in case

		// circuit boards become their resulting machines or computers
		if (ispath(item, /obj/item/circuitboard))
			var/obj/item/circuitboard/C = item
			var/machine = initial(C.build_path)
			if (machine)
				item = machine
		var/icon_file = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		if (!(icon_state in icon_states(icon_file)))
			warning("design [D] with icon '[icon_file]' missing state '[icon_state]'")
			continue
		var/icon/I = icon(icon_file, icon_state, SOUTH)

		// computers (and snowflakes) get their screen and keyboard sprites
		if (ispath(item, /obj/machinery/computer) || ispath(item, /obj/machinery/power/solar_control))
			var/obj/machinery/computer/C = item
			var/screen = initial(C.icon_screen)
			var/keyboard = initial(C.icon_keyboard)
			var/all_states = icon_states(icon_file)
			if (screen && (screen in all_states))
				I.Blend(icon(icon_file, screen, SOUTH), ICON_OVERLAY)
			if (keyboard && (keyboard in all_states))
				I.Blend(icon(icon_file, keyboard, SOUTH), ICON_OVERLAY)

		Insert(initial(D.id), I)
	return ..()
