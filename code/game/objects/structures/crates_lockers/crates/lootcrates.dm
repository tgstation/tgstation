GLOBAL_LIST_INIT(externalareasstorm, list(
	/area/space,
	/area/space/nearstation,
	/area/hallway/secondary/entry,
	/area/solars/starboard/fore,
	/area/maintenance/solars/starboard/fore,
	/area/construction/mining/aux_base,
	/area/maintenance/starboard/fore,
	/area/security/checkpoint,
	/area/security/checkpoint/customs,
	/area/maintenance/disposal,
	/area/cargo/storage,
	/area/cargo/warehouse,
	/area/cargo/sorting,
	/area/security/checkpoint/supply,
	/area/security/prison,
	/area/security/prison/safe,
	/area/security/execution/education,
	/area/security/brig,
	/area/security/execution/transfer,
	/area/security/office,
	/area/command/heads_quarters/hos,
	/area/security/interrogation,
	/area/security/warden,
	/area/ai_monitored/security/armory,
	/area/security/range,
	/area/commons/fitness/recreation,
	/area/holodeck/rec_center,
	/area/solars/starboard/aft,
	/area/medical/psychology,
	/area/hallway/secondary/construction,
	/area/maintenance/solars/starboard/aft,
	/area/security/detectives_office/private_investigators_office,
	/area/service/theater/abandoned,
	/area/medical/virology,
	/area/medical/surgery,
	/area/medical/surgery/room_b,
	/area/command/heads_quarters/cmo,
	/area/medical/morgue,
	/area/maintenance/aft,
	/area/maintenance/port/aft,
	/area/security/checkpoint/customs/auxiliary,
	/area/hallway/secondary/exit/departure_lounge,
	/area/security/checkpoint/escape,
	/area/service/chapel/main,
	/area/service/chapel/office,
	/area/maintenance/solars/port/aft,
	/area/solars/port/aft,
	/area/service/library/abandoned,
	/area/science/storage,
	/area/science/mixing,
	/area/science/misc_lab,
	/area/science/research/abandoned,
	/area/maintenance/department/science,
	/area/science/misc_lab/range,
	/area/science/genetics,
	/area/service/abandoned_gambling_den,
	/area/maintenance/department/electrical,
	/area/engineering/main,
	/area/engineering/storage,
	/area/command/heads_quarters/ce,
	/area/security/checkpoint/engineering,
	/area/engineering/gravity_generator,
	/area/engineering/break_room,
	/area/engineering/storage_shared,
	/area/engineering/atmos,
	/area/maintenance/disposal/incinerator,
	/area/maintenance/solars/port/fore,
	/area/solars/port/fore,
	/area/engineering/atmos/upper,
	/area/maintenance/port/fore,
	/area/service/abandoned_gambling_den/secondary,
	/area/service/theater,
	/area/service/bar,
	/area/service/bar/atrium,
	/area/service/hydroponics/garden/abandoned,
	/area/service/electronic_marketing_den,
	/area/commons/vacant_room/office,
	/area/service/janitor,
	/area/commons/toilet/auxiliary))

GLOBAL_LIST_INIT(middleareastorm, list(
	/area/hallway/primary/port,
	/area/maintenance/port,
	/area/engineering/storage/tech,
	/area/commons/storage/primary,
	/area/service/hydroponics,
	/area/service/library,
	/area/commons/vacant_room/commissary,
	/area/science/xenobiology,
	/area/science/nanite,
	/area/science/genetics,
	/area/science/research,
	/area/science/server,
	/area/command/heads_quarters/rd,
	/area/science/robotics/lab,
	/area/science/robotics/mechbay,
	/area/science/lab,
	/area/security/checkpoint/science/research,
	/area/hallway/primary/aft,
	/area/medical/chemistry,
	/area/medical/pharmacy,
	/area/medical/medbay/central,
	/area/medical/treatment_center,
	/area/security/checkpoint/medical,
	/area/maintenance/starboard/aft,
	/area/commons/dorms,
	/area/commons/locker,
	/area/commons/toilet/restrooms,
	/area/maintenance/starboard,
	/area/security/courtroom,
	/area/service/lawoffice,
	/area/hallway/primary/starboard,
	/area/security/detectives_office,
	/area/cargo/miningoffice,
	/area/cargo/qm,
	/area/cargo/office,
	/area/hallway/primary/fore,
	/area/service/kitchen,
	/area/hallway/secondary/service))

GLOBAL_LIST_INIT(innerareastorm, list(
	/area/hallway/primary/central/aft,
	/area/hallway/primary/central/fore,
	/area/hallway/secondary/command,
	/area/ai_monitored/command/storage/eva,
	/area/command/gateway,
	/area/command/corporate_showroom,
	/area/command/heads_quarters/hop,
	/area/command/teleporter,
	/area/command/heads_quarters/captain/private,
	/area/command/heads_quarters/captain,
	/area/tcommsat/server,
	/area/tcommsat/computer,
	/area/command/heads_quarters/hop,
	/area/command/meeting_room/council,
	/area/command/bridge))





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
	src.add_filter("default",10, list("type"="rays","density" = 10, "size" = 32, "color" = "#00BFFF"))
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
	src.add_filter("default",10, list("type"="rays","density" = 10, "size" = 40, "color" = "#f18f1f"))
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
