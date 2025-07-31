///Allowed equipment lists for anything that's worn as a suit
#define ANY_SUIT_STORAGE "any_suit"
#define ANY_SUIT_ALLOWED list( \
	/obj/item/clipboard, \
	/obj/item/flashlight, \
	/obj/item/tank/internals/emergency_oxygen, \
	/obj/item/tank/internals/plasmaman, \
	/obj/item/lighter, \
	/obj/item/pen, \
	/obj/item/modular_computer/pda, \
	/obj/item/toy, \
	/obj/item/radio, \
	/obj/item/storage/bag/books, \
	/obj/item/storage/fancy/cigarettes, \
	/obj/item/tank/jetpack/oxygen/captain, \
	/obj/item/stack/spacecash, \
	/obj/item/storage/wallet, \
	/obj/item/folder, \
	/obj/item/storage/box/matches, \
	/obj/item/cigarette, \
	/obj/item/gun/energy/laser/bluetag, \
	/obj/item/gun/energy/laser/redtag, \
	/obj/item/storage/belt/holster \
)
///Alphabetized suit storage types

#define ABDUCTOR_SUIT_STORAGE "abductor_suit"
#define ABDUCTOR_SUIT_ALLOWED list( \
	/obj/item/abductor, \
	/obj/item/melee/baton, \
	/obj/item/gun/energy, \
	/obj/item/restraints/handcuffs \
)

#define ATMOSPHERICS_SUIT_STORAGE "atmospherics_suit"
#define ATMOSPHERICS_SUIT_ALLOWED ENGINEERING_SUIT_STORAGE | list( \
	/obj/item/extinguisher, \
	/obj/item/tank/internals \
	/obj/item/fireaxe \
)

#define BOTANY_SUIT_STORAGE "botany_suit"
#define BOTANY_SUIT_ALLOWED list( \
	/obj/item/cultivator, \
	/obj/item/geneshears, \
	/obj/item/graft, \
	/obj/item/hatchet, \
	/obj/item/plant_analyzer, \
	/obj/item/reagent_containers/cup/beaker, \
	/obj/item/reagent_containers/cup/bottle, \
	/obj/item/reagent_containers/cup/tube, \
	/obj/item/reagent_containers/spray/pestspray, \
	/obj/item/reagent_containers/spray/plantbgone, \
	/obj/item/secateurs, \
	/obj/item/seeds, \
	/obj/item/storage/bag/plants, \
	/obj/item/tank/internals/emergency_oxygen \
)

#define CAPTAIN_SUIT_STORAGE "captain_suit"
#define CAPTAIN_SUIT_ALLOWED HEAD_OF_STAFF_SUIT_ALLOWED | SECURITY_SUIT_ALLOWED | list( \
	/obj/item/melee, \
	/obj/item/storage/belt/sheath/sabre, \
	/obj/item/disk, \
	/obj/item/reagent_containers/cup/glass/flask/gold \
)

///Allowed equipment for cargo outerwear (parka, QM coat)
#define CARGO_SUIT_STORAGE "cargo_suit"
#define CARGO_SUIT_ALLOWED list( \
	/obj/item/crowbar, \
	/obj/item/stamp, \
	/obj/item/storage/bag/mail, \
	/obj/item/universal_scanner, \
	/obj/item/tank/internals, \
	/obj/item/boxcutter, \
	/obj/item/dest_tagger, \
	/obj/item/hand_labeler, \
	/obj/item/stack/package_wrap, \
	/obj/item/switchblade \
)

#define CARP_SUIT_STORAGE "carp_suit"
#define CARP_SUIT_ALLOWED list( \
	/obj/item/gun/ballistic/rifle/boltaction/harpoon \
) | EVA_SUIT_ALLOWED

#define CE_SUIT_STORAGE "ce_suit"
#define CE_SUIT_ALLOWED HEAD_OF_STAFF_SUIT_ALLOWED | ATMOSPHERICS_SUIT_ALLOWED | ENGINEERING_SUIT_ALLOWED

//Allowed list for all chaplain suits
#define CHAPLAIN_SUIT_STORAGE "chaplain_suit"
#define CHAPLAIN_SUIT_ALLOWED list( \
	/obj/item/book/bible, \
	/obj/item/nullrod, \
	/obj/item/reagent_containers/cup/glass/bottle/holywater, \
	/obj/item/storage/fancy/candle_box, \
	/obj/item/gun/ballistic/bow/divine, \
	/obj/item/gun/ballistic/revolver/chaplain \
)

