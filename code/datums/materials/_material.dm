/datum/material
	var/name = "material"
	var/desc = "its..stuff."
	var/id = "mat"
	var/color = "#000000" // rgb: 0, 0, 0
	var/list/categories = list() //Materials "Traits". its a map of key = category | Value = Bool
	var/sheet_type = null //This should be replaced as soon as possible by greyscale sheets.
	var/coin_type = null//This should be replaced as soon as possible by greyscale coins.


/datum/material/proc/on_applied(atom/source, amount) //What happens to the object that has this material?
	return
