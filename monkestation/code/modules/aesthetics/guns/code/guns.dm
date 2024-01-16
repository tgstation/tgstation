/obj/item/gun/energy/e_gun/advtaser
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/cfa_phalanx
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/mini
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/stun
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/old
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/hos
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/e_gun/dragnet
	worn_icon = null
	worn_icon_state = "gun"

/obj/item/gun/energy/ionrifle
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/energy.dmi'
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "\improper Peacekeeper combat shotgun"
	desc = "A semi-automatic Nanotrasen Peacekeeper shotgun with tactical furnishing and heavier internals meant for sustained fire. Lacks a threaded barrel."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	worn_icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_back.dmi'
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'
	inhand_icon_state = "shotgun_combat"
	inhand_x_dimension = 32
	inhand_y_dimension = 32

/obj/item/gun/grenadelauncher
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'

/obj/item/gun/ballistic/automatic/pistol/m1911
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	inhand_icon_state = "colt"
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'

/obj/item/gun/ballistic/revolver/mateba
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/ballistic/automatic/c20r
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/ballistic/automatic/m90
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
/obj/item/gun/ballistic/revolver/detective
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/ballistic/automatic/pistol/aps
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/ballistic/automatic/pistol
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/energy/e_gun/nuclear
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/nucgun.dmi'
	ammo_x_offset = 2
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'
	worn_icon_state = "gun"
	worn_icon = null

/obj/item/gun/energy/laser/thermal
	icon = 'icons/obj/guns/energy.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/energy/lasercannon
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/energy.dmi'
	fire_sound_volume = 100
	ammo_x_offset = 2
	charge_sections = 5
	inhand_icon_state = ""
	lefthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/modules/aesthetics/guns/icons/guns_righthand.dmi'

/obj/item/gun/energy/e_gun/nuclear/rainbow
	name = "fantastic energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell. This one seems quite fancy!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/rainbow, /obj/item/ammo_casing/energy/disabler/rainbow)

/obj/item/ammo_casing/energy/laser/rainbow
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/nucgun.dmi'
	select_name = "kill"
	projectile_type = /obj/projectile/beam/laser/rainbow

/obj/projectile/beam/laser/rainbow
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/nucgun.dmi'
	icon_state = "laser"

/obj/item/ammo_casing/energy/disabler/rainbow
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/nucgun.dmi'
	select_name = "disable"
	projectile_type = /obj/projectile/beam/disabler/rainbow

/obj/projectile/beam/disabler/rainbow
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/nucgun.dmi'
	icon_state = "laser"

/obj/item/gun/energy/e_gun/nuclear/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(pin)
		to_chat(user, span_warning("You probably want to do this on a new gun!"))
		return FALSE
	to_chat(user, "<font color='#ff2700'>T</font><font color='#ff4e00'>h</font><font color='#ff7500'>e</font> <font color='#ffc400'>g</font><font color='#ffeb00'>u</font><font color='#ebff00'>n</font> <font color='#9cff00'>s</font><font color='#75ff00'>u</font><font color='#4eff00'>d</font><font color='#27ff00'>d</font><font color='#00ff00'>e</font><font color='#00ff27'>n</font><font color='#00ff4e'>l</font><font color='#00ff75'>y</font> <font color='#00ffc4'>f</font><font color='#00ffeb'>e</font><font color='#00ebff'>e</font><font color='#00c4ff'>l</font><font color='#009cff'>s</font> <font color='#004eff'>q</font><font color='#0027ff'>u</font><font color='#0000ff'>i</font><font color='#2700ff'>t</font><font color='#4e00ff'>e</font> <font color='#9c00ff'>f</font><font color='#c400ff'>a</font><font color='#eb00ff'>n</font><font color='#ff00eb'>t</font><font color='#ff00c4'>a</font><font color='#ff009c'>s</font><font color='#ff0075'>t</font><font color='#ff004e'>i</font><font color='#ff0027'>c</font><font color='#ff0000'>!</font>")
	new /obj/item/gun/energy/e_gun/nuclear/rainbow(get_turf(user))
	qdel(src)

