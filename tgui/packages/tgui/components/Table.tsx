/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

type Props = Partial<{
  /** Collapses table to the smallest possible size. */
  collapsing: boolean;
}> &
  BoxProps;

export function Table(props: Props) {
  const { className, collapsing, children, ...rest } = props;

  return (
    <table
      className={classes([
        'Table',
        collapsing && 'Table--collapsing',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <tbody>{children}</tbody>
    </table>
  );
}

type RowProps = Partial<{
  /** Whether this is a header cell. */
  header: boolean;
}> &
  BoxProps;

export function TableRow(props: RowProps) {
  const { className, header, ...rest } = props;

  return (
    <tr
      className={classes([
        'Table__row',
        header && 'Table__row--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
}

Table.Row = TableRow;

type CellProps = Partial<{
  /** Collapses table cell to the smallest possible size,
  and stops any text inside from wrapping. */
  collapsing: boolean;
  /** Additional columns for this cell to expand, assuming there is room. */
  colSpan: number;
  /** Whether this is a header cell. */
  header: boolean;
  /** Rows for this cell to expand, assuming there is room. */
  rowSpan: number;
}> &
  BoxProps;

export function TableCell(props: CellProps) {
  const { className, collapsing, colSpan, header, ...rest } = props;

  return (
    <td
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        header && 'Table__cell--header',
        className,
        computeBoxClassName(props),
      ])}
      colSpan={colSpan}
      {...computeBoxProps(rest)}
    />
  );
}

Table.Cell = TableCell;
