import { mock } from 'bun:test';

type MockWindowProps = Partial<{
  title: string;
  children: React.ReactNode;
}>;

function Window(props: MockWindowProps) {
  const { title = 'Test UI', children } = props;

  return (
    <div className="Window">
      <div>{title}</div>
      {children}
    </div>
  );
}

function Content({ children }: { children?: React.ReactNode }) {
  return <div className="Window__content">{children}</div>;
}

Window.Content = Content;

mock.module('../layouts', () => ({
  Window,
  Layout: Window,
  Pane: Window,
}));
