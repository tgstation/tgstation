//Object and area definitions go here
/area/vault //Please make all areas used in vaults a subtype of this!
	name = "mysterious structure"
	requires_power = 0
	icon_state = "firingrange"
	lighting_use_dynamic = 1

/area/vault/icetruck

/area/vault/asteroid

/area/vault/tommyboyasteroid
	requires_power = 1

/area/vault/satelite

/area/vault/factory

/area/vault/clownbase

/area/vault/gym

/area/vault/oldarmory

/area/vault/rust
	requires_power = 1

/area/vault/dancedance

/area/vault/dancedance/loot
	jammed = 2

/area/vault/spacepond

/area/vault/ioufort

/area/vault/biodome
	requires_power = 1

/mob/living/simple_animal/hostile/monster/cyber_horror/quiet
	speak_chance = 1 //shut the fuck up

/obj/item/weapon/bananapeel/traitorpeel/curse
	name = "cursed banana peel"
	desc = "A peel from a banana, surrounded by an evil aura of trickery and mischief. "

	anchored = 1
	cant_drop = 1

	slip_power = 10

/obj/item/weapon/melee/morningstar/catechizer
	name = "The Catechizer"
	desc = "An unholy weapon forged eons ago by a servant of Nar-Sie."

	force = 37
	throwforce = 30
	throw_speed = 3
	throw_range = 5

/obj/effect/landmark/catechizer_spawn //Multiple of these are put in a single area. One of these landmark will contain a true catachizer, others only mimics
	name = "catechizer spawn"

/obj/effect/landmark/catechizer_spawn/New()
	spawn()
		if(!isturf(loc)) return

		var/list/all_spawns = list()
		for(var/obj/effect/landmark/catechizer_spawn/S in get_area(src))
			all_spawns.Add(S)

		var/obj/effect/true_spawn = pick(all_spawns)
		all_spawns.Remove(true_spawn)

		var/obj/item/weapon/melee/morningstar/catechizer/original = new(get_turf(true_spawn))

		for(var/obj/effect/S in all_spawns)
			new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(S), original) //Make copies
			qdel(S)

		qdel(src)

/obj/machinery/door/poddoor/vault_rust
	id_tag = "tokamak_yadro_ventilyatsionnyy" // Russian for "tokamak_core_vent"

/obj/machinery/door_control/vault_rust
	name   = "tokamak yadro ventilyatsionnyy"
	id_tag = "tokamak_yadro_ventilyatsionnyy"

/obj/item/weapon/fuel_assembly/trilithium
	name = "trilithium fuel rod assembly"

/obj/item/weapon/fuel_assembly/trilithium/New()
	. = ..()
	rod_quantities["Trilithium"] = 300

/obj/machinery/power/apc/frame/rust_vault
	make_alerts = FALSE

/obj/machinery/power/apc/frame/rust_vault/initialize()
	. = ..()
	name = "regulyator moshchnosti oblast'"

/obj/machinery/power/generator/rust_vault
	name = "termoelektricheskiy generator metki dva"

	thermal_efficiency = 0.90

/obj/machinery/power/battery_port/rust_vault
	name = "raz\"yem pitaniya"

/obj/machinery/power/rust_core/rust_vault
	name = "\improper Razmnozitel' Ustojcivogo Sostojanija Termojadernyj versija sem' tokamak yadro"

/obj/machinery/vending/engineering/rust_vault
	name = "\improper Robco instrumental'shchik"

/obj/item/device/rcd/rpd/rust_vault
	name = "\improper Bystroye Ustroystvo Truboprovodov (BUT)"

/obj/item/device/rcd/matter/engineering/rust_vault
	name = "\improper Bystroye Stroitel'stvo Ustroystv (BSU)"

/obj/item/weapon/paper/tommyboy
	name = "failed message transcript"
	info = {"This is Major Tom to Ground Control<br>
			I'm stepping through the door<br>
			And I'm floating in the most peculiar way<br>
			And the stars look very different today<br>
			For here am I sitting in my tin can<br>
			Far above the world<br>
			Planet Earth is blue<br>
			And there's nothing I can do.
			"}

/obj/machinery/atmospherics/binary/msgs/rust_vault
	name = "\improper Magnitno Priostanovleno Blok Khraneniya Gaza"

/obj/item/weapon/paper/iou
	name = "paper- 'IOU'"
	info = "I owe you a rod of destruction. Redeemable at Milliway's at the end of time."

/obj/machinery/floodlight/on

	New()
		..()
		on = 1
		set_light(brightness_on)
		update_icon()

/obj/machinery/bot/farmbot/duey
	name = "Duey"
	desc = "Looks like a maintenance droid, repurposed for botany management. Seems the years haven't been too kind."
	health = 150
	maxhealth = 150
	icon_state = "duey0"
	icon_initial = "duey"
	Max_Fertilizers = 50
