# Working with Pixel Movement

## Introduction
Pixel movement is a relatively new feature in the /tg/ station codebase. As this feature changes a lot this readme file serves to give some useful pointers and tips on how to handle and work with pixel movement

Please read the official byond reference on pixel movement first before continuing
Offical reference: http://www.byond.com/docs/ref/index.html#/{notes}/pixel-movement

## Step vs Walk
The first thing you'll notice is that using steps will only make one move in the direction chosen this is equivalent to a single keypress and would require a lot more step calls to create a smooth movement to a location, the preferred solution to this is to use the respective walk proc(walk, walk_to, walk_towards) for non-player moves, we also have a special walk_for helper which is constant movement in a direction for a specified duration

## locs, bounds and obounds
Now that we're no longer using turfs, if you want to check if something is in range you can call the bounds or obounds procs, more information in these respective reference links
bounds: http://www.byond.com/docs/ref/index.html#/proc/bounds
obounds: http://www.byond.com/docs/ref/index.html#/proc/obounds
loc itself is a very inconsistent var and it's not always the nearest turf to the ref, for that theres a new helper proc called nearest_turf() which takes ref as an argument and returns the turf that's closest to it. locs is a new list that returns a list of all turfs overlapped by the ref.
Bounds can take additional arguments so you can use dynamic hitboxes for certain checks, making the bounding boxes larger or smaller depending on the results you want.

## forceStep
If you've worked with the codebase prior then you would know about the forceMove proc which would teleport the provided ref to the location defined. forceStep is the pixel movement version of this proc, setting the step_x and step_y values to the ones defined by the args, if you'd like to set the step_x and step_y values manually you should call forceStep(null, <desired_x>, <desired_y>) and if you want the step_ values to line up with a defined movable then you simply call forceStep(<desired_movable>) and ref will copy the step_ values of the object which will offset its location on the turf
