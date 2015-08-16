/datum/rcd_schematic/decon
	name			= "Deconstruct"
	category		= "Construction"
	energy_cost		= 5

	var/can_r_wall	= 0

/datum/rcd_schematic/decon/attack(var/atom/A, var/mob/user)
	if(istype(A, /turf/simulated/wall))
		var/turf/simulated/wall/T = A
		if(istype(T, /turf/simulated/wall/r_wall) && !can_r_wall)
			return "it cannot deconstruct reinforced walls!"

		user << "Deconstructing \the [T]..."
		playsound(get_turf(master), 'sound/machines/click.ogg', 50, 1)

		if(do_after(user, T, 40))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(/turf/simulated/floor/plating)
			return 0

	else if(istype(A, /turf/simulated/floor))
		var/turf/simulated/floor/T = A
		user << "Deconstructing \the [T]..."
		if(do_after(user, T, 50))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
			T.ChangeTurf(get_base_turf(T.z))
			return 0

	else if(istype(A, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/D = A
		user << "Deconstructing \the [D]..."
		if(do_after(user, D, 50))
			if(master.get_energy(user) < energy_cost)
				return 1

			playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
			qdel(D)
			return 0

	return 1

/datum/rcd_schematic/con_floors
	name		= "Build floors"
	category	= "Construction"
	energy_cost	= 1

	flags		= RCD_GET_TURF

/datum/rcd_schematic/con_floors/attack(var/atom/A, var/mob/user)
	if(!(istype(A, /turf/space) && !istype(A, /turf/space/transit)))
		return "it can only create floors on space!"

	var/turf/space/S = A

	user << "Building floor..."
	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
	S.ChangeTurf(/turf/simulated/floor/plating/airless)
	return 0

/datum/rcd_schematic/con_walls
	name		= "Build walls"
	category	= "Construction"
	energy_cost	= 3

/datum/rcd_schematic/con_walls/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf/simulated/floor))
		return 1

	var/turf/simulated/floor/T = A
	user << "Building wall"
	playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
	if(do_after(user, A, 20))
		if(master.get_energy(user) < energy_cost)
			return 1

		playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)
		T.ChangeTurf(/turf/simulated/wall)
		return 0

	return 1

/datum/rcd_schematic/con_airlock
	name						= "Build airlock"
	category					= "Construction"
	energy_cost					= 3

	var/allow_access			= 1
	var/selected_name			= "Airlock"
	var/list/selected_access	= list()	//Selected access levels.
	var/one_access				= 0

	var/list/schematics			= list()
	var/datum/airlock_schematic/selected

/datum/rcd_schematic/con_airlock/no_access
	allow_access				= 0

/datum/rcd_schematic/con_airlock/New()
	. = ..()

	for(var/path in typesof(/datum/airlock_schematic))
		schematics += new path

	selected = schematics[1]

/datum/rcd_schematic/con_airlock/deselect()
	. = ..()
	selected = schematics[1]	//Reset the selection.

/datum/rcd_schematic/con_airlock/send_icons(var/client/client)
	for(var/datum/airlock_schematic/C in schematics)
		C.send_icon(client)

