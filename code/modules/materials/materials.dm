/datum/material
	var/name = "material"
	var/color = "#FFFFFF"
	var/force_multiplier = 1
	var/health_multiplier = 1
	var/prefix = "material"
	var/starting_material = 0
	var/atom/my_atom
	var/can_process = 0
	var/conduction = 0

/datum/material/proc/fire_act()
	return

/datum/material/proc/throw_impact(atom/hit_atom)
	return

/datum/material/proc/init_material(var/atom/A)
	return

/datum/material/iron
	name = "Iron"
	color = "#908D8D"
	force_multiplier = 1
	health_multiplier = 1
	prefix = "iron"
	conduction = 1

/datum/material/gold
	name = "Gold"
	color = "" // Handled by the material init. proc.
	force_multiplier = 0.25
	health_multiplier = 0.25 // this aint digmineconstructcraft buddy
	prefix = "gold"
	conduction = 1


/datum/material/gold/init_material(var/atom/A) // Borrowed from GUN_HOG's old EUK code
	if(istype(A, /obj/item))
		var/obj/item/I = A
		I.unacidable = 1
	var/icon/I
	var/icon/P = new /icon
	for(var/iconstate in icon_states(A.icon))
		var/icon/O = new('icons/effects/material_overlays.dmi', "gold") //Oooh, shiny!
		I = new(A.icon, iconstate)
		O.Blend(I, ICON_ADD) //Trim the shine to the item only and add some vibrance to the item.
		P.Insert(O, iconstate) //Build a new icon set to use with the item itself.

	A.icon = P //Apply the new icon.
	return

/datum/material/diamond
	name = "Diamond"
	color = "#BFFFFF"
	force_multiplier = 2
	health_multiplier = 4
	prefix = "diamond"

/datum/material/glass
	name = "Glass"
	color = "#FFFFFF"
	force_multiplier = 0.5
	health_multiplier = 0.5
	prefix = "glass"

/datum/material/glass/throw_impact(atom/hit_atom)
	if(prob(50))
		my_atom.visible_message("[my_atom] shatters!")
		qdel(my_atom)
	return

/datum/material/sandstone
	name = "Sandstone"
	color = "#E7C88F"
	force_multiplier = 1
	health_multiplier = 1
	prefix = "sandstone"

/datum/material/uranium
	name = "Uranium"
	color = "#39C639"
	force_multiplier = 3
	health_multiplier = 5
	prefix = "uranium"

/datum/material/plasma
	name = "Plasma"
	color = "#E122D9"
	force_multiplier = 1
	health_multiplier = 1
	prefix = "plasma"

/datum/material/silver
	name = "Silver"
	color = "#DCDCDC"
	force_multiplier = 1
	health_multiplier = 1
	prefix = "silver"

/datum/material/bananium
	name = "Bananium"
	color = "#FFD800"
	force_multiplier = 1
	health_multiplier = 1
	prefix = "bananium"

/datum/material/plasteel
	name = "Plasteel"
	color = "#A0A0A0"
	force_multiplier = 1.5
	health_multiplier = 1.5
	prefix = "plasteel"

/datum/material/wood
	name = "Wood"
	color = "#B78B67"
	force_multiplier = 1
	health_multiplier = 0.5
	prefix = "wood"

/datum/material/cloth
	name = "Cloth"
	color = "#EAEAE1"
	force_multiplier = 0.1
	health_multiplier = 0.1
	prefix = "cloth"

/datum/material/cardboard
	name = "Cardboard"
	color = "#70736C"
	force_multiplier = 0.3
	health_multiplier = 0.3
	prefix = "cardboard"

/datum/material/iron/starting
	starting_material = 1

/atom/proc/init_material()
	if(material)
		if(!material.starting_material)
			var/name_base = name
			name = material.prefix + " " + name_base
			if(has_greyscale)
				var/temp_state = icon_state
				icon = 'icons/obj/greyscale.dmi'
				icon_state = "[temp_state]_greyscale"
			if(material.can_process)
				SSobj.processing |= src
			material.init_material(src)
			color = material.color
			if(material.conduction)
				if(istype(src, /obj/item))
					var/obj/item/I = src
					I.flags |= CONDUCT
					I.siemens_coefficient = material.conduction
		material.my_atom = src
	return

/atom/Destroy()
	if(material)
		if(material.can_process)
			SSobj.processing -= src
	..()

/atom/process()
	if(material)
		if(material.can_process)
			material.process()
	..()