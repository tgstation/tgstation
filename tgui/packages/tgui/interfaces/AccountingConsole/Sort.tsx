import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';
import { SORTING } from './types';

type SortButtonProps = {
  sorting: SORTING;
  setSorting: (sorting: SORTING) => void;
  otherSorters: ((sorting: SORTING) => void)[];
};

export const SortButton = (props: SortButtonProps) => {
  const { act } = useBackend();
  const { sorting, setSorting, otherSorters } = props;

  return (
    <Button
      height="16px"
      fontSize="10px"
      ml={1}
      onClick={() => {
        act('typesound');
        if (sorting === SORTING.none) {
          setSorting(SORTING.ascending);
        } else if (sorting === SORTING.ascending) {
          setSorting(SORTING.descending);
        } else {
          setSorting(SORTING.none);
        }
        for (const otherSorter of otherSorters) {
          otherSorter(SORTING.none);
        }
      }}
    >
      {sorting === SORTING.ascending ? '^' : ''}
      {sorting === SORTING.descending ? 'v' : ''}
      {sorting === SORTING.none ? 'x' : ''}
    </Button>
  );
};
