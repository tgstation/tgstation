//Gun crafting parts til they can be moved elsewhere

// PARTS //

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 6)
	resistance_flags = FLAMMABLE
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "riflestock"

/obj/item/weaponcrafting/giant_wrench
	name = "Big Slappy parts kit"
	desc = "Illegal parts to make a giant like wrench commonly known as a Big Slappy."
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "weaponkit_gw"

///These gun kits are printed from the security protolathe to then be used in making new weapons

// GUN PART KIT //

/obj/item/weaponcrafting/gunkit
	name = "generic gun parts kit"
	desc = "It's an empty gun parts container! Why do you have this?"
	icon = 'icons/obj/weapons/improvised.dmi'
	icon_state = "kitsuitcase"

/obj/item/weaponcrafting/gunkit/nuclear
	name = "advanced energy gun parts kit (lethal/nonlethal)"
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into an advanced energy gun."

/obj/item/weaponcrafting/gunkit/tesla
	name = "tesla cannon parts kit (lethal)"
	desc = "A suitcase containing the necessary gun parts to construct a tesla cannon around a stabilized flux anomaly. Handle with care."

/obj/item/weaponcrafting/gunkit/xray
	name = "x-ray laser gun parts kit (lethal)"
	desc = "A suitcase containing the necessary gun parts to turn a laser gun into a x-ray laser gun. Do not point most parts directly towards face."

/obj/item/weaponcrafting/gunkit/ion
	name = "ion carbine parts kit (nonlethal/highly destructive/very lethal (silicons))"
	desc = "A suitcase containing the necessary gun parts to transform a standard laser gun into a ion carbine. Perfect against lockers you don't have access to."

/obj/item/weaponcrafting/gunkit/temperature
	name = "temperature gun parts kit (less lethal/very lethal (lizardpeople))"
	desc = "A suitcase containing the necessary gun parts to tranform a standard energy gun into a temperature gun. Fantastic at birthday parties and killing indigenious populations of lizardpeople."

/obj/item/weaponcrafting/gunkit/beam_rifle
	name = "particle acceleration rifle part kit (lethal)"
	desc = "The coup de grace of guncrafting. This suitcase contains the highly experimental rig for a particle acceleration rifle. Requires an energy gun, a stabilized flux anomaly and a stabilized gravity anomaly."

/obj/item/weaponcrafting/gunkit/decloner
	name = "decloner part kit (lethal)"
	desc = "An uttery baffling array of gun parts and technology that somehow turns a laser gun into a decloner. Haircut not included."

/obj/item/weaponcrafting/gunkit/ebow
	name = "energy crossbow part kit (less lethal)"
	desc = "Highly illegal weapons refurbishment kit that allows you to turn the standard proto-kinetic accelerator into a near-duplicate energy crossbow. Almost like the real thing!"

/obj/item/weaponcrafting/gunkit/hellgun
	name = "hellfire laser gun degradation kit (warcrime lethal)"
	desc = "Take a perfectly functioning laser gun. Butcher the inside of the gun so it runs hot and mean. You now have a hellfire laser. You monster."
