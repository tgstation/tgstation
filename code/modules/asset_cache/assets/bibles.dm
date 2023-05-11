/datum/asset/spritesheet/bibles
	name = "bibles"

/datum/asset/spritesheet/bibles/create_spritesheets()
	var/obj/item/book/hollow/bible/holy_template = /obj/item/book/hollow/bible
	InsertAll("display", initial(holy_template.icon))

/datum/asset/spritesheet/bibles/ModifyInserted(icon/pre_asset)
	pre_asset.Scale(224, 224) // Scale up by 7x
	return pre_asset
