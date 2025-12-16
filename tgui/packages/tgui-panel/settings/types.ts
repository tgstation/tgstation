import * as z from 'zod';
import type { ChatPages } from '../chat/types';

const viewSchema = z.object({
  activeTab: z.string(),
  visible: z.boolean(),
});

export const settingsSchema = z.object({
  adminMusicVolume: z.number(),
  fontFamily: z.string(),
  fontSize: z.number(),
  initialized: z.boolean(),
  lineHeight: z.number(),
  statFontSize: z.number(),
  statLinked: z.boolean(),
  statTabsStyle: z.string(),
  theme: z.string(),
  version: z.number(),
  view: viewSchema,
});

export type HighlightSetting = {
  highlightColor: string;
  highlightText: string;
  highlightWholeMessage: boolean;
  id: string;
  matchCase: boolean;
  matchWord: boolean;
};

export type HighlightState = {
  highlightSettings: string[];
  highlightSettingById: Record<string, HighlightSetting>;
  highlightText: string;
  highlightColor: string;
};

export type SettingsState = z.infer<typeof settingsSchema>;

// Imported and loaded settings without chatpages
export interface MergedSettings extends SettingsState, HighlightState {}

// Full exported settings with chatpages
export interface ExportedSettings extends MergedSettings, ChatPages {}
