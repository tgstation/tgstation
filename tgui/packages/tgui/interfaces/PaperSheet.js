/**
 * @file
 * @copyright 2020 WarlockD (https://github.com/warlockd)
 * @author Original WarlockD (https://github.com/warlockd)
 * @author Changes stylemistake
 * @author Changes ThePotato97
 * @author Changes Ghommie
 * @author Changes Timberpoes
 * @license MIT
 */

import { classes } from 'common/react';
import { Component } from 'inferno';
import { marked } from 'marked';
import { useBackend } from '../backend';
import { Box, Flex, Tabs, TextArea } from '../components';
import { Window } from '../layouts';
import { clamp } from 'common/math';
import { sanitizeText } from '../sanitize';
const MAX_PAPER_LENGTH = 5000; // Question, should we send this with ui_data?

// Hacky, yes, works?...yes
const textWidth = (text, font, fontsize) => {
  // default font height is 12 in tgui
  font = fontsize + 'x ' + font;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d');
  ctx.font = font;
  const width = ctx.measureText(text).width;
  return width;
};

const setFontinText = (text, font, color, bold = false) => {
  return (
    '<span style="' +
    'color:' +
    color +
    ';' +
    "font-family:'" +
    font +
    "';" +
    (bold ? 'font-weight: bold;' : '') +
    '">' +
    text +
    '</span>'
  );
};

const createIDHeader = (index) => {
  return 'paperfield_' + index;
};
// To make a field you do a [_______] or however long the field is
// we will then output a TEXT input for it that hopefully covers
// the exact amount of spaces
const field_regex = /\[(_+)\]/g;
const field_tag_regex =
  /\[<input\s+(?!disabled)(.*?)\s+id="(?<id>paperfield_\d+)"(.*?)\/>\]/gm;
const sign_regex = /%s(?:ign)?(?=\\s|$)?/gim;

const createInputField = (length, width, font, fontsize, color, id) => {
  return (
    '[<input ' +
    'type="text" ' +
    'style="' +
    "font:'" +
    fontsize +
    'x ' +
    font +
    "';" +
    'color:' +
    color +
    ';' +
    'min-width:' +
    width +
    ';' +
    'max-width:' +
    width +
    ';' +
    '" ' +
    'id="' +
    id +
    '" ' +
    'maxlength=' +
    length +
    ' ' +
    'size=' +
    length +
    ' ' +
    '/>]'
  );
};

const createFields = (txt, font, fontsize, color, counter) => {
  const ret_text = txt.replace(field_regex, (match, p1, offset, string) => {
    const width = textWidth(match, font, fontsize) + 'px';
    return createInputField(
      p1.length,
      width,
      font,
      fontsize,
      color,
      createIDHeader(counter++)
    );
  });
  return {
    counter,
    text: ret_text,
  };
};

const signDocument = (txt, color, user) => {
  return txt.replace(sign_regex, () => {
    return setFontinText(user, 'Times New Roman', color, true);
  });
};

const run_marked_default = (value) => {
  // Override function, any links and images should
  // kill any other marked tokens we don't want here
  const walkTokens = (token) => {
    switch (token.type) {
      case 'url':
      case 'autolink':
      case 'reflink':
      case 'link':
      case 'image':
        token.type = 'text';
        // Once asset system is up change to some default image
        // or rewrite for icon images
        token.href = '';
        break;
    }
  };
  return marked(value, {
    breaks: true,
    smartypants: true,
    smartLists: true,
    walkTokens,
    // Once assets are fixed might need to change this for them
    baseUrl: 'thisshouldbreakhttp',
  });
};

/*
 ** This gets the field, and finds the dom object and sees if
 ** the user has typed something in.  If so, it replaces,
 ** the dom object, in txt with the value, spaces so it
 ** fits the [] format and saves the value into a object
 ** There may be ways to optimize this in javascript but
 ** doing this in byond is nightmarish.
 **
 ** It returns any values that were saved and a corrected
 ** html code or null if nothing was updated
 */
