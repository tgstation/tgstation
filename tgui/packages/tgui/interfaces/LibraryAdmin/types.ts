import type { BooleanLike } from 'tgui-core/react';

export type History = Record<string, HistoryEntry[]>;

type HistoryEntry = {
  // The id of this logged action
  id: number;
  // The book id this log applies to
  book: number;
  // The reason this action was enacted
  reason: string;
  // The admin who performed the action
  ckey: string;
  // The time of the action being performed
  datetime: string;
  // The action that ocurred
  action: string;
  // The ip address of the admin who performed the action
  ip_addr: string;
};

export enum ModifyTypes {
  Delete = 'delete',
  Restore = 'restore',
}

export type HistoryObj = Record<string, HistoryEntry[]>;

export type Book = {
  author: string;
  category: string;
  title: string;
  id: number;
};

export type LibraryAdminData = {
  author_ckey: string;
  author: string;
  book_id: number;
  can_connect: BooleanLike;
  can_db_request: BooleanLike;
  category: string;
  history: HistoryObj;
  our_page: number;
  page_count: number;
  pages: Book[];
  params_changed: BooleanLike;
  search_categories: string[];
  show_deleted: BooleanLike;
  title: string;
  view_raw: BooleanLike;
};
