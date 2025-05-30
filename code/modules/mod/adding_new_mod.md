## Introduction

This is a step by step guide for creating a MODsuit theme, skin and module.

## Theme

This is pretty simple, we go [here](./mod_theme.dm) and add a new definition, let's go with a Psychologist theme as an example. \
Their names should be like model names or use similar adjectives, like "magnate" or simply "engineering", so we'll go with "psychological". \
After that, it's good to decide what company is manufacturing the suit, and a basic description of what it offers, we'll write that down in the desc. \
So, let's our suit should be a low-power usage with lowered module capacity. We'd go with something like this.

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
```

For people that want to see additional stuff, we add an extended description with some more insight into what the suit does. We also set the default skin to usually the theme name, like so.

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
	extended_desc = "DeForest Medical Corporation's prototype suit, based off the work of \
		Nakamura Engineering. The suit has been modified to save power compared to regular suits, \
		for operating at lower power levels, keeping people sane. As consequence, the capacity \
		of the suit has decreased, not being able to fit many modules at all."
	default_skin = "psychological"
```

Next we want to set the statistics, you can view them all in the theme file, so let's just grab our relevant ones, armor, charge and capacity and set them to what we establilished. \
Currently crew MODsuits should be lightly armored in combat relevant stats.

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
	extended_desc = "DeForest Medical Corporation's prototype suit, based off the work of \
		Nakamura Engineering. The suit has been modified to save power compared to regular suits, \
		for operating at lower power levels, keeping people sane. As consequence, the capacity \
		of the suit has decreased, not being able to fit many modules at all."
	default_skin = "psychological"
	armor_type = /datum/armor/modtheme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
```

Now we have a basic theme, it lacks a skin which will be covered in the next section, and an item, which we will add right now. \
Let's go into [here](./mod_types.dm). It's as simple as adding a new suit type with the appropriate modules you want.

```dm
/obj/item/mod/control/pre_equipped/psychological
	theme = /datum/mod_theme/psychological
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
	)
```

This will create our psychological suit, equipped with a storage and flashlight modules by default. We might also want to make it craftable, in which case we go [here](./mod_construction.dm) and set this.

```dm
/obj/item/mod/construction/armor/psychological
	theme = /datum/mod_theme/psychological
```

After that we put it in the techweb or whatever other source we want. Now our suit is almost ready, it just needs a skin.

## Skin

So, now that we have our theme, we want to add a skin to it (or another theme of our choosing). Let's start with a basis.

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
	extended_desc = "DeForest Medical Corporation's prototype suit, based off the work of \
		Nakamura Engineering. The suit has been modified to save power compared to regular suits, \
		for operating at lower power levels, keeping people sane. As consequence, the capacity \
		of the suit has decreased, not being able to fit many modules at all."
	default_skin = "psychological"
	armor_type = /datum/armor/modtheme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	variants = list(
		"psychological" = list(
			/obj/item/clothing/head/mod = list(
			),
			/obj/item/clothing/suit/mod = list(
			),
			/obj/item/clothing/gloves/mod = list(
			),
			/obj/item/clothing/shoes/mod = list(
			),
		),
	)
```

We now have a psychological skin, this will apply the psychological icons to every part of the suit. Next we'll be looking at the flags. Boots, gauntlets and the chestplate are usually very standard, we set their thickmaterial and pressureproofness while hiding the jumpsuit on the chestplate. On the helmet however, we'll actually look at its icon. \
For example, if our helmet's icon covers the full head (like the research skin), we want to do something like this.

```dm
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|BLOCK_GAS_SMOKE_EFFECT,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
```

Otherwise, with an open helmet that becomes closed (like the engineering skin), we'd do this.

```dm
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
```

There are specific cases of helmets that semi-cover the head, like the cosmohonk, apocryphal and whatnot. You can look at these for more specific suits. So let's say our suit is an open helmet design, and also add an alternate skin with a closed helmet called psychotherapeutic. It'd look something like this.

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
	extended_desc = "DeForest Medical Corporation's prototype suit, based off the work of \
		Nakamura Engineering. The suit has been modified to save power compared to regular suits, \
		for operating at lower power levels, keeping people sane. As consequence, the capacity \
		of the suit has decreased, not being able to fit many modules at all."
	default_skin = "psychological"
	armor_type = /datum/armor/modtheme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	variants = list(
		"psychological" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		"psychotherapeutic" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		),
	)
