//May expand later, but right now it just repairs lights.
/obj/item/device/portalathe
	name = "\improper Portable Autolathe"
	desc = "It blinks and has an antenna on it.  It must be advanced."
	icon_state = "t-ray0"

	afterattack(var/atom/target, mob/user as mob)
		if(!target || !user)
			return
		if(!istype(target))
			return
		if(!istype(target, /obj/machinery/light))
			return
		var/obj/machinery/light/L = target
		if(L.status > 1) //Burned or broke
			L.status = 0
			L.update()
			user.visible_message("[user] repairs \the [target] on the spot with their [src]!","You repair the lightbulb!")
		return