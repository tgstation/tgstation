import { BooleanLike } from 'common/react';

export type CargoData = {
  amount_by_name: Record<string, number> | undefined;
  app_cost?: number;
  away: BooleanLike;
  can_approve_requests: BooleanLike;
  can_send: BooleanLike;
  cart: CartEntry[];
  department: string;
  docked: BooleanLike;
  grocery: number;
  loan_dispatched: BooleanLike;
  loan: BooleanLike;
  location: string;
  max_order: number;
  message: string;
  points: number;
  requests: Request[];
  requestonly: BooleanLike;
  self_paid: BooleanLike;
  supplies: Record<string, SupplyCategory>;
};

export type SupplyCategory = {
  name: string;
  packs: Supply[];
};

export type Supply = {
  access: BooleanLike;
  cost: number;
  desc: string;
  goody: BooleanLike;
  id: string;
  name: string;
  small_item: BooleanLike;
};

type CartEntry = {
  amount: number;
  can_be_cancelled: BooleanLike;
  cost_type: string;
  cost: number;
  dep_order: BooleanLike;
  id: string;
  object: string;
  orderer: string;
  paid: BooleanLike;
};

type Request = {
  cost: number;
  id: string;
  object: string;
  orderer: string;
  reason: string;
};
