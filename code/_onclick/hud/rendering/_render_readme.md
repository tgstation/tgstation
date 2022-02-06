# The Render Readme

1. [Byond internal functionality](#byond-internal-functionality)
2. [Known internal snowflake](#known-internal-snowflake)
3. [The rendering solution](#the-rendering-solution)
4. [Render plates](#render-plates)

## Byond internal functionality
This part of the guide will assume that you have read the byond reference entry for rendering at www.byond.com/docs/ref//#/{notes}/renderer

When you create an atom, this will always create an internal byond structure called an "appearance". This appearance you will likely be familiar with, as it is exposed through the /atom/var/appearance var. This appearance var holds data on how to render the object, ie what icon/icon_state/color etc it is using. Note that appearance vars will always copy, and do not hold a reference. When you update a var, for example lets pretend we add a filter, the appearance will be updated to include the filter. Note that, however, vis_contents objets are uniquely excluded from appearances. Then, when the filter is updated, the appearance will be recreated, and the atom marked as "dirty". After it has been updated, the SendMaps() function (sometimes also called maptick), which is a internal byond function that iterates over all objects in a clients view and in the clients.mob.contents, checks for "dirty" atoms, then resends any "dirty" appearances to clients as needed and unmarks them as dirty. This function is notoriosly slow, but we can see it's tick usage through the world.map_cpu var. We can also avoid more complex checks checking whether an object is visible on a clients screen by using the TILE_BOUND appearance flag.

Finally, we arrive at clientside behavior, where we have two main clientside functions: GetMapIcons, and Render. GetMapIcons is repsonsible for actual rendering calculations on the clientside, such as "Group Icons and Set bounds", which performs clientside calculations for transform matrixes. Note that particles here are handled in a separate thread and are not diplayed in the clientside profiler. Render handles the actual drawing of the screen.

For debugging rendering issues its reccomended you do two things:
A) Talk to someone who has inside knowledge(like lummox) about it, most of this is undocumented and bugs often
B) Use the undocumented debug printer which reads of data on icons rendering, this is very dense but can be useful in some cases. To use: Right click top tab -> Options & Messages -> Client -> Command -> Enter ".debug profile mapicons" and press Enter -> go to your Byond directory and find BYOND/cfg/mapicons.json . Yes this is one giant one-line json.

## Known internal snowflake
The following is an incomplete list of pitfalls that come from byond snowflake that are known, this list is obviously incomplete.

1. Transforms are very slow on clientside. This is not usually noticable, but if you start using large amounts of them it will grind you to a halt quickly, regardless of whether its on overlays or objs
2. The darkness plane. The darkness plane has specific variables it needs to render correctly, and these can be found in the plane masters file. it is composed internally of two parts, a black mask over the clients screen, and a non rendering mask that blocks all luminosity=0 turfs and their contents from rendering if the SEE_BLACKNESS flag is set properly. It behaves very oddly, such as forcing itself to ALWAYS render or pre-render on blend_multiply blend mode or refusing to render the black mask properly otherwise. The blocker will always block rendering but the mask can be layered under other objects.
3. render_target/source. Render_target/source will only copy certain rendering instructions, and these are only defined as "etc." in the byond reference. Known non copied appearance vars include: blend_mode, plane, layer, vis_contents, mouse_opacity...
4. Large icons on the screen that peek over the edge will instead of only rendering partly like you would expect will instead stretch the screen while not adgusting the render buffer, which means that you can actively see as tiles and map objects are rendered. You can use this for an easy "offscreen" UI.
5. Numerically large filters on objects of any size will torpedo performance, even though large objects with small filters will perform massively better. (ie blur(size=20) BAD)
6. Texture Atlas: the texture atlas byond uses to render icons is very susceptible to corruption and can regularily replace icons with other icons or just not render at all. This can be exasperated by alt tabbing or pausing the dreamseeker process.
7. The renderer is awful code and lummox said he will try changing a large part of it for 515 so keep an eye on that
8. Byond uses DirectX 9 (Lummox said he wants to update to DirectX 11)
9. Particles are just fancy overlays and are not independent of their owner
10. Maptick items inside mob.contents are cheaper compared to most other movables
11. Displacement filter: The byond "displacement filter" does not, as the name would make you expect, use displacement maps, but instead uses normal maps.

## The rendering solution
One of the main issues with making pretty effects is how objects can only render to one plane, and how filters can only be applied to single objects. Quite simply it means we cant apply effects to multiple planes at once, and an effect to one plane only by treating it as a single unit:

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_old.png)

A semi-fix to stop from having to apply effects to every single plane is to use the render controllers, to automatically apply filters and colors automatically onto their controlled planes.

The solution is thus instead we replace plane masters rendering directly to client with planes that render multiple planes onto them as objects in order to be able to affect multiple planes while treating them as a single object. This is done by relaying the plane using a "render relay" onto a "render plate" which acts as a plane master of plane masters of sorts, and since planes are rendered onto it as single objects any filters we apply to them will render over the planes, treating them as a single unit.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_refactored.png)

We can also choose to render these by decreasing the scaling all applied effects (effect_size/number_of_plates_rendered_to) then rendering it onto multiple planes:

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_refactored_multiple.png)

Through these this allows us to treat planes as single objects, and lets us distort them as a single unit, most notably works wonders with the displacement filter. Specifically, here you can displacement_filter a plane onto a plate, which then will treat all the other planes rendered on that plate as a single unit.

## Render plates

The rendering system uses two objects to unify planes: render_relay and render_plates. Render relays use render_target/source and the relay_render_to_plane proc to replicate the plane master on the render relay. This render relay is then rendered onto a render_plate, which is a plane master that renders the render_relays onto itself. This plate can then be hierachically rendered with the same process until it reaches the master render_plate, which is the plate that will actually render to the player. These plates naturally in the byond style have quirks. For example, rendering to two plates will double any effects such as color or filters, and as such you need to carefully manage how you render them. Keep in mind as well that when sorting the layers for rendering on a plane that they should not be negative, this is handled automatically in relay_render_to_plane. When debugging note that mouse_opacity can act bizzarly with this method, such as only allowing you to click things that are layered over objects on a certain plane but auomatically setting the mouse_opacity should be handling this. Note that if you decide to manipulate a plane with internal byond objects that you will have to manually extrapolate the vars that are set if you want to render them to another plane (See blackness plane for example), and that this is not documented anywhere.


Goodluck and godspeed with coding
	- Just another contributor
