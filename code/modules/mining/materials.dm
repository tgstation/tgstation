/**
* Materials system
*
* Replaces all of the horrible variables that tracked each individual thing.
*/

/**
* MATERIALS DATUM
*
* Tracks and manages material storage for an object.
*/

proc/initialize_materials()
	for(var/matdata in typesof(/datum/material) - /datum/material)
		var/datum/material/mat = new matdata
		material_list += list(mat.id = mat)
		initial_materials += list(mat.id = 0)

var/global/list/material_list		//Stores an instance of all the datums as an assoc with their matids
var/global/list/initial_materials	//Stores all the matids = 0 in helping New

/datum/materials
	var/atom/holder
	var/list/storage

/datum/materials/New(atom/newholder)
	holder = newholder
	storage = list()

	if(!material_list)
		initialize_materials()

	if(!storage.len)
		storage = initial_materials.Copy()

/datum/materials/Destroy()
	holder = null

/datum/materials/resetVariables(args)
	var/newargs
	if(args)
		newargs = args + "storage"
	else
		newargs = "storage"

	..(arglist(newargs))

	if(!initial_materials)
		initialize_materials()

	storage = initial_materials.Copy()

/datum/materials/proc/addAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("addAmount(): Unknown material [mat_id]!")
		return
	// I HATE BYOND
	// storage[mat_id].stored++
	storage[mat_id] = max(0, storage[mat_id] + amount)


/datum/materials/proc/removeFrom(var/datum/materials/mats)
	src.addFrom(mats,zero_after=1)

/datum/materials/proc/addFrom(var/datum/materials/mats, var/zero_after=0)
	if(mats == null)
		return
	for(var/mat_id in storage)
		if(mats.storage[mat_id]>0)
			storage[mat_id] += mats.storage[mat_id]
			if(zero_after)
				mats.storage[mat_id] = 0

/datum/materials/proc/getVolume()
	var/volume=0
	for(var/mat_id in storage)
		volume += storage[mat_id]
	return volume

//Gives total value, doing mat value * stored mat
/datum/materials/proc/getValue()
	var/value=0
	for(var/mat_id in storage)
		var/datum/material/mat = getMaterial(mat_id)
		value += mat.value * storage[mat_id]
	return value

/datum/materials/proc/removeAmount(var/mat_id,var/amount)
	if(!(mat_id in storage))
		warning("removeAmount(): Unknown material [mat_id]!")
		return
	addAmount(mat_id,-amount)

/datum/materials/proc/getAmount(var/mat_id)
	if(!(mat_id in storage))
		warning("getAmount(): Unknown material [mat_id]!")
		return 0

	return storage[mat_id]

/datum/materials/proc/getMaterial(var/mat_id)
	if(!(mat_id in material_list))
		warning("getMaterial(): Unknown material [mat_id]!")
		return 0

	return material_list[mat_id]

/datum/materials/proc/makeSheets(var/atom/loc)
	for (var/id in storage)
		var/amount = getAmount(id)
		if(amount)
			var/datum/material/mat = getMaterial(id)
			getFromPool(mat.sheettype, loc, Floor(amount / mat.cc_per_sheet))

//HOOKS//
/atom/proc/onMaterialChange(matID, amount)
	return


///MATERIALS///
/datum/material
	var/name=""
	var/processed_name=""
	var/id=""
	var/cc_per_sheet=CC_PER_SHEET_MISC
	var/oretype=null
	var/sheettype=null
	var/cointype=null
	var/value=0

/datum/material/New()
	if(processed_name=="")
		processed_name=name

/datum/material/iron
	name="Iron"
	id=MAT_IRON
	value=1
	cc_per_sheet=CC_PER_SHEET_METAL
	oretype=/obj/item/weapon/ore/iron
	sheettype=/obj/item/stack/sheet/metal
	cointype=/obj/item/weapon/coin/iron

/datum/material/glass
	name="Sand"
	processed_name="Glass"
	id=MAT_GLASS
	value=1
	cc_per_sheet=CC_PER_SHEET_GLASS
	oretype=/obj/item/weapon/ore/glass
	sheettype=/obj/item/stack/sheet/glass/glass

/datum/material/diamond
	name="Diamond"
	id=MAT_DIAMOND
	value=40
	cc_per_sheet = 1750
	oretype=/obj/item/weapon/ore/diamond
	sheettype=/obj/item/stack/sheet/mineral/diamond
	cointype=/obj/item/weapon/coin/diamond

/datum/material/plasma
	name="Plasma"
	id=MAT_PLASMA
	value=40
	oretype=/obj/item/weapon/ore/plasma
	sheettype=/obj/item/stack/sheet/mineral/plasma
	cointype=/obj/item/weapon/coin/plasma

