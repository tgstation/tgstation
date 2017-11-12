/obj/item/grenade/chem_grenade/saringas
	name = "Sarin gas grenade"
	desc = "Tiger Cooperative military grade nerve gas. WARNING: Ensure internals are active before use, nerve agents are exceptionally lethal regardless of dosage"
	stage = READY

/obj/item/grenade/chem_grenade/saringas/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("sarin", 100)
	B2.reagents.add_reagent("sarin", 100)
	B1.reagents.chem_temp = 1000
	B2.reagents.chem_temp = 1000
	beakers += B1
	beakers += B2