// Shotgun

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	worn_icon_state = "shell"
	caliber = CALIBER_SHOTGUN
	custom_materials = list(/datum/material/iron=4000)
	projectile_type = /obj/projectile/bullet/shotgun_slug

/obj/item/ammo_casing/shotgun/executioner
	name = "executioner slug"
	desc = "A 12 gauge lead slug purpose built to annihilate flesh on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/executioner

/obj/item/ammo_casing/shotgun/pulverizer
	name = "pulverizer slug"
	desc = "A 12 gauge lead slug purpose built to annihilate bones on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/pulverizer

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	custom_materials = list(/datum/material/iron=250)
	projectile_type = /obj/projectile/bullet/shotgun_beanbag

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun

/obj/item/ammo_casing/shotgun/incendiary/no_trail
	name = "precision incendiary slug"
	desc = "An incendiary-coated shotgun slug, specially treated to only ignite on impact."
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/no_trail

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_stunslug
	custom_materials = list(/datum/material/iron=250)

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteorslug shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/projectile/bullet/shotgun_meteorslug

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 20
	custom_materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/incapacitate
	name = "custom incapacitating shot"
	desc = "A shotgun casing filled with... something. used to incapacitate targets."
	icon_state = "bountyshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_incapacitate
	pellets = 12//double the pellets, but half the stun power of each, which makes this best for just dumping right in someone's face.
	variance = 25
	custom_materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_improvised
	custom_materials = list(/datum/material/iron=250)
	pellets = 10
	variance = 25

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/projectile/bullet/dart
	var/reagent_amount = 30

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)

// Energy shells - they can be emp'd for varying effects
/obj/item/ammo_casing/shotgun/energy
	name = "lethal scatter shell"
	desc = "An advanced shotgun shell which uses a sudden discharge of energy to fire a flurry of laser particles."
	icon_state = "enshell"
	projectile_type = /obj/projectile/beam/pellet/lethal
	caliber = CALIBER_SHOTGUN_ENERGY
	pellets = 4
	variance = 35
	var/max_pellets = 4

/obj/item/ammo_casing/shotgun/energy/emp_act(severity)
	. = ..()
	if(prob(40/severity) && projectile_type)
		if(pellets > 1)
			pellets = rand(1,max_pellets)
		variance = rand(10,90)

/obj/item/ammo_casing/shotgun/energy/disable
	name = "nonlethal scatter shell"
	desc = "An advanced shotgun shell which uses a sudden discharge of energy to fire a flurry of disabling static particles."
	icon_state = "disshell"
	projectile_type = /obj/projectile/beam/pellet/disable

/obj/item/ammo_casing/shotgun/energy/net
	name = "SNATCHERnet shell"
	desc = "An advanced shotgun shell which flings out holonets to snare targets and teleport them to a pre-designated location. Requires a functioning and activated teleporter hub to teleport to its intended destination."
	icon_state = "netshell"
	projectile_type = /obj/projectile/beam/pellet/net

/obj/item/ammo_casing/shotgun/energy/snare
	name = "TRIPnet shell"
	desc = "An advanced shotgun shell that hurtles an energy snare at targets, tripping them up and dealing moderate stamina damage."
	icon_state = "bolashell"
	projectile_type = /obj/projectile/energy/trap
	pellets = 0
	variance = 0

/obj/item/ammo_casing/shotgun/energy/grav
	name = "gravity blast shell"
	desc = "An advanced shotgun shell that shoots an extremely fast conflux of gravitational distortions that launchs a target upon impact."
	icon_state = "bolashell"
	projectile_type = /obj/projectile/energy/trap
	pellets = 0
	variance = 0

/obj/item/ammo_casing/shotgun/energy/ion
	name = "ion scatter shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak

/obj/item/ammo_casing/shotgun/energy/pulseslug
	name = "pulse slug shell"
	desc = "A delicate device which can be loaded into an energy shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/projectile/beam/pulse/shotgun
	pellets = 0
	variance = 0

/obj/item/ammo_casing/shotgun/energy/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for an energy shotgun."
	icon_state = "heshell"
	projectile_type = /obj/projectile/bullet/shotgun_frag12
	pellets = 0
	variance = 0
