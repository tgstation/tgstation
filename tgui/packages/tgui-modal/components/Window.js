import { Component } from 'inferno';
import { Layout } from 'tgui/layouts';
import { toTitleCase } from 'common/string';
import { dragStartHandler, recallWindowGeometry } from 'tgui/drag';

const MODAL_SIZE = [500, 75];

/**
 * Custom implementation for tgui modal window.
 * Check the path! Don't implement this accidentally.
 */
export class Window extends Component {
  componentDidMount() {
    recallWindowGeometry({
      size: MODAL_SIZE,
    });
  }
  render() {
    const { theme, children, buttons } = this.props;

    return (
      <Layout className="Window" theme={theme}>
        <TitleBar
          title="Title"
          onDragStart={dragStartHandler}
          onClose={() => {
            Byond.sendMessage('close');
          }}>
          {buttons}
        </TitleBar>
        <div className="Window__rest">{children}</div>
      </Layout>
    );
  }
}

/** Renders the content within the window itself. */
const WindowContent = (props) => {
  const { children } = props;

  return (
    <Layout.Content className="Window__content">
      <div className="Window__contentPadding">{children}</div>
    </Layout.Content>
  );
};

Window.Content = WindowContent;

/** Items placed at the top of the window */
const TitleBar = (props) => {
  const { title, onClose, onDragStart, children } = props;

  return (
    <div className="TitleBar">
      <div className="TitleBar__dragZone" onMousedown={(e) => onDragStart(e)} />
      <div className="TitleBar__title">
        {toTitleCase(title)}
        {!!children && <div className="TitleBar__buttons">{children}</div>}
      </div>
      <div
        className="TitleBar__close TitleBar__clickable"
        // IE8: Synthetic onClick event doesn't work on IE8.
        // IE8: Use a plain character instead of a unicode symbol.
        // eslint-disable-next-line react/no-unknown-property
        onclick={onClose}>
        {Byond.IS_LTE_IE8 ? 'x' : '×'}
      </div>
    </div>
  );
};
