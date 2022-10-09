import { linkEvent } from 'inferno';
import { Button } from 'tgui/components';
import { createRenderer } from 'tgui/renderer';

const render = createRenderer();

const handleClick = () => undefined;

export const SingleButton = () => {
  const node = <Button>Hello world!</Button>;
  render(node);
};

export const SingleButtonWithCallback = () => {
  const node = <Button onClick={() => undefined}>Hello world!</Button>;
  render(node);
};

export const SingleButtonWithLinkEvent = () => {
  const node = (
    <Button onClick={linkEvent(null, handleClick)}>Hello world!</Button>
  );
  render(node);
};

export const ListOfButtons = () => {
  const nodes: JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = <Button key={i}>Hello world! {i}</Button>;
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithCallback = () => {
  const nodes: JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} onClick={() => undefined}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithLinkEvent = () => {
  const nodes: JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} onClick={linkEvent(null, handleClick)}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithIcons = () => {
  const nodes: JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} icon={'arrow-left'}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};

export const ListOfButtonsWithTooltips = () => {
  const nodes: JSX.Element[] = [];
  for (let i = 0; i < 100; i++) {
    const node = (
      <Button key={i} tooltip={'Hello world!'}>
        Hello world! {i}
      </Button>
    );
    nodes.push(node);
  }
  render(<div>{nodes}</div>);
};
