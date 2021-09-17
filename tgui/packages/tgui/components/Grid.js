/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Table } from './Table';
import { pureComponentHooks } from 'common/react';

/** @deprecated */
export const Grid = props => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>
        {children}
      </Table.Row>
    </Table>
  );
};

Grid.defaultHooks = pureComponentHooks;

/** @deprecated */
export const GridColumn = props => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: size + '%',
        ...style,
      }}
      {...rest} />
  );
};

Grid.defaultHooks = pureComponentHooks;

Grid.Column = GridColumn;