const checkAllFields = (txt, font, color, user_name, bold = false) => {
  let matches;
  let values = {};
  let replace = [];
  // I know its tempting to wrap ALL this in a .replace
  // HOWEVER the user might not of entered anything
  // if thats the case we are rebuilding the entire string
  // for nothing, if nothing is entered, txt is just returned
  while ((matches = field_tag_regex.exec(txt)) !== null) {
    const full_match = matches[0];
    const id = matches.groups.id;
    if (id) {
      const dom = document.getElementById(id);
      // make sure we got data, and kill any html that might
      // be in it
      const dom_text = dom && dom.value ? dom.value : '';
      if (dom_text.length === 0) {
        continue;
      }
      const sanitized_text = sanitizeText(dom.value.trim(), []);
      if (sanitized_text.length === 0) {
        continue;
      }
      // this is easier than doing a bunch of text manipulations
      const target = dom.cloneNode(true);
      // in case they sign in a field
      if (sanitized_text.match(sign_regex)) {
        target.style.fontFamily = 'Times New Roman';
        bold = true;
        target.defaultValue = user_name;
      } else {
        target.style.fontFamily = font;
        target.defaultValue = sanitized_text;
      }
      if (bold) {
        target.style.fontWeight = 'bold';
      }
      target.style.color = color;
      target.disabled = true;
      const wrap = document.createElement('div');
      wrap.appendChild(target);
      values[id] = sanitized_text; // save the data
      replace.push({ value: '[' + wrap.innerHTML + ']', raw_text: full_match });
    }
  }
  if (replace.length > 0) {
    for (const o of replace) {
      txt = txt.replace(o.raw_text, o.value);
    }
  }
  return { text: txt, fields: values };
};

const pauseEvent = (e) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
};

const Stamp = (props, context) => {
  const { image, opacity } = props;
  const stamp_transform = {
    'left': image.x + 'px',
    'top': image.y + 'px',
    'transform': 'rotate(' + image.rotate + 'deg)',
    'opacity': opacity || 1.0,
  };
  return (
    <div
      id="stamp"
      className={classes(['Paper__Stamp', image.sprite])}
      style={stamp_transform}
    />
  );
};

const setInputReadonly = (text, readonly) => {
  return readonly
    ? text.replace(/<input\s[^d]/g, '<input disabled ')
    : text.replace(/<input\sdisabled\s/g, '<input ');
};

// got to make this a full component if we
// want to control updates
const PaperSheetView = (props, context) => {
  const { value = '', stamps = [], backgroundColor, readOnly } = props;
  const stamp_list = stamps;
  const text_html = {
    __html:
      '<span class="paper-text">' +
      setInputReadonly(value, readOnly) +
      '</span>',
  };
  return (
    <Box
      position="relative"
      backgroundColor={backgroundColor}
      width="100%"
      height="100%">
      <Box
        className="Paper__Page"
        fillPositionedParent
        width="100%"
        height="100%"
        dangerouslySetInnerHTML={text_html}
        p="10px"
      />
      {stamp_list.map((o, i) => (
        <Stamp
          key={o[0] + i}
          image={{ sprite: o[0], x: o[1], y: o[2], rotate: o[3] }}
        />
      ))}
    </Box>
  );
};