/obj/item/gun/energy/e_gun/nuclear/rainbow/update_overlays()
	. = ..()
	. += "[icon_state]_emagged"

/obj/item/gun/energy/e_gun/nuclear/rainbow/emag_act(mob/user, obj/item/card/emag/E)
	return FALSE

//BEAM SOUNDS
/obj/item/ammo_casing/energy
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/laser.ogg'

/obj/item/ammo_casing/energy/laser/pulse
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/pulse.ogg'

/obj/item/gun/energy/xray
	fire_sound_volume = 100

/obj/item/ammo_casing/energy/xray
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/xray_laser.ogg'

/obj/item/ammo_casing/energy/laser/accelerator
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/laser_cannon_fire.ogg'

/obj/item/gun/ballistic/automatic/sniper_rifle
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_gubman2.dmi'
	icon_state = "sniper"
	fire_delay = 60

/obj/item/gun/ballistic/automatic/sniper_rifle/syndicate
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_gubman2.dmi'
	icon_state = "sniper2"
	fire_delay = 55

/obj/item/gun/ballistic/automatic/sniper_rifle/modular
	name = "AUS-107 anti-materiel rifle"
	desc = "A devastating Aussec Armory heavy sniper rifle, fitted with a modern scope."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_gubman2.dmi'
	icon_state = "sniper"
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle.ogg'
	suppressed_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle_s.ogg'
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/sniper_rifle/modular/syndicate
	name = "'Caracal' anti-materiel rifle"  //we flop out
	desc = "A sleek, light bullpup .50 BMG sniper rifle with a reciprocating barrel, nicknamed 'Caracal' by Scarborough Arms. Its compact folding parts make it able to fit into a backpack, and its modular barrel can have a suppressor installed within it rather than as a muzzle extension. Its advanced scope accounts for all ballistic inaccuracies of a reciprocating barrel."
	icon_state = "sysniper"
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle.ogg'
	suppressed_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle_s.ogg'
	fire_delay = 40 //Delay reduced thanks to recoil absorption
	burst_size = 0.5
	recoil = 1
	can_suppress = TRUE
	can_unsuppress = TRUE
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/ballistic/automatic/sniper_rifle/modular/syndicate/give_manufacturer_examine()
	AddElement(/datum/element/manufacturer_examine, COMPANY_SCARBOROUGH)

/obj/item/gun/ballistic/automatic/sniper_rifle/modular/blackmarket  //Normal sniper but epic
	name = "SA-107 anti-materiel rifle"
	desc = "An illegal Scarborough Arms rendition of an Aussec Armory sniper rifle. This one has been fitted with a heavier duty scope, a sturdier stock, and has a removable muzzle brake that allows easy attachment of suppressors."
	icon_state = "sniper2"
	fire_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle.ogg'
	suppressed_sound = 'modular_skyrat/modules/aesthetics/guns/sound/sniperrifle_s.ogg'
	fire_sound_volume = 90
	vary_fire_sound = FALSE
	load_sound = 'sound/weapons/gun/sniper/mag_insert.ogg'
	rack_sound = 'sound/weapons/gun/sniper/rack.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = TRUE
	can_unsuppress = TRUE
	recoil = 1.8
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	fire_delay = 55 //Slightly smaller than standard sniper
	burst_size = 1
	slot_flags = ITEM_SLOT_BACK
	fire_select_modes = list(SELECT_SEMI_AUTOMATIC) //MONKESTATION EDIT CHANGE
	mag_display = TRUE

