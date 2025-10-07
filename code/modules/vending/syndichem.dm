/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by Donk Co."
	products = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/assembly/igniter = 20,
		/obj/item/assembly/prox_sensor = 5,
		/obj/item/assembly/signaler = 5,
		/obj/item/assembly/timer = 5,
		/obj/item/assembly/voice = 5,
		/obj/item/assembly/health = 5,
		/obj/item/assembly/infra = 5,
		/obj/item/grenade/chem_grenade = 5,
		/obj/item/grenade/chem_grenade/large = 5,
		/obj/item/grenade/chem_grenade/pyro = 5,
		/obj/item/grenade/chem_grenade/cryo = 5,
		/obj/item/grenade/chem_grenade/adv_release = 5,
		/obj/item/reagent_containers/cup/glass/bottle/holywater = 1
	)
	product_slogans = "It's not pyromania if you're getting paid!;You smell that? Plasma, son. Nothing else in the world smells like that.;I love the smell of Plasma in the morning."
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/syndichem

/obj/item/vending_refill/syndichem
	machine_name = "SyndiChem"
	icon_state = "refill_syndichem"
