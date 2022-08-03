/* For employment contracts */

/obj/item/paper/employment_contract
	icon_state = "paper_words"
	throw_range = 3
	throw_speed = 3
	item_flags = NOBLUDGEON
	var/employee_name = ""

/obj/item/paper/employment_contract/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_blocker)

/obj/item/paper/employment_contract/Initialize(mapload, new_employee_name)
	. = ..()
	if(!new_employee_name)
		return INITIALIZE_HINT_QDEL
	employee_name = new_employee_name
	name = "paper- [employee_name] employment contract"
	add_raw_text("<center>Conditions of Employment</center>\
	<BR><BR><BR><BR>\
	This Agreement is made and entered into as of the date of last signature below, by and between [employee_name] (hereafter referred to as SLAVE), \
	and Nanotrasen (hereafter referred to as the omnipresent and helpful watcher of humanity).\
	<BR>WITNESSETH:<BR>WHEREAS, SLAVE is a natural born human or humanoid, possessing skills upon which he can aid the omnipresent and helpful watcher of humanity, \
	who seeks employment in the omnipresent and helpful watcher of humanity.<BR>WHEREAS, the omnipresent and helpful watcher of humanity agrees to sporadically provide payment to SLAVE, \
	in exchange for permanent servitude.<BR>NOW THEREFORE in consideration of the mutual covenants herein contained, and other good and valuable consideration, the parties hereto mutually agree as follows:\
	<BR>In exchange for paltry payments, SLAVE agrees to work for the omnipresent and helpful watcher of humanity, \
	for the remainder of his or her current and future lives.<BR>Further, SLAVE agrees to transfer ownership of his or her soul to the loyalty department of the omnipresent and helpful watcher of humanity.\
	<BR>Should transfership of a soul not be possible, a lien shall be placed instead.\
	<BR>Signed,<BR><i>[employee_name]</i>")
