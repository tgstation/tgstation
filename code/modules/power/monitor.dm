// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"

	//computer stuff
	density = 1
	anchored = 1.0
	var/circuit = /obj/item/weapon/circuitboard/powermonitor
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	var/datum/html_interface/interface
	var/tmp/last_time_processed = 0

/obj/machinery/power/monitor/New()
	..()

	var/const/head = "<style type=\"text/css\">span.area { display: block; white-space: nowrap; text-overflow: ellipsis; overflow: hidden; width: auto; }</style>\
	           <script type=\"text/javascript\">function checkSize(){ $(\"span.area\").css(\"width\", \"auto\");\
	           if ($(window).width() < window.document.body.scrollWidth){ var width = 0; $(\"span.area\").each(function(){ width = Math.max(width, $(this).parent().outerWidth()); });\
	           width = Math.round($(window).width() - (window.document.body.scrollWidth - width + 16 + 8));$(\"span.area\").css(\"width\", width + \"px\"); } }\
	           $(window).on(\"resize\", checkSize); $(window).on(\"onUpdateContent\", checkSize); $(document).on(\"ready\", checkSize);</script>"
	src.interface = new/datum/html_interface/nanotrasen(src, "Power Monitoring", 420, 600, head)

	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()

/obj/machinery/power/monitor/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			src.interface.hide(user)
			return


	user.set_machine(src)
	src.interface.show(user)

/obj/machinery/power/monitor/power_change()
	..()
	if(stat & BROKEN)
		icon_state = "broken"
	else
		if (stat & NOPOWER)
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
		else
			icon_state = initial(icon_state)

//copied from computer.dm
/obj/machinery/power/monitor/attackby(I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/screwdriver) && circuit)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/weapon/circuitboard/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for (var/obj/C in src)
				C.loc = src.loc
			if (src.stat & BROKEN)
				user.show_message("<span class=\"info\">The broken glass falls out.</span>")
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				user.show_message("<span class=\"info\">You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"

			del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/power/monitor/process()
	if(stat & (BROKEN|NOPOWER))
		return
	// src.last_time_processed == 0 is in place to make it update the first time around, then wait until someone watches
	if ((src.last_time_processed == 0 || src.interface.isUsed()) && world.time - src.last_time_processed > 30)
		src.last_time_processed = world.time
		var/t
	//	t += "<BR><HR><A href='?src=\ref[src.interface];update=1'>Refresh</A>"
	//	t += "<BR><HR><A href='?src=\ref[src.interface];close=1'>Close</A>"

		if(!powernet)
			t += "<span class=\"error\">No connection.</span>"
		else

			t = t + "<table class=\"table\" width=\"100%; table-layout: fixed;\">"
			t = t + "<colgroup><col style=\"width: 180px;\"/><col/></colgroup>"
			t = t + "<tr><td><strong>Total power:</strong></td><td>[powernet.avail] W</td></tr>"
			t = t + "<tr><td><strong>Total load:</strong></td><td>[num2text(powernet.viewload,10)] W</td></tr>"

			var/tbl
			var/total_demand = 0

			var/list/S = list(" Off","AOff","  On", " AOn")
			var/list/chg = list("N","C","F")
			var/found = FALSE

			for(var/obj/machinery/power/terminal/term in powernet.nodes)
				if(istype(term.master, /obj/machinery/power/apc))
					found = TRUE

					var/obj/machinery/power/apc/A = term.master
					tbl = tbl + "<tr>"
					tbl = tbl + "<td><span class=\"area\">["\The [A.areaMaster]"]</span></td>"
					tbl = tbl + "<td>[S[A.equipment+1]]</td><td>[S[A.lighting+1]]</td><td>[S[A.environ+1]]</td>"
					tbl = tbl + "<td align=\"right\">[A.lastused_total]</td>"
					tbl = tbl + "[A.cell ? "<td align=\"right\">[round(A.cell.percent())]%</td><td align=\"right\">[chg[A.charging+1]]" : "<td colspan=\"2\" align=\"right\">N/C</td>"]"
					tbl = tbl + "</tr>"
					total_demand = total_demand + A.lastused_total

			if (found)
				t += "<tr><td><strong>Total demand:</strong></td><td>[total_demand] W</td></tr>"

			t = t + "</table>"

			t = t + "<table class=\"table\" width=\"100%; table-layout: fixed;\">"
			t = t + "<colgroup><col /><col style=\"width: 60px;\"/><col style=\"width: 60px;\"/><col style=\"width: 60px;\"/><col style=\"width: 80px;\"/><col style=\"width: 80px;\"/><col style=\"width: 20px;\"/></colgroup>"
			t = t + "<thead><tr><th>Area</th><th>Eqp.</th><th>Lgt.</th><th>Env.</th><th align=\"right\">Load</th><th align=\"right\">Cell</th><th></th></tr></thead>"
			t = t + "<tbody>[tbl]</tbody></table>"

		src.interface.updateContent("content", t)