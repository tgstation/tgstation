#!/usr/bin/perl -pi
#ha ha time for regexes
#
#This is not the best solution for fixing pathes, but it works faster than opening every dmm and correcting the pathes there
use warnings;
use strict;
s@/obj/effect/decal/cleanable/xenoblood/xgibs@/obj/effect/decal/cleanable/blood/gibs/xgibs@g;
s@/obj/effect/decal/cleanable/xenoblood@/obj/effect/decal/cleanable/blood/xeno@g;

