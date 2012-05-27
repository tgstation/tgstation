//May expand later, but right now it just repairs lights.
/obj/item/device/portalathe
	name = "portable autolathe"
	desc = "A device which can repair broken lights instantly. Must be advanced."
	icon = 'janitor.dmi'
	icon_state = "portalathe"

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
			L.on = 1
			L.update()
			user.visible_message("[user] repairs \the [target] on the spot with their [src]!","You repair the lightbulb!")
		return