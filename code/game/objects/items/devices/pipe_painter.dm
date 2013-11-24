/obj/item/device/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler1"
	item_state = "flight"
	var/list/modes = list("grey","red","blue","cyan","green","yellow","purple")
	var/mode = "grey"

/obj/item/device/pipe_painter/afterattack(atom/A, mob/user as mob)
	if(!istype(A,/obj/machinery/atmospherics/pipe) || istype(A,/obj/machinery/atmospherics/pipe/tank) || istype(A,/obj/machinery/atmospherics/pipe/vent) || istype(A,/obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(A,/obj/machinery/atmospherics/pipe/simple/insulated))
		return
	var/obj/machinery/atmospherics/pipe/P = A
	P._color = mode
	user.visible_message("<span class='notice'>[user] paints \the [P] [mode].</span>","<span class='notice'>You paint \the [P] [mode].</span>")
	P.update_icon()

/obj/item/device/pipe_painter/attack_self(mob/user as mob)
	mode = input("Which colour do you want to use?","Pipe painter") in modes

/obj/item/device/pipe_painter/examine()
	..()
	usr << "It is in [mode] mode."