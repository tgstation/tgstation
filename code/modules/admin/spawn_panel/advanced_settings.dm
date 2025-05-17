			// .["value"] = input("Pick icon:", "Icon") as null|icon
			// if(.["value"] == null)
			// 	.["class"] = null
			// 	return

/datum/spawnpanel/proc/set_atom_icon(reset = FALSE)
	var/icon/new_icon = input("Select a new icon file:", "Icon") as null|icon
	if(!new_icon)
		return
