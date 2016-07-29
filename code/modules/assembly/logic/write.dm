//////////////////////////Write/Read circuit////////////////////////
// * Can be connected to two assemblies - READ and WRITE
// * Two stored values: stored_num and stored_txt. One stores a number, the other one text.
//
// * When pulsed, read READ's value and store it. Write the stored value to WRITE
// * READ's value converted to number is written to stored_num, READ's value converted to text is written to stored_txt

/obj/item/device/assembly/read_write
	name = "write/read circuit"
	desc = "A small circuit intended for use in assembly frames. It can be connected to two assemblies: READ and WRITE. ."

	icon_state = "circuit_write"

	starting_materials = list(MAT_IRON = 130, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC

	origin_tech = "programming=1"

	wires = WIRE_RECEIVE

	connection_text = "connected to"

	var/stored_num = 0
	var/stored_txt = "NULL"

	accessible_values = list("Stored number" = "stored_num;number",\
		"Stored string" = "stored_txt;text")

	var/obj/item/device/assembly/READ = null
	var/READ_value = ""

	var/obj/item/device/assembly/WRITE = null
	var/WRITE_value = ""

	var/list/device_pool = list() //List of all connected assemblies, to make life easier

/obj/item/device/assembly/read_write/activate()
	if(!..()) return 0

	if(READ && READ_value)
		var/value = READ.get_value(READ_value)

		if(istext(value))
			stored_num = text2num(value)
			stored_txt = value
		else if(isnum(value))
			stored_num = value
			stored_txt = num2text(value)

	if(WRITE && WRITE_value)
		var/list/W_params = params2list(WRITE.accessible_values[WRITE_value])
		switch(W_params[VALUE_VARIABLE_TYPE])
			if("text")
				WRITE.write_to_value(WRITE_value, stored_txt)
			if("number")
				WRITE.write_to_value(WRITE_value, stored_num)

/obj/item/device/assembly/read_write/interact(mob/user)
	var/dat = ""

	dat += "<p><b>READ</b>: <a href='?src=\ref[src];set_read=1'>[READ ? "[READ] ([READ_value])" : "nothing"]</a></p>"
	dat += "<p><b>WRITE</b>: <a href='?src=\ref[src];set_write=1'>[WRITE ? "[WRITE] ([WRITE_value])" : "nothing"]</a></p><hr>"
	dat += "<p>Stored value 1 (number): [stored_num] (<a href='?src=\ref[src];set_num_value=1'>change</a>)</p>"
	dat += "<p>Stored value 2 (text): [stored_txt] (<a href='?src=\ref[src];set_txt_value=1'>change</a>)</p>"

	var/datum/browser/popup = new(user, "circuit4", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "circuit4")

/obj/item/device/assembly/read_write/Topic(href, href_list)
	if(..()) return

	if(href_list["set_num_value"])
		var/choice = input(usr, "Select a new numeric value to be stored in \the [src].", "\The [src]") as null|num

		if(isnull(choice)) return
		if(..()) return

		stored_num = choice
	if(href_list["set_txt_value"])
		var/choice = input(usr, "Select a new string value to be stored in \the [src].", "\The [src]") as null|text

		if(isnull(choice)) return
		if(..()) return

		stored_txt = choice

	if(href_list["set_read"])
		var/choice = input(usr, "Select a new READ assembly for \the [src].", "\The [src]") as null|anything in (device_pool + "Nothing")

		if(isnull(choice)) return
		if(..()) return

		var/obj/item/device/assembly/A = choice
		var/new_value = input(usr, "Select which of \the [A]'s values will be read.", "\The [src]") as null|anything in A.accessible_values

		if(isnull(new_value)) return
		if(..()) return
		if(choice == "Nothing")
			READ = null
			to_chat(usr, "<span class='info'>\The [src] will no longer read anything.</span>")
		else
			if(!device_pool.Find(choice)) return

			READ = choice
			READ_value = new_value

			to_chat(usr, "<span class='info'>\The [src] will now read [A]'s [new_value].</span>")

	if(href_list["set_write"])
		var/choice = input(usr, "Select a new WRITE assembly for \the [src].", "\The [src]") as null|anything in (device_pool + "Nothing")

		if(isnull(choice)) return
		if(..()) return
		if(choice == "Nothing")
			WRITE = null
			to_chat(usr, "<span class='info'>\The [src] will no longer write to anything.</span>")
		else
			var/obj/item/device/assembly/A = choice
			var/new_value = input(usr, "Select which of \the [A]'s values will be written to.", "\The [src]") as null|anything in A.accessible_values

			if(isnull(new_value)) return
			if(..()) return

			if(!device_pool.Find(choice)) return

			WRITE = choice
			WRITE_value = new_value

			to_chat(usr, "<span class='info'>\The [src] will now write to [A]'s [new_value].</span>")

	if(usr)
		attack_self(usr)

/obj/item/device/assembly/read_write/connected(var/obj/item/device/assembly/A, in_frame)
	..()

	device_pool |= A //Make the connected assembly available

/obj/item/device/assembly/read_write/disconnected(var/obj/item/device/assembly/A, in_frame)
	..()

	//Remove all references and make the disconnected assembly unavailable
	device_pool.Remove(A)
	if(READ == A) READ = null
	if(WRITE == A) WRITE = null
