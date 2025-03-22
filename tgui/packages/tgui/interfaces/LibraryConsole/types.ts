import { BooleanLike } from 'tgui-core/react';

export type LibraryConsoleData = {
  active_newscaster_cooldown: BooleanLike;
  can_db_request: BooleanLike;
  display_lore: BooleanLike;
  has_cache: BooleanLike;
  has_inventory: BooleanLike;
  has_scanner: BooleanLike;
  inventory_page_count: number;
  inventory_page: number;
  inventory: any[];
  screen_state: number;
  show_dropdown: BooleanLike;
  upload_categories: string[];
  default_category: string;
};
