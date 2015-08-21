#!/usr/bin/perl -pi
#ha ha time for regexes
#
use warnings;
use strict;
s@/obj/item/organ/heart@/obj/item/organ/internal/heart@g;
s@/obj/item/organ/appendix@/obj/item/organ/internal/appendix@g;
s@/obj/item/body_egg@/obj/item/organ/internal/body_egg@g;

