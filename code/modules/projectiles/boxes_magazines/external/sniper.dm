/obj/item/ammo_box/magazine/sniper_rounds
	name = "anti-materiel sniper rounds (.50 BMG)"
	desc = "A .50 BMG box magazine suitable for anti-materiel sniper rifles."
	icon_state = ".50mag"
	base_icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/p50
	max_ammo = 6
	caliber = CALIBER_50BMG

/obj/item/ammo_box/magazine/sniper_rounds/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][ammo_count() ? "-ammo" : ""]"

/obj/item/ammo_box/magazine/sniper_rounds/surplus
	name = "anti-materiel sniper rounds (.50 BMG Surplus)"
	desc = parent_type::desc + " Improper storage means they don't punch through armor, dismember, or stun like fresh ammo, but they're still very good at killing people."
	icon_state = "surplus"
	base_icon_state = "surplus"
	ammo_type = /obj/item/ammo_casing/p50/surplus

/obj/item/ammo_box/magazine/sniper_rounds/disruptor
	name = "anti-materiel sniper rounds (.50 BMG Bzzt)"
	desc = parent_type::desc + " Loaded with disruptor sniper rounds, filled with a special blend of soporific chemicals \
		and a electromagnetic payload to cause anything hit to come to a grinding halt."
	base_icon_state = "disruptor"
	ammo_type = /obj/item/ammo_casing/p50/disruptor

/obj/item/ammo_box/magazine/sniper_rounds/incendiary
	name = "anti-materiel sniper rounds (.50 BMG incendiary)"
	desc = parent_type::desc + " Loaded with incendiary sniper rounds, which cause massive combustion at the site of impact."
	base_icon_state = "incendiary"
	ammo_type = /obj/item/ammo_casing/p50/incendiary

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	name = "anti-materiel sniper rounds (.50 BMG penetrator)"
	desc = parent_type::desc + " Loaded with extremely powerful penetrator rounds, capable of passing straight through cover and anyone unfortunate enough to be behind it."
	base_icon_state = "penetrator"
	ammo_type = /obj/item/ammo_casing/p50/penetrator

/obj/item/ammo_box/magazine/sniper_rounds/marksman
	name = "anti-materiel sniper rounds (.50 BMG marksman)"
	desc = parent_type::desc + " Loaded with extremely fast marksman rounds, able to pretty much instantly hit their targets."
	base_icon_state = "marksman"
	ammo_type = /obj/item/ammo_casing/p50/marksman

// Lahti-L39 Magazine //

/obj/item/ammo_box/magazine/lahtimagazine
	name = "\improper Lahti sniper rounds (20x138mm)"
	desc = "A 20x138mm magazine suitable ammo for anti kaiju-rifles."
	icon_state = ".50mag"
	base_icon_state = ".50mag"
	ammo_type = /obj/item/ammo_casing/mm20x138
	max_ammo = 9
	caliber = CALIBER_50BMG
