import { Component } from "inferno";
import { classes } from "common/react";
import { Box } from './Box';
import { Icon } from './Icon';

/* eslint-disable react/destructuring-assignment */
export class Dropdown extends Component {
  constructor(props) {
    super(props);
    this.state = {
      selected: props.selected,
      open: false,
    };
  }

  componentDidUpdate(prevProps, prevState) {
    const { open } = this.state;
    const prevSelected = prevProps.selected;
    const nextSelected = this.props.value;
    if () {

    };
  }

  setOpen(open) {
    this.setState({ open: open });
  }

  setSelected(selected) {
    this.setState({
      selected: selected,
      open: false,
    });
    this.props.onSelected(selected);
  }

  buildMenu() {
    const { options = [] } = this.props;
    const ops = options.map(option => (
      <Box
        key={option}
        className="Dropdown__menuentry"
        onClick={e => this.setSelected(option)}
      >
        {option}
      </Box>
    ));
    return ops.length ? ops : "No Options Found";
  }

  render() {
    const { props } = this;
    const {
      color,
      onClick,
      onSet,
      ...boxProps
    } = props;
    const {
      className,
      fluid,
      ...rest
    } = boxProps;

    const menu = this.state.open ? (
      <Box
        className="Dropdown__menu"
        {...rest}
      >
        {this.buildMenu()}
      </Box>
    ) : null;

    return (
      <div className="Dropdown">
        <Box
          className={classes([
            'Dropdown__control',
            color ? "Button--color--" + color : "Button--color--normal",
            className,
          ])}
          {...rest}
          onClick={e => {
            this.setOpen(!this.state.open);
          }}
          onBlur={e => {
            this.setOpen(false);
          }}
        >
          <Box
            inline
            className="Dropdown__selected-text"
          >
            {this.state.selected}
          </Box>
          <Box
            inline
            className={classes([
              "Dropdown__arrow-button",
            ])}
          >
            <Icon
              name={this.state.open ? "chevron-up" : "chevron-down"}
            />
          </Box>
        </Box>
        {menu}
      </div>
    );
  }
}
