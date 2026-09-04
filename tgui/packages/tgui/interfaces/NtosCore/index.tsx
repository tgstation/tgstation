import { useBackend } from 'tgui/backend';
import type { BooleanLike } from 'tgui-core/react';
import { createContext, useContext } from 'react';

type NtosData = {
  system: NtosSystemData;
  static_system: NtosSystemStaticData;
  programs_data: any;
  static_programs_data: any;
};

type NtosApi = {
  exit_program: (name: string) => void;
  shutdown: () => void;
  minimize_program: (name: string) => void;
  kill_program: (name: string) => void;
  run_program: (name: string) => void;
  toggle_light: () => void;
  switch_light_color: () => void;
  eject_disk: (name: string) => void;
  imprint_id: () => void;
  interact_pai: (option: string) => void;
};

type NtosSystemData = {
  light_color: string;
  has_light: BooleanLike;
  id_name: string;
  is_light_on: BooleanLike;
  login: Login;
  pai: string | null;
  alert_style: number;
  alert_color: string;
  alert_name: string;
  battery_icon: string | null;
  battery_percent: string | null;
  device_theme: string;
  is_lowpower_mode_on: BooleanLike;
  ntnet_icon: string;
  program_headers: Program[];
  station_date: string;
  station_time: string;
  programs: Program[];
  proposed_login: Login;
  removable_media: string[];
};

type NtosSystemStaticData = {
  show_imprint: BooleanLike;
};

type Program = {
  tgui_id: string;
  alert: BooleanLike;
  desc: string;
  header_program: BooleanLike;
  icon: string;
  name: string;
  active: BooleanLike;
  idle: BooleanLike;
  metadata?: ProgramMetadata;
};

type ProgramMetadata = {
  x: number;
  y: number;
  width: number;
  height: number;
};

type Login = {
  is_id_inserted?: BooleanLike;
  id_job: string | null;
  id_name: string | null;
};

type NtosState<TData> = {
  act: any;
  system: NtosSystemData & NtosSystemStaticData;
  data: TData;
  api: NtosApi;
};

export const NtosContext = createContext<string | null>(null);

export function useNtos<TData extends Record<string, any>>(): NtosState<TData> {
  const tgui_id = useContext(NtosContext);
  const { data, act } = useBackend<NtosData>();

  const systemAct = (action: string, payload: Record<string, unknown> = {}) => {
    return act(action, {
      ntos_sender_id: 'system',
      ...payload,
    });
  };

  const result: NtosState<TData> = {
    act: (action: string, payload: Record<string, unknown> = {}) =>
      tgui_id
        ? act(action, {
            ntos_sender_id: tgui_id,
            ...payload,
          })
        : systemAct(action, payload),
    system: { ...data?.system, ...data?.static_system } as NtosSystemData &
      NtosSystemStaticData,
    data: (tgui_id
      ? {
          ...data?.programs_data?.[tgui_id],
          ...data?.static_programs_data?.[tgui_id],
        }
      : {}) as TData,
    api: {
      exit_program: (name) => {
        systemAct('exit_program', { name: name });
      },
      shutdown: () => {
        systemAct('shutdown');
      },
      minimize_program: (name: string) => {
        systemAct('minimize_program', { name: name });
      },
      kill_program: (name: string) => {
        systemAct('kill_program', { name: name });
      },
      run_program: (name: string) => {
        systemAct('run_program', { name: name });
      },
      toggle_light: () => {
        systemAct('toggle_light');
      },
      switch_light_color: () => {
        systemAct('switch_light_color');
      },
      eject_disk: (name: string) => {
        systemAct('eject_disk', { name: name });
      },
      imprint_id: () => {
        systemAct('imprint_id');
      },
      interact_pai: (option: string) => {
        systemAct('interact_pai', { option: option });
      },
    },
  };

  return result;
}
