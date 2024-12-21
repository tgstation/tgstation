export type PaperContext = {
  // ui_static_data
  default_pen_color: string;
  default_pen_font: string;
  max_input_field_length: number;
  max_length: number;
  paper_color: string;
  paper_name: string;
  raw_field_input?: FieldInput[];
  raw_stamp_input?: StampInput[];
  raw_text_input?: PaperInput[];
  sanitize_text: boolean;
  signature_font: string;
  user_name: string;

  // ui_data
  held_item_details?: WritingImplement;
};

export type FieldInput = {
  field_index: string;
  field_data: PaperInput;
  is_signature: boolean;
};

export type PaperInput = {
  raw_text: string;
} & Partial<{
  font: string;
  color: string;
  bold: boolean;
  advanced_html: boolean;
}>;

type StampInput = {
  class: string;
  x: number;
  y: number;
  rotation: number;
};

export enum InteractionType {
  reading = 0,
  writing = 1,
  stamping = 2,
}

export type WritingImplement = {
  interaction_mode: InteractionType;
} & Partial<{
  color: string;
  font: string;
  stamp_class: string;
  stamp_icon_state: string;
  use_bold: boolean;
}>;
