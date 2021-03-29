/obj/structure/closet/crate/loot
	desc = "A loot crate."
	name = "loot crate"
	icon_state = "weaponcrate"
	var/list/loot_table_armor = list(/obj/item/gun/ballistic/shotgun)
	var/list/loot_table_heal = list(/obj/item/gun/ballistic/shotgun)
	var/list/loot_table_basic = list(/obj/item/gun/ballistic/shotgun)
	var/list/loot_table_rare = list(/obj/item/gun/ballistic/shotgun)
	var/list/loot_table_legendary = list(/obj/item/gun/ballistic/shotgun)
	var/list/loot_content


/obj/structure/closet/crate/loot/Initialize()
	//Check for an armour spawn
	if(prob(90))
		loot_content = loot_content + pickweight(loot_table_armor)
	//Check for a heal spawn
	if(prob(20))
		loot_content = loot_content +  pickweight(loot_table_heal)
	..()

/obj/structure/closet/crate/loot/PopulateContents()
	for(var/item in loot_content)
		new item(src)

///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/basic
	desc = "A basic loot crate."
	name = "basic loot crate"

/obj/structure/closet/crate/loot/basic/Initialize()
	var/list/loot_table = loot_table_basic + loot_table_rare + loot_table_legendary
	LAZYADD(loot_content,pickweight(loot_table))
	..()

/obj/structure/closet/crate/loot/basic/PopulateContents()
	for(var/item in loot_content)
		new item(src)

///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/rare
	desc = "A rare loot crate."
	name = "rare loot crate"

/obj/structure/closet/crate/loot/rare/Initialize()
	var/list/loot_table = loot_table_rare + loot_table_legendary
	LAZYADD(loot_content,pickweight(loot_table))
	..()

/obj/structure/closet/crate/loot/rare/PopulateContents()
	for(var/item in loot_content)
		new item(src)

///Basic lootcrate, only has basic, low chance of armour and healing items

/obj/structure/closet/crate/loot/legendary
	desc = "A legendary loot crate."
	name = "legendary loot crate"

/obj/structure/closet/crate/loot/legendary/Initialize()
	var/list/loot_table =  loot_table_legendary
	LAZYADD(loot_content,pickweight(loot_table))
	..()

/obj/structure/closet/crate/loot/legendary/PopulateContents()
	for(var/item in loot_content)
		new item(src)
