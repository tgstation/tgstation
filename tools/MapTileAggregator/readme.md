## What does this tool do?

This tool aggregates or "flattens" out turf_decal tiles on a map. For example, let's assume you have this map key:

```txt
"qp" = (
/obj/effect/decal/cleanable/dirt,
/obj/machinery/atmospherics/pipe/smart/manifold4w/supply/hidden,
/obj/effect/turf_decal/tile/blue,
/obj/effect/turf_decal/tile/blue{
    dir = 4
    },
/turf/open/floor/iron{
    initial_gas_mix = "TEMP=2.7"
    },
/area/shuttle/caravan/freighter1)
```

This tool will just turn those two separate `/obj/effect/turf_decal/tile/blue` into one `/obj/effect/turf_decal/tile/blue/half/contrasted` with the correct dir, like so:

```txt
"qp" = (
/obj/effect/decal/cleanable/dirt,
/obj/machinery/atmospherics/pipe/smart/manifold4w/supply/hidden,
/obj/effect/turf_decal/tile/blue/half/contrasted{
    dir = 4
    },
/turf/open/floor/iron{
    initial_gas_mix = "TEMP=2.7"
    },
/area/shuttle/caravan/freighter1)
```

Simple! This goes for any possible permuation of turf decals in a map key, respecting any possible color and combination thereof.

##### [click me if you don't understand what you just saw](https://hackmd.io/@tgstation/ry4-gbKH5#Map-Keys-no-holds-barred)

## How do I use this tool?

Just double-click the `MapTileAggregator.bat` file in this directory and it'll automatically run the Python tool on all of the `.dmm` files in the `/_maps` directory. It'll also automatically run the `MapMerge` tool once it's done to keep everything nice and tidy.
