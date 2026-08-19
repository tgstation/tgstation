/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import type { BooleanLike } from 'tgui-core/react';
import { Window } from './Window';

export type NTOSData = {
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

export const NtosWindow = (props) => {
  const { width = 575, height = 700, children } = props;
  return <div style={{ width: width, height: height }}>{children}</div>;
};

const NtosWindowContent = (props) => {
  return (
    <div className="NtosWindow__content">
      <Window.Content {...props} />
    </div>
  );
};

NtosWindow.Content = NtosWindowContent;
