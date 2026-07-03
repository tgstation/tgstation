import type { Dispatch, ReactNode, SetStateAction } from 'react';
import { Tabs } from 'tgui-core/components';

type Props<TPage> = {
  icon: string;
  currentPage: TPage;
  page: TPage;
  otherActivePages?: TPage[];
  setPage: Dispatch<SetStateAction<TPage>>;
  children?: ReactNode;
};

export function PageButton<TPage extends number>(props: Props<TPage>) {
  const { children, currentPage, page, otherActivePages, setPage, icon } =
    props;
  const pageIsActive =
    currentPage === page ||
    (otherActivePages && otherActivePages.indexOf(currentPage) !== -1);

  return (
    <Tabs.Tab selected={pageIsActive} icon={icon} onClick={() => setPage(page)}>
      {children}
    </Tabs.Tab>
  );
}
