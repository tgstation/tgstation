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

/obj/structure/closet/crate/secure/freezer/interdyne
	name = "\improper Interdyne freezer"
	desc = "This is an Interdyne Pharmauceutics branded freezer. May or may not contain fresh organs."
	icon_state = "interdynefreezer"
	base_icon_state = "interdynefreezer"
	req_access = list(ACCESS_SYNDICATE)

/obj/structure/closet/crate/secure/freezer/interdyne/blood
	name = "\improper Interdyne blood freezer"
	desc = "This is an Interdyne Pharmauceutics branded freezer. It's made to contain fresh, high-quality blood."

/obj/structure/closet/crate/secure/freezer/interdyne/blood/PopulateContents()
	. = ..()
	for(var/i in 1 to 13)
		new /obj/item/reagent_containers/blood/random(src)

/obj/structure/closet/crate/secure/freezer/donk
	name = "\improper Donk Co. fridge"
	desc = "A Donk Co. brand fridge, keeps your donkpockets and foam ammunition fresh!"
	icon_state = "donkcocrate_secure"
	base_icon_state = "donkcocrate_secure"
	req_access = list(ACCESS_SYNDICATE)

/obj/structure/closet/crate/secure/syndicate
	name = "\improper Syndicate crate"
	desc = "A secure crate with the Syndicate's branding on it."
	icon_state = "syndicrate"
	base_icon_state = "syndicrate"
	req_access = list(ACCESS_SYNDICATE)

/obj/structure/closet/crate/secure/syndicate/interdyne
	name = "\improper Interdyne crate"
	desc = "Crate belonging to Interdyne Pharmaceutics. Hopefully doesn't have bioweapons inside..."
	icon_state = "interdynecrate"
	base_icon_state = "interdynecrate"

/obj/structure/closet/crate/secure/syndicate/tiger
	name = "\improper Tiger Co-Op crate"
	icon_state = "tigercrate"
	base_icon_state = "tigercrate"

/obj/structure/closet/crate/secure/syndicate/self
	name = "\improper S.E.L.F. crate"
	desc = "A secure crate locked from the inside with a scanning panel above it and holographic display of lock's status. Sentient Engine Liberation Front engineers are quite the show-offs."
	icon_state = "selfcrate_secure"
	base_icon_state = "selfcrate_secure"

/obj/structure/closet/crate/secure/syndicate/mi13
	name = "mysterious secure crate"
	desc = "A secure crate. Lacks any obvious logos or even codes for where it arrived from, but looks like taken straight from a spy movie."
	icon_state = "mithirteencrate"
	base_icon_state = "mithirteencrate"
	open_sound_volume = 15
	close_sound_volume = 20

/obj/structure/closet/crate/secure/syndicate/arc
	name = "\improper Animal Rights Consortium crate"
	icon_state = "arccrate"
	base_icon_state = "arccrate"

/obj/structure/closet/crate/secure/syndicate/cybersun
	name = "\improper Cybersun crate"

/obj/structure/closet/crate/secure/syndicate/cybersun/dawn
	desc = "A secure crate from Cybersun Industries. It has distinct orange-green colouring, probably of some departament or division, but you cannot tell what is it."
	icon_state = "cyber_dawncrate"
	base_icon_state = "cyber_dawncrate"

/obj/structure/closet/crate/secure/syndicate/cybersun/noon
	desc = "A secure crate from Cybersun Industries. It has distinct yellow-orange colouring, probably of some departament or division, but you cannot tell what is it."
	icon_state = "cyber_nooncrate"
	base_icon_state = "cyber_nooncrate"

/obj/structure/closet/crate/secure/syndicate/cybersun/dusk
	desc = "A secure crate from Cybersun Industries. It has distinct purple-green colouring, probably of some departament or division, but you cannot tell what is it."
	icon_state = "cyber_duskcrate"
	base_icon_state = "cyber_duskcrate"

/obj/structure/closet/crate/secure/syndicate/cybersun/night
	desc = "A secure crate from Cybersun Industries. This one blatantly adorns syndicate colours. You can only guess it contains equipement for syndicate operatives."
	icon_state = "cyber_nightcrate"
	base_icon_state = "cyber_nightcrate"

/obj/structure/closet/crate/secure/syndicate/wafflecorp
	name = "\improper Waffle corp. crate"
	desc = "A very outdated model and design of shipment crate with a modern lock strapped on it, how befitting of its brand owner, Waffle Corporation. Golden lettering written in cursive by the logo reads 'bringing you consecutively top five world-wide rated* breakfast since 2055. A much smaller fineprint, also in cursive, clarifies: '*in years 2099-2126'... It's year 2563 now, however."
	icon_state = "wafflecrate"
	base_icon_state = "wafflecrate"

/obj/structure/closet/crate/secure/syndicate/gorlex
	name = "\improper Gorlex Marauders crate"
	icon_state = "gorlexcrate"
	base_icon_state = "gorlexcrate"

/obj/structure/closet/crate/secure/syndicate/gorlex/weapons
	desc = "A secure weapons crate of Gorlex Marauders."
	name = "weapons crate"
	icon_state = "gorlex_weaponcrate"
	base_icon_state = "gorlex_weaponcrate"

/obj/structure/closet/crate/secure/syndicate/gorlex/weapons/bustedlock
	desc = "A beaten up weapon crate with Gorlex Marauders branding. Its lock looks broken."
	name = "damaged weapons crate"
	secure = FALSE
	locked = FALSE
	max_integrity = 400
	damage_deflection = 15