#define CHEF_SUIT_STORAGE "chef_suit"
#define CHEF_SUIT_ALLOWED list( \
	/obj/item/kitchen, \
	/obj/item/knife/kitchen, \
	/obj/item/storage/bag/tray \
)

#define CHEMISTRY_SUIT_STORAGE "chemistry_suit"
#define CHEMISTRY_SUIT_ALLOWED list( \
	/obj/item/reagent_containers/blood, \
	/obj/item/reagent_containers/dropper, \
	/obj/item/reagent_containers/cup/beaker, \
	/obj/item/reagent_containers/cup/bottle, \
	/obj/item/reagent_containers/cup/tube, \
	/obj/item/reagent_containers/hypospray, \
	/obj/item/reagent_containers/medigel, \
	/obj/item/reagent_containers/applicator, \
	/obj/item/reagent_containers/spray, \
	/obj/item/reagent_containers/syringe, \
	/obj/item/construction/plumbing, \
	/obj/item/gun/syringe/syndicate, \
	/obj/item/storage/pill_bottle \
)

#define CULT_SUIT_STORAGE "cult_suit"
#define CULT_SUIT_ALLOWED list( \
	/obj/item/tome, \
	/obj/item/melee/cultblade, \
	/obj/item/melee/sickly_blade/cursed, \
	/obj/item/tank/internals \
)

#define CURATOR_SUIT_STORAGE "curator_suit"
#define CURATOR_SUIT_ALLOWED list( \
	/obj/item/melee/curator_whip, \
	/obj/item/tank/internals \
)

///Allowed equipment lists for detective outerwear.
#define DETECTIVE_VEST_STORAGE "detective_vest"
#define DETECTIVE_VEST_ALLOWED list( \
	/obj/item/detective_scanner, \
	/obj/item/gun/ballistic, \
	/obj/item/gun/energy, \
	/obj/item/melee/baton, \
	/obj/item/reagent_containers/spray/pepper, \
	/obj/item/restraints/handcuffs, \
	/obj/item/taperecorder, \
	/obj/item/gun/ballistic/shotgun/automatic/combat/compact \
)

#define ENGINEERING_SUIT_STORAGE "engineering_suit"
#define ENGINEERING_SUIT_ALLOWED list( \
	/obj/item/blueprints, \
	/obj/item/storage/bag/construction, \
	/obj/item/gun/ballistic/rifle/rebarxbow, \
	/obj/item/storage/bag/rebar_quiver, \
	/obj/item/storage/bag/construction \
) | GLOB.tool_items.Copy()

#define EVA_SUIT_STORAGE "eva_suit"
#define EVA_SUIT_ALLOWED list( \
	/obj/item/tank/internals, \
	/obj/item/gps, \
	/obj/item/tank/jetpack \
)

#define FIRESUIT_STORAGE "firesuit"
#define FIRESUIT_ALLOWED list( \
	/obj/item/crowbar, \
	/obj/item/extinguisher, \
	/obj/item/fireaxe \
	/obj/item/tank/internals \
)

#define FLOOR_SIGN_SUIT_STORAGE "floor_sign_suit"
#define FLOOR_SIGN_SUIT_ALLOWED list( \
	/obj/item/mop, \
	/obj/item/gun/ballistic/rifle/boltaction/pipegun \
)


#define HEAD_OF_STAFF_SUIT_STORAGE "head_of_staff_suit"
#define HEAD_OF_STAFF_SUIT_ALLOWED list( \
	/obj/item/assembly/flash/handheld, \
	/obj/item/door_remote, \
	/obj/item/gun/energy/e_gun, \
	/obj/item/gun/energy/laser, \
	/obj/item/melee/baton, \
	/obj/item/tank/internals, \
	/obj/item/restraints/handcuffs, \
	/obj/item/megaphone, \
	/obj/item/stamp, \
)

#define HOP_SUIT_STORAGE "hop_suit"
// the irressistible urge of every HoP to vanish mysteriously on an odyssey
#define HOP_SUIT_ALLOWED HEAD_OF_STAFF_SUIT_ALLOWED | list( \
	/obj/item/gps \
)

