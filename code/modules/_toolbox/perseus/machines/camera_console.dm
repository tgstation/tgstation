/obj/machinery/computer/camera_advanced/perseus
	name = "Perseus Observation Console"
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "perccamera"
	var/alternatedesc = "All you see are strange green numbers falling down the screen from top to bottom like rain."

/obj/machinery/computer/camera_advanced/perseus/New()
	var/image/I = new(src)
	I.loc = src
	I.icon = 'icons/oldschool/perseus.dmi'
	I.icon_state = "perccameraimplanted"
	perseus_client_imaged_machines[src] = I
	. = ..()

/obj/machinery/computer/camera_advanced/perseus/can_use(mob/living/user)
	if(check_perseus(user))
		return TRUE
	to_chat(user, alternatedesc)
	return FALSE

/obj/machinery/computer/camera_advanced/perseus/examine()
	if(!check_perseus(usr))
		desc = alternatedesc
	. = ..()
	desc = initial(desc)

/obj/machinery/computer/camera_advanced/perseus/update_icon()
	return

/obj/machinery/computer/camera_advanced/perseus/Destroy()
	if(perseus_client_imaged_machines[src])
		qdel(perseus_client_imaged_machines[src])
		perseus_client_imaged_machines[src] = null
		perseus_client_imaged_machines.Remove(src)
	. = ..()