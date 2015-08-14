#!/usr/bin/perl -pi.orig
#ha ha time for regexes
#
use warnings;
use strict;
s@/obj/machinery/atmospherics/(unary|binary|trinary)@/obj/machinery/atmospherics/components/$1@g;
s@/obj/machinery/atmospherics/pipe/simple/insulated@/obj/machinery/atmospherics/pipe/simple@g