```

Thus we finished our codeside. Now we go to the icon files for the suits and simply add our new skin's icons. \
Now our suit is finished. But let's say we want to give it an unique module.

## Module

So, for our psychological suit, let's say we want a module that heals the brain damage of everyone in range. \
As it's a medical module, we'll put it [here](modules/modules_medical.dm). Let's start with the object definition.

```dm
/obj/item/mod/module/neuron_healer
	name = "MOD neuron healer module"
	desc = "A module made experimentally by DeForest Medical Corporation. On demand it releases waves \
		that heal neuron damage of everyone nearby, getting their brains to a better state."
	icon_state = "neuron_healer"
```

As we want this effect to be on demand, we probably want this to be an usable module. There are four types of modules:

- Passive: These have a passive effect.
- Togglable: You can turn these on and off.
- Usable: You can use these for a one time effect.
- Active: You can only have one selected at a time. It gives you a special click effect.

As we have an usable module, we want to set a cooldown time. All modules are also incompatible with themselves, have a specific power cost and complexity varying on how powerful they are, and are equippable to certain slots, so let's update our definition, and also add a new variable for how much brain damage we'll heal.

```dm
/obj/item/mod/module/neuron_healer
	name = "MOD neuron healer module"
	desc = "A module made experimentally by DeForest Medical Corporation. On demand it releases waves \
		that heal neuron damage of everyone nearby, getting their brains to a better state."
	icon_state = "neuron_healer"
	module_type = MODULE_USABLE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/neuron_healer)
	cooldown_time = 15 SECONDS
	required_slot = list(ITEM_SLOT_HEAD)
	var/brain_damage_healed = 25
```

Now, we want to override the on_use proc for our new effect. You can read about most procs and variables by reading [this](modules/_module.dm)

```dm
/obj/item/mod/module/neuron_healer/on_use()
```

After this, we want to put our special code, a basic effect of healing all mobs nearby for their brain damage and creating a beam to them.

```dm
/obj/item/mod/module/neuron_healer/on_use()
	for(var/mob/living/carbon/carbon_mob in range(5, src))
		if(carbon_mob == mod.wearer)
			continue
		carbon_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -brain_damage_healed)
		mod.wearer.Beam(carbon_mob, icon_state = "plasmabeam", time = 1.5 SECONDS)
	playsound(src, 'sound/effects/magic.ogg', 100, TRUE)
	drain_power(use_energy_cost)
```

We now have a basic module, we can add it to the techwebs to make it printable ingame, and we can add an inbuilt, advanced version of it for our psychological suit. We'll give it more healing power, no complexity and make it unremovable.

```dm
/obj/item/mod/module/neuron_healer/advanced
	name = "MOD advanced neuron healer module"
	complexity = 0
	brain_damage_healed = 50
```

Now we want to add it to the psychological theme, which is very simple, finishing with this:

```dm
/datum/mod_theme/psychological
	name = "psychological"
	desc = "A DeForest Medical Corporation power-saving psychological suit, limiting its module capacity."
	extended_desc = "DeForest Medical Corporation's prototype suit, based off the work of \
		Nakamura Engineering. The suit has been modified to save power compared to regular suits, \
		for operating at lower power levels, keeping people sane. As consequence, the capacity \
		of the suit has decreased, not being able to fit many modules at all."
	default_skin = "psychological"
	armor_type = /datum/armor/modtheme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	inbuilt_modules = list(/obj/item/mod/module/neuron_healer/advanced)
	variants = list(
		"psychological" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		"psychotherapeutic" = list(
			/obj/item/clothing/head/mod = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		),
	)
```

## Ending

This finishes this hopefully easy to follow along tutorial. You should now know how to make a basic theme, a skin for it, and a module.
