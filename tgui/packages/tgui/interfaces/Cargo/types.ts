import type { BooleanLike } from 'tgui-core/react';

export type CargoData = {
  app_cost?: number;
  away: BooleanLike;
  can_approve_requests: BooleanLike;
  can_send: BooleanLike;
  cart: CartEntry[];
  department: string;
  displayed_currency_full_name: string;
  displayed_currency_name: string;
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
  first_item_icon: string | null;
  first_item_icon_state: string | null;
  goody: BooleanLike;
  id: string;
  name: string;
  small_item: BooleanLike;
  contraband: BooleanLike;
  contains: SupplyItem[];
};

type SupplyItem = {
  name: string;
  icon: string | null;
  icon_state: string | null;
  amount: number;
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
  account: string;
  reason: string;
};
