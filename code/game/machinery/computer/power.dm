// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"
	density = 1
	anchored = 1
	use_power = 2
	idle_power_usage = 20
	active_power_usage = 80

	l_color = "#FF9933"

//fix for issue 521, by QualityVan.
//someone should really look into why circuits have a powernet var, it's several kinds of retarded.

/obj/machinery/power/monitor/New()
	..()
	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()


/obj/machinery/power/monitor/attack_ai(mob/user)
	src.add_hiddenprint(user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				getFromPool(/obj/item/weapon/shard, loc)
				var/obj/item/weapon/circuitboard/powermonitor/M = new /obj/item/weapon/circuitboard/powermonitor( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				del(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/powermonitor/M = new /obj/item/weapon/circuitboard/powermonitor( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				del(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/power/monitor/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=powcomp")
			return


	user.set_machine(src)
	var/t = "<TT><B>Power Monitoring</B><HR>"


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\power.dm:84: t += "<BR><HR><A href='?src=\ref[src];update=1'>Refresh</A>"
	t += {"<BR><HR><A href='?src=\ref[src];update=1'>Refresh</A>
		<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"}
	// END AUTOFIX
	if(!powernet)
		t += "\red No connection"
	else

		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\power.dm:97: t += "<PRE>Total power: [powernet.avail] W<BR>Total load:	[num2text(powernet.viewload,10)] W<BR>"
		t += {"<PRE>Total power: [powernet.avail] W<BR>Total load:	[num2text(powernet.viewload,10)] W<BR>
			<FONT SIZE=-1>"}
		// END AUTOFIX

		var/list/State = list("<font color=red> Off</font>",
								"<font color=red>AOff</font>",
								"<font color=green>  On</font>",
								"<font color=green> AOn</font>")
		var/list/chg   = list("Not charging",
								"Charging",
								"Fully charged")
		// Start of power report table
		// Table header
		t += {"<TABLE>
		       <TH><TR><B><TD>Area</TD><TD>Eqp.</TD><TD>Lgt.</TD><TD>Env.</TD><TD>Load</TD><TD>Cell</TD></B></TR></TH>"}
		if(L.len > 0)
			// Each entry
			for(var/obj/machinery/power/apc/A in L)
				t += {"<TR>
				<TD> [A.areaMaster        ]</TD>
				<TD> [State[A.equipment+1]]</TD>
				<TD> [State[A.lighting+1 ]]</TD>
				<TD> [State[A.environ+1  ]]</TD>
				<TD> [A.lastused_total    ]</TD>
				<TD>[A.cell ? "[round(A.cell.percent())]% [chg[A.charging+1]]" : "  N/C"] </TD>
				</TR>"}

		t += "</TABLE></FONT></PRE></TT>"
		// End of powa report

	user << browse(t, "window=powcomp;size=640x800")
	onclose(user, "powcomp")


/obj/machinery/power/monitor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=powcomp")
		usr.unset_machine()
		return
	if( href_list["update"] )
		src.updateDialog()
		return


/obj/machinery/power/monitor/power_change()

	if(!(stat & (BROKEN|NOPOWER)))
		SetLuminosity(2)
	else
		SetLuminosity(0)

	if(stat & BROKEN)
		icon_state = "broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER
