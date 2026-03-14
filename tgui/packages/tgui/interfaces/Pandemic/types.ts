import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  beaker?: Beaker;
  blood?: Blood;
  has_beaker: BooleanLike;
  has_blood: BooleanLike;
  is_ready: BooleanLike;
  resistances?: Resistance[];
  viruses?: Virus[];
};

type Beaker = {
  volume: number;
  capacity: number;
};

type Blood = {
  dna: string;
  type: string;
};

type Resistance = {
  id: string;
  name: string;
};

type Virus = {
  name: string;
  can_rename: BooleanLike;
  is_adv: BooleanLike;
  symptoms?: Symptom[];
  resistance: number;
  stealth: number;
  stage_speed: number;
  transmission: number;
  index: number;
  agent: string;
  description: string;
  spread: string;
  cure: string;
};

export type Symptom = {
  name: string;
  desc: string;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  level: number;
  neutered: BooleanLike;
  threshold_desc: Threshold[];
};

export type Threshold = {
  label: string;
  descr: string;
};
