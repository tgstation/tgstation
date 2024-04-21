/datum/uplink_category/implants
	name = "Implants"
	weight = 3


/datum/uplink_item/implants
	category = /datum/uplink_category/implants
	surplus = 50

/datum/uplink_item/implants/reusableautosurgeon
	name = "Syndicate Autosurgeon"
	desc = "A multi-use autosurgeon for surgically implanting whatever you want into yourself. \
			Works on both organs and cybernetics. Often useful for installing multiple of our cybernetics."
	item = /obj/item/autosurgeon/syndicate
	cost = 4

/datum/uplink_item/implants/reusableautosurgeon/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		cost /= 2

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "Can be activated to release common restraints such as handcuffs, legcuffs, and even bolas tethered around the legs."
	item = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/freedom/New()
	. = ..()
	desc += " Implant has enough energy for [FREEDOM_IMPLANT_CHARGES] uses before it becomes inert and harmlessly self-destructs."

/datum/uplink_item/implants/radio
	name = "Internal Syndicate Radio Implant"
	desc = "An implant injected into the body, allowing the use of an internal Syndicate radio. \
			Used just like a regular headset, but can be disabled to use external headsets normally and to avoid detection."
	item = /obj/item/storage/box/syndie_kit/imp_radio
	cost = 4
	restricted = TRUE


/datum/uplink_item/implants/stealthimplant
	name = "Stealth Implant"
	desc = "This one-of-a-kind implant will make you almost invisible if you play your cards right. \
			On activation, it will conceal you inside a chameleon cardboard box that is only revealed once someone bumps into it."
	item = /obj/item/storage/box/syndie_kit/imp_stealth
	cost = 8

/datum/uplink_item/implants/storage
	name = "Storage Implant"
	desc = "An implant injected into the body, and later activated at the user's will. It will open a small bluespace \
			pocket capable of storing two regular-sized items."
	item = /obj/item/storage/box/syndie_kit/imp_storage
	cost = 8

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "An implant injected into the body, and later activated at the user's will. Has no telecrystals and must be charged by the use of physical telecrystals. \
			Undetectable (except via surgery), and excellent for escaping confinement."
	item = /obj/item/storage/box/syndie_kit // the actual uplink implant is generated later on in spawn_item
	cost = UPLINK_IMPLANT_TELECRYSTAL_COST
	// An empty uplink is kinda useless.
	surplus = 0
	restricted = TRUE
	purchasable_from = parent_type::purchasable_from & ~UPLINK_SPY

/datum/uplink_item/implants/uplink/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/obj/item/storage/box/syndie_kit/uplink_box = ..()
	uplink_box.name = "Uplink Implant Box"
	new /obj/item/implanter/uplink(uplink_box, uplink_handler)
	return uplink_box

/datum/uplink_item/implants/weapons_auth
	name = "Syndicate Firearm Authentication Implant"
	desc = "A singular implant, it's required for using most advanced syndicate weaponry such as the C-20r or the Bulldog. \
			Only really useful if you're in close contact with some of our more heavily armed operatives, likely of the nuclear variety."
	item = /obj/item/storage/box/syndie_kit/syndiefirearmauth
	progression_minimum = 20 MINUTES
	cost = 1
	surplus = 0
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY)

/datum/uplink_item/implants/adrenalin
	name = "Adrenaline Implant"
	desc = "A single implanter, containing an adrenaline implant. When activated, it infuses the host's bloodstream with \
			10 units of Synaptizine, Omnizine, and Stimulants leading to massive healing, increased speed, and near-immunity to stuns for a limited time. \
			Can be used 3 times."
	item = /obj/item/storage/box/syndie_kit/adrenalineimplant
	cost = 7
	surplus = 15

