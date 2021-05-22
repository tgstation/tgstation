/obj/item/clothing/suit/armor/skeledoom
	name = "skeleton suit"
	desc = "An armor suit with a skeleton print on it. Spooky!"
	icon_state = "skeleton"
	inhand_icon_state = "skeleton"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	clothing_flags = THICKMATERIAL

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/suit/armor/skeledoom/cryo
	icon_state = "skeleton_cryo"
	cold_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/gloves/skeleton
	name = "skeleton gloves"
	desc = "Black gloves with bone print of them and a bunch of odd electronics attached to the fingertips. Strange."
	icon_state = "skeleton"
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/skeleton/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		ADD_TRAIT(user, TRAIT_ROBOTIC_FRIEND, SUPERHERO_TRAIT)
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/hack)

/obj/item/clothing/gloves/skeleton/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		REMOVE_TRAIT(user, TRAIT_ROBOTIC_FRIEND, SUPERHERO_TRAIT)
		UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/clothing/gloves/skeleton/proc/hack(mob/living/carbon/human/H, atom/A, proximity)
	if(!proximity)
		return

	if(!istype(A, /mob/living/simple_animal/bot))
		return

	var/mob/living/simple_animal/bot/bot = A
	H.visible_message("<span class='warning'>[H] presses [H.p_their()] fingertips against [bot]'s hatch and [bot.p_they()] starts buzzing oddly.</span>", "<span class='notice'>As you press fingertips against [bot]'s hatch, [src]'s circuits start overloading [bot]'s sensor systems.</span>")
	if(!do_after(H, 4 SECONDS, target = bot))
		return

	to_chat("<span class='notice'>You feel soft buzzing underneath your hand and remove it from [bot]. Now [bot] sees everybody except you as target.</span>")
	bot.emag_act(H)
	bot.emag_act(H) //We hack them twice for aggro mode

/obj/item/clothing/mask/gas/skeleton
	name = "skeleton gas mask"
	desc = "Spooky."
	icon_state = "death"

/obj/item/clothing/head/beret/black/skeledoom
	name = "armored black beret"
	desc = "An armored black beret, perfect for badass snipers."
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/head/beret/black/skeledoom/cryo //He gets a bootleg version of wintercoat because... dunno, just thought that it's going to be funny.
	name = "armored black hood"
	desc = "A black hood separated from a coat. Not very useful nor comfortable."
	icon_state = "hood_hos"
	icon = 'icons/obj/clothing/head/winterhood.dmi'
	worn_icon = 'icons/mob/clothing/head/winterhood.dmi'
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/armor/skeledoom/Initialize()
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/armor/skeledoom/cryo/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

//Hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/syndi/skeledoom
	name = "skeleton hardsuit helmet"
	desc = "A dual-mode advanced helmet with a skeleton print. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet with a skeleton print. It is in combat mode."
	icon_state = "hardsuit1-skeleton"
	inhand_icon_state = "s_helmet"
	hardsuit_type = "skeleton"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/clothing/suit/space/hardsuit/syndi/skeledoom
	name = "skeleton hardsuit"
	desc = "A dual-mode advanced  hardsuit with a skeleton print. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit with a skeleton print. It is in combat mode."
	icon_state = "hardsuit1-skeleton"
	inhand_icon_state = "s_suit"
	hardsuit_type = "skeleton"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/skeledoom

	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 60, BOMB = 55, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

/obj/item/gun/ballistic/automatic/sniper_rifle/skeledoom
	name = "modified sniper rifle"
	desc = "A modified .50 sniper rifle with a dna-locked pin and a suppressor. It has \"This is my gun, fuck off.\" written on the grip."
	can_suppress = TRUE
	can_unsuppress = FALSE
	fire_delay = 2 //Speedy!
	pin = /obj/item/firing_pin/dna

/obj/item/gun/ballistic/automatic/sniper_rifle/skeledoom/Initialize()
	. = ..()
	var/obj/item/suppressor/suppressor = new(src)
	install_suppressor(suppressor)
	qdel(magazine)
	magazine = new /obj/item/ammo_box/magazine/sniper_rounds/taser(src)

/obj/projectile/bullet/p50/smoke
	name =".50 smoke bullet"
	armour_penetration = 15
	damage = 10
	dismemberment = 0
	paralyze = 0
	breakthings = FALSE

