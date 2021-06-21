
/obj/structure/closet/crate/loot
	desc = "A loot crate."
	name = "loot crate"
	icon_state = "weaponcrate"

	var/list/loot_table_armor = list(
		/obj/item/clothing/suit/armor/vest = 25,
		/obj/item/clothing/head/helmet/sec = 25,
		/obj/item/clothing/under/rank/security/officer = 20,
		/obj/item/clothing/suit/armor/bulletproof = 10,
		/obj/item/clothing/head/helmet/alt = 10,
		/obj/item/clothing/suit/armor/hos/trenchcoat = 10,
		/obj/item/clothing/under/syndicate = 15,
		/obj/item/clothing/suit/armor/vest/capcarapace/syndicate = 15,
		/obj/item/clothing/gloves/tackler/combat/insulated = 10,
		/obj/item/clothing/suit/space/hardsuit/ert/sec = 1
	)
	var/list/loot_table_melee = list(
		/obj/item/kitchen/knife/shiv = 18,
		/obj/item/kitchen/knife = 15,
		/obj/item/kitchen/knife/butcher = 10,
		/obj/item/kitchen/knife/combat = 5,
	)
	var/list/loot_table_heal = list(
		/obj/item/reagent_containers/pill/patch/libital = 20,
		/obj/item/reagent_containers/medigel/libital = 15,
		/obj/item/storage/firstaid/brute = 10,
		/obj/item/reagent_containers/hypospray/combat = 5,
		/obj/item/reagent_containers/hypospray/combat/nanites = 2)

	var/list/loot_table_basic = list(
		/obj/item/gun/ballistic/automatic/pistol=25,
		/obj/item/gun/ballistic/automatic/pistol/suppressed=20,
		/obj/item/gun/ballistic/automatic/pistol/toy/riot=20,
		/obj/item/gun/ballistic/rifle/boltaction/pipegun=20,
		/obj/item/gun/ballistic/revolver/detective=20)

	var/list/loot_table_rare = list(
		/obj/item/gun/ballistic/shotgun/lethal=8,
		/obj/item/gun/ballistic/automatic/surplus=9,
		/obj/item/gun/ballistic/automatic/pistol/m1911=8,
		/obj/item/gun/ballistic/automatic/wt550=9,
		/obj/item/gun/ballistic/automatic/plastikov=9)

	var/list/loot_table_legendary = list(
		/obj/item/gun/ballistic/automatic/sniper_rifle=2,
		/obj/item/gun/ballistic/revolver=2,
		/obj/item/gun/ballistic/automatic/pistol/deagle/gold=1,
		/obj/item/gun/ballistic/automatic/ar=1)
	var/list/loot_content


/obj/structure/closet/crate/loot/Initialize()
	//Check for an armour spawn
	if(prob(50))
		loot_content = loot_content + pickweight(loot_table_armor)
	//chance for a melee item
	if(prob(50))
		loot_content = loot_content + pickweight(loot_table_melee)
	//Check for a heal spawn
	if(prob(70))
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



//Handles the drop events

/datum/round_event_control/stray_cargo/fortnite
	name = "DROP EPICNESS"
	typepath = /datum/round_event/stray_cargo/fortnite
/datum/round_event/stray_cargo/fortnite
	possible_pack_types = list(/obj/structure/closet/crate/loot/basic)

///Apply the box pod skin
/datum/round_event/stray_cargo/fortnite/make_pod()
	var/obj/structure/closet/supplypod/S = new
	S.setStyle(STYLE_BOX)
	return S

/datum/round_event_control/stray_cargo/fortnite/rare
	name = "DROP RARE EPICNESS"
	typepath = /datum/round_event/stray_cargo/fortnite/rare

/datum/round_event/stray_cargo/fortnite/rare
	possible_pack_types = list(/obj/structure/closet/crate/loot/rare)
/datum/round_event_control/stray_cargo/fortnite/legendary
	name = "DROP LEGENDARY EPICNESS"
	typepath = /datum/round_event/stray_cargo/fortnite/legendary

/datum/round_event/stray_cargo/fortnite/legendary
	possible_pack_types = list(/obj/structure/closet/crate/loot/legendary)