/obj/item/gun/ballistic/automatic/ar/modular
	name = "NT ARG-63"
	desc = "Nanotrasen's prime ballistic option based on the Stoner design, fitted with a light polymer frame and other tactical furniture - nicknamed 'Boarder' by Special Operations teams."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_gubman2.dmi'
	icon_state = "arg"
	inhand_icon_state = "arg"
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/ar/modular/solrifle
	name = "MCRS-5B ICWS"
	desc = "State of the art expensive combat rifle used by the SFMC. This one is a lighter model that fires 5.56, designed for use by pilots. Do it for her."
	icon_state = "mcrs"
	inhand_icon_state = "arg"
	selector_switch_icon = TRUE
	mag_type = /obj/item/ammo_box/magazine/m556
	can_suppress = FALSE
	burst_size = 5
	fire_delay = 0.4
	spread = 1
	w_class = WEIGHT_CLASS_NORMAL
	can_suppress = FALSE
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/energy/kinetic_accelerator
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/energy.dmi'

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Mosin Nagant 91-30"
	desc = "This piece of junk looks like something that could have been used 700 years ago. It feels slightly moist."
	sawn_desc = "An extremely sawn-off Mosin Nagant, popularly known as an \"obrez\". There was probably a reason it wasn't manufactured this short to begin with."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

/obj/item/gun/ballistic/rifle/boltaction/brand_new
	name = "\improper Mosin Nagant M39"
	desc = "A freshly-produced Mosin Nagant variant issued by Nanotrasen for their interns. You would rather not damage it."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	company_flag = COMPANY_NANOTRASEN

/obj/item/gun/ballistic/rifle/boltaction/brand_new/quartermaster
	name = "\improper FTU 'Archangel' Mosin"
	desc = "A very... Modernized MN91-30 rifle, the frame even feels a little flimsy. This thing was probably built with a conversion kit from spaceBay."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'
	icon_state = "bubba"
	worn_icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns_back.dmi'
	worn_icon_state = "bubba"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/bubba
	can_be_sawn_off = FALSE
	realistic = TRUE
	company_flag = null //Cargonia's own

/obj/item/ammo_box/magazine/internal/boltaction/bubba
	name = "mosin nagant extended internal magazine"
	desc = "How did you get it out?"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = CALIBER_A762
	max_ammo = 8
	multiload = TRUE

/obj/item/gun/ballistic/automatic/surplus
	name = "\improper Type-69 surplus rifle"
	desc = "One of countless obsolete ballistic rifles that still sees use as a cheap deterrent. Uses 10mm ammo and its bulky frame prevents one-hand firing."
	icon = 'modular_skyrat/modules/aesthetics/guns/icons/guns.dmi'

// GUBMAN3 - FULL BULLET RENAME
// i loathe the above

// overrides for .310 Strilka-derived ammo, e.g. lionhunter ammo, because you don't want to give security the ability to print infinite wallhack ammo, right?
/obj/item/ammo_casing/strilka310/lionhunter
	name = "hunter's rifle round"
	can_be_printed = FALSE // trust me bro you dont wanna give security homing wallhack Better Rubbers

/obj/item/ammo_casing/strilka310/enchanted
	name = "enchanted rifle round"
	can_be_printed = FALSE // these are Really Really Better Rubbers

// overrides for tgcode's .223 (formerly 5.56), used in the M90-gl - renamed to .277 Aestus
/obj/item/ammo_casing/a223
	name = ".277 Aestus casing"
	desc = "A .277 bullet casing."

/obj/item/ammo_casing/a223/phasic
	name = ".277 Aestus phasic casing"
	desc = "A .277 Aestus bullet casing.\
	<br><br>\
	<i>PHASIC: Ignores all surfaces except organic matter.</i>"
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_PHASIC

// shotgun ammo overrides moved to modular_skyrat\modules\shotgunrebalance\code\shotgun.dm

// overrides for tgcode .50cal, used in their sniper/anti-materiel rifles
/obj/item/ammo_casing/p50
	name = ".416 Stabilis polymer casing"
	desc = "A .416 bullet casing."
	advanced_print_req = TRUE // you are NOT printing more ammo for this without effort.
	// then again the offstations with ammo printers and sniper rifles come with an ammo disk anyway, so

