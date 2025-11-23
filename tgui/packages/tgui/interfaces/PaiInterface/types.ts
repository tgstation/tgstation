import type { BooleanLike } from 'tgui-core/react';

export type PaiData = {
  available: Record<string, number>;
  directives: string;
  door_jack: string | null;
  emagged: BooleanLike;
  screen_image_interface_icon: string;
  installed: ReadonlyArray<string>;
  languages: BooleanLike;
  master_dna: string | null;
  master_name: string | null;
  ram: number;
};
