	//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/***************************************************************
**						Design Datums						  **
**	All the data for building stuff and tracking reliability. **
***************************************************************/
/*
For the materials datum, it assumes you need reagents unless specified otherwise. To designate a material that isn't a reagent,
you use one of the material IDs below. These are NOT ids in the usual sense (they aren't defined in the object or part of a datum),
they are simply references used as part of a "has materials?" type proc. They all start with a $ to denote that they aren't reagents.
The currently supporting non-reagent materials:
- $iron (/obj/item/stack/metal). One sheet = 3750 units. NB: do not use $metal. It is outdated and will cause issues
- $glass (/obj/item/stack/glass). One sheet = 3750 units.
- $plasma (/obj/item/stack/plasma). One sheet = 3750 units.
- $silver (/obj/item/stack/silver). One sheet = 3750 units.
- $gold (/obj/item/stack/gold). One sheet = 3750 units.
- $uranium (/obj/item/stack/uranium). One sheet = 3750 units.
- $diamond (/obj/item/stack/diamond). One sheet = 3750 units.
- $clown (/obj/item/stack/clown). One sheet = 3750 units. ("Bananium")
- $cardboard (/obj/item/stack/sheet/cardboard). One sheet = 3750 units.
(Insert new ones here)

Don't add new keyword/IDs if they are made from an existing one (such as rods which are made from metal). Only add raw materials.

Design Guidlines
- The reliability formula for all R&D built items is reliability_base (a fixed number) + total tech levels required to make it +
reliability_mod (starts at 0, gets improved through experimentation). Example: PACMAN generator. 79 base reliablity + 6 tech
(3 plasmatech, 3 powerstorage) + 0 (since it's completely new) = 85% reliability. Reliability is the chance it works CORRECTLY.
- When adding new designs, check rdreadme.dm to see what kind of things have already been made and where new stuff is needed.
- A single sheet of anything is 3750 units of material. Materials besides metal/glass require help from other jobs (mining for
other types of metals and chemistry for reagents).
- Add the AUTOLATHE tag to

The required techs are the following:
- Materials Research				max=9	"materials"
- Engineering Research				max=5	"engineering"
- Plasma Research					max=4	"plasmatech"
- Power Manipulation Technology		max=6	"powerstorage"
- 'Blue-space' Research				max=10	"bluespace"
- Biological Technology				max=5	"biotech"
- Combat Systems Research			max=6	"combat"
- Electromagnetic Spectrum Research	max=8	"magnets"
- Data Theory Research				max=5	"programming"
- Illegal Technologies Research		max=8	"syndicate"
*/

#define	IMPRINTER	1	//For circuits. Uses glass/chemicals.
#define PROTOLATHE	2	//New stuff. Uses glass/metal/chemicals
#define	AUTOLATHE	4	//Uses glass/metal only.
#define CRAFTLATHE	8	//Uses fuck if I know. For use eventually.
#define MECHFAB		16  //Remember, objects built under fabricators need DESIGNS
#define PODFAB		32  //Used by the spacepod part fabricator. Same idea as the mechfab
#define FLATPACKER	64  //This design creates a machine, not an item.
#define GENFAB		128 //Generic item.
//Note: More then one of these can be added to a design but imprinter and lathe designs are incompatable.

/datum/design							//Datum for object designs, used in construction
	var/name = "Name"					//Name of the created object.
	var/desc = "Desc"					//Description of the created object.
	var/id = "id"						//ID of the created object for easy refernece. Alphanumeric, lower-case, no symbols
	var/list/req_tech = list()			//IDs of that techs the object originated from and the minimum level requirements.
	var/reliability_mod = 0				//Reliability modifier of the device at it's starting point.
	var/reliability_base = 100			//Base reliability of a device before modifiers.
	var/reliability = 100				//Reliability of the device.
	var/build_type = null				//Flag as to what kind machine the design is built in. See defines.
	var/list/materials = list()			//List of materials. Format: "id" = amount.
	var/build_path = null				//The file path of the object that gets created
	var/locked = 0						//If true it will spawn inside a lockbox with currently sec access
	var/list/req_lock_access			//Sets the access for the lockbox that a locked item spawns in
	var/category = "Misc"				//Primarily used for Mech Fabricators, but can be used for anything

//A proc to calculate the reliability of a design based on tech levels and innate modifiers.
//Input: A list of /datum/tech; Output: The new reliabilty.
/datum/design/proc/CalcReliability(var/list/temp_techs)
	var/new_reliability = reliability_mod + reliability_base
	for(var/datum/tech/T in temp_techs)
		if(T.id in req_tech)
			new_reliability += T.level
	new_reliability = Clamp(new_reliability, reliability_base, 100)
	reliability = new_reliability
	return

//give it an object or a type
//if it gets passed an object, it makes it into a type
//it then finds the design which has a buildpath of that type
//material_strict will check the atom's materials against the design's materials if set to 1, but won't for machines
//If you want to check machine materials strictly as well, set material_strict to 2
proc/FindDesign(var/atom/part, material_strict = 0)
	if(ispath(part))
		return FindTypeDesign(part)

	if(!istype(part))
		return

	for(var/datum/design/D in design_list)
		if(D.build_path == part.type)
			if(material_strict && ((istype(part, /obj/machinery) && material_strict == 2) || (!istype(part, /obj/machinery) && material_strict)) && istype(part.materials, /list)) //if we care about materials, we have to check candidates
				var/all_correct = 1

				for(var/matID in D.materials)
					if(copytext(matID, 1, 2) == "$" && (part.materials.storage[matID] != D.materials[matID])) //if it's a materal, but it doesn't match the atom's values
						all_correct = 0
						break
				if(all_correct)
					return D
			else
				return D

proc/FindTypeDesign(var/part_path)
	for(var/datum/design/D in design_list)
		if(D.build_path == part_path)
			return D

//Acts as FindDesign, but makes a new design if it doesn't find one
//Doesn't take types for the design creation, so don't rely on it for that
proc/getScanDesign(var/obj/O)
	var/datum/design/D
	if(O.materials)
		D = FindDesign(O, 1) //The 1 means we check strict materials - if we don't have materials, we just check the type
	else
		D = FindDesign(O)
	if(D)
		return D

	else
		return new/datum/design/mechanic_design(O)

//sum of the required tech of a design
/datum/design/proc/TechTotal()
	var/total = 0
	for(var/tech in src.req_tech)
		total += src.req_tech[tech]
	return total

//sum of the required materials of a design
//do not confuse this with Total_Materials. That gets the machine's materials, this gets design materials
/datum/design/proc/MatTotal()
	var/total = 0
	for(var/matID in src.materials)
		total += src.materials[matID]
	//log_admin("[total] for [part.name]")
	return total

////////////////////////////////////////
//Disks for transporting design datums//
////////////////////////////////////////

/obj/item/weapon/disk/design_disk
	name = "Component Design Disk"
	desc = "A disk for storing device design data for construction in lathes."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = 1.0
	starting_materials = list(MAT_IRON = 30, MAT_GLASS = 10)
	w_type = RECYK_ELECTRONIC
	var/datum/design/blueprint

/obj/item/weapon/disk/design_disk/New()
	..()
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)
