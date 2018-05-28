/datum/component/atom_linker
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/id
	var/list/linked_components
	var/static/list/linker_lists = list()

/datum/component/atom_linker/Initialize(id)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	
	if(!id || (!istext(id) && !ispath(id)))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Invalid link id: [id]")

	src.id = id
	linked_components = linker_lists[id]
	if(!linked_components)
		linker_lists[id] = linked_components = list()
	linked_components += src

/datum/component/atom_linker/Destroy()
	linked_components -= src
	linked_components = null
	if(!linked_components.len)
		linker_lists[id] = null
	return ..()

/datum/component/atom_linker/proc/GetLinks()
	return linked_components.Copy()

/atom/proc/GetLinkedAtoms(id)
	for(var/I in GetComponents(/datum/component/atom_linker))
		var/datum/component/atom_linker/al = I
		if(al.id == id)
			return al.linked_components.Copy()

/proc/GetLinkedAtomsWithId(id)
	var/datum/component/atom_linker/al
	//remove compiler warning
	pass(al)
	var/list/linker_lists = al.linker_lists
	return linker_lists[id]

/proc/GetLinkedAtomIds()
	var/datum/component/atom_linker/al
	//remove compiler warning
	pass(al)
	. = al.linker_lists.Copy()
	for(var/I in .)
		.[I] = null

/datum/admins/proc/ViewLinkedAtoms()
	set name = "View Linked Atoms"
	set category = "Mapping"
	set desc = "View current lists of design time linked atoms"

	var/id = input(usr, "Select group to view", "Link Groups") in GetLinkedAtomIds() | null
	if(!id)
		return
	
	var/list/atom_list = list()
	for(var/I in GetLinkedAtomsWithId(id))
		var/atom/A = I
		atom_list["[A.name] ([A.type]) ([COORD(A)])"] = I
	
	if(!atom_list.len)
		if(usr)
			alert(usr, "Group is now empty!")
		return

	var/to_view = input(usr, "Select atom to view", "Link Group \"[id]\"") in atom_list | null
	if(!to_view)
		return

	var/atom/atom_to_view = atom_list[to_view]
	if(!usr)
		return
		
	if(QDELETED(atom_to_view))
		alert(usr, "Atom deleted!")
	else
		usr.client.debug_variables(atom_to_view)
