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

/area/vault/rust
	requires_power = 1

/mob/living/simple_animal/hostile/monster/cyber_horror/quiet
	speak_chance = 1 //shut the fuck up

/obj/item/weapon/bananapeel/traitorpeel/curse
	name = "cursed banana peel"
	desc = "A peel from a banana, surrounded by an evil aura of trickery and mischief. "

	anchored = 1
	cant_drop = 1

	slip_power = 10


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
