import { classes } from 'common/react';
import { Component } from 'inferno';
import { Box } from './Box';
import { Icon } from './Icon';

export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
      open: false,
    };
    this.handleClick = () => {
      if (this.state.open) {
        this.setOpen(false);
      }
    };
  }

  componentWillUnmount() {
    window.removeEventListener('click', this.handleClick);
  }

  setOpen(open) {
    this.setState({ open: open });
    if (open) {
      setTimeout(() => window.addEventListener('click', this.handleClick));
      this.menuRef.focus();
    }
    else {
      window.removeEventListener('click', this.handleClick);
    }
  }

  setSelected(selected) {
    this.setState({
      selected: selected,
    });
    this.setOpen(false);
    this.props.onSelected(selected);
  }

  buildMenu() {
    const { options = [] } = this.props;
    const ops = options.map(option => (
      <div
        key={option}
        className="Dropdown__menuentry"
        onClick={() => {
          this.setSelected(option);
        }}>
        {option}
      </div>
    ));
    return ops.length ? ops : 'No Options Found';
  }

  render() {
    const { props } = this;
    const {
      color = 'default',
      over,
      noscroll,
      nochevron,
      width,
      onClick,
      selected,
      disabled,
      ...boxProps
    } = props;
    const {
      className,
      ...rest
    } = boxProps;

    const adjustedOpen = over ? !this.state.open : this.state.open;

    const menu = this.state.open ? (
      <div
        ref={menu => { this.menuRef = menu; }}
        tabIndex="-1"
        style={{
          'width': width,
        }}
        className={classes([
          noscroll && 'Dropdown__menu-noscroll' || 'Dropdown__menu',
          over && 'Dropdown__over',
        ])}>
        {this.buildMenu()}
      </div>
    ) : null;

    return (
      <div className="Dropdown">
        <Box
          width={width}
          className={classes([
            'Dropdown__control',
            'Button',
            'Button--color--' + color,
            disabled && 'Button--disabled',
            className,
          ])}
          {...rest}
          onClick={() => {
            if (disabled && !this.state.open) {
              return;
            }
            this.setOpen(!this.state.open);
          }}>
          <span className="Dropdown__selected-text">
            {this.state.selected}
          </span>
          {!!nochevron || (
            <span className="Dropdown__arrow-button">
              <Icon name={adjustedOpen ? 'chevron-up' : 'chevron-down'} />
            </span>
          )}
        </Box>
        {menu}
      </div>
    );
  }
}
