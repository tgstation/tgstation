/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Warlockd
 * @license MIT
 */

import { KEY } from 'common/keys';
import { classes } from 'common/react';
import { Component, createRef, RefObject } from 'inferno';
import { Box, BoxProps } from './Box';

type Props = {
  autoFocus: boolean;
  autoSelect: boolean;
  className: string;
  displayedValue: string;
  dontUseTabForIndent: boolean;
  fluid: boolean;
  innerRef: RefObject<HTMLTextAreaElement>;
  maxLength: number;
  noborder: boolean;
  nowrap: boolean;
  onBlur: (event: Event) => void;
  onChange: (event: Event, value: string) => void;
  onEnter: (event: KeyboardEvent, value: string) => void;
  onEscape: (event: Event) => void;
  onFocus: (event: Event) => void;
  onInput: (event: Event, value: string) => void;
  onKey: (event: Event, value: string) => void;
  onKeyDown: (event: KeyboardEvent) => void;
  onKeyPress: (event: KeyboardEvent, value: string) => void;
  placeholder: string;
  scrollbar: boolean;
  selfClear: boolean;
  value: string;
} & BoxProps;

type State = {
  editing: boolean;
  scrolledAmount: number;
};

export class TextArea extends Component<Partial<Props>, State> {
  private textareaRef: RefObject<HTMLTextAreaElement>;
  public state: State = {
    editing: false,
    scrolledAmount: 0,
  };

  constructor(props: Props) {
    super(props);
    this.textareaRef = props.innerRef || createRef();
  }

  componentDidMount() {
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input) {
      input.value = nextValue || '';
    }
    if (this.props.autoFocus || this.props.autoSelect) {
      setTimeout(() => {
        if (input) {
          input.focus();

          if (this.props.autoSelect) {
            input.select();
          }
        }
      }, 1);
    }
  }

  componentDidUpdate(prevProps: Props) {
    const prevValue = prevProps.value;
    const nextValue = this.props.value;
    const input = this.textareaRef.current;
    if (input && typeof nextValue === 'string' && prevValue !== nextValue) {
      input.value = nextValue || '';
    }
  }

  setEditing(editing: boolean) {
    this.setState({ editing });
  }

  handleEvent = (
    event: Event,
    callback?: (event: Event, value: string) => void
  ) => {
    const { editing } = this.state;
    const target = event.target as HTMLTextAreaElement;
    if (!editing) {
      this.setEditing(true);
    }
    callback?.(event, target.value);
  };

  handleKeyDown = (event: KeyboardEvent) => {
    const { onChange, onInput, onEnter, onKey, dontUseTabForIndent } =
      this.props;
    const target = event.target as HTMLTextAreaElement;

    if (event.key === KEY.Enter) {
      this.setEditing(false);
      onChange?.(event, target.value);
      onInput?.(event, target.value);
      onEnter?.(event, target.value);
      if (this.props.selfClear) {
        target.value = '';
        target.blur();
      }
      return;
    }

    if (event.key === KEY.Escape) {
      this.props.onEscape?.(event);
      this.setEditing(false);
      if (this.props.selfClear) {
        target.value = '';
      } else {
        target.value = this.props.value || '';
        target.blur();
      }
      return;
    }

    if (!this.state.editing) {
      this.setEditing(true);
    }

    onKey?.(event, target.value);

    if (!dontUseTabForIndent && event.key === KEY.Tab) {
      event.preventDefault();
      const { selectionStart, selectionEnd } = target;
      target.value =
        target.value.substring(0, selectionStart) +
        '\t' +
        target.value.substring(selectionEnd);
      target.selectionEnd = selectionStart + 1;
      onInput?.(event, target.value);
    }
  };

  handleFocus = () => {
    if (!this.state.editing) {
      this.setEditing(true);
    }
  };

  handleBlur = (e: Event) => {
    const { onChange, onBlur } = this.props;
    if (this.state.editing) {
      this.setEditing(false);
      if (onChange) {
        onChange(e, (e.target as HTMLTextAreaElement).value);
      }
    }
    onBlur?.(e);
  };

  handleScroll = () => {
    const { displayedValue } = this.props;
    const input = this.textareaRef.current;
    if (displayedValue && input) {
      this.setState({
        scrolledAmount: input.scrollTop,
      });
    }
  };

  render() {
    const {
      className,
      displayedValue,
      fluid,
      maxLength,
      noborder,
      nowrap,
      placeholder,
      scrollbar,
      value,
      ...rest
    } = this.props;

    const { scrolledAmount } = this.state;

    return (
      <Box
        className={classes([
          'TextArea',
          fluid && 'TextArea--fluid',
          noborder && 'TextArea--noborder',
          className,
        ])}
        {...rest}>
        {!!displayedValue && (
          <Box position="absolute" width="100%" height="100%" overflow="hidden">
            <div
              className={classes([
                'TextArea__textarea',
                'TextArea__textarea_custom',
              ])}
              style={{
                'transform': `translateY(-${scrolledAmount}px)`,
              }}>
              {displayedValue}
            </div>
          </Box>
        )}
        <textarea
          className={classes([
            'TextArea__textarea',
            scrollbar && 'TextArea__textarea--scrollable',
            nowrap && 'TextArea__nowrap',
          ])}
          maxLength={maxLength}
          onBlur={this.handleBlur}
          onChange={(event) => this.handleEvent(event, this.props.onChange)}
          onFocus={this.handleFocus}
          onInput={(event) => this.handleEvent(event, this.props.onInput)}
          onKeyDown={this.handleKeyDown}
          onKeyPress={(event) => this.handleEvent(event, this.props.onKeyPress)}
          onScroll={this.handleScroll}
          placeholder={placeholder}
          ref={this.textareaRef}
          style={{
            'color': displayedValue ? 'rgba(0, 0, 0, 0)' : 'inherit',
          }}
        />
      </Box>
    );
  }
}
