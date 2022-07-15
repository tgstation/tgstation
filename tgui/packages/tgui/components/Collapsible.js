/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Component } from 'inferno';
import { Box } from './Box';
import { Button } from './Button';

export class Collapsible extends Component {
  constructor(props) {
    super(props);
    const { open } = props;
    this.state = {
      open: open || false,
    };
  }

  render() {
    const { props } = this;
    const { open } = this.state;
    const { children, color = 'default', title, buttons, ...rest } = props;
    return (
      <Box mb={1}>
        <div className="Table">
          <div className="Table__cell">
            <Button
              fluid
              color={color}
              icon={open ? 'chevron-down' : 'chevron-right'}
              onClick={() => this.setState({ open: !open })}
              {...rest}
            >
              {title}
            </Button>
          </div>
          {buttons && (
            <div className="Table__cell Table__cell--collapsing">{buttons}</div>
          )}
        </div>
        {open && <Box mt={1}>{children}</Box>}
      </Box>
    );
  }
}
