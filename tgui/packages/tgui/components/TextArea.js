/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes Warlockd (https://github.com/warlockd)
 * @license MIT
 */


import { classes, canRender } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';


const toInputValue = value => {
  if (!canRender(value)) {
    return '';
  }
  return value;
};

export class TextArea extends Component {
  constructor(props, context) {
    super(props, context);
    this.textareaRef = createRef();
    this.fillerRef = createRef();
    const {
      autoresize = false,
      dontUseTabForIndent = false,
      value,
    } = props;
    this.state = {
      value: value,
      editing: false,
    };

    // found this hack that expands the text area without
    // having to hard set rows all the time
    // there has GOT to be a better way though
    this.autoresize = () => {
      if (!autoresize) {
        return;
      }
      if (this.fillerRef && this.textareaRef) {
      //  this.fillerRef.current.innerHTML =
      //  this.textareaRef.current.value.replace(/\n/g, '<br/>');
      }
    };
    this.handleOnInput = e => {
      const { editing } = this.state;
      const { onInput } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      this.setValue(e.target.value);
      if (onInput) {
        onInput(e, e.target.value);
      }
      this.autoresize();
    };
    this.handleOnChange = e => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
      }
      if (onChange) {
        onChange(e, e.target.value);
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
      this.autoresize();
    };
    this.handleKeyDown = e => {
      const { editing } = this.state;
      const { onKeyDown } = this.props;
      if (!editing) {
        this.setEditing(true);
      }
      if (!dontUseTabForIndent) {
        const keyCode = e.keyCode || e.which;
        if (keyCode === 9) {
          e.preventDefault();
          const s = e.target.selectionStart;
          e.target.value
          = e.target.value.substring(0, e.target.selectionStart)
            + "\t"
            + e.target.value.substring(e.target.selectionEnd);
          e.target.selectionEnd = s +1;
        }
      }
      if (onKeyDown) {
        onKeyDown(e, e.target.value);
      }
      this.autoresize();
    };
    this.handleFocus = e => {
      const { editing } = this.state;
      if (!editing) {
        this.setEditing(true);
      }
    };
    this.handleBlur = e => {
      const { editing } = this.state;
      const { onChange } = this.props;
      if (editing) {
        this.setEditing(false);
        if (onChange) {
          onChange(e, e.target.value);
        }
      }
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input) {
      this.setValue(nextValue);
      this.autoresize();
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input && !editing && prevValue !== nextValue) {
      this.setValue(nextValue);
      this.autoresize();
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  setValue(value) {
    this.setState({ value });
  }

  getValue() {
    return toInputValue(this.state.value);
  }

  render() {
    const { props } = this;
    // Input only props
    const {
      onChange,
      onKeyDown,
      onKeyPress,
      onInput,
      onFocus,
      onBlur,
      onEnter,
      value,
      placeholder,
      ...boxProps
    } = this.props;
    // Box props
    const {
      className,
      fluid,
      ...rest
    } = boxProps;
    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          className,
        ])}
        {...rest}>
        <textarea
          value={this.getValue()}
          ref={this.textareaRef}
          className="TextArea__textarea"
          placeholder={placeholder}
          onChange={this.handleOnChange}
          onKeyDown={this.handleKeyDown}
          onKeyPress={this.handleKeyPress}
          onInput={this.handleOnInput}
          onFocus={this.handleFocus}
          onBlur={this.handleBlur} />
      </Box>
    );
  }
}