/datum/rcd_schematic/con_airlock/get_HTML()
	. = "<p>"
	for(var/i = 1 to schematics.len)
		var/datum/airlock_schematic/C = schematics[i]
		var/selected_text = ""
		if(selected == C)
			selected_text = " class='selected'"

		. += "<a href='?src=\ref[master.interface];set_selected=[i]' title='[sanitize(C.name)]'[selected_text]><img src='[C.img]'/></a>"

		if(!(i % 5))
			. += "<br/>"

	. += {"
		<!-- Name form -->
		<form action="?src=\ref[master.interface]" method="get">
			<input type="hidden" name="src" value="\ref[master.interface]"/> <!-- Here so the SRC href gets passed down -->
			<input type="text" name="new_name" value="[selected_name]"/>
			<input type="submit" name="act" value="Save Name"/>
		</form><br/>
	"}

	if(allow_access)
		. += {"
		<!-- Access list visibility toggler -->
		<script>
		$("#accessListShowButton").click(
			function toggleAccessList()
			{
				if($("#accessList").is(":hidden"))
				{
					$("#accessList").slideDown("fast");
					$("#accessListShowButton").html("Hide access controls");
				}
				else
				{
					$("#accessList").slideUp("fast");
					$("#accessListShowButton").html("Show access controls");
				}
			}
		);
		</script>

		<a id="accessListShowButton">Show access controls</a><br/>

		<!-- Access levels form. -->
		<form action="?src=\ref[master.interface]" method="get" id="accessList" style="display: none;">
			<input type="hidden" name="src" value="\ref[master.interface]"/> <!-- Here so the SRC href gets passed down -->
			<input type="submit" value="Save Access Settings"/><br/><br/>

			<!-- One access radio buttons -->
			Access requirement is set to: <br/>
		"}
		if(one_access)	//So we check the correct button by default
			. += {"
			<input type="radio" name="oneAccess" value="0"/>ALL
			<br/>
			<input type="radio" name="oneAccess" value="1" checked/>ONE
			"}

		else
			. += {"
			<input type="radio" name="oneAccess" value="0" checked/>ALL
			<br/>
			<input type="radio" name="oneAccess" value="1"/>ONE
			"}

		. += {"<br/>
		Access levels: <br/>
		"}

		//Access level selection comes here.
		for(var/access in get_all_accesses())
			var/access_name	= get_access_desc(access)
			if(!access_name)	//I noticed in testing there's a broken access level that shows up, this should filter it out.
				continue

			var/checked		= ""

			if(access in selected_access)
				checked		= " checked"
			. += {"
				<input type="checkbox" name="[access]"[checked]/> [access_name] <br/>
			"}

		. += "</form>"

	. += "</p>"

/datum/rcd_schematic/con_airlock/Topic(var/href, var/href_list)
	if(href_list["set_selected"])
		var/idx = Clamp(text2num(href_list["set_selected"]), 1, schematics.len)
		var/datum/airlock_schematic/C = schematics[idx]

		selected = C
		selected_name = C.name	//Reset the name.

		master.update_options_menu()
		return 1

	if(href_list["new_name"])
		selected_name = copytext(sanitize(href_list["new_name"]), 1, MAX_NAME_LEN)

		master.update_options_menu()
		return 1

	if(href_list["oneAccess"] && allow_access)
		one_access = text2num(href_list["oneAccess"])

		//Along with oneAccess, the hrefs for access levels get called, as such we process them here before we return 1
		selected_access.Cut()
		var/list/access_levels = get_all_accesses()

		for(var/href_key in href_list - list("oneAccess", "src"))	//This should loop through all the access levels that are on.
			var/access = text2num(href_key)
			if(!(access in access_levels))	//Only check valid access levels.
				continue

			selected_access |= access

		master.update_options_menu()
		return 1

/datum/rcd_schematic/con_airlock/attack(var/atom/A, var/mob/user)
	if(!istype(A, /turf))
		return 1

	if(locate(/obj/machinery/door/airlock) in A)
		return "there is already an airlock on this spot!"

	user << "Building airlock..."

	if(!do_after(user, A, 50))
		return 1

	if(master.get_energy(user) < energy_cost)
		return 1

	if(locate(/obj/machinery/door/airlock) in A)
		return "there is already an airlock on this spot!"

	playsound(get_turf(master), 'sound/items/Deconstruct.ogg', 50, 1)

	var/obj/machinery/door/airlock/D = new selected.airlock_type(A)
	if(capitalize(selected_name) == selected_name)	//The name inputted is capitalized, so we add \improper.
		D.name	= "\improper [selected_name]"
	else
		D.name		= selected_name

	if(allow_access)
		if(one_access)
			D.req_one_access = selected_access.Copy()
		else
			D.req_access = selected_access.Copy()

	D.autoclose	= 1

//Schematics for schematics, I know, but it's OOP!
/datum/airlock_schematic
	var/name			= "airlock"						//Name of the airlock for the tooltip.
	var/airlock_type	= /obj/machinery/door/airlock	//Type of the airlock.
	var/img				= "rcd_airlock.png"				//Icon to send to the client AND to use for the preview.
	var/icon			= 'icons/obj/doors/Doorint.dmi'	//Icon file to pull the icon from to send to the client.

/datum/airlock_schematic/proc/send_icon(var/client/client)
	client << browse_rsc(new /icon(icon, "door_closed"), img)

//ALL THE AIRLOCK TYPES.
/datum/airlock_schematic/engie
	name			= "\improper Engineering Airlock"
	airlock_type	= /obj/machinery/door/airlock/engineering
	img				= "rcd_airlock_eng.png"
	icon			= 'icons/obj/doors/Dooreng.dmi'

/datum/airlock_schematic/atmos
	name			= "\improper Atmospherics Airlock"
	airlock_type	= /obj/machinery/door/airlock/atmos
	img				= "rcd_airlock_atmos.png"
	icon			= 'icons/obj/doors/Dooratmo.dmi'

/datum/airlock_schematic/sec
	name			= "\improper Security Airlock"
	airlock_type	= /obj/machinery/door/airlock/security
	img				= "rcd_airlock_sec.png"
	icon			= 'icons/obj/doors/Doorsec.dmi'

/datum/airlock_schematic/command
	name			= "\improper Command Airlock"
	airlock_type	= /obj/machinery/door/airlock/command
	img				= "rcd_airlock_command.png"
	icon			= 'icons/obj/doors/Doorcom.dmi'

/datum/airlock_schematic/med
	name			= "\improper Medical Airlock"
	airlock_type	= /obj/machinery/door/airlock/medical
	img				= "rcd_airlock_med.png"
	icon			= 'icons/obj/doors/Doormed.dmi'

/datum/airlock_schematic/sci
	name			= "\improper Research Airlock"
	airlock_type	= /obj/machinery/door/airlock/research
	img				= "rcd_airlock_sci.png"
	icon			= 'icons/obj/doors/doorresearch.dmi'

/datum/airlock_schematic/mining
	name			= "\improper Mining Airlock"
	airlock_type	= /obj/machinery/door/airlock/mining
	img				= "rcd_airlock_mining.png"
	icon			= 'icons/obj/doors/Doormining.dmi'

/datum/airlock_schematic/maint
	name			= "\improper Maintenance Access"
	airlock_type	= /obj/machinery/door/airlock/maintenance
	img				= "rcd_airlock_maint.png"
	icon			= 'icons/obj/doors/Doormaint.dmi'

/datum/airlock_schematic/ext
	name			= "\improper External Airlock"
	airlock_type	= /obj/machinery/door/airlock/external
	img				= "rcd_airlock_ext.png"
	icon			= 'icons/obj/doors/Doorext.dmi'

/datum/airlock_schematic/high_sec
	name			= "\improper High-Tech Security Airlock"
	airlock_type	= /obj/machinery/door/airlock/highsecurity
	img				= "rcd_airlock_high-sec.png"
	icon			= 'icons/obj/doors/hightechsecurity.dmi'


/datum/airlock_schematic/glass
	name			= "\improper Glass Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass
	img				= "rcd_airlock_glass.png"
	icon			= 'icons/obj/doors/Doorglass.dmi'

/datum/airlock_schematic/glass_eng
	name			= "\improper Glass Engineering Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_engineering
	img				= "rcd_airlock_glass_eng.png"
	icon			= 'icons/obj/doors/Doorengglass.dmi'

/datum/airlock_schematic/glass_atmos
	name			= "\improper Glass Atmospherics Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_atmos
	img				= "rcd_airlock_glass_atmos.png"
	icon			= 'icons/obj/doors/Dooratmoglass.dmi'

/datum/airlock_schematic/glass_sec
	name			= "\improper Glass Security Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_security
	img				= "rcd_airlock_glass_sec.png"
	icon			= 'icons/obj/doors/Doorsecglass.dmi'

/datum/airlock_schematic/glass_command
	name			= "\improper Glass Command Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_command
	img				= "rcd_airlock_glass_com.png"
	icon			= 'icons/obj/doors/Doorcomglass.dmi'

/datum/airlock_schematic/glass_med
	name			= "\improper Glass Medical Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_medical
	img				= "rcd_airlock_glass_med.png"
	icon			= 'icons/obj/doors/doormedglass.dmi'

/datum/airlock_schematic/glass_sci
	name			= "\improper Glass Research Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_research
	img				= "rcd_airlock_glass_sci.png"
	icon			= 'icons/obj/doors/doorresearchglass.dmi'

/datum/airlock_schematic/glass_mining
	name			= "\improper Glass Mining Airlock"
	airlock_type	= /obj/machinery/door/airlock/glass_mining
	img				= "rcd_airlock_glass_mining.png"
	icon			= 'icons/obj/doors/Doorminingglass.dmi'
