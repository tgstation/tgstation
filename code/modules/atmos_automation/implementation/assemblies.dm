/datum/automation/pulse_assembly
	name = "Assembly: Pulse"
	var/assembly_num = 1 //1 to parent.max_linked_assembly_amount (5)

/datum/automation/pulse_assembly/Export()
	var/list/json = ..()
	json["assembly_num"] = assembly_num
	return json

/datum/automation/pulse_assembly/Import(var/list/json)
	..(json)
	assembly_num = text2num(json["assembly_num"])

/datum/automation/pulse_assembly/process()
	var/obj/item/device/assembly/A = parent.linked_assemblies[assembly_num]

	if(A)
		A.activate()

	return 0

/datum/automation/pulse_assembly/GetText()
	var/T = null

	if(assembly_num in (1 to parent.max_linked_assembly_amount))
		var/obj/item/device/assembly/A = parent.linked_assemblies[assembly_num]

		if(istype(A))
			T = A

	return "Pulse assembly #<a href=\"?src=\ref[src];set_ass_num=1\">[assembly_num]</a>[T ? "- [T]" : ""]." //Pulse assembly #3 - remote signaling device

/datum/automation/pulse_assembly/Topic(href,href_list)
	. = ..()
	if(.)
		return

	if(href_list["set_ass_num"])
		assembly_num = input("Select an assembly port to send a pulse to (max: [parent.max_linked_assembly_amount]).", "Assembly", assembly_num) as null|num

		assembly_num = Clamp(assembly_num, 1, parent.max_linked_assembly_amount)

		parent.updateUsrDialog()
		return 1
