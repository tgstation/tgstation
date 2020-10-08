#define DEBUG_NETWORKS

PROCESSING_SUBSYSTEM_DEF(networks)
	name = "Networks"
	priority = FIRE_PRIORITY_NETWORKS
	wait = 1
	stat_tag = "NET"
	flags = SS_KEEP_TIMING
	init_order = INIT_ORDER_NETWORKS

	var/datum/ntnet/station/station_network
	var/list/network_initialize_queue = list()

	var/list/interfaces_by_hardware_id = list()
	var/list/networks = list()
	// Used with map tags to look up hardware address

/datum/controller/subsystem/processing/stat_entry(msg)
	msg = "[stat_tag]:[length(processing)]"
	return ..()

/datum/controller/subsystem/processing/networks/Initialize()
	station_network = new
	return ..()


// verifies the network name has the right letters in it.  Might need to expand unwanted punctuations

/datum/controller/subsystem/processing/networks/proc/verify_network_name(name)
	return istext(name) && length(name) > 0 && findtext(name, @"[^\.][A-Z0-9_\.]+[^\.]") == 0

// Fixes a network name by replacing the spaces and making eveything uppercase
/datum/controller/subsystem/processing/networks/proc/_simple_network_name_fix(net_name)
	return replacetext(uppertext(net_name),"\[ -\]", "_")

/// Ok, so instead of goign though all the maps and making sure all the tags
/// are set up properly, we can use THIS to set a root id to an area so when the
/// atom loads it joins the right local network.  neat!
/datum/controller/subsystem/processing/networks/proc/lookup_root_id(area/A, datum/map_template/M=null)
	/// Alright boys, lets cycle though a few special cases
	if(M)
		if(M.station_id && M.station_id != NETWORK_LIMBO)
			return M.station_id // override due to template
		if(istype(M, /datum/map_template/shuttle))
			var/datum/map_template/shuttle/T = M	// we are a shuttle so use shuttle id
			return _simple_network_name_fix(T.shuttle_id)
		else if(istype(M,/datum/map_template/ruin))
			var/datum/map_template/ruin/R = M	// ruins have an id var?  why so many var names
			return _simple_network_name_fix(R.id)
	// ok so template overrides over
	if(A)
		if(SSmapping.level_trait(A.z, ZTRAIT_STATION))
			return STATION_NETWORK_ROOT
		else if(SSmapping.level_trait(A.z, ZTRAIT_CENTCOM))
			return CENTCOM_NETWORK_ROOT

	to_chat(world, "Limbo? Area '[A.name]' is going to limbo?")
	return NETWORK_LIMBO // shouldn't get here often...hopefully


/datum/controller/subsystem/processing/networks/fire(resumed = 0)
	// so life sucks.  Can't be in Initialize because Initialize is run async and we must start
	// when everything is built and working.
	if(SSmapping.initialized)
		station_network.register_map_supremecy()
	else
		to_chat(world, "Holly fuck those maps take a while to load")




// create a network name from a list containing the network tree
/datum/controller/subsystem/processing/networks/proc/network_list_to_string(list/tree)
	ASSERT(tree && tree.len > 0) // this should be obvious but JUST in case.
	for(var/part in tree)
		if(!istext(part))
			log_runtime("Cannot create network with [part]")
			return null // not a valid tree
		if(!verify_network_name(part) && findtext(name,".")==0) // and no stray dots
			log_runtime("Cannot create network with [part]")
			return null 	// name part wrong
	return tree.Join(".")

// create a network tree from a network string
/datum/controller/subsystem/processing/networks/proc/network_string_to_list(name)
#ifdef DEBUG_NETWORKS
	if(!verify_network_name(name))
		log_runtime("network_string_to_list: [name] IS INVALID")
#endif
	return splittext(name,".") // should we do a splittext_char?  I doubt we really need unicode in network names

// finds OR creates a network from a simple string like "SS13.ATMOS.AIRALRM", runtimes if error
/datum/controller/subsystem/processing/networks/proc/create_network_simple(network_id)
	var/datum/ntnet/network = networks[network_id]
	if(network)
		return network // don't worry about it	if(network_id in networks)

#ifdef DEBUG_NETWORKS
	if(!verify_network_name(network_id))
		to_chat(world, "create_network_simple: [network_id] IS INVALID")
		return null
#endif
	var/list/network_tree = network_string_to_list(network_id)
	ASSERT(network_tree.len > 0)
	var/network_name_part = ""
	var/datum/ntnet/parent = null
	var/start = FALSE
	for(var/i in 1 to network_tree.len)
		if(start)
			network_name_part += "."
		if(!network_tree[i])
			continue
		start = TRUE
		network_name_part += network_tree[i]

		network = networks[network_name_part]
		if(!network)
			network = new(network_name_part, parent)
		parent = network
	to_chat(world, "create_network_simple:  created final [network.network_id]")
	return network // and we are done!


