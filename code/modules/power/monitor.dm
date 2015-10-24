#define POWER_MONITOR_HIST_SIZE 15

// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet
/obj/machinery/power/monitor
	name = "Power Monitoring Computer"
	desc = "It monitors power levels across the station."
	icon = 'icons/obj/computer.dmi'
	icon_state = "power"

	use_auto_lights = 1
	light_range_on = 3
	light_power_on = 1
	light_color = LIGHT_COLOR_YELLOW

	//computer stuff
	density = 1
	anchored = 1.0
	var/circuit = /obj/item/weapon/circuitboard/powermonitor
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	var/datum/html_interface/interface
	var/tmp/next_process = 0

	//Lists used for the charts.
	var/list/demand_hist[0]
	var/list/supply_hist[0]
	var/list/load_hist[0]

/obj/machinery/power/monitor/New()
	..()

	for(var/i = 1 to POWER_MONITOR_HIST_SIZE) //The chart doesn't like lists with null.
		demand_hist.Add(list(0))
		supply_hist.Add(list(0))
		load_hist.Add(list(0))

	var/head = {"
		<style type="text/css">
			span.area
			{
				display: block;
				white-space: nowrap;
				text-overflow: ellipsis;
				overflow: hidden;
				width: auto;
			}
		</style>
		<script src="Chart.js"></script>
		<script>var chartSize = [POWER_MONITOR_HIST_SIZE];</script>
		<script src="powerChart.js"></script>
	"}

	src.interface = new/datum/html_interface/nanotrasen(src, "Power Monitoring", 420, 600, head)

	var/obj/structure/cable/attached = null
	var/turf/T = loc
	if(isturf(T))
		attached = locate() in T
	if(attached)
		powernet = attached.get_powernet()
	html_machines += src

	init_ui()

/obj/machinery/power/monitor/proc/init_ui()
	var/dat = {"
		<div id="operatable">
			<canvas id="powerChart" style="width: 261px;"><!--261px is as much as possible.-->

			</canvas>
			<div id="legend" style="float: right;"></div>
			<table class="table" width="100%; table-layout: fixed;">
				<colgroup><col style="width: 180px;"/><col/></colgroup>
				<tr><td><strong>Total power:</strong></td><td id="totPower">X W</td></tr>
				<tr><td><strong>Total load:</strong></td><td id="totLoad">X W</td></tr>
				<tr><td><strong>Total demand:</strong></td><td id="totDemand">X W</td></tr>
			</table>

		<table class="table" width="100%; table-layout: fixed;">
			<colgroup><col/><col style="width: 60px;"/><col style="width: 60px;"/><col style="width: 60px;"/><col style="width: 80px;"/><col style="width: 80px;"/><col style="width: 20px;"/></colgroup>
			<thead><tr><th>Area</th><th>Eqp.</th><th>Lgt.</th><th>Env.</th><th align="right">Load</th><th align="right">Cell</th><th></th></tr></thead>
			<tbody id="APCTable">

			</tbody>
		</table>
		</div>
		<div id="n_operatable" style="display: none;">
			<span class="error">No connection.</span>
		</div>
	"}

	interface.updateContent("content", dat)

/obj/machinery/power/monitor/attack_ai(mob/user)
	. = attack_hand(user)

/obj/machinery/power/monitor/Destroy()
	..()
	html_machines -= src

	qdel(interface)
	interface = null

/obj/machinery/power/monitor/attack_hand(mob/user)
	. = ..()
	if(.)
		interface.hide(user)
		return

	interact(user)

//Needs to be overriden because else it will use the shitty set_machine().
/obj/machinery/power/monitor/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	return hclient.client.mob.html_mob_check(src.type)

/obj/machinery/power/monitor/interact(mob/user)
	var/delay = 0
	delay += send_asset(user.client, "Chart.js")
	delay += send_asset(user.client, "powerChart.js")

	spawn(delay) //To prevent Jscript issues with resource sending.
		interface.show(user)

		interface.executeJavaScript("makeChart()", user) //Making the chart in something like $("document").ready() won't work so I do it here

		for(var/i = 1 to POWER_MONITOR_HIST_SIZE)
			interface.callJavaScript("pushPowerData", list(demand_hist[i], supply_hist[i], load_hist[i]), user)

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
		if(do_after(user,src,20))
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

			qdel(src)
	else
		src.attack_hand(user)
	return

/obj/machinery/power/monitor/process()
	if(stat & (BROKEN|NOPOWER) || !powernet)
		interface.executeJavaScript("setDisabled()")
		return

	else
		interface.executeJavaScript("setEnabled()")

	demand_hist += load()
	supply_hist += avail()
	load_hist += powernet.viewload

	if(demand_hist.len > POWER_MONITOR_HIST_SIZE) //Should always be true but eh.
		demand_hist.Cut(1, 2)
		supply_hist.Cut(1, 2)
		load_hist.Cut(1,2)

	interface.callJavaScript("pushPowerData", list(load(), avail(), powernet.viewload))

	// src.next_process == 0 is in place to make it update the first time around, then wait until someone watches
	if ((!src.next_process || src.interface.isUsed()) && world.time >= src.next_process)
		src.next_process = world.time + 30

		interface.updateContent("totPower", "[avail()] W")
		interface.updateContent("totLoad", "[num2text(powernet.viewload,10)] W")
		interface.updateContent("totDemand", "[load()] W")

		var/tbl = list()

		var/list/S = list(" <span class='bad'>Off","<span class='bad'>AOff","  <span class='good'>On", " <span class='good'>AOn")
		var/list/chg = list(" <span class='bad'>N","<span class='average'>C","<span class='good'>F")

		for(var/obj/machinery/power/terminal/term in powernet.nodes)
			if(istype(term.master, /obj/machinery/power/apc))


				var/obj/machinery/power/apc/A = term.master
				tbl += "<tr>"
				tbl += "<td><span class=\"area\">["\The [A.areaMaster]"]</span></td>"
				tbl += "<td>[S[A.equipment+1]]</span></td><td>[S[A.lighting+1]]</span></td><td>[S[A.environ+1]]</span></td>"
				tbl += "<td align=\"right\">[A.lastused_total]</td>"
				if(A.cell)
					var/class = "good"

					switch(A.cell.percent())
						if(49 to 15)
							class = "average"
						if(15 to -INFINITY)
							class = "bad"

					tbl += "<td align='right' class='[class]'>[round(A.cell.percent())]%</td><td align='right'>[chg[A.charging+1]]</span>"
				else
					tbl += "<td colspan='2' align='right'>N/C</td>"
				tbl += "</tr>"

		tbl = list2text(tbl)
		src.interface.updateContent("APCTable", tbl)

#undef POWER_MONITOR_HIST_SIZE