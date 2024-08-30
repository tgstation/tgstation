/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_state = "securecrate"
	base_icon_state = "securecrate"
	secure = TRUE
	locked = TRUE
	max_integrity = 500
	armor_type = /datum/armor/crate_secure
	damage_deflection = 25

	var/tamperproof = 0

/datum/armor/crate_secure
	melee = 30
	bullet = 50
	laser = 50
	energy = 100
	fire = 80
	acid = 80

/obj/structure/closet/crate/secure/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_MISSING_ITEM_ERROR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NO_MANIFEST_CONTENTS_ERROR, TRAIT_GENERIC)

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()

/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, span_danger("The crate's anti-tamper system activates!"))
		log_bomber(user, "has detonated a", src)
	dump_contents()
	explosion(src, heavy_impact_range = 1, light_impact_range = 5, flash_range = 5)
	qdel(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"
	base_icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"
	base_icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"
	base_icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydroponics
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"
	base_icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/freezer //for consistency with other "freezer" closets/crates
	desc = "An icebox with a lock on it, used to secure perishables."
	name = "secure kitchen icebox"
	icon_state = "kitchen_secure_crate"
	base_icon_state = "kitchen_secure_crate"
	paint_jobs = null

/obj/structure/closet/crate/secure/freezer/pizza
	name = "secure pizza crate"
	desc = "An insulated crate with a lock on it, used to secure pizza."
	tamperproof = 10
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/crate/secure/freezer/pizza/PopulateContents()
	. = ..()
	new /obj/effect/spawner/random/food_or_drink/pizzaparty(src)

/obj/structure/closet/crate/secure/centcom
	name = "secure centcom crate"
	icon_state = "centcom_secure"
	base_icon_state = "centcom_secure"

/obj/structure/closet/crate/secure/cargo
	name = "secure cargo crate"
	icon_state = "cargo_secure"
	base_icon_state = "cargo_secure"

/obj/structure/closet/crate/secure/cargo/mining
	name = "secure mining crate"
	icon_state = "mining_secure"
	base_icon_state = "mining_secure"

/obj/structure/closet/crate/secure/radiation
	name = "secure radioation crate"
	icon_state = "radiation_secure"
	base_icon_state = "radiation_secure"

/obj/structure/closet/crate/secure/engineering
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	name = "secure engineering crate"
	icon_state = "engi_secure_crate"
	base_icon_state = "engi_secure_crate"

/obj/structure/closet/crate/secure/engineering/atmos
	name = "secure atmospherics crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's atmospherics engineers."
	icon_state = "atmos_secure"
	base_icon_state = "atmos_secure"

/obj/structure/closet/crate/secure/science
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"
	base_icon_state = "scisecurecrate"

/obj/structure/closet/crate/secure/science/robo
	name = "robotics science crate"
	icon_state = "robo_secure"
	base_icon_state = "robo_secure"

/obj/structure/closet/crate/secure/trashcart
	desc = "A heavy, metal trashcart with wheels. It has an electronic lock on it."
	name = "secure trash cart"
	max_integrity = 250
	damage_deflection = 10
	icon_state = "securetrashcart"
	base_icon_state = "securetrashcart"
	paint_jobs = null
	req_access = list(ACCESS_JANITOR)

/obj/structure/closet/crate/secure/trashcart/filled

/obj/structure/closet/crate/secure/trashcart/filled/PopulateContents()
	. = ..()
	for(var/i in 1 to rand(8,12))
		new /obj/effect/spawner/random/trash/deluxe_garbage(src)
		if(prob(35))
			new /obj/effect/spawner/random/trash/garbage(src)
	for(var/i in 1 to rand(4,6))
		if(prob(30))
			new /obj/item/storage/bag/trash/filled(src)

/obj/structure/closet/crate/secure/owned
	name = "private crate"
	desc = "A crate cover designed to only open for who purchased its contents."
	icon_state = "privatecrate"
	base_icon_state = "privatecrate"
	///Account of the person buying the crate if private purchasing.
	var/datum/bank_account/buyer_account
	///Department of the person buying the crate if buying via the NIRN app.
	var/datum/bank_account/department/department_account
	///Is the secure crate opened or closed?
	var/privacy_lock = TRUE
	///Is the crate being bought by a person, or a budget card?
	var/department_purchase = FALSE

/obj/structure/closet/crate/secure/owned/examine(mob/user)
	. = ..()
	. += span_notice("It's locked with a privacy lock, and can only be unlocked by the buyer's ID.")

/obj/structure/closet/crate/secure/owned/Initialize(mapload, datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account
	if(IS_DEPARTMENTAL_ACCOUNT(buyer_account))
		department_purchase = TRUE
		department_account = buyer_account

/obj/structure/closet/crate/secure/owned/togglelock(mob/living/user, silent)
	if(privacy_lock)
		if(!broken)
			var/obj/item/card/id/id_card = user.get_idcard(TRUE)
			if(id_card)
				if(id_card.registered_account)
					if(id_card.registered_account == buyer_account || (department_purchase && (id_card.registered_account?.account_job?.paycheck_department) == (department_account.department_id)))
						if(iscarbon(user))
							add_fingerprint(user)
						locked = !locked
						user.visible_message(span_notice("[user] unlocks [src]'s privacy lock."),
										span_notice("You unlock [src]'s privacy lock."))
						privacy_lock = FALSE
						update_appearance()
					else if(!silent)
						to_chat(user, span_warning("Bank account does not match with buyer!"))
				else if(!silent)
					to_chat(user, span_warning("No linked bank account detected!"))
			else if(!silent)
				to_chat(user, span_warning("No ID detected!"))
		else if(!silent)
			to_chat(user, span_warning("[src] is broken!"))
	else ..()
