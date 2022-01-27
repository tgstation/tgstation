/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_state = "securecrate"
	secure = TRUE
	locked = TRUE
	max_integrity = 500
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	var/tamperproof = 0
	damage_deflection = 25

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()

/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, span_danger("The crate's anti-tamper system activates!"))
		log_bomber(user, "has detonated a", src)
	for(var/obj/loot in src)
		SSexplosions.high_mov_atom += loot
	explosion(src, heavy_impact_range = 1, light_impact_range = 5, flash_range = 5)
	qdel(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weaponcrate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasmacrate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgearcrate"

/obj/structure/closet/crate/secure/hydroponics
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydrosecurecrate"

/obj/structure/closet/crate/secure/freezer //for consistency with other "freezer" closets/crates
	desc = "An insulated crate with a lock on it, used to secure perishables."
	name = "secure kitchen crate"
	icon_state = "kitchen_secure_crate"

/obj/structure/closet/crate/secure/freezer/pizza
	name = "secure pizza crate"
	desc = "An insulated crate with a lock on it, used to secure pizza."
	req_access = list(28)
	tamperproof = 10

/obj/structure/closet/crate/secure/freezer/pizza/PopulateContents()
	. = ..()
	new /obj/effect/spawner/random/food_or_drink/pizzaparty(src)

/obj/structure/closet/crate/secure/engineering
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	name = "secure engineering crate"
	icon_state = "engi_secure_crate"

/obj/structure/closet/crate/secure/science
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "scisecurecrate"

/obj/structure/closet/crate/secure/owned
	name = "private crate"
	desc = "A crate cover designed to only open for who purchased its contents."
	icon_state = "privatecrate"
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
	if(istype(buyer_account, /datum/bank_account/department))
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