/obj/item/ammo_casing/p50/disruptor
	name = ".416 Stabilis disruptor casing"
	desc = "A .416 bullet casing that specialises in sending the target to sleep rather than hell.\
	<br><br>\
	<i>DISRUPTOR: Forces humanoid targets to sleep, does heavy damage against cyborgs, EMPs struck targets.</i>"

/obj/item/ammo_casing/p50/penetrator
	name = ".416 Stabilis APFSDS ++P bullet casing"
	desc = "A .416 round casing designed to go through basically everything. A label warns not to use the round if the weapon cannot handle pressures greater than 85000 PSI.\
	<br><br>\
	<i>PENETRATOR: Goes through every surface, and every mob. Goes through everything. Yes, really.</i>"

// overrides for tgcode 4.6x30mm, used in the WT-550
/obj/item/ammo_casing/c46x30mm
	name = "8mm Usurpator bullet casing"
	desc = "An 8mm bullet casing."

/obj/item/ammo_casing/c46x30mm/ap
	name = "8mm Usurpator armor-piercing bullet casing"
	desc = "An 8mm armor-piercing bullet casing.\
	<br><br>\
	<i>ARMOR PIERCING: Increased armor piercing capabilities. What did you expect?</i>"
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c46x30mm/inc
	name = "8mm Usurpator incendiary bullet casing"
	desc = "An 8mm incendiary bullet casing.\
	<br><br>\
	<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

// overrides for tgcode .45, used in the M1911 and C20-r
/obj/item/ammo_casing/c45
	name = ".460 Ceres bullet casing"
	desc = "A .460 bullet casing."

/obj/item/ammo_casing/c45/ap
	name = ".460 Ceres armor-piercing bullet casing"
	desc = "An armor-piercing .460 bullet casing.\
	<br><br>\
	<i>ARMOR PIERCING: Increased armor piercing capabilities. What did you expect?</i>"
	custom_materials = AMMO_MATS_AP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c45/inc
	name = ".460 Ceres incendiary bullet casing"
	desc = "An incendiary .460 bullet casing.\
	<br><br>\
	<i>INCENDIARY: Leaves a trail of fire when shot, sets targets aflame.</i>"
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

// overrides for .50AE, used in the deagle
/obj/item/ammo_casing/a50ae
	name = ".454 Trucidator bullet casing"
	desc = "A .454 Trucidator bullet casing. Extremely powerful.\
	<br><br>\
	<i>HAND CANNON: Fired out of a handgun, deals disproportionately large damage.</i>"

// overrides for .357, used in the .357 revolver
/obj/item/ammo_casing/a357    //We can keep the Magnum classic.
	name = ".357 bullet casing"
	desc = "A .357 bullet casing.\
	<br><br>\
	<i>HAND CANNON: Fired out of a handgun, deals disproportionately large damage.</i>"

/obj/item/ammo_casing/a357/match
	desc = "A .357 bullet casing, manufactured to exceedingly high standards.\
	<br><br>\
	<i>MATCH: Ricochets everywhere. Like crazy.</i>"

/obj/item/ammo_casing/a357/phasic
	desc = "A .357 phasic bullet casing.\
	<br><br>\
	<i>PHASIC: Ignores all surfaces except organic matter.</i>"
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_PHASIC

/obj/item/ammo_casing/a357/heartseeker
	desc = "A .357 heartseeker bullet casing.\
	<br><br>\
	<i>HEARTSEEKER: Has homing capabilities, methodology unknown.</i>"
	advanced_print_req = TRUE
	custom_materials = AMMO_MATS_HOMING // meme ammo. meme print cost

// overrides for .38 Special, used in the .38 revolvers, including the det's
/obj/item/ammo_box/c38
	caliber = CALIBER_38

