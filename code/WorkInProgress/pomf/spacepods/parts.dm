/obj/item/pod_parts
	parent_type = /obj/item/mecha_parts
	icon = 'icons/pods/equipment.dmi'

/obj/item/pod_parts/core
	name="Space Pod Core"
	icon_state = "core"
	construction_cost = list("iron"=5000,"uranium"=1000,"plasma"=5000)
	flags = FPRINT | CONDUCT
	origin_tech = "programming=2;materials=3;bluespace=2;engineering=3"