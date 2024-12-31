# Greyscale Auto-Generated Sprites (GAGS)

If you're wanting to add easy recolors for your sprite then this is the system for you. Features include:

- Multiple color layers so your sprite can be generated from more than one color.
- Mixed greyscale and colored sprite layers; You can choose to only greyscale a part of the sprite or have premade filters applied to layers.
- Blend modes; Instead of just putting layers of sprites on top of each other you can use the more advanced blend modes.
- Reusable configurations; You can reference greyscale sprites from within the configuration of another, allowing you to have a bunch of styles with minimal additional configuration.

## Other Documents

- [Troubleshooting help](https://hackmd.io/@tgstation/GAGS-Troubleshooting)
- [Basic follow along guide on hackmd](https://hackmd.io/@tgstation/GAGS-Walkthrough)
- [Layer types list](https://hackmd.io/@tgstation/GAGS-Layer-Types)

## Broad overview

There are three main parts to GAGS that you'll need to be aware of when adding a new greyscale sprite:

- The json configuration

All configuration files can be found in [code/datums/greyscale/json_configs](./json_configs) and is where you control how your icons are combined together along with the colors specified from in code.

- The dmi file

It contains the sprites that will be used as the basis for the rest of the generation process. You can only have one dmi file specified per configuration but if you want to split up your sprites you can reference other configurations instead.

- The configuration type

This is simply some pointers in the code linking together your dmi and the json configuration.

## Json Configuration File

The json is made up of some metadata and a list of layers used while creating the sprite. Inner lists are processed as their own chunk before being applied elsewhere, this is useful when you start using more advanced blend modes. Most of the time though you're just going to want a list of icons overlaid on top of each other.

```json
{
	"icon_state_name": [
		{
			"type": "reference",
			"reference_type": "/datum/greyscale_config/some_other_config",
			"blend_mode": "overlay",
			"color_ids": [ 1 ]
		},
		[
			{
				"type": "icon_state",
				"icon_state": "highlights",
				"blend_mode": "overlay",
				"color_ids": [ 2 ]
			},
			{
				"type": "reference",
				"reference_type": "/datum/greyscale_config/sparkle_effect",
				"blend_mode": "add"
			}
		]
	]
}
```

In this example, we start off by creating a sprite specified by a different configuration. The "type" key is required to specify the kind of layer you defining. Once that is done, the next two layers are grouped together, so they will be generated into one sprite before being applied to any sprites outside their group. You can think of it as an order of operations.

The first of the two in the inner group is an "icon_state", this means that the icon will be retrieved from the associated dmi file using the "icon_state" key.

Note that you don't need to give colors to every layer if the layer does not need any colors applied to it, such as if it's a pre-colored component.
In this example, the last layer is one such example, referencing a separately colored config.

"blend_mode" and "color_ids" are special, all layer types have them. The blend mode is what controls how that layer's finished product gets merged together with the rest of the sprite. The color ids control what colors are passed in to the layer.

Once it is done generating it will be placed in an icon file with the icon state of "icon_state_name". You can use any name you like here.

Most commonly, we'll only use the "icon_state" type...
Thus, **this will be the most common layout**:
```json
{
	"full_icon_state_name": [
		{
			"type": "icon_state",
			"icon_state": "component_state_1",
			"blend_mode": "overlay",
			"color_ids": [ 1 ]
		},
		{
			"type": "icon_state",
			"icon_state": "component_state_2",
			"blend_mode": "overlay",
			"color_ids": [ 2 ]
		},
		{
			"type": "icon_state",
			"icon_state": "non_colorable_component_state",
			"blend_mode": "overlay",
		}
	]
}
```

## Dmi File

There are no special requirements from the dmi file to work with this system. You just need to specify the icon file in code and the icon_state in the json configuration.
Additionally, for the sake of mappers, it's appreciated if there's a pre-made obj icon of the same name as the item's icon_state; this way, the item will appear in mapping software.

## Dm Code

While the amount of dm code required to make a greyscale sprite was minimized as much as possible, some small amount is required anyway if you want anything to use it.

As an example:
```c
/datum/greyscale_config/canister
	name = "Canister" //Required for debugging, will runtime without one!
	icon_file = 'icons/obj/pipes_n_cables/canisters/default.dmi'
	json_config = 'code/datums/greyscale/json_configs/canister_default.json'
```
And that's all you need to make it usable by other code:

```c
/obj/machinery/portable_atmospherics/canister
	...
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#ee4242"
```

More configurations can be found in the greyscale_configs folder [code/datums/greyscale/config_types/greyscale_configs/greyscale_unsorted.dm] (./config_types/greyscale_configs/greyscale_unsorted.dm)

While creating a greyscale config, be sure to take subtypes into account! Rather than create several unique configs that all link to the same icon file, you can make the variants all a subtype of one base config:

```c
/datum/greyscale_config/tablet
	name = "PDA"
	icon_file = 'icons/obj/devices/modular_pda.dmi'
	json_config = 'code/datums/greyscale/json_configs/pda.json'

/datum/greyscale_config/tablet/chaplain
	name = "Chaplain PDA"
	json_config = 'code/datums/greyscale/json_configs/pda_chaplain.json'
```

Building on this, if your obj and worn sprites have the same amount of component states, then instead of making separate .json configs for obj and worn, link to two separate .dmi's while still using the same .json config! For example:

```c
/datum/greyscale_config/trek
	name = "Trek Uniform"
	icon_file = 'icons/obj/clothing/under/trek.dmi'
	json_config = 'code/datums/greyscale/json_configs/trek.json'

/datum/greyscale_config/trek/worn
	name = "Worn Trek Uniform"
	icon_file = 'icons/mob/clothing/under/trek.dmi'
	//The worn json is exactly the same, and both icon files use identically-named component states; so, we can just inherit the json!
```

If you want your item to be colorable in a vending machine (or other places if there's ever any support added for that), you should do it like this:

```c
/obj/item/clothing/head/beret
	...
	flags_1 = IS_PLAYER_COLORABLE_1
```
However, **be extremely careful**, as this *requires* that you put *all* of the object's `flags_1` flags in that statement all over again. It's ugly, I know, but there's no
better way to do this with BYOND just yet. You can put multiple flags like this (not real flags):
```c
/obj/item/clothing/head/beret
	...
	flags_1 = IS_PLAYER_COLORABLE_1 | THIS_IS_A_FAKE_FLAG | THIS_IS_ANOTHER_FAKE_FLAG
```

## Debugging

If you're making a new greyscale sprite you sometimes want to be able to see how layers got generated or maybe you're just tweaking some colors. Rather than rebooting the server with every change there is a greyscale modification menu that can be found in the vv dropdown menu for the greyscale object. Here you can change colors, preview the results, and reload everything from their files.
