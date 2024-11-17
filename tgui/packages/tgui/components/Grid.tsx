/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { ComponentProps } from 'react';
import { Box, Table } from 'tgui-core/components';

import { logger } from '../logging';

type BoxProps = ComponentProps<typeof Box>;

/** @deprecated Do not use. Use stack instead. */
export function Grid(props: BoxProps) {
  const { children, ...rest } = props;
  logger.error('Grid component is deprecated. Use a Stack instead.');
  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
}

type Props = Partial<{
  /** Width of the column in percentage. */
  size: number;
}> &
  BoxProps;

/** @deprecated Do not use. Use stack instead. */
export function GridColumn(props: Props) {
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
}

Grid.Column = GridColumn;
