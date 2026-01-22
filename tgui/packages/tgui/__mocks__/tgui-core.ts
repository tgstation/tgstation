import { mock } from 'bun:test';

const MockComponent = ({ children, ...props }: any) => children;

mock.module('tgui-core/components', () => ({
  Autofocus: MockComponent,
  Box: MockComponent,
  Button: MockComponent,
  ByondUi: MockComponent,
  Container: MockComponent,
  Divider: MockComponent,
  Flex: MockComponent,
  Input: MockComponent,
  LabeledList: MockComponent,
  NumberInput: MockComponent,
  ProgressBar: MockComponent,
  Section: MockComponent,
  Slider: MockComponent,
  Stack: MockComponent,
  Table: MockComponent,
  Tabs: MockComponent,
  Tooltip: MockComponent,
  VirtualList: MockComponent,
}));

mock.module('tgui-core/http', () => ({
  fetchRetry: mock(() => Promise.resolve(new Response())),
}));

mock.module('tgui-core', () => {});