/datum/uplink_item/implants/regenerative
	name = "Regenerative Implant"
	desc = "A surgical implant that when inserted into the body will slowly repair the host. Allowing for slow recovery of all forms of damage. \
			Beware of health scanners, as constant supervision of your health may give you away. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/regenerativebetter/hidden/single_use
	cost = 8
	surplus = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/implants/chemstorage
	name = "Chemical Storage Implant"
	desc = "A box containing a chemical storage implant case, an implanter, a syringe, and a beaker. You'll have to supply your own chemicals though. \
			To apply: inject chemicals (up to 50u) into the implant case using the syringe, then use the implanter to remove the implant and inject into target or yourself. \
			Targets can only have one of these implants at any given time. When activated, the chemicals within the implant are injected directly into the host's bloodstream."
	item = /obj/item/storage/box/syndie_kit/chem_storage_implant
	cost = 1
	surplus = 60

/datum/uplink_item/implants/syndiantidrop
	name = "Syndicate Anti-Drop Implant"
	desc = "An anti-drop implant which can be activated to bind whatever is in your hands TO YOUR HANDS, preventing disarms and any attempts to drop the item. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/anti_drop/hidden/single_use
	progression_minimum = 10 MINUTES
	cost = 4
	surplus = 10

/datum/uplink_item/implants/reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness, and can even repair your body and \
			defibrillate your heart should you perish. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/reviver/hidden/single_use
	cost = 6
	surplus = 20
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/implants/syndiantistun
	name = "Syndicate CNS Rebooter Implant"
	desc = "A CNS Rebooter implant specifically designed to hide from medical scans of all kinds. When installed, it'll reduce the effectiveness of stuns upon the owner. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/anti_stun/hidden/single_use
	progression_minimum = 10 MINUTES
	cost = 6
	surplus = 40
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/implants/syndisignaller
	name = "Signaler Implant"
	desc = "An hidden implant which can be activated to reveal a signaler. For the most devious of scenario-makers. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/signaler/hidden/single_use
	cost = 1
	surplus = 0

/datum/uplink_item/implants/toolsets
	name = "Toolset Implants"
	desc = "A multisurgeon containing both an arm-concealed toolset implant and a surgical toolset. Comes with an autosurgeon."
	item = /obj/item/multisurgeon/toolsets
	cost = 2
	surplus = 30

/datum/uplink_item/implants/esword
	name = "Hardlight Blade Implant"
	desc = "An autosurgeon containing a hardlight blade implant, has the same effectiveness as a energy sword but has no defensive abilities. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/esword/hidden/single_use
	progression_minimum = 30 MINUTES
	cost = 10
	surplus = 40

/datum/uplink_item/implants/strength
	name = "S.A.E.M Implants"
	desc = "A multisurgeon containing two strong-arm empowered musculature implants. \
			These implants grant the arms of it's user increased punching power, increasing it's damage toward body and stamina. \
			Also knocks people around easily."
	item = /obj/item/multisurgeon/syndicate/muscle/single_use
	progression_minimum = 10 MINUTES
	cost = 6
	surplus = 30

/datum/uplink_item/implants/buster
	name = "Buster Arm Implants"
	desc = "A multisurgeon containing two buster-arm empowered musculature implants that double as grappling hooks. \
			These implants grant the arms of it's user increased punching power, increasing it's damage toward body and stamina greatly. \
			Also knocks people around easily and can cause them to crash harmfully into walls and people. \
			Activate the implant with nothing in hand to reveal a grappling hook capable of grabbing people and pulling them close, comes with two hooks."
	item = /obj/item/multisurgeon/syndicate/muscle/buster/single_use
	progression_minimum = 30 MINUTES
	cost = 25
	surplus = 10
	purchasable_from = ~UPLINK_SPY // Letting this pass as a bounty would be hellish. Bounties ain't hard enough for this to be reasonably earned.

/datum/uplink_item/implants/gasharpoon
	name = "Garsharpoon Implant"
	desc = "A heavily modified harpoon gun that automatically synthesizes incredibly sharp harpoons for ammunition. \
			Fits within your arm for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/gasharpoon/hidden/single_use
	progression_minimum = 20 MINUTES
	cost = 10
	surplus = 20

/datum/uplink_item/implants/kravmaga
	name = "Krav Maga Implant"
	desc = "A single sterile implanter containing a neural datachip containing extensive education of Krav Maga, an effective martial art. \
			Allows the user to 'toggle' knowledge over Krav Maga, allowing you to conceal the martial arts gained."
	item = /obj/item/storage/box/syndie_kit/krav_maga
	progression_minimum = 30 MINUTES
	cost = 12
	surplus = 10