/obj/projectile/bullet/p50/smoke/on_hit(atom/target, blocked = FALSE)
	playsound(src, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(3, src)
	smoke.start()
	qdel(smoke)
	. = ..()

/obj/item/ammo_casing/p50/smoke
	name = ".50 smoke bullet casing"
	desc = "A .50 bullet casing, containing a small mix that creates smoke upon impact."
	projectile_type = /obj/projectile/bullet/p50/smoke
	harmful = FALSE

/obj/item/ammo_box/magazine/sniper_rounds/smoke
	name = "sniper rounds (Smoke)"
	desc = "Smoke sniper rounds, designed for professional bee hunters."
	icon_state = "smoker"
	base_icon_state = "smoker"
	ammo_type = /obj/item/ammo_casing/p50/smoke
	max_ammo = 5
	caliber = CALIBER_50

/obj/item/ammo_casing/p50/taser
	name = ".50 taser bullet casing"
	desc = "A modified .50 bullet casing that will turn kinetical energy into electricity, creating a small taser bolt."
	projectile_type = /obj/projectile/energy/electrode
	harmful = FALSE

/obj/item/ammo_box/magazine/sniper_rounds/taser
	name = "sniper rounds (Taser)"
	desc = "Taser sniper rounds, perfect for pacifists and security."
	icon_state = "taser"
	base_icon_state = "taser"
	ammo_type = /obj/item/ammo_casing/p50/taser
	max_ammo = 5
	caliber = CALIBER_50

/obj/projectile/bullet/p50/net
	name =".50 net bullet"
	armour_penetration = 0
	damage = 0
	dismemberment = 0
	paralyze = 0
	breakthings = FALSE

/obj/projectile/bullet/p50/net/on_hit(atom/target, blocked = FALSE)
	if(!isliving(target))
		return ..()
	var/mob/living/net_target = target
	if(locate(/obj/structure/energy_net) in net_target.drop_location())
		return ..()
	var/obj/structure/energy_net/net = new (net_target.drop_location())
	net.affecting = net_target
	if(net_target.buckled)
		net_target.buckled.unbuckle_mob(firer, TRUE)
	net.buckle_mob(net_target, TRUE)
	. = ..()

/obj/item/ammo_casing/p50/net
	name = ".50 net bullet casing"
	desc = "A .50 bullet casing with an energy net projector attached to them."
	projectile_type = /obj/projectile/bullet/p50/net
	harmful = FALSE

/obj/item/ammo_box/magazine/sniper_rounds/net
	name = "sniper rounds (Net)"
	desc = "Smoke sniper rounds, designed for professional bee hunters."
	icon_state = "net_sniper"
	base_icon_state = "net_sniper"
	ammo_type = /obj/item/ammo_casing/p50/net
	max_ammo = 3
	caliber = CALIBER_50

/obj/item/reagent_containers/hypospray/medipen/beepen
	name = "anti-bee medipen"
	desc = "Contains a special mix of chemicals that will quickly purge all bee toxins from the body."
	icon_state = "beepen"
	inhand_icon_state = "medipen"
	base_icon_state = "beepen"
	volume = 40
	amount_per_transfer_from_this = 40
	list_reagents = list(/datum/reagent/medicine/calomel = 2, /datum/reagent/medicine/c2/multiver = 10, /datum/reagent/medicine/polypyr = 5, /datum/reagent/medicine/leporazine = 8, /datum/reagent/medicine/silibinin = 15)

/obj/item/storage/belt/bee_hunter
	name = "bee hunter belt"
	desc = "A belt for holding everything a professional bee hunter needss."
	icon_state = "grenadebeltnew"
	inhand_icon_state = "security"
	worn_icon_state = "grenadebeltnew"

/obj/item/storage/belt/bee_hunter/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 20
	STR.max_combined_w_class = 60
	STR.display_numerical_stacking = TRUE
	STR.set_holdable(list(/obj/item/ammo_box/magazine/sniper_rounds,
						  /obj/item/reagent_containers/hypospray/medipen/beepen,
						  /obj/item/grenade,
						  /obj/item/restraints/handcuffs
					))

/obj/item/storage/belt/bee_hunter/full/PopulateContents()
	for(var/i = 1 to 3)
		new /obj/item/ammo_box/magazine/sniper_rounds/net(src)
		new /obj/item/ammo_box/magazine/sniper_rounds/taser(src)
		new /obj/item/ammo_box/magazine/sniper_rounds/smoke(src)
		new /obj/item/reagent_containers/hypospray/medipen/beepen(src)
		new /obj/item/grenade/smokebomb(src)
		new /obj/item/grenade/flashbang(src)

	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/handcuffs(src)

/obj/item/storage/belt/bee_hunter/full/cryo/PopulateContents()
	for(var/i = 1 to 3)
		new /obj/item/ammo_box/magazine/sniper_rounds/net(src)
		new /obj/item/ammo_box/magazine/sniper_rounds/taser(src)
		new /obj/item/ammo_box/magazine/sniper_rounds/smoke(src)
		new /obj/item/reagent_containers/hypospray/medipen/beepen(src)
		new /obj/item/grenade/gluon(src)
		new /obj/item/grenade/flashbang(src)

	new /obj/item/restraints/handcuffs(src)
	new /obj/item/restraints/handcuffs(src)

/obj/item/clothing/glasses/thermal/sunglasses
	name = "thermal sunglasses"
	desc = "Sunglasses with thermal vision. Badass."
	icon_state = "sunhudsec"
	darkness_view = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	glass_colour_type = /datum/client_colour/glass_colour/darkred
