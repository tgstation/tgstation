#define MODE_ADDING 1
#define MODE_DELETING 2

/obj/item/device/assembly/light_tile_control
	name = "light tile remote"
	short_name = "LT remote"

	desc = "A device used to configure light floors from a distance."
	icon_state = "light_tiler"
	starting_materials = list(MAT_IRON = 1500, MAT_GLASS = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=2;programming=2"

	wires = WIRE_RECEIVE

	accessible_values = list(
		"Turn light floors on" = "set_state;number",\
		"Red color"   = "color_r;number;0;255",\
		"Green color" = "color_g;number;0;255",\
		"Blue color"  = "color_b;number;0;255"
	)

	var/list/connected_floors = list()

	var/work_mode = MODE_ADDING //If MODE_ADDING, attacking a light floor adds it to our list. If MODE_DELETING, it removes it instead.

	var/last_used = 0
	var/cooldown_max = 5 //Half a second

	var/color_r = 255
	var/color_g = 255
	var/color_b = 255

	var/set_state = 1 //1 - turn the light floors on, 0 - turn them off

	var/list/image/image_overlays = list() //This list stores "highlighter" images that show the user which floors are connected
	var/highlighting_connected_floors = 0

/obj/item/device/assembly/light_tile_control/activate()
	if(!..()) return 0

	change_floors()

/obj/item/device/assembly/light_tile_control/afterattack(atom/A, mob/user, proximity_flag)
	if(istype(A, /obj/item/stack/tile/light))
		to_chat(user, "<span class='notice'>\The [A] must be installed into the floor before it can be controlled by \the [src]!</span>")
		return

	var/turf/simulated/floor/T = A
	if(!istype(T)) return
	if(!istype(T.floor_tile, /obj/item/stack/tile/light))
		to_chat(user, "<span class='notice'>\The [src] is only compactible with light tiles.</span>")
		return

	if(work_mode == MODE_ADDING)
		if(connected_floors.Find(T))
			to_chat(user, "<span class='notice'>\The [T] is already in \the [src]'s memory.</span>")
			return

		add_turf_to_memory(T)
		to_chat(user, "<span class='info'>Connected \the [T] to \the [src]!</span>")
	else
		del_turf_from_memory(T)
		to_chat(user, "<span class='info'>Disconnected \the [T] from \the [src]!</span>")

/obj/item/device/assembly/light_tile_control/interact(mob/user)
	var/dat = ""

	dat += {"
	<tt>[src]</tt><BR><BR>
	<p>Connected to <b>[connected_floors.len]</b> floors</p>
	<p><a href='?src=\ref[src];show_connections=1'>Show connected floors for 10 seconds</a> | <a href='?src=\ref[src];toggle_mode=1'>Now [work_mode == MODE_ADDING ? "adding" : "removing"] floors</a> | <a href='?src=\ref[src];delete_all=1'>Remove all connections</a></p>
	<BR>
	<p><font color="[rgb(color_r,color_g,color_b)]">Selected color: <b>[color_r] | [color_g] | [color_b]</b></font></p>
	<p><a href='?src=\ref[src];change_color=1'>Change color</a> | <a href='?src=\ref[src];toggle_set_state=1'>Light floors will be turned <b>[set_state ? "ON" : "OFF"]</b></a></p>
	<BR>
	<p><a href='?src=\ref[src];apply=1'>Activate</a></p>
	<p><a href='?src=\ref[src];refresh=1'>Refresh</a></p>
	"}

	var/datum/browser/popup = new(user, "\ref[src]", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "\ref[src]")

/obj/item/device/assembly/light_tile_control/Topic(href, href_list)
	if(..()) return 1

	if(href_list["show_connections"]) //Highlight all connected floors for 10 seconds
		if(last_used + cooldown_max > world.time)
			to_chat(usr, "<span class='notice'>\The [src] is not responding.</span>")
			return

		var/mob/user = usr
		if(!user || !user.client) return

		for(var/turf/T in connected_floors)
			highlight_turf(T, user)

		highlighting_connected_floors = 1
		last_used = world.time + 9.5 SECONDS //Add 9.5 seconds to the cooldown for a total cd of 10 seconds

		spawn(10 SECONDS)
			highlighting_connected_floors = 0

			if(user.client)
				user.client.images -= image_overlays

			image_overlays = list()

	if(href_list["toggle_mode"])
		if(work_mode == MODE_ADDING)
			work_mode = MODE_DELETING
			to_chat(usr, "<span class='info'>When applied to light floors, \the [src] will now disconnect from them.</span>")
		else
			work_mode = MODE_ADDING
			to_chat(usr, "<span class='info'>When applied to light floors, \the [src] will now connect to them.</span>")

		if(usr)
			attack_self(usr)

	if(href_list["toggle_set_state"])
		set_state = !set_state

		if(set_state)
			to_chat(usr, "<span class='info'>Light floors will be turned on.</span>")
		else
			to_chat(usr, "<span class='info'>Light floors will be turned off.</span>")

		if(usr)
			attack_self(usr)

	if(href_list["delete_all"])
		to_chat(usr, "<span class='notice'>Disconnected [connected_floors.len] tiles from the network.</span>")

		connected_floors = list()

		if(usr)
			attack_self(usr)

	if(href_list["change_color"])
		var/new_color = input(usr, "Please select a new color for \the [src].", "[src]", rgb(color_r,color_g,color_b)) as color

		if(..())
			return

		color_r = hex2num(copytext(new_color, 2, 4))
		color_g = hex2num(copytext(new_color, 4, 6))
		color_b = hex2num(copytext(new_color, 6, 8))

		to_chat(usr, "<span class='info'>Changed color to [color_r];[color_g];[color_b]!</span>")

		if(usr)
			attack_self(usr)

	if(href_list["apply"])
		change_floors()

	if(href_list["refresh"])
		if(usr)
			attack_self(usr)

/obj/item/device/assembly/light_tile_control/proc/change_floors()
	if(last_used + cooldown_max > world.time)
		return

	var/turf/our_turf = get_turf(src)

	for(var/turf/simulated/floor/T in connected_floors)
		if(T.z != our_turf.z)
			connected_floors.Remove(T)
			continue

		var/obj/item/stack/tile/light/light_tile = T.floor_tile

		if(!istype(light_tile)) //Not a light tile
			connected_floors.Remove(T)
			continue

		light_tile.on = src.set_state

		light_tile.color_r = src.color_r
		light_tile.color_g = src.color_g
		light_tile.color_b = src.color_b

		T.update_icon()

/obj/item/device/assembly/light_tile_control/proc/add_turf_to_memory(turf/T)
	connected_floors.Add(T)

	if(usr && highlighting_connected_floors)
		highlight_turf(T, usr)

/obj/item/device/assembly/light_tile_control/proc/del_turf_from_memory(turf/T)
	if(!connected_floors.Remove(T)) return //Don't do the next part if the turf isn't in connected_floors

	if(usr && highlighting_connected_floors)
		for(var/image/I in image_overlays)
			if(I.loc == T)
				image_overlays -= I
				usr.client.images -= I

				break

/obj/item/device/assembly/light_tile_control/proc/highlight_turf(turf/T, mob/user)
	var/image/tmp_overlay = image('icons/turf/areas.dmi', T, "red", TURF_LAYER+0.01)

	image_overlays += tmp_overlay
	user.client.images += tmp_overlay

#undef MODE_ADDING
#undef MODE_DELETING