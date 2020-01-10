import { classes, pureComponentHooks } from 'common/react';
import { tridentVersion } from '../byond';
import { KEY_ENTER, KEY_ESCAPE, KEY_SPACE } from '../hotkeys';
import { createLogger } from '../logging';
import { refocusLayout } from '../refocus';
import { Box } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';
import { Input } from './Input';
import { Component, createRef } from 'inferno';
import { Grid } from './Grid';

const logger = createLogger('Button');

export const Button = props => {
  const {
    className,
    fluid,
    icon,
    color,
    disabled,
    selected,
    tooltip,
    tooltipPosition,
    ellipsis,
    content,
    iconRotation,
    iconSpin,
    children,
    onclick,
    onClick,
    ...rest
  } = props;
  const hasContent = !!(content || children);
  // A warning about the lowercase onclick
  if (onclick) {
    logger.warn(
      `Lowercase 'onclick' is not supported on Button and lowercase`
      + ` prop names are discouraged in general. Please use a camelCase`
      + `'onClick' instead and read: `
      + `https://infernojs.org/docs/guides/event-handling`);
  }
  // IE8: Use a lowercase "onclick" because synthetic events are fucked.
  // IE8: Use an "unselectable" prop because "user-select" doesn't work.
  return (
    <Box as="span"
      className={classes([
        'Button',
        fluid && 'Button--fluid',
        disabled && 'Button--disabled',
        selected && 'Button--selected',
        hasContent && 'Button--hasContent',
        ellipsis && 'Button--ellipsis',
        (color && typeof color === 'string')
          ? 'Button--color--' + color
          : 'Button--color--default',
        className,
      ])}
      tabIndex={!disabled && '0'}
      unselectable={tridentVersion <= 4}
      onclick={e => {
        refocusLayout();
        if (!disabled && onClick) {
          onClick(e);
        }
      }}
      onKeyDown={e => {
        const keyCode = window.event ? e.which : e.keyCode;
        // Simulate a click when pressing space or enter.
        if (keyCode === KEY_SPACE || keyCode === KEY_ENTER) {
          e.preventDefault();
          if (!disabled && onClick) {
            onClick(e);
          }
          return;
        }
        // Refocus layout on pressing escape.
        if (keyCode === KEY_ESCAPE) {
          e.preventDefault();
          refocusLayout();
          return;
        }
      }}
      {...rest}>
      {icon && (
        <Icon name={icon} rotation={iconRotation} spin={iconSpin} />
      )}
      {content}
      {children}
      {tooltip && (
        <Tooltip
          content={tooltip}
          position={tooltipPosition} />
      )}
    </Box>
  );
};

Button.defaultHooks = pureComponentHooks;

export const ButtonCheckbox = props => {
  const { checked, ...rest } = props;
  return (
    <Button
      color="transparent"
      icon={checked ? 'check-square-o' : 'square-o'}
      selected={checked}
      {...rest} />
  );
};

Button.Checkbox = ButtonCheckbox;

export class ButtonConfirm extends Component {
  constructor() {
    super();
    this.state = {
      clickedOnce: false,
    };
    this.handleClick = () => {
      if (this.state.clickedOnce) {
        this.setClickedOnce(false);
      }
    };
  }

  setClickedOnce(clickedOnce) {
    this.setState({
      clickedOnce,
    });
    if (clickedOnce) {
      setTimeout(() => window.addEventListener('click', this.handleClick));
    }
    else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  render() {
    const {
      confirmMessage = "Confirm?",
      confirmColor = "bad",
      color,
      content,
      onClick,
      ...rest
    } = this.props;
    return (
      <Button
        content={this.state.clickedOnce ? confirmMessage : content}
        color={this.state.clickedOnce ? confirmColor : color}
        onClick={() => this.state.clickedOnce
          ? onClick()
          : this.setClickedOnce(true)}
        {...rest}
      />
    );
  }
}

Button.Confirm = ButtonConfirm;

export class ButtonInput extends Component {
  constructor() {
    super();
    this.state = {
      inInput: false,
      currentText: "",
    };
  }

  setCurrentText(currentText) {
    this.setState({
      currentText,
    });
  }

  setInInput(inInput) {
    this.setState({
      inInput,
    });
    if (!inInput) {
      if (this.state.currentText !== "") {
        this.props.onCommit(this.state.currentText);
      } else {
        this.props.onCommit("Untitled");
      }
      this.setCurrentText("");
    }
  }

  render() {
    const {
      fluid,
      placeholder,
      maxLength,
      ...rest
    } = this.props;

    const input = (
      <table
        className="Table"
        style={{
          'margin-top': '0px',
        }}>
        <tr className="Table__row">
          <td className="Table__cell">
            <Input
              fluid
              value={this.state.currentText}
              onInput={(e, value) => this.setCurrentText(value)}
              onEnter={(e, value) => this.setInInput(false)}
            />
          </td>
          <td className="Table__cell Table__cell--collapsing">
            <Button
              icon="times"
              color="bad"
              onClick={() => this.setInInput(false)}
            />
          </td>
        </tr>
      </table>
    );

    const button = (
      <Button
        fluid={fluid}
        onClick={() => this.setInInput(true)}
        {...rest}
      />
    );

    return (
      this.state.inInput ? (
        input
      ) : (
        button
      )
    );
  }
}

Button.Input = ButtonInput;
