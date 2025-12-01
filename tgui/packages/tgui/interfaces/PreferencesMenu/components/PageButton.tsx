import type { Dispatch, ReactNode, SetStateAction } from 'react';
import { Button } from 'tgui-core/components';

type Props<TPage> = {
  currentPage: TPage;
  page: TPage;
  otherActivePages?: TPage[];
  setPage: Dispatch<SetStateAction<TPage>>;
  children?: ReactNode;
};

export function PageButton<TPage extends number>(props: Props<TPage>) {
  const { children, currentPage, page, otherActivePages, setPage } = props;

  const pageIsActive =
    currentPage === page ||
    (otherActivePages && otherActivePages.indexOf(currentPage) !== -1);

  return (
    <Button
      align="center"
      fontSize="1.2em"
      fluid
      selected={pageIsActive}
      onClick={() => setPage(page)}
    >
      {children}
    </Button>
  );
}
