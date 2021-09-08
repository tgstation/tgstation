# The Render Readme

1. [Byond internal functionality](#byond-internal-functionality)
2. [Known internal snowflake](#known-internal-snowflake)
3. [The rendering solution](#the-rendering-solution)
4. [Render plates](#render-plates)

## Byond internal functionality
This part of the guide will assume that you have read the byond reference entry for rendering at www.x

When you create an atom, this will always create an internal byond structure called an "appearance". This appearance you will likely be familiar with,as it is exposed through the /atom/var/appearance var. This appearance var holds data on how to render the object, ie what icon/icon_state/color etc it is using. Note that appearance vars will always copy, and do not hold a reference. When you update a var, for example lets pretend we add a filter, the appearance will be updated to include the filter. Note that, however, vis_contents objets are uniquely excluded from appearances. Then, when the filter is updated, the appearance will be recreated, and the atom marked as "dirty". After it has been updated, the SendMaps() function (sometimes also called maptick), which is a internal byond function that iterates over all objects in a clients view and in the clients.mob.contents, checks for "dirty" atoms, then resends any "dirty" appearances to clients as needed and unmarks them as dirty. This function is notoriosly slow, but we can see it's tick usage through the world.map_cpu var. We can also avoid more complex checks checking whether an object is visible on a clients screen by using the TILE_BOUND appearance flag.

Finally we arrive at clientside behavior, where we have two main clientside functions: GetMapIcons, and Render. GetMapIcons is repsonsible for actual rendering calculations on the clientside, such as "Group Icons and Set bounds", which performs clientside calculations for transform matrixes. Note that particles here are handled in a seperate thread and are not diplayed in the clientside profiler. Render handles the actual drawing of the screen.

## Known internal snowflake
The following is an incomplete list of pitfalls that come from byond snowflake that are known, this list is obviously incomplete.

1. Transforms are very slow on clientside. This is not usually noticable, but if you start using large amounts of them it will grind you to a halt quickly, regardless of whether its on overlays or objs
2. The darkness plane. The darkness plane has specific variables it needs to render correctly, and these can be found in the plane masters file. it is composed internally of two parts, a black mask over the clients screen, and a non rendering mask that blocks all luminosity=0 turfs and their contents from rendering if the SEE_BLACKNESS flag is set. it behaves very oddly, such as forcing itself to ALWAYS render or pre-render on blend_multiply blend mode or refusing to render the black mask properly otherwise.
3. render_target/source. Render_target/source will only copy certain rendering instructions, and these are only defined as "etc." in the byond reference. Known non copied appearance vars include: blend_mode(exception with darkness plane), plane, layer, vis_contents
4. Numerically large filters on objects of any size will torpedo performance, even though large objects with small filters will perform massively better. (ie blur(size=20) BAD)
5. Texture Atlas: the texture atlas byond uses to render icons is very susceptible to corruption and can regularily replace icons with other icons or just not render at all. This can be exasperated by alt tabbing or pausing the dreamseeker process.
6. The renderer is awful code and lummox said he will try changing a large part of it for 515 so keep an eye on that
7. Byond uses DirectX 9 (Lummox said he wants to update to DirectX 11)
8. Particles are just fancy overlays and are not independent of their owner
9. Maptick items inside mob.contents are cheaper compared to most other movables

## The rendering solution
One of the main issues with making pretty effects is how objects can only render to one plane, and how filters can only be applied to single objects. Quite simply it means we cant apply effects to multiple planes at once, and an effect to one plane only by treating it as a single unit:

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_old.png)

A semi-fix to stop from having to apply effects is to use the render controllers, to automatically apply filters and colors automatically onto their controlled planes.

The solution is thus instead we replace plane masters rendering directly to client with planes that render multiple planes onto them as objects in order to be able to affect multiple planes while treating them as a single object. This is done by relaying the plane using a "render relay" onto a "render plate" which acts as a plane master of plane masters of sorts, and since planes are rendered onto it as single objects any filters we apply to them will render over the planes, treating them as a single unit.

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_refactored.png)

We can also choose to render these by decreasing the scaling all applied effects (scale/number_of_plates_rendered_to) then rendering it onto multiple planes:

![](https://raw.githubusercontent.com/tgstation/documentation-assets/main/rendering/renderpipe_refactored_multiple.png)

