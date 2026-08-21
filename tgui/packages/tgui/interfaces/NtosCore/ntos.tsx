import { useBackend } from 'tgui/backend';
import type { BooleanLike } from 'tgui-core/react';

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
  comp_light_color: string;
  has_light: BooleanLike;
  id_name: string;
  light_on: BooleanLike;
  login: Login;
  pai: string | null;
  alert_style: number;
  alert_color: string;
  alert_name: string;
  PC_batteryicon: string | null;
  PC_batterypercent: string | null;
  PC_device_theme: string;
  PC_lowpower_mode: BooleanLike;
  PC_ntneticon: string;
  PC_programheaders: Program[];
  PC_showexitprogram: BooleanLike;
  PC_stationdate: string;
  PC_stationtime: string;
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
  IDInserted?: BooleanLike;
  IDJob: string | null;
  IDName: string | null;
};

type UseNtosProps = {
  tgui_id?: string;
};

type NtosState<TData> = {
  act: any;
  system: NtosSystemData & NtosSystemStaticData;
  data: TData;
  api: NtosApi;
};

export function useNtos<TData extends Record<string, any>>(
  props: UseNtosProps,
): NtosState<TData> {
  const { tgui_id } = props;
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