/datum/uplink_item/implants/lifesupport
	name = "Life-Support Implants"
	desc = "A breathing tube and nutriment pump PLUS implant within one multisurgeon. You'll never have to eat or wear a mask again. Comes with an autosurgeon."
	item = /obj/item/multisurgeon/lifesupport
	cost = 3
	surplus = 20

/datum/uplink_item/implants/medicalhud
	name = "Syndicate MedHUD Implant"
	desc = "A cybersun industries branded MedicalHUD implant, comes with a one-use autosurgeon for quick installation. Only one HUD implant can be installed per agent. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/contraband_medhud
	cost = 1
	surplus = 0

/datum/uplink_item/implants/diagnostichud
	name = "Syndicate DiagnosticHUD Implant"
	desc = "A cybersun industries branded DiagnosticHUD implant, comes with a one-use autosurgeon for quick installation. Only one HUD implant can be installed per agent. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/contraband_diaghud
	cost = 1
	surplus = 0

/datum/uplink_item/implants/securityhud
	name = "Syndicate SecHUD Implant"
	desc = "A cybersun industries branded SecurityHUD implant, comes with a one-use autosurgeon for quick installation. Only one HUD implant can be installed per agent. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/contraband_sechud
	cost = 2
	surplus = 10

/datum/uplink_item/implants/wasps
	name = "Wasp Revenge Implant"
	desc = "An implanter containing a special bluespace container that shall release 5 of our finest toxic specimens upon your death. \
			The implant does NOT expire upon death, and if revived will activate again upon your next death. \
			Works well as a final 'Fuck-you' to whoever killed you."
	item = /obj/item/storage/box/syndie_kit/waspimplant
	cost = 2
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/implants/waspsmacro
	name = "Macro Wasp Revenge Implant"
	desc = "An implanter containing a special bluespace container that shall release 20 of our finest toxic specimens upon your death. \
			The implant does NOT expire upon death, and if revived will activate again upon your next death. \
			Works EXCEPTIONALLY well as a final 'Fuck-you' to whoever killed you. Pray you get revived for maximum carnage."
	item = /obj/item/storage/box/syndie_kit/waspimplantmacro
	progression_minimum = 30 MINUTES
	cost = 8
	surplus = 10
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/implants/tesla
	name = "Flyzapper Implant"
	desc = "An implanter containing a special tesla coil which discharges biological lightning upon your death. \
			The implant does NOT expire upon death, and if revived will activate again upon your next death. \
			Electrocutes everyone nearby upon it's activation."
	item = /obj/item/storage/box/syndie_kit/teslaimplant
	cost = 2
	surplus = 50

/datum/uplink_item/implants/teslamacro
	name = "Macro Flyzapper Implant"
	desc = "An implanter containing a special tesla coil which discharges biological lightning upon your death. \
			The implant does NOT expire upon death, and if revived will activate again upon your next death. \
			Electrocutes everyone in a massive area around you upon it's activation, capable of killing people en-mass."
	item = /obj/item/storage/box/syndie_kit/teslaimplantmacro
	progression_minimum = 30 MINUTES
	cost = 8
	surplus = 10

/datum/uplink_item/implants/flash
	name = "Photon Projector Implant"
	desc = "An arm-mounted flash, perfect for those pesky silicons in a pinch. The bulb will replace itself over time. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/flash/hidden/single_use
	progression_minimum = 10 MINUTES
	cost = 6
	surplus = 25

/datum/uplink_item/implants/jumpshoes
	name = "Jumpshoes Implants"
	desc = "A pair of cybernetic jumpshoes for each leg, allows you to dash forward a short distance every 6 seconds. \
			Comes with a one-use multisurgeon."
	item = /obj/item/multisurgeon/jumpboots
	cost = 5
	surplus = 0

/datum/uplink_item/implants/airshoes
	name = "Airshoes Implants"
	desc = "A pair of cybernetic airshoes for each leg, allows you to dash forward a medium distance every 4 seconds. \
			Comes with a one-use multisurgeon."
	item = /obj/item/multisurgeon/airshoes
	progression_minimum = 15 MINUTES
	cost = 8
	surplus = 40

