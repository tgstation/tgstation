/obj/machinery/computer/area_atmos
	name = "Area Air Control"
	desc = "A computer used to control the stationary scrubbers and pumps in the area."
	icon_state = "area_atmos"
	circuit = "/obj/item/weapon/circuitboard/area_atmos"

	var/list/connectedscrubbers = new()
	var/status = ""

	var/range = 25

	//Simple variable to prevent me from doing attack_hand in both this and the child computer
	var/zone = "This computer is working on a wireless range, the range is currently limited to 25 meters."

	New()
		..()
		//So the scrubbers have time to spawn
		spawn(10)
			scanscrubbers()

	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)

	attack_paw(var/mob/user as mob)
		return

	attack_hand(var/mob/user as mob)
		if(..(user))
			return
		src.add_fingerprint(usr)
		var/dat = {"
		<html>
			<head>
				<style type="text/css">
					a.green:link
					{
						color:#00CC00;
					}
					a.green:visited
					{
						color:#00CC00;
					}
					a.green:hover
					{
						color:#00CC00;
					}
					a.green:active
					{
						color:#00CC00;
					}
					a.red:link
					{
						color:#FF0000;
					}
					a.red:visited
					{
						color:#FF0000;
					}
					a.red:hover
					{
						color:#FF0000;
					}
					a.red:active
					{
						color:#FF0000;
					}
				</style>
			</head>
			<body>
				<center><h1>Area Air Control</h1></center>
				<font color="red">[status]</font><br>
				<a href="?src=\ref[src];scan=1">Scan</a>
				<table border="1" width="90%">"}
		for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in connectedscrubbers)
			dat += {"
					<tr>
						<td>[scrubber.name]</td>
						<td width="150"><a class="green" href="?src=\ref[src];scrub=\ref[scrubber];toggle=1">Turn On</a> <a class="red" href="?src=\ref[src];scrub=\ref[scrubber];toggle=0">Turn Off</a></td>
					</tr>"}

		dat += {"
				</table><br>
				<i>[zone]</i>
			</body>
		</html>"}
		user << browse("[dat]", "window=miningshuttle;size=400x400")
		status = ""

	Topic(href, href_list)
		if(..())
			return
		usr.set_machine(src)
		src.add_fingerprint(usr)


		if(href_list["scan"])
			scanscrubbers()
		else if(href_list["toggle"])
			var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber = locate(href_list["scrub"])

			if(!validscrubber(scrubber))
				spawn(20)
					status = "ERROR: Couldn't connect to scrubber! (timeout)"
					connectedscrubbers -= scrubber
					src.updateUsrDialog()
				return

			scrubber.on = text2num(href_list["toggle"])
			scrubber.update_icon()

	proc/validscrubber( var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber as obj )
		if(!isobj(scrubber) || get_dist(scrubber.loc, src.loc) > src.range || scrubber.loc.z != src.loc.z)
			return 0

		return 1

	proc/scanscrubbers()
		connectedscrubbers = new()

		var/found = 0
		for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in range(range, src.loc))
			if(istype(scrubber))
				found = 1
				connectedscrubbers += scrubber

		if(!found)
			status = "ERROR: No scrubber found!"

		src.updateUsrDialog()


/obj/machinery/computer/area_atmos/area
	zone = "This computer is working in a wired network limited to this area."

	validscrubber( var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber as obj )
		if(!isobj(scrubber))
			return 0

		/*
		wow this is stupid, someone help me
		*/
		var/turf/T_src = get_turf(src)
		if(!T_src.loc) return 0
		var/area/A_src = T_src.loc
		if (A_src.master)
			A_src = A_src.master

		var/turf/T_scrub = get_turf(scrubber)
		if(!T_scrub.loc) return 0
		var/area/A_scrub = T_scrub.loc
		if (A_scrub.master)
			A_scrub = A_scrub.master

		if(A_scrub != A_src)
			return 0

		return 1

	scanscrubbers()
		connectedscrubbers = new()

		var/found = 0

		var/turf/T = get_turf(src)
		if(!T.loc) return
		var/area/A = T.loc
		if (A.master)
			A = A.master
		for(var/obj/machinery/portable_atmospherics/scrubber/huge/scrubber in world )
			var/turf/T2 = get_turf(scrubber)
			if(T2 && T2.loc)
				var/area/A2 = T2.loc
				if(istype(A2) && A2.master && A2.master == A )
					connectedscrubbers += scrubber
					found = 1


		if(!found)
			status = "ERROR: No scrubber found!"

		src.updateUsrDialog()