// This will create OR find a network.  This is a heavy function as it can handle something like create_network("BASENETWORK", "ATMOS.AIRALARM", "AREA3")
// or even network tree lists (at a latter date).  you should use create_network_simple to check for networks that are already on
// a network_id but if your building from a raw user string use this
/datum/controller/subsystem/processing/networks/proc/create_network(...)
	var/list/network_tree = list()
	for(var/part in args)
#ifdef DEBUG_NETWORKS
		if(!part || !istext(part))
			log_runtime("create_network: We only take text")
			return null
#endif
		network_tree += network_string_to_list(part)
#ifdef DEBUG_NETWORKS
	var/network_id = network_tree.Join(".")
	to_chat(world, "Trying to create [network_id]")
	var/datum/ntnet/net = create_network_simple(network_id)
	if(!net)
		log_runtime("create_network: Network create Failed for [network_id]")
	if(net.network_id != network_id)
		log_runtime("create_network: huh? [network_id]")
	return net
#else
	return create_network_simple(network_tree.Join("."))
#endif


/// I think we should do this more like a routable ip address
/datum/controller/subsystem/processing/networks/proc/get_next_HID()
	do
		var/string = md5("[num2text(rand(HID_RESTRICTED_END, 999999999), 12)]")
		if(!string)
			log_runtime("Could not generagea m5 hash from address, problem with md5?")
			return		//errored
		. = "[copytext_char(string, 1, 9)]"		//16 ^ 8 possibilities I think.
	while(interfaces_by_hardware_id[.])


// debug networks.  Gives you a list of networks so you can look to see where eveything is
/client/proc/debug_networks()
	set category = "Debug"
	set name = "View Networks"
	//set src in world
	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!usr.client || !usr.client.holder)		//This is usr because admins can call the proc on other clients, even if they're not admins, to show them VVs.
		to_chat(usr, "<span class='danger'>You need to be an administrator to access this.</span>", confidential = TRUE)
		return

	var/datum/asset/asset_cache_datum = get_asset_datum(/datum/asset/simple/vv)
	asset_cache_datum.send(usr)


	var/title = ""
	var/hash

	var/no_icon = FALSE


	title = "Root Networks"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	var/sprite_text
	if(sprite)
		sprite_text = no_icon? "\[NO ICON\]" : "<img src='vv[hash].png'></td><td>"
	var/list/header = islist(D)? list("<b>/list</b>") : D.vv_get_header()

	var/list/root_networks_html = list()
	for(var/datum/ntnet/net in SSnetworks.networks)

	var/list/dropdownoptions
	if (islist)
		dropdownoptions = list(
			"---",
			"Add Item" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ADD),
			"Remove Nulls" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_NULLS),
			"Remove Dupes" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_ERASE_DUPES),
			"Set len" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SET_LENGTH),
			"Shuffle" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_LIST_SHUFFLE),
			"Show VV To Player" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_EXPOSE),
			"View References" = VV_HREF_TARGETREF_INTERNAL(refid, VV_HK_VIEW_REFERENCES),
			"---"
			)
		for(var/i in 1 to length(dropdownoptions))
			var/name = dropdownoptions[i]
			var/link = dropdownoptions[name]
			dropdownoptions[i] = "<option value[link? "='[link]'":""]>[name]</option>"
	else
		dropdownoptions = D.vv_get_dropdown()

	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V
	sleep(1)

	var/list/variable_html = list()
	if(islist)
		var/list/L = D
		for(var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && IS_VALID_ASSOC_KEY(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, L)
	else
		names = sortList(names)
		for(var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<head>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
		<title>[title]</title>
		<link rel="stylesheet" type="text/css" href="[SSassets.transport.get_asset_url("view_variables.css")]">
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if (c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			var last_filter = "";
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var vars_ol = document.getElementById("vars");

				if (filter === last_filter) {
					// An event triggered an update but nothing has changed.
					return;
				} else if (filter.indexOf(last_filter) === 0) {
					// The new filter starts with the old filter, fast path by removing only.
					var children = vars_ol.childNodes;
					for (var i = children.length - 1; i >= 0; --i) {
						try {
							var li = children\[i];
							if (li.innerText.toLowerCase().indexOf(filter) == -1) {
								vars_ol.removeChild(li);
							}
						} catch(err) {}
					}
				} else {
					// Remove everything and put back what matches.
					while (vars_ol.hasChildNodes()) {
						vars_ol.removeChild(vars_ol.lastChild);
					}

					for (var i = 0; i < complete_list.length; ++i) {
						try {
							var li = complete_list\[i];
							if (!filter || li.innerText.toLowerCase().indexOf(filter) != -1) {
								vars_ol.appendChild(li);
							}
						} catch(err) {}
					}
				}

				last_filter = filter;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);

			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				updateSearch();
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if (value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[header.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<span id='marked'>[marked_line]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='?_src_=vars;
datumrefresh=[refid];[HrefToken()]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()">
									<option value selected>Select option</option>
									[dropdownoptions.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
"}
	src << browse(html, "window=variables[refid];size=475x650")
