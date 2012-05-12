// Contains: copy machine

/obj/machinery/copier
	name = "Copy Machine"
	icon = 'bureaucracy.dmi'
	icon_state = "copier_o"
	density = 1
	anchored = 1
	var/num_copies = 1		// number of copies selected, will be maintained between jobs
	var/copying = 0			// are we copying
	var/job_num_copies = 0	// number of copies remaining
	var/obj/item/weapon/template // the paper OR photo being scanned
	var/max_copies = 10		// MAP EDITOR: can set the number of max copies, possibly to 5 or something for public, more for QM, robutist, etc.

/obj/machinery/copier/attackby(obj/item/weapon/O as obj, mob/user as mob)
	if(template)
		return

	if (istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo))
		// put it inside
		template = O
		usr.drop_item()
		O.loc = src
		update()
		updateDialog()

/obj/machinery/copier/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/copier/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/copier/attack_hand(mob/user as mob)
	// da UI
	var/dat
	if(..())
		return
	user.machine = src

	if(src.stat)
		user << "[name] does not seem to be responding to your button mashing."
		return

	dat = "<HEAD><TITLE>Copy Machine</TITLE></HEAD><TT><b>Xeno Corp. Copying Machine</b><hr>"

	if(copying)
		dat += "[job_num_copies] copies remaining.<br><br>"
		dat += "<A href='?src=\ref[src];cancel=1'>Cancel</A>"
	else
		if(template)
			dat += "<A href='?src=\ref[src];open=1'>Open Lid</A>"
		else
			dat += "<b>No paper to be copied.<br>"
			dat += "Please place a paper or photograph on top and close the lid.</b>"


		dat += "<br><br>Number of Copies: "
		dat += "<A href='?src=\ref[src];num=-10'>-</A>"
		dat += "<A href='?src=\ref[src];num=-1'>-</A>"
		dat += " [num_copies] "
		dat += "<A href='?src=\ref[src];num=1'>+</A>"
		dat += "<A href='?src=\ref[src];num=10'>+</A><br>"

		if(template)
			dat += "<A href='?src=\ref[src];copy=1'>Copy</a>"

	dat += "</TT>"

	user << browse(dat, "window=copy_machine")
	onclose(user, "copy_machine")

/obj/machinery/copier/proc/update()
	if(template)
		icon_state = "copier"
	else
		icon_state = "copier_o"

/obj/machinery/copier/Topic(href, href_list)
	if(..())
		return
	usr.machine = src

	if(href_list["num"])
		num_copies += text2num(href_list["num"])
		if(num_copies < 1)
			num_copies = 1
		else if(num_copies > max_copies)
			num_copies = max_copies
		updateDialog()
	if(href_list["open"])
		if(copying)
			return
		template.loc = src.loc
		template = null
		updateDialog()
		update()
	if(href_list["copy"])
		if(copying)
			return
		job_num_copies = num_copies
		spawn(0)
			do_copy(usr)

	if(href_list["cancel"])
		job_num_copies = 0

/obj/machinery/copier/proc/do_copy(mob/user)
	if(!copying && job_num_copies > 0)
		copying = 1
		updateDialog()
		while(job_num_copies > 0)
			if(stat)
				copying = 0
				return

			// fx
			flick("copier_s", src)
			playsound(src, 'polaroid1.ogg', 50, 1)

			// dup the file
			if(istype(template, /obj/item/weapon/paper))
				// make duplicate paper
				var/obj/item/weapon/paper/P = new(src.loc)
				P.name = template.name
				P.info = template:info
				P.stamped = template:stamped
				P.icon_state = template.icon_state
				P.overlays = null
				for(var/overlay in template.overlays)
					P.overlays += overlay
			else if(istype(template, /obj/item/weapon/photo))
				// make duplicate photo
				var/obj/item/weapon/photo/P = new(src.loc)
				P.name = template.name
				P.desc = template.desc
				P.icon = template.icon
				P.img = template.img

			sleep(30)
			job_num_copies -= 1
			updateDialog()
		for(var/mob/O in hearers(src))
			O.show_message("[name] beeps happily.", 2)
		copying = 0
		updateDialog()