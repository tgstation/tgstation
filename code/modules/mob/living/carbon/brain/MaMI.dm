/obj/item/organ/brain/mami
	name = "Machine-Man Interface"
	desc = "A complex socket-system of electrodes and neurons intended to give silicon-based minds control of organic tissue."
	origin_tech = "biotech=4;programming=4"
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mami_empty"
	var/obj/item/device/mmi/posibrain/posibrain = null

/obj/item/organ/brain/mami/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/device/mmi/posibrain) && !brainmob)
		posibrain = O
		if(!posibrain.brainmob || !posibrain.brainmob.mind || !posibrain.brainmob.ckey)
			user << "<span class='warning'>You aren't sure where this brain came from, but you're pretty sure it's a useless brain.</span>"
			posibrain = null
			return
		src.visible_message("<span class='notice'>[user] sticks \a [O] into \the [src].</span>")

		brainmob = posibrain.brainmob
		brainmob.loc = src
		brainmob.container = src

		src.brainmob << "<b><font color='red' size=3>Recall your positronic directives!</font></b>"
		src.brainmob << "<b>You are \a [posibrain], brought into existence on [station_name()].</b>"
		src.brainmob << "<b>As a synthetic intelligence, you answer to all crewmembers, as well as the AI.</b>"
		src.brainmob << "<b>Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"

		user.drop_item()
		posibrain.loc = src

		name = "Machine-Man Interface: [brainmob.real_name]"
		icon_state = "mami_full"
		return 1
	return ..()

/obj/item/organ/brain/mami/attack_self(mob/user)
	if(brainmob && !posibrain)
		posibrain = new(src)
		posibrain.reset_search()
	if(posibrain)
		user << "You upend \the [src], dropping its contents onto the floor."
		posibrain.loc = user.loc
		posibrain.brainmob = brainmob
		brainmob.container = posibrain
		brainmob.loc = posibrain

		icon_state = "mami_empty"
		name = initial(name)

		posibrain = null
		brainmob = null
		return 1
	return ..()
