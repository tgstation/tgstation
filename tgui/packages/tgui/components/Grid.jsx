/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { logger } from '../logging';
import { Table } from './Table';

/** @deprecated */
export const Grid = (props) => {
  const { children, ...rest } = props;
  logger.error('Grid component is deprecated. Use a Stack instead.');

  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
};

/** @deprecated */
export const GridColumn = (props) => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: size + '%',
        ...style,
      }}
      {...rest}
    />
  );
};

Grid.Column = GridColumn;
