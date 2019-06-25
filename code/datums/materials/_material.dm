/datum/material
	var/name = "material"
	var/desc = "its..stuff."
	var/color = "#000000" // rgb: 0, 0, 0
	var/list/categories = list() //Materials "Traits". its a map of key = category | Value = Bool


/datum/material/proc/on_applied(atom/source, amount) //What happens to the object that has this material?

