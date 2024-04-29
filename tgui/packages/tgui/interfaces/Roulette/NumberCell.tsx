import { classes } from 'common/react';

import { useBackend } from '../../backend';
import { Button, Table } from '../../components';

type Props = {
  color: string;
  text: string;
  value: string;
} & Partial<{
  buttonClass: string;
  cellClass: string;
  colspan: number;
  rowspan: number;
}>;

export function RouletteNumberCell(props: Props) {
  const {
    buttonClass,
    cellClass,
    color,
    colspan = 1,
    rowspan = 1,
    text,
    value,
  } = props;
  const { act } = useBackend();

  return (
    <Table.Cell
      className={classes([
        'Roulette__board-cell',
        'Roulette__board-cell-number',
        cellClass,
      ])}
      colSpan={colspan}
      rowSpan={rowspan}
    >
      <Button
        color={color}
        className={classes(['Roulette__board-button', buttonClass])}
        onClick={() => act('ChangeBetType', { type: value })}
      >
        <span className="Roulette__board-button-text">{text}</span>
      </Button>
    </Table.Cell>
  );
}