/obj/item/ammo_casing/c38/trac
	custom_materials = AMMO_MATS_TRAC
	advanced_print_req = TRUE

/obj/item/ammo_casing/c38/dumdum
	advanced_print_req = TRUE

/obj/item/ammo_casing/c38/hotshot
	custom_materials = AMMO_MATS_TEMP
	advanced_print_req = TRUE

/obj/item/ammo_casing/c38/iceblox
	custom_materials = AMMO_MATS_TEMP // plasma's wack.
	advanced_print_req = TRUE

// The ones above are the casings for the ammo, whereas the ones below are the actual projectiles that give you feedback when you're shot

/obj/projectile/bullet/a223
	name = ".277 Aestus bullet"

/obj/projectile/bullet/a223/phasic
	name = ".277 phasic bullet"

/obj/projectile/bullet/c9mm
	name = "9x25mm bullet"

/obj/projectile/bullet/c9mm/ap
	name = "9x25mm armor-piercing bullet"

/obj/projectile/bullet/c9mm/hp
	name = "9x25mm fragmenting bullet"

/obj/projectile/bullet/incendiary/c9mm
	name = "9x25mm incendiary bullet"

/obj/projectile/bullet/c45
	name = ".460 bullet"

/obj/projectile/bullet/c45/ap
	name = ".460 armor-piercing bullet"

/obj/projectile/bullet/incendiary/c45
	name = ".460 incendiary bullet"

/obj/projectile/bullet/c46x30mm
	name = "8mm Usurpator bullet"

/obj/projectile/bullet/c46x30mm/ap
	name = "8mm armor-piercing bullet"

/obj/projectile/bullet/incendiary/c46x30mm
	name = "8mm incendiary bullet"

/obj/projectile/bullet/p50
	name = ".416 Stabilis bullet"

/obj/projectile/bullet/p50/disruptor
	name = ".416 disruptor bullet"

/obj/projectile/bullet/p50/penetrator
	name = ".416 penetrator bullet"

/obj/projectile/bullet/a50ae
	name = ".454 Trucidator bullet"


// MAGAZINES UPDATED TO MATCH STUFF

/obj/item/ammo_box/magazine/wt550m9
	name = "\improper WT-550 magazine"
	desc = "A 20-round toploaded 8mm Usurpator magazine that fits neatly in the WT-550."

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "\improper WT-550 AP magazine"

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "\improper WT-550 IND magazine"

/obj/item/ammo_box/magazine/smgm45
	name = ".460 Ceres SMG magazine"
	desc = "A magazine chambered for .460 meant to fit in submachine guns."

/obj/item/ammo_box/magazine/smgm45/ap
	name = ".460 Ceres AP SMG magazine"

/obj/item/ammo_box/magazine/smgm45/incen
	name = ".460 Ceres IND SMG magazine"

/obj/item/ammo_box/magazine/tommygunm45
	name = "\improper Tommy Gun .460 Ceres drum"
	desc = "A disc magazine chambered for .460 Ceres."

/obj/item/ammo_box/magazine/m556
	name = ".277 Aestus toploading magazine"
	desc = "A toploading magazine chambered for .277 Aestus."

/obj/item/ammo_box/magazine/m556/phasic
	name = ".277 PHASE toploading magazine"

/obj/item/ammo_box/magazine/sniper_rounds
	name = "anti-materiel rifle magazine"
	desc = "A heavy magazine chambered for .416 Stabilis."

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	desc = "A magazine with soporific .416 Stabilis ammo, designed for happy days and dead quiet nights."

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "anti-materiel rifle ++P magazine"
	desc = "A heavy magazine with over the top, overpressurized, and frankly over the top .416 penetrator ammo."

/obj/item/ammo_box/magazine/m50
	name = ".454 Trucidator handcannon magazine"
	desc = "An absurdly THICK magazine possibly meant for a heavy hitting pistol, if you can call it that."
