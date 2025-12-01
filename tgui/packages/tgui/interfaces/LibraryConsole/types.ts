import type { BooleanLike } from 'tgui-core/react';

type CheckoutEntry = {
  author: string;
  borrower: string;
  due_in_minutes: number;
  id: string;
  overdue: BooleanLike;
  ref: string;
  title: string;
};

type InventoryEntry = {
  author: string;
  ref: string;
  title: string;
};

type Page = {
  author: string;
  category: string;
  id: string;
  title: string;
};

export type LibraryConsoleData = {
  active_newscaster_cooldown: BooleanLike;
  author: string;
  bible_name: string;
  bible_sprite: string;
  book_id: string;
  cache_author: string;
  cache_content: string;
  cache_title: string;
  can_connect: BooleanLike;
  can_db_request: BooleanLike;
  category: string;
  checkout_page_count: number;
  checkout_page: number;
  checkouts: CheckoutEntry[];
  cooldown_string: string;
  default_category: string;
  deity: string;
  display_lore: BooleanLike;
  has_cache: BooleanLike;
  has_checkout: BooleanLike;
  has_inventory: BooleanLike;
  has_scanner: BooleanLike;
  inventory_page_count: number;
  inventory_page: number;
  inventory: InventoryEntry[];
  our_page: number;
  page_count: number;
  pages: Page[];
  params_changed: BooleanLike;
  posters: string[];
  religion: string;
  screen_state: number;
  search_categories: string[];
  show_dropdown: BooleanLike;
  title: string;
  upload_categories: string[];
};
