import * as z from 'zod';

export type ChatPages = {
  chatPages: Record<string, Page>;
};

export type Page = {
  isMain: boolean;
  id: string;
  name: string;
  acceptedTypes: Record<string, boolean>;
  unreadCount: number;
  hideUnreadCount: boolean;
  createdAt: number;
};

export const storedSettingsSchema = z.object({
  version: z.number(),
  scrollTracking: z.boolean(),
  currentPageId: z.string(),
  pages: z.array(z.string()),
  pageById: z.record(z.string(), z.any()),
});

export type StoredChatSettings = z.infer<typeof storedSettingsSchema>;