/datum/uplink_item/implants/noslipall
	name = "No-Slip Implants"
	desc = "A pair of highly advanced cybernetics which directly attach to the host's nervous system. \
			When the cybernetics detect the host is slipping, they'll quickly manipulate the host's muscles to avoid a fall. \
			Comes with a one-use multisurgeon."
	item = /obj/item/multisurgeon/noslipall
	progression_minimum = 20 MINUTES
	cost = 12
	surplus = 25

/datum/uplink_item/implants/magboots
	name = "Magboots Implants"
	desc = "A pair of highly experimental magnetic cybernetics which are to be installed within the user's legs. \
			When installed, the host will be able to toggle the magnetics within the cybernetics, attaching to the floor as if they were wearing magboots. \
			Comes with a one-use multisurgeon."
	item = /obj/item/multisurgeon/magboots
	progression_minimum = 15 MINUTES
	cost = 8
	surplus = 10

/datum/uplink_item/implants/mantis
	name = "G.O.R.L.E.X. Mantis Blade"
	desc = "One G.O.R.L.E.X Mantis blade implant able to be retracted inside your body at will for easy storage and concealing. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/syndie_mantis
	cost = 6
	surplus = 50
	purchasable_from = ~UPLINK_SPY
	progression_minimum = 5 MINUTES

/datum/uplink_item/implants/makarov_implant
	name = "Makarov Arm implant"
	desc = "A modified version of the Makarov pistol placed inside of the forearm to allow for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/makarov_implant
	cost = 9
	surplus = 20

/datum/uplink_item/implants/m1911_implant
	name = "M1911 Arm implant"
	desc = "A modified version of the M1911 pistol placed inside of the forearm to allow for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/m1911_implant
	cost = 8
	surplus = 20

/datum/uplink_item/implants/deagle_implant
	name = "Desert Eagle Arm implant"
	desc = "A modified version of the Desert Eagle placed inside of the forearm to allow for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/deagle_implant
	cost = 12
	surplus = 20

/datum/uplink_item/implants/viper_implant
	name = "Viper Arm implant"
	desc = "A modified version of the Viper pistol placed inside of the forearm to allow for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/viper_implant
	cost = 10
	surplus = 20

/datum/uplink_item/implants/cobra_implant
	name = "Cobra Arm implant"
	desc = "A modified version of the Cobra pistol placed inside of the forearm to allow for easy concealment. Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/cobra_implant
	progression_minimum = 5 MINUTES
	cost = 9
	surplus = 20

/datum/uplink_item/implants/spinaloverclock
	name = "Neural Overclocker Implant"
	desc = "Stimulates your central nervous system in order to enable you to perform muscle movements faster. Careful not to overuse it. \
			Comes with an autosurgeon."
	item = /obj/item/autosurgeon/syndicate/spinalspeed
	cost = 14
	surplus = 0
	limited_stock = 1
	progression_minimum = 30 MINUTES

/datum/uplink_item/implants/emp_shield
	name = "EMP Shield Implant"
	desc = "Developed by Cybersun to assist with the S.E.L.F. movement, this implant will protect you and your insides from electromagnetic interference. \
			Due to technical limitations, it will overload and shut down for a short time if triggered too often."
	item = /obj/item/storage/box/syndie_kit/emp_shield
	cost = 4
	surplus = 20
	progression_minimum = 10 MINUTES

/datum/uplink_item/implants/hammerimplant
	name = "Vxtvul Hammer Implant"
	desc = "An implant which will fold a Vxtvul hammer into your hands upon injection. \
			This hammer can be retracted and wielded in two hands as an effective armor-piercing weapon. \
			It can be charged by the user's concentration, which permits a single blow that will decimate construction, \
			fling bodies, and heavily damage mechs. Vir'ln krx'tai, lost one. Comes with an autosurgeon."
	cost = 16
	surplus = 5
	progression_minimum = 35 MINUTES
	item = /obj/item/autosurgeon/syndicate/syndie_hammer
