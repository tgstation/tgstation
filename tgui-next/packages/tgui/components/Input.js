import { classes, pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';
import { Box } from './Box';

/* eslint-disable react/destructuring-assignment */
export class Input extends Component {
  constructor() {
    super();
    this.inputRef = createRef();
    this.state = {
      editing: false,
    };
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input) {
      input.value = nextValue;
    }
  }

  componentDidUpdate(prevProps, prevState) {
    const { editing } = this.state;
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.inputRef.current;
    if (input && !editing && prevValue !== nextValue) {
      input.value = nextValue;
    }
  }

  setEditing(editing) {
    this.setState({ editing });
  }

  render() {
    const { props } = this;
    // Input only props
    const {
      onInput,
      onChange,
      value,
      ...boxProps
    } = props;
    // Box props
    const {
      className,
      fluid,
      ...rest
    } = boxProps;
    return (
      <Box
        className={classes([
          'Input',
          fluid && 'Input--fluid',
          className,
        ])}
        {...rest}>
        <div className="Input__baseline">
          .
        </div>
        <input
          ref={this.inputRef}
          type="text"
          className="Input__input"
          onInput={e => {
            this.setEditing(true);
            if (onInput) {
              onInput(e, e.target.value);
            }
          }}
          onFocus={e => {
            this.setEditing(true);
          }}
          onBlur={e => {
            const { editing } = this.state;
            if (editing) {
              this.setEditing(false);
              if (onChange) {
                onChange(e, e.target.value);
              }
            }
          }}
          onKeyDown={e => {
            if (e.keyCode === 13) {
              this.setEditing(false);
              if (onChange) {
                onChange(e, e.target.value);
              }
              if (onInput) {
                onInput(e, e.target.value);
              }
              e.target.blur();
              return;
            }
            if (e.keyCode === 27) {
              this.setEditing(false);
              e.target.value = props.value;
              e.target.blur();
              return;
            }
          }} />
      </Box>
    );
  }
}

Input.defaultHooks = pureComponentHooks;
