import { mock } from 'bun:test';

function MockComponent({ children, ...props }: any) {
  return children;
}

function Button({ children, ...props }: any) {
  return <button {...props}>{children}</button>;
}

Button.Confirm = Button;
Button.Checkmark = Button;
Button.File = Button;

function Div({ children, ...props }: any) {
  return <div>{children}</div>;
}

Div.Item = Div;

function Input({ ...props }: any) {
  return <input {...props} />;
}

mock.module('tgui-core/components', () => ({
  Autofocus: MockComponent,
  Box: Div,
  Button,
  ByondUi: MockComponent,
  Container: MockComponent,
  Divider: Div,
  Flex: Div,
  Input,
  LabeledList: MockComponent,
  NumberInput: MockComponent,
  ProgressBar: MockComponent,
  Section: Div,
  Slider: MockComponent,
  Stack: Div,
  Table: MockComponent,
  Tabs: MockComponent,
  Tooltip: MockComponent,
  VirtualList: MockComponent,
}));

mock.module('tgui-core/http', () => ({
  fetchRetry: mock(() => Promise.resolve(new Response())),
}));

mock.module('tgui-core', () => {});
