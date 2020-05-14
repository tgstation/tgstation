import { toTitleCase } from 'common/string';
import { Grid, Fragment, Box, Button } from '../components';
import { useBackend, useSharedState, useLocalState } from '../backend';
import { Window } from '../layouts';
// import marked from 'marked';
import { marked } from '../components/marked/marked';
import { pureComponentHooks, classes, isFalsy } from 'common/react';
import { Component, createRef, createElement, render } from 'inferno';

import { createLogger } from '../logging';

const logger = createLogger('PaperSheet');
// Start of stupid cut and paste


// so..why this?  textarea is shit, lets be honest
// however, without it cut and paste is annoying
// SO we are left with using textarea for input, handle focus
// as well paste and copy to the clipboard.
// I am expermenting with editable box, but considering hotkeys.js
// fiters eveything expcet input and textbox, don't really have
// a choice without editing hotkeys or having a way to turn it off
class TextArea extends Component {
  constructor(props, context) {
    super(props, context);
    this.textarea_ref = createRef();
    this.filler_ref = createRef();
    this.state = { editing: false, value: props.value || "" };
    this.handleOnChange = e => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
      }
      if (onChange) {
        onChange(e, e.target.value);
      }
      if (this.textarea_ref) {
        this.value = this.textarea_ref.current.value;
        this.setState({ value: this.textarea_ref.current.value });
      }
      this.autoresize();
    };
    this.handleKeyDown = e => {
      const { editing } = this.state;
      const { onKeyDown } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onKeyDown) {
        onKeyDown(e, e.target.value);
      }
      if (this.textarea_ref) {
        this.value = this.textarea_ref.current.value;
        this.setState({ value: this.textarea_ref.current.value });
      }
      this.autoresize();
    };
    this.handleKeyPress = e => {
      const { editing } = this.state;
      const { onKeyPress } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (onKeyPress) {
        onKeyPress(e, e.target.value);
      }
      if (this.textarea_ref) {
        this.value = this.textarea_ref.current.value;
        this.setState({ value: this.textarea_ref.current.value });
      }
      this.autoresize();
    };
  }
  getText() {
    return this.state.value;
  }

  setEditing(editing) {
    this.setState({ editing: editing });
  }
  // found this hack that expands the text area.  see the paper
  // theam for the css that goes with it
  // mabye I should just hard add it in here humm
  autoresize() {
    if (this.filler_ref && this.textarea_ref) {
      this.filler_ref.current.innerHTML = this.textarea_ref.current.value.replace(/\n/g, '<br/>');
    }
  }

  render() {
    const { props } = this;
    const {
      value,
      onKeyPress,
      onKeyDown,
      onChange,
      claseName,
      ...rest
    } = props;
    // might need to use the classnames extension here
    return (
      <Box class="textarea-container" {...rest}>
        <textarea ref={this.textarea_ref}
          autoCapitalize="none" autoComplete="off"
          onKeyPress={this.handleKeyPress.bind(this)}
          onKeyDown={this.handleKeyDown.bind(this)}
          onChange={this.handleOnChange.bind(this)} />
        <div ref={this.filler_ref} />
      </Box>
    );
  }
}

class Marked extends Component {
  constructor(props, context) {
    super(props, context);
    const {
      value ="",
    } = props;

    this.state = { value: value };
    //this.setState({ raw: props.value || "" });
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (("value" in nextState) && nextState.value !== this.state.value) {
      return true;
    }
    return false;
  }

  render() {
    const {
      value,
      ...rest
    } = this.props;

    return (
      // eslint-disable-next-line react/jsx-no-useless-fragment
      <Fragment {...rest}>
        {marked(this.state.value, { breaks: true, smartypants: true })}
      </Fragment>
    );
  }
}

export class PaperSheetEditor extends Component {
  constructor(props, context) {
    super(props, context);
    const {
      canEdit = true,
      value = "",
    } = props;
    this.context = context;
    this.marked_ref = createRef();
    this.textarea_ref = createRef();
    this.canEdit = canEdit;
    this.state = { value: value|| "", canEdit: canEdit };
    this.handleKeyEvents = e => {
      // Need to fix cut and paste humm
      if (this.textarea_ref && this.marked_ref) {
        setTimeout(() => {
          if (this.marked_ref.current.state.value !== this.textarea_ref.current.value) {
            this.marked_ref.current.setState({ value: this.textarea_ref.current.state.value });
          }
        }, 1);
      }
    };
  }
  render() {
    const {
      canEdit,
      value,
      ...rest
    } = this.props;
    const { act, data } = useBackend(this.context);
    if (this.state.canEdit) {
      const border_style = {
        'border-color': "#25252525",
        'border-width': "2px",
        'border-style': "solid",
      };
      return (
        <Grid column-fill="auto">
          <Grid.Column >
          <Button
                fluid
                textAlign="center"
                fontSize="20px"
                lineHeight="30px"
                width="55px"
                onClick={() => act('save', { text:this.textarea_ref.current.state.value  })} />
            ))}
            <TextArea height={(window.innerHeight-60) + "px"} style={border_style}
              onKeyPress={this.handleKeyEvents.bind(this)}
              onKeyDown={this.handleKeyEvents.bind(this)}
              onChange={this.handleKeyEvents.bind(this)}
              ref={this.textarea_ref} />
          </Grid.Column>
          <Grid.Column>
            <Marked value={this.state.value} ref={this.marked_ref}/>
          </Grid.Column>
        </Grid>
      );
    } else {
      return <Marked value={this.state.value} />;
    }
  }
};

export const PaperSheet = (props, context) => {
  const { act, data } = useBackend(context);
  const text_ref = createRef();
  // https://github.com/segment-boneyard/socrates/blob/master/libs/marked.js
  // his is older code where the updated
  const {
    text = "This is a paper test",
    readonly,
    paper_color,
    ...rest
  } = data;
  let marked_obj = "";
  const onChange = (ev, value) => {
    marked_obj = value || ev.target.value;
    text_ref.setText(marked_obj);
  };
  const paper_style = {
    'background-color': '#FFFFFFFF',
    'background-image': 'none',
  };
  let textarea_width = 0;
  let textarea_height = window.innerHeight;
  window.addEventListener("resize", () => {
    textarea_height = window.innerHeight;
  });

  return (
    <Window resizable theme="paper" backgroundColor={paper_color || "white"}>
      <Window.Content scrollable >
        <PaperSheetEditor canedit="true" />
      </Window.Content>
    </Window>
  );
};