/datum/material/gold
	name="Gold"
	id=MAT_GOLD
	value=20
	oretype=/obj/item/weapon/ore/gold
	sheettype=/obj/item/stack/sheet/mineral/gold
	cointype=/obj/item/weapon/coin/gold

/datum/material/silver
	name="Silver"
	id=MAT_SILVER
	value=20
	oretype=/obj/item/weapon/ore/silver
	sheettype=/obj/item/stack/sheet/mineral/silver
	cointype=/obj/item/weapon/coin/silver

/datum/material/uranium
	name="Uranium"
	id=MAT_URANIUM
	value=20
	oretype=/obj/item/weapon/ore/uranium
	sheettype=/obj/item/stack/sheet/mineral/uranium
	cointype=/obj/item/weapon/coin/uranium

/datum/material/clown
	name="Bananium"
	id=MAT_CLOWN
	value=100
	oretype=/obj/item/weapon/ore/clown
	sheettype=/obj/item/stack/sheet/mineral/clown
	cointype=/obj/item/weapon/coin/clown

/datum/material/phazon
	name="Phazon"
	id=MAT_PHAZON
	value=200
	cc_per_sheet = 1500
	oretype=/obj/item/weapon/ore/phazon
	sheettype=/obj/item/stack/sheet/mineral/phazon
	cointype=/obj/item/weapon/coin/phazon

/datum/material/plastic
	name="Plastic"
	id=MAT_PLASTIC
	value=1
	oretype=null
	sheettype=/obj/item/stack/sheet/mineral/plastic
	cointype=null

/datum/material/cardboard
	name="Cardboard"
	id=MAT_CARDBOARD
	value=1
	oretype=null
	sheettype=/obj/item/stack/sheet/cardboard
	cointype=null
	cc_per_sheet = CC_PER_SHEET_METAL

/* //Commented out to save save space in menus listing materials until they are used
/datum/material/pharosium
	name="Pharosium"
	id="pharosium"
	value=10
	oretype=/obj/item/weapon/ore/pharosium
	sheettype=/obj/item/stack/sheet/mineral/pharosium
	cointype=null


/datum/material/char
	name="Char"
	id="char"
	value=5
	oretype=/obj/item/weapon/ore/char
	sheettype=/obj/item/stack/sheet/mineral/char
	cointype=null


/datum/material/claretine
	name="Claretine"
	id="claretine"
	value=50
	oretype=/obj/item/weapon/ore/claretine
	sheettype=/obj/item/stack/sheet/mineral/claretine
	cointype=null


/datum/material/bohrum
	name="Bohrum"
	id="bohrum"
	value=50
	oretype=/obj/item/weapon/ore/bohrum
	sheettype=/obj/item/stack/sheet/mineral/bohrum
	cointype=null


/datum/material/syreline
	name="Syreline"
	id="syreline"
	value=70
	oretype=/obj/item/weapon/ore/syreline
	sheettype=/obj/item/stack/sheet/mineral/syreline
	cointype=null


/datum/material/erebite
	name="Erebite"
	id="erebite"
	value=50
	oretype=/obj/item/weapon/ore/erebite
	sheettype=/obj/item/stack/sheet/mineral/erebite
	cointype=null


/datum/material/cytine
	name="Cytine"
	id="cytine"
	value=30
	oretype=/obj/item/weapon/ore/cytine
	sheettype=/obj/item/stack/sheet/mineral/cytine
	cointype=null


/datum/material/uqill
	name="Uqill"
	id="uqill"
	value=90
	oretype=/obj/item/weapon/ore/uqill
	sheettype=/obj/item/stack/sheet/mineral/uqill
	cointype=null


/datum/material/telecrystal
	name="Telecrystal"
	id="telecrystal"
	value=30
	oretype=/obj/item/weapon/ore/telecrystal
	sheettype=/obj/item/stack/sheet/mineral/telecrystal
	cointype=null


/datum/material/mauxite
	name="Mauxite"
	id="mauxite"
	value=5
	oretype=/obj/item/weapon/ore/mauxite
	sheettype=/obj/item/stack/sheet/mineral/mauxite
	cointype=null


/datum/material/cobryl
	name="Cobryl"
	id="cobryl"
	value=30
	oretype=/obj/item/weapon/ore/cobryl
	sheettype=/obj/item/stack/sheet/mineral/cobryl
	cointype=null


/datum/material/cerenkite
	name="Cerenkite"
	id="cerenkite"
	value=50
	oretype=/obj/item/weapon/ore/cerenkite
	sheettype=/obj/item/stack/sheet/mineral/cerenkite
	cointype=null

/datum/material/molitz
	name="Molitz"
	id="molitz"
	value=10
	oretype=/obj/item/weapon/ore/molitz
	sheettype=/obj/item/stack/sheet/mineral/molitz
	cointype=null
*/
