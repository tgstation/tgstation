type View = {
  activeTab: string;
  visible: boolean;
};

export type HighlightSetting = {
  highlightColor: string;
  highlightText: string;
  highlightWholeMessage: boolean;
  id: string;
  matchCase: boolean;
  matchWord: boolean;
};

export type SettingsState = {
  adminMusicVolume: number;
  fontFamily: string;
  fontSize: number;
  initialized: boolean;
  lineHeight: number;
  statFontSize: number;
  statLinked: boolean;
  statTabsStyle: string;
  theme: 'light' | 'dark';
  version: number;
  view: View;
};

export type HighlightState = {
  /** Keep this for compatibility with other servers */
  highlightColor?: string;
  highlightSettings: string[];
  highlightSettingById: Record<string, HighlightSetting>;
  /** Keep this for compatibility with other servers */
  highlightText?: string;
};
