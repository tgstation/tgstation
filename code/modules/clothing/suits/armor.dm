
/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_storage,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/gun/lawgiver)
	body_parts_covered = FULL_TORSO
	flags = FPRINT
	heat_conductivity = ARMOUR_HEAT_CONDUCTIVITY
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.6


/obj/item/clothing/suit/armor/vest
	name = "armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags = FPRINT  | ONESIZEFITSALL
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	desc = "An armored vest that protects against some damage. This one has Nanotrasen corporate badge."
	icon_state = "armorsec"
	item_state = "armor"

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's jacket"
	desc = "An armoured jacket with silver rank pips and livery."
	icon_state = "warden_jacket"
	item_state = "armor"


/obj/item/clothing/suit/armor/riot
	name = "Riot Suit"
	desc = "A suit of armor with heavy padding to protect against melee attacks. Looks like it might impair movement."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS|IGNORE_INV
	slowdown = 1
	armor = list(melee = 80, bullet = 10, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5


/obj/item/clothing/suit/armor/knight
 	name = "plate armour"
 	desc = "A classic suit of plate armour, highly effective at stopping melee attacks."
 	icon_state = "knight_green"
 	item_state = "knight_green"
 	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
 	slowdown = 1
 	armor = list(melee = 40, bullet = 5, laser = 5, energy = 5, bomb = 0, bio = 0, rad = 0)


/obj/item/clothing/suit/armor/knight/yellow
 	icon_state = "knight_yellow"
 	item_state = "knight_yellow"

/obj/item/clothing/suit/armor/knight/blue
 	icon_state = "knight_blue"
 	item_state = "knight_blue"

/obj/item/clothing/suit/armor/knight/red
 	icon_state = "knight_red"
 	item_state = "knight_red"

/obj/item/clothing/suit/armor/knight/templar
 	name = "crusader armour"
 	desc = "God wills it!"
 	icon_state = "knight_templar"
 	item_state = "knight_templar"


/obj/item/clothing/suit/armor/xcomsquaddie
	name = "Squaddie Armor"
	desc = "A suit of armor with heavy padding to protect against projectile and laser attacks. Distributed to shadow organization squaddies."
	icon_state = "xcomarmor2"
	item_state = "xcomarmor2"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	armor = list(melee = 10, bullet = 50, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.5

/obj/item/clothing/suit/armor/xcomsquaddie/dredd
	name = "Judge Armor"
	desc = "A large suit of heavy armor, fit for a Judge."
	icon_state = "dredd-suit"
	item_state = "dredd-suit"


/obj/item/clothing/suit/armor/xcomarmor
	name = "Mysterious Armor"
	desc = "A suit of armor with heavy plating to protect against melee attacks. Distributed to shadow organization squaddies."
	icon_state = "xcomarmor1"
	item_state = "xcomarmor1"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	armor = list(melee = 50, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)
	slowdown = 1
	siemens_coefficient = 0.5


/obj/item/clothing/suit/armor/bulletproof
	name = "Bulletproof Vest"
	desc = "A vest that excels in protecting the wearer against high-velocity solid projectiles."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 80, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/laserproof
	name = "Ablative Armor Vest"
	desc = "A vest that excels in protecting the wearer against energy projectiles."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list(melee = 10, bullet = 10, laser = 80, energy = 50, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/swat/officer
	name = "officer jacket"
	desc = "An armored jacket used in special operations."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"

/obj/item/clothing/suit/armor/det_suit
	name = "armor"
	desc = "An armored vest with a detective's badge on it."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags = FPRINT  | ONESIZEFITSALL
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)


//Reactive armor
//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive
	name = "Reactive Teleport Armor"
	desc = "Someone seperated our Research Director from his own head!"
	var/active = 0.0
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	slowdown = 1
	flags = FPRINT  | ONESIZEFITSALL
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/reactive/IsShield()
	if(active)
		return 1
	return 0

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user as mob)
	src.active = !( src.active )
	if (src.active)
		to_chat(user, "<span class='notice'>The reactive armor is now active.</span>")
		src.icon_state = "reactive"
		src.item_state = "reactive"
	else
		to_chat(user, "<span class='notice'>The reactive armor is now inactive.</span>")
		src.icon_state = "reactiveoff"
		src.item_state = "reactiveoff"
		src.add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/reactive/on_block(damage, attack_text)
	if(!prob(35)) return 0 //35% chance

	var/mob/living/carbon/human/L = loc
	if(!istype(L)) return 0 //Not living mob
	if(L.wear_suit != src) //Not worn
		return 0 //Don't do anything

	var/list/turfs = new/list()

	for(var/turf/T in orange(6, loc))
		if(istype(T,/turf/space)) continue
		if(T.density) continue
		if(T.x>world.maxx-6 || T.x<6)	continue
		if(T.y>world.maxy-6 || T.y<6)	continue
		turfs += T
	if(!turfs.len) turfs += pick(/turf in orange(6))
	var/turf/picked = pick(turfs)
	if(!isturf(picked)) return

	L.visible_message("<span class='danger'>The reactive teleport system flings [L] clear of [attack_text]!</span>", "<span class='notice'>The reactive teleport system flings you clear of [attack_text].</span>")

	playsound(get_turf(L), 'sound/effects/teleport.ogg', 30, 1)

	L.forceMove(picked)

	return 1

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	active = 0
	src.icon_state = "reactiveoff"
	src.item_state = "reactiveoff"
	..()


//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	desc = "A suit that protects against some damage."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = 4//bulky item
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/tank/emergency_nitrogen)
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	desc = "A heavily armored suit that protects against moderate damage."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	slowdown = 3
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS

/obj/item/clothing/suit/armor/tdome/red
	name = "Thunderdome suit (red)"
	desc = "Reddish armor."
	icon_state = "tdred"
	item_state = "tdred"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tdome/green
	name = "Thunderdome suit (green)"
	desc = "Pukish armor."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/vest/piratelord
	name = "pirate lord's armor"
	desc = "The attire of an all powerful and bloodthirsty pirate lord. Simply looking at sends chills down your spine."
	armor = list(melee = 75, bullet = 75, laser = 75,energy = 75, bomb = 75, bio = 100, rad = 90)
	icon_state = "piratelord"
	item_state = "piratelord"

/obj/item/clothing/suit/armor/volnutt
	name = "Digouter Suit"
	desc = "Found abandoned on an ancient space colony!"
	icon_state = "volnutt"
	item_state = "volnutt"
	body_parts_covered = ARMS|LEGS|FULL_TORSO|FEET|HANDS
	heat_conductivity = ARMOUR_HEAT_CONDUCTIVITY
	slowdown = 0
	armor = list(melee = 50, bullet = 40, laser = 40, energy = 40, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/doomguy
	name = "Doomguy's armor"
	desc = ""
	icon_state = "doom"
	item_state = "doom"
	body_parts_covered = FULL_TORSO
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	slowdown = 0
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 30, bio = 0, rad = 0)
