/datum/computer
	var/size = 4.0
	var/obj/item/weapon/disk/data/holder = null
	var/datum/computer/folder/holding_folder = null
	folder
		name = "Folder"
		size = 0.0
		var/gen = 0
		Del()
			for(var/datum/computer/F in src.contents)
				del(F)
			..()
		proc
			add_file(datum/computer/R)
				if(!holder || holder.read_only || !R)
					return 0
				if(istype(R,/datum/computer/folder) && (src.gen>=10))
					return 0
				if((holder.file_used + R.size) <= holder.file_amount)
					src.contents.Add(R)
					R.holder = holder
					R.holding_folder = src
					src.holder.file_used -= src.size
					src.size += R.size
					src.holder.file_used += src.size
					if(istype(R,/datum/computer/folder))
						R:gen = (src.gen+1)
					return 1
				return 0

			remove_file(datum/computer/R)
				if(holder && !holder.read_only || !R)
//					world << "Removing file [R]. File_used: [src.holder.file_used]"
					src.contents.Remove(R)
					src.holder.file_used -= src.size
					src.size -= R.size
					src.holder.file_used += src.size
					src.holder.file_used = max(src.holder.file_used, 0)
//					world << "Removed file [R]. File_used: [src.holder.file_used]"
					return 1
				return 0
	file
		name = "File"
		var/extension = "FILE" //Differentiate between types of files, why not
		proc
			copy_file_to_folder(datum/computer/folder/newfolder)
				if(!newfolder || (!istype(newfolder)) || (!newfolder.holder) || (newfolder.holder.read_only))
					return 0

				if((newfolder.holder.file_used + src.size) <= newfolder.holder.file_amount)
					var/datum/computer/file/newfile = new src.type

					for(var/V in src.vars)
						if (issaved(src.vars[V]) && V != "holder")
							newfile.vars[V] = src.vars[V]

					if(!newfolder.add_file(newfile))
						del(newfile)

					return 1

				return 0


	Del()
		if(holder && holding_folder)
			holding_folder.remove_file(src)
		..()


/datum/computer/file/computer_program
	name = "blank program"
	extension = "PROG"
	//var/size = 4.0
	//var/obj/item/weapon/disk/data/holder = null
	var/obj/machinery/computer2/master = null
	var/active_icon = null
	var/id_tag = null
	var/list/req_access = list()

	New(obj/holding as obj)
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/machinery/computer2))
				src.master = src.holder.loc

	Del()
		if(master)
			master.processing_programs.Remove(src)
		..()

	proc
		return_text()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.stat & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents))
				//world << "Holder [holder] not in [master] of prg:[src]"
				if(master.active_program == src)
					master.active_program = null
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		process()
			if((!src.holder) || (!src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				master.processing_programs.Remove(src)
				return 1

			if(!src.holder.root)
				src.holder.root = new /datum/computer/folder
				src.holder.root.holder = src
				src.holder.root.name = "root"

			return 0

		receive_command(obj/source, command, datum/signal/signal)
			if((!src.holder) || (!src.master) || (!source) || (source != src.master))
				return 1

			if((!istype(holder)) || (!istype(master)))
				return 1

			if(master.stat & (NOPOWER|BROKEN))
				return 1

			if(!(holder in src.master.contents))
				if(master.active_program == src)
					master.active_program = null
				return 1

			return 0

		peripheral_command(command, datum/signal/signal)
			if(master)
				master.send_command(command, signal)
			else
				del(signal)

		transfer_holder(obj/item/weapon/disk/data/newholder,datum/computer/folder/newfolder)

			if((newholder.file_used + src.size) > newholder.file_amount)
				return 0

			if(!newholder.root)
				newholder.root = new /datum/computer/folder
				newholder.root.holder = newholder
				newholder.root.name = "root"

			if(!newfolder)
				newfolder = newholder.root

			if((src.holder && src.holder.read_only) || newholder.read_only)
				return 0

			if((src.holder) && (src.holder.root))
				src.holder.root.remove_file(src)

			newfolder.add_file(src)

			if(istype(newholder.loc,/obj/machinery/computer2))
				src.master = newholder.loc

			//world << "Setting [src.holder] to [newholder]"
			src.holder = newholder
			return 1

		//Check access per program.
		allowed(mob/M)
			//check if it doesn't require any access at all
			if(src.check_access(null))
				return 1
			if(istype(M, /mob/living/silicon))
				//AI can do whatever he wants
				return 1
			else if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				//if they are holding or wearing a card that has access, that works
				if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
					return 1
			else if(istype(M, /mob/living/carbon/monkey))
				var/mob/living/carbon/monkey/george = M
				//they can only hold things :(
				if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && src.check_access(george.equipped()))
					return 1
			return 0

		check_access(obj/item/weapon/card/id/I)
			if(!src.req_access) //no requirements
				return 1
			if(!istype(src.req_access, /list)) //something's very wrong
				return 1

			var/list/L = src.req_access
			if(!L.len) //no requirements
				return 1
			if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
				return 0
			for(var/req in src.req_access)
				if(!(req in I.access)) //doesn't have this access
					return 0
			return 1

	Topic(href, href_list)
		if((!src.holder) || (!src.master))
			return 1

		if((!istype(holder)) || (!istype(master)))
			return 1

		if(master.stat & (NOPOWER|BROKEN))
			return 1

		if(src.master.active_program != src)
			return 1

		if ((!usr.contents.Find(src.master) && (!in_range(src.master, usr) || !istype(src.master.loc, /turf))) && (!istype(usr, /mob/living/silicon)))
			return 1

		if(!(holder in src.master.contents))
			if(master.active_program == src)
				master.active_program = null
			return 1

		usr.machine = src.master

		if (href_list["close"])
			usr.machine = null
			usr << browse(null, "window=comp2")
			return 0

		if (href_list["quit"])
//			src.master.processing_programs.Remove(src)
			if(src.master.host_program && src.master.host_program.holder && (src.master.host_program.holder in src.master.contents))
				src.master.run_program(src.master.host_program)
				src.master.updateUsrDialog()
				return 1
			else
				src.master.active_program = null
			src.master.updateUsrDialog()
			return 1

		return 0