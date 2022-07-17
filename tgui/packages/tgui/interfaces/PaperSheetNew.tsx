/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @author Changes ThePotato97
 * @author Changes Ghommie
 * @author Changes Timberpoes
 * @license MIT


// import { classes } from 'common/react';
// import { Component } from 'inferno';
// import { marked } from 'marked';
import { useBackend } from '../backend';
// import { Box, Flex, Tabs, TextArea } from '../components';
// import { Window } from '../layouts';
// import { clamp } from 'common/math';
// import { sanitizeText } from '../sanitize';

type PaperContext = {
  edit_mode: number,
  text: string,
  paper_color: string,
  pen_color: string,
  pen_font: string,
  stamps?: Stamp[],
  stamp_class: string,
  add_text: string[],
  add_font: string[],
  add_color: string[],
  add_sign: string[],
  field_counter: number,
}

type Stamp = {
  class: string,
  x: number,
  y: number,
  rotation: number,
}

// This creates the html from marked text as well as the form fields
const createPreview = (
  value,
  text,
  do_fields = false,
  field_counter,
  color,
  font,
  user_name,
  is_crayon = false
) => {
  const out = { text: text, field_counter: field_counter };
  // check if we are adding to paper, if not
  // we still have to check if someone entered something
  // into the fields
  value = value.trim();
  if (value.length > 0) {
    // First lets make sure it ends in a new line.
    value += value[value.length] === '\n' ? ' \n' : '\n \n';
    // Second, sign the document if necessary.
    const signed_text = signDocument(value, color, user_name);
    // Third we replace the [__] with fields as markedjs has issues with them.
    const fielded_text = createFields(
      signed_text,
      font,
      12,
      color,
      field_counter
    );
    // Fourth, parse the text using markup
    const formatted_text = run_marked_default(fielded_text.text);
    // Fifth, we wrap the created text in the pin color, and font.
    // crayon is bold (<b> tags), maybe make fountain pin italic?
    const fonted_text = setFontinText(formatted_text, font, color, is_crayon);
    out.text += fonted_text;
    out.field_counter = fielded_text.counter;
  }
  if (do_fields) {
    // finally we check all the form fields to see
    // if any data was entered by the user and
    // if it was return the data and modify the text
    const final_processing = checkAllFields(
      out.text,
      font,
      color,
      user_name,
      is_crayon
    );
    out.text = final_processing.text;
    out.form_fields = final_processing.fields;
  }
  return out;
};

export const PaperSheet = (props, context) => {
  const { data } = useBackend<PaperContext>(context);
  const {
    edit_mode,
    text,
    paper_color,
    pen_color,
    pen_font,
    stamps,
    stamp_class,
    add_text,
    add_font,
    add_color,
    add_sign,
    field_counter,
  } = data;


  // some features can add text to a paper sheet outside of this ui
  // we need to parse, sanitize and add any of it to the text value.
  const values = { text: text, field_counter: field_counter };

  for (let i = 0; i < add_text.length; i++) {
    const used_color = add_color[i];
    const used_font = add_font[i];
    const used_sign = add_sign[i];

    const processing = createPreview(
      add_text[index],
      values.text,
      false,
      values.field_counter,
      used_color,
      used_font,
      used_sign
    );
    values.text = processing.text;
    values.field_counter = processing.field_counter;
  }


  values.text = sanitizeText(text);

  const stamp_list = !stamps ? [] : stamps;
  const decide_mode = (mode) => {
    switch (mode) {
      case 0:
        return (
          <PaperSheetView value={values.text} stamps={stamp_list} readOnly />
        );
      case 1:
        return (
          <PaperSheetEdit
            value={values.text}
            counter={values.field_counter}
            textColor={pen_color}
            fontFamily={pen_font}
            stamps={stamp_list}
            backgroundColor={paper_color}
          />
        );
      case 2:
        return (
          <PaperSheetStamper
            value={values.text}
            stamps={stamp_list}
            stamp_class={stamp_class}
          />
        );
      default:
        return 'ERROR ERROR WE CANNOT BE HERE!!';
    }
  };
  return (
    <Window
      theme="paper"
      width={sizeX || 400}
      height={sizeY || 500}>
      <Window.Content backgroundColor={paper_color} scrollable>
        <Box id="page" fitted fillPositionedParent>
          {decide_mode(edit_mode)}
        </Box>
      </Window.Content>
    </Window>
  );
};
*/
