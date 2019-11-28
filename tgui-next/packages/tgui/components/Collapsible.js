import { classes } from 'common/react';
import { Component, Fragment } from 'inferno';
import { Box } from './Box';
import { Icon } from './Icon';

export class Collapsible extends Component {

  constructor(props) {
    super(props);
    const { open = false } = props;
    this.state = {
      open,
    };
  }

  render() {
    const { props } = this;
    const { open } = this.state;
    const {
      children,
      color = "default",
      title,
      buttons,
      onClick,
      ...boxProps
    } = props;
    // Box props
    const {
      className,
      ...rest
    } = boxProps;
    return (
      <Fragment>
        <table
          style={{
            "width": "100%",
          }}
        >
          <tr>
            <td>
              <Box
                mb={open ? 0 : 1}
                className={classes([
                  "Button",
                  "Button--fluid",
                  "Button--color--" + color,
                  className,
                ])}
                onClick={e => this.setState({open: !open})}
                {...rest}
              >
                <Box
                  inline
                  mr={1}
                >
                  <Icon name={this.state.open ? "chevron-down" : "chevron-right"} />
                </Box>
                {title}
              </Box>
            </td>
            {buttons && (
              <td
                style={{
                  "width": "0.01%",
                }}
              >
                {buttons}
              </td>
            )}
          </tr>
        </table>
        {open && children}
      </Fragment>
    );
  }
}