#define MEDICAL_SUIT_STORAGE "medical_suit"
#define MEDICAL_SUIT_ALLOWED list( \
	/obj/item/bikehorn/rubberducky, \
	/obj/item/blood_filter, \
	/obj/item/bonesetter, \
	/obj/item/cautery, \
	/obj/item/circular_saw, \
	/obj/item/clothing/glasses, \
	/obj/item/clothing/gloves, \
	/obj/item/clothing/neck/stethoscope, \
	/obj/item/clothing/mask/breath, \
	/obj/item/clothing/mask/muzzle, \
	/obj/item/clothing/mask/surgical, \
	/obj/item/clothing/head/utility/surgerycap, \
	/obj/item/construction/plumbing, \
	/obj/item/dnainjector, \
	/obj/item/geiger_counter, \
	/obj/item/gun/syringe/syndicate, \
	/obj/item/healthanalyzer, \
	/obj/item/hemostat, \
	/obj/item/holosign_creator/medical, \
	/obj/item/implant, \
	/obj/item/implantcase, \
	/obj/item/implanter, \
	/obj/item/lazarus_injector, \
	/obj/item/pinpointer/crew, \
	/obj/item/plunger, \
	/obj/item/reagent_containers/blood, \
	/obj/item/reagent_containers/dropper, \
	/obj/item/reagent_containers/cup/beaker, \
	/obj/item/reagent_containers/cup/bottle, \
	/obj/item/reagent_containers/cup/tube, \
	/obj/item/reagent_containers/hypospray, \
	/obj/item/reagent_containers/medigel, \
	/obj/item/reagent_containers/applicator, \
	/obj/item/reagent_containers/spray, \
	/obj/item/reagent_containers/syringe, \
	/obj/item/retractor, \
	/obj/item/scalpel, \
	/obj/item/shears, \
	/obj/item/stack/medical, \
	/obj/item/stack/sticky_tape, \
	/obj/item/stamp, \
	/obj/item/sensor_device, \
	/obj/item/storage/pill_bottle, \
	/obj/item/surgical_drapes, \
	/obj/item/surgicaldrill, \
	/obj/item/wrench/medical, \
	/obj/item/knife/ritual, \
	/obj/item/flesh_shears, \
	/obj/item/blood_scanner, \
	/obj/item/reflexhammer, \
	/obj/item/storage/bag/bio \
)

//Allowed list for all mining suits
#define MINING_SUIT_STORAGE "mining_suit"
#define MINING_SUIT_ALLOWED list( \
	/obj/item/t_scanner/adv_mining_scanner, \
	/obj/item/melee/cleaving_saw, \
	/obj/item/climbing_hook, \
	/obj/item/grapple_gun, \
	/obj/item/tank/internals, \
	/obj/item/gun/energy/recharge/kinetic_accelerator, \
	/obj/item/kinetic_crusher, \
	/obj/item/knife, \
	/obj/item/mining_scanner, \
	/obj/item/organ/monster_core, \
	/obj/item/storage/bag/ore, \
	/obj/item/pickaxe, \
	/obj/item/resonator, \
	/obj/item/spear \
)

#define RADSUIT_STORAGE "radsuit"
#define RADSUIT_ALLOWED list( \
	/obj/item/geiger_counter, \
	/obj/item/tank/internals \
)

///Allowed equipment lists for security outerwear.
#define SECURITY_SUIT_STORAGE "security_vest"
#define SECURITY_SUIT_ALLOWED list( \
	/obj/item/gun/ballistic, \
	/obj/item/gun/energy, \
	/obj/item/knife/combat, \
	/obj/item/melee/baton, \
	/obj/item/reagent_containers/spray/pepper, \
	/obj/item/restraints/handcuffs, \
	/obj/item/gun/ballistic/shotgun/automatic/combat/compact \
)

#define SECURITY_EVA_SUIT_STORAGE "security_eva_suit"
#define SECURITY_EVA_SUIT_ALLOWED EVA_SUIT_ALLOWED | SECURITY_SUIT_ALLOWED

///Allowed equipment lists for security outerewear; coats can carry bigger tanks
///in exchange for sacrificing protection
#define SECURITY_WINTER_COAT_STORAGE "security_winter_coat"
#define SECURITY_WINTER_COAT_ALLOWED SECURITY_EVA_SUIT_ALLOWED

#define TOUGH_CUSTOMER_SUIT_STORAGE "tough_customer"
#define TOUGH_CUSTOMER_SUIT_ALLOWED list( \
	/obj/item/gun/ballistic/automatic/pistol, \
	/obj/item/gun/ballistic/revolver, \
	/obj/item/gun/ballistic/revolver/c38/detective, \
	/obj/item/gun/ballistic/rifle/boltaction/pipegun, \
	/obj/item/gun/energy/laser/musket \
)


