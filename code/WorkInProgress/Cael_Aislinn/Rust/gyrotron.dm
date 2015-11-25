/obj/machinery/rust/gyrotron
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "emitter-off"
	name = "gyrotron"
	anchored = 0
	state = 0
	density = 1
	layer = 4
	machine_flags = MULTITOOL_MENU | WRENCHMOVE | WELD_FIXED | FIXED2WORK

	var/frequency = 1
	var/emitting = 0
	var/rate = 10
	var/mega_energy = 0.001
	var/id_tag

	req_access = list(access_engine)

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100000 //Yes that is a shitton. No you're not running this engine on an SE/AME you SE/AME scrubs.

/obj/machinery/rust/gyrotron/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

	. = ..()

/obj/machinery/rust/gyrotron/New()
	. = ..()

	if(ticker)
		initialize()

/obj/machinery/rust/gyrotron/proc/stop_emitting()
	emitting = 0
	use_power = 1
	update_icon()

/obj/machinery/rust/gyrotron/proc/start_emitting()
	if(stat & (NOPOWER | BROKEN) || emitting && state == 2) //Sanity.
		return

	emitting = 1
	use_power = 2

	update_icon()

	spawn()
		while(emitting)
			emit()
			sleep(rate)

/obj/machinery/rust/gyrotron/proc/emit()
	var/obj/item/projectile/beam/emitter/A = getFromPool(/obj/item/projectile/beam/emitter, loc)
	A.frequency = frequency
	A.damage = mega_energy * 1500

	playsound(get_turf(src), 'sound/weapons/emitter.ogg', 25, 1)
	use_power(100 * mega_energy + 500)

	A.dir = dir
	A.dumbfire()

	flick("emitter-active", src)

/obj/machinery/rust/gyrotron/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li>[format_tag("ID Tag","id_tag")]</li>
		</ul>
	"}

/obj/machinery/rust/gyrotron/power_change()
	. =..()
	if(stat & (NOPOWER | BROKEN))
		stop_emitting()

	update_icon()

/obj/machinery/rust/gyrotron/update_icon()
	if(!(stat & (NOPOWER | BROKEN)) && emitting)
		icon_state = "emitter-on"
	else
		icon_state = "emitter-off"

/obj/machinery/rust/gyrotron/weldToFloor(var/obj/item/weapon/weldingtool/WT, var/mob/user)
	if(emitting)
		to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
		return -1
	. = ..()

/obj/machinery/rust/gyrotron/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set src in oview(1)
	set category = "Object"

	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting || !Adjacent(usr))
		return

	if(anchored)
		to_chat(usr, "<span class='notify'>\the [src] is anchored to the floor!</span>")
		return

	dir = turn(dir, -90)

/obj/machinery/rust/gyrotron/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set src in oview(1)
	set category = "Object"

	if(usr.restrained() || usr.stat || usr.weakened || usr.stunned || usr.paralysis || usr.resting || !Adjacent(usr))
		return

	if(anchored)
		to_chat(usr, "<span class='notify'>\the [src] is anchored to the floor!</span>")
		return

	dir = turn(dir, 90)
