/obj/item/ammo_casing/caseless/rocket
	name = "\improper PM-9HE"
	desc = "An 84mm High Explosive rocket. Fire at people and pray."
	caliber = CALIBER_84MM
	icon_state = "srm-8"
	projectile_type = /obj/projectile/bullet/a84mm/he

/obj/item/ammo_casing/caseless/rocket/hedp
	name = "\improper PM-9HEDP"
	desc = "An 84mm High Explosive Dual Purpose rocket. Pointy end toward mechs."
	icon_state = "84mm-hedp"
	projectile_type = /obj/projectile/bullet/a84mm

/obj/item/ammo_casing/caseless/rocket/weak
	name = "\improper PM-9HE Low-Yield"
	desc = "An 84mm High Explosive rocket. This one isn't quite as devastating."
	projectile_type = /obj/projectile/bullet/a84mm/weak

/obj/item/ammo_casing/caseless/rocket/sabot
	name = "\improper APCBCFSDSGLATM"
	desc = "Why anyone would name a rocket 'Armour Piercing Capped Ballistic Capped Fin Stabilized Discarding Sabot Gun Launched Anti Tank Missile' is beyond your understanding."
	icon_state = "84mm-sabot"
	projectile_type = /obj/projectile/bullet/a84mm/sabot
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ammo_casing/caseless/rocket/emp
	name = "\improper GLEMPS"
	desc = "This rocket seems to be packed full of machinery and a special chemical mix that makes a large emp on impact."
	icon_state = "84mm-emp"
	projectile_type = /obj/projectile/bullet/a84mm/emp
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ammo_casing/caseless/rocket/smoke
	name = "\improper HVSD"
	desc = "The acronym stands for high velocty smoke deployment, surely that makes it non-lethal, right?"
	icon_state = "84mm-smoke"
	projectile_type = /obj/projectile/bullet/a84mm/smoke
	w_class = WEIGHT_CLASS_BULKY

/obj/item/ammo_casing/caseless/rocket/smoke/phosphor
	name = "\improper HVWP"
	desc = "Good old fashioned white phosphorus, don't tell anyone that we still use these."
	icon_state = "84mm-coldsmoke"
	projectile_type = /obj/projectile/bullet/a84mm/smoke/phosphor

/obj/item/ammo_casing/caseless/rocket/smoke/sleeping
	name = "\improper RCSD"
	desc = "It had a warning label, but it was covered by a big arrow pointing toward the tip that says, 'Graytide in this direction'."
	icon_state = "84mm-sleepsmoke"
	projectile_type = /obj/projectile/bullet/a84mm/smoke/sleeping

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = CALIBER_75
	icon_state = "s-casing-live"
	projectile_type = /obj/projectile/bullet/gyro
