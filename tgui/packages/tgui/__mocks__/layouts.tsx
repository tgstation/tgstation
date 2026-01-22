import { mock } from 'bun:test';

function Window({ children, ...props }: any) {
  return (
    <div style={{ height: `${props.height}px`, width: `${props.width}px` }}>
      {children}
    </div>
  );
}

function Content({ children, ...props }: any) {
  return <div style={{ flex: 1, overflow: 'auto' }}>{children}</div>;
}

Window.Content = Content;

mock.module('../layouts', () => ({
  Window,
  Layout: Window,
  Pane: Window,
}));