// again, need the states for dragging and such
class PaperSheetStamper extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      x: 0,
      y: 0,
      rotate: 0,
    };
    this.style = null;
    this.handleMouseMove = (e) => {
      const pos = this.findStampPosition(e);
      if (!pos) {
        return;
      }
      // center offset of stamp & rotate
      pauseEvent(e);
      this.setState({ x: pos[0], y: pos[1], rotate: pos[2] });
    };
    this.handleMouseClick = (e) => {
      if (e.pageY <= 30) {
        return;
      }
      const { act, data } = useBackend(this.context);
      const stamp_obj = {
        x: this.state.x,
        y: this.state.y,
        r: this.state.rotate,
        stamp_class: this.props.stamp_class,
        stamp_icon_state: data.stamp_icon_state,
      };
      act('stamp', stamp_obj);
    };
  }

  findStampPosition(e) {
    let rotating;
    const windowRef = document.querySelector('.Layout__content');
    if (e.shiftKey) {
      rotating = true;
    }

    if (document.getElementById('stamp')) {
      const stamp = document.getElementById('stamp');
      const stampHeight = stamp.clientHeight;
      const stampWidth = stamp.clientWidth;

      const currentHeight = rotating
        ? this.state.y
        : e.pageY - windowRef.scrollTop - stampHeight;
      const currentWidth = rotating ? this.state.x : e.pageX - stampWidth / 2;

      const widthMin = 0;
      const heightMin = 0;

      const widthMax = windowRef.clientWidth - stampWidth;
      const heightMax =
        windowRef.clientHeight - windowRef.scrollTop - stampHeight;

      const radians = Math.atan2(
        e.pageX - currentWidth,
        e.pageY - currentHeight
      );

      const rotate = rotating
        ? radians * (180 / Math.PI) * -1
        : this.state.rotate;

      const pos = [
        clamp(currentWidth, widthMin, widthMax),
        clamp(currentHeight, heightMin, heightMax),
        rotate,
      ];
      return pos;
    }
  }

  componentDidMount() {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('click', this.handleMouseClick);
  }

  componentWillUnmount() {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('click', this.handleMouseClick);
  }

  render() {
    const { value, stamp_class, stamps } = this.props;
    const stamp_list = stamps || [];
    const current_pos = {
      sprite: stamp_class,
      x: this.state.x,
      y: this.state.y,
      rotate: this.state.rotate,
    };
    return (
      <>
        <PaperSheetView readOnly value={value} stamps={stamp_list} />
        <Stamp active_stamp opacity={0.5} image={current_pos} />
      </>
    );
  }
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
  const out = { text: text };
  // check if we are adding to paper, if not
  // we still have to check if someone entered something
  // into the fields
  value = value.trim();
  if (value.length > 0) {
    // First lets make sure it ends in a new line
    value += value[value.length] === '\n' ? ' \n' : '\n \n';
    // Second, we sanitize the text of html
    const sanitized_text = sanitizeText(value);
    const signed_text = signDocument(sanitized_text, color, user_name);
    // Third we replace the [__] with fields as markedjs fucks them up
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

// ugh.  So have to turn this into a full
// component too if I want to keep updates
// low and keep the weird flashing down
class PaperSheetEdit extends Component {
  constructor(props, context) {
    super(props, context);
    this.state = {
      previewSelected: 'Preview',
      old_text: props.value || '',
      counter: props.counter || 0,
      textarea_text: '',
      combined_text: props.value || '',
    };
  }

  createPreviewFromData(value, do_fields = false) {
    const { data } = useBackend(this.context);
    return createPreview(
      value,
      this.state.old_text,
      do_fields,
      this.state.counter,
      data.pen_color,
      data.pen_font,
      data.edit_usr,
      data.is_crayon
    );
  }
  onInputHandler(e, value) {
    if (value !== this.state.textarea_text) {
      const combined_length =
        this.state.old_text.length + this.state.textarea_text.length;
      if (combined_length > MAX_PAPER_LENGTH) {
        if (combined_length - MAX_PAPER_LENGTH >= value.length) {
          // Basically we cannot add any more text to the paper
          value = '';
        } else {
          value = value.substr(
            0,
            value.length - (combined_length - MAX_PAPER_LENGTH)
          );
        }
        // we check again to save an update
        if (value === this.state.textarea_text) {
          // Do nothing
          return;
        }
      }
      this.setState(() => ({
        textarea_text: value,
        combined_text: this.createPreviewFromData(value),
      }));
    }
  }
  // the final update send to byond, final upkeep
  finalUpdate(new_text) {
    const { act } = useBackend(this.context);
    const final_processing = this.createPreviewFromData(new_text, true);
    act('save', final_processing);
    this.setState(() => {
      return {
        textarea_text: '',
        previewSelected: 'save',
        combined_text: final_processing.text,
        old_text: final_processing.text,
        counter: final_processing.field_counter,
      };
    });
    // byond should switch us to readonly mode from here
  }

  render() {
    const { textColor, fontFamily, stamps, backgroundColor } = this.props;
    return (
      <Flex direction="column" fillPositionedParent>
        <Flex.Item>
          <Tabs>
            <Tabs.Tab
              key="marked_edit"
              textColor={'black'}
              backgroundColor={
                this.state.previewSelected === 'Edit' ? 'grey' : 'white'
              }
              selected={this.state.previewSelected === 'Edit'}
              onClick={() => this.setState({ previewSelected: 'Edit' })}>
              Edit
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_preview"
              textColor={'black'}
              backgroundColor={
                this.state.previewSelected === 'Preview' ? 'grey' : 'white'
              }
              selected={this.state.previewSelected === 'Preview'}
              onClick={() =>
                this.setState(() => {
                  const new_state = {
                    previewSelected: 'Preview',
                    textarea_text: this.state.textarea_text,
                    combined_text: this.createPreviewFromData(
                      this.state.textarea_text
                    ).text,
                  };
                  return new_state;
                })
              }>
              Preview
            </Tabs.Tab>
            <Tabs.Tab
              key="marked_done"
              textColor={'black'}
              backgroundColor={
                this.state.previewSelected === 'confirm'
                  ? 'red'
                  : this.state.previewSelected === 'save'
                    ? 'grey'
                    : 'white'
              }
              selected={
                this.state.previewSelected === 'confirm' ||
                this.state.previewSelected === 'save'
              }
              onClick={() => {
                if (this.state.previewSelected === 'confirm') {
                  this.finalUpdate(this.state.textarea_text);
                } else if (this.state.previewSelected === 'Edit') {
                  this.setState(() => {
                    const new_state = {
                      previewSelected: 'confirm',
                      textarea_text: this.state.textarea_text,
                      combined_text: this.createPreviewFromData(
                        this.state.textarea_text
                      ).text,
                    };
                    return new_state;
                  });
                } else {
                  this.setState({ previewSelected: 'confirm' });
                }
              }}>
              {this.state.previewSelected === 'confirm' ? 'Confirm' : 'Save'}
            </Tabs.Tab>
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1} basis={1}>
          {(this.state.previewSelected === 'Edit' && (
            <TextArea
              value={this.state.textarea_text}
              textColor={textColor}
              fontFamily={fontFamily}
              height={window.innerHeight - 80 + 'px'}
              backgroundColor={backgroundColor}
              onInput={this.onInputHandler.bind(this)}
            />
          )) || (
            <PaperSheetView
              value={this.state.combined_text}
              stamps={stamps}
              fontFamily={fontFamily}
              textColor={textColor}
            />
          )}
        </Flex.Item>
      </Flex>
    );
  }
}

export const PaperSheet = (props, context) => {
  const { data } = useBackend(context);
  const {
    edit_mode,
    text,
    paper_color = 'white',
    pen_color = 'black',
    pen_font = 'Verdana',
    stamps,
    stamp_class,
    sizeX,
    sizeY,
    name,
    add_text,
    add_font,
    add_color,
    add_sign,
    field_counter,
  } = data;
  // some features can add text to a paper sheet outside of this ui
  // we need to parse, sanitize and add any of it to the text value.
  const values = { text: text, field_counter: field_counter };
  if (add_text) {
    for (let index = 0; index < add_text.length; index++) {
      const used_color = add_color[index];
      const used_font = add_font[index];
      const used_sign = add_sign[index];
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
  } else {
    values.text = sanitizeText(text);
  }
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
      title={name}
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
