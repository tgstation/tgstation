import { mock } from 'bun:test';

import type { PropsWithChildren } from 'react';

type WindowProps = Partial<{
  title: string;
}>;

function Window(props: PropsWithChildren<WindowProps>) {
  const { title = 'Test UI', children } = props;

  return (
    <div className="Window">
      <div>{title}</div>
      {children}
    </div>
  );
}

function Content(props: PropsWithChildren) {
  const { children } = props;

  return <div className="Window__content">{children}</div>;
}

Window.Content = Content;

mock.module('../layouts', () => ({
  Window,
  Layout: Window,
  Pane: Window,
}));
