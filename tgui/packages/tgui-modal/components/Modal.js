
import { classes } from 'common/react';
import { toTitleCase } from 'common/string';
import { Component } from 'inferno';
import { dragStartHandler, recallWindowGeometry, resizeStartHandler } from '../../tgui/drag';
import { Layout } from '../../tgui/layouts/Layout';

const DEFAULT_SIZE = [300, 200];

export class Modal extends Component {
  componentDidMount() {
    const { canClose = true } = this.props;
    Byond.winset(Byond.windowId, {
      'can-close': Boolean(canClose),
    });
    recallWindowGeometry({ size: DEFAULT_SIZE });
  }

  render() {
    const {
      canClose = true,
      theme,
      title,
      children,
      buttons,
    } = this.props;
    return (
      <Layout
        className="Window"
        theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={title}
          onDragStart={dragStartHandler}
          onClose={() => {
            Byond.sendMessage('button');
          }}
          canClose={canClose}>
          {buttons}
        </TitleBar>
        <div
          className="Window__rest">
          {children}
        </div>
        {fancy && (
          <>
            <div className="Window__resizeHandle__e"
              onMousedown={resizeStartHandler(1, 0)} />
            <div className="Window__resizeHandle__s"
              onMousedown={resizeStartHandler(0, 1)} />
            <div className="Window__resizeHandle__se"
              onMousedown={resizeStartHandler(1, 1)} />
          </>
        )}
      </Layout>
    );
  }
}

const WindowContent = props => {
  const {
    className,
    fitted,
    children,
    ...rest
  } = props;
  return (
    <Layout.Content
      className={classes([
        'Window__content',
        className,
      ])}
      {...rest}>
      {fitted && children || (
        <div className="Window__contentPadding">
          {children}
        </div>
      )}
    </Layout.Content>
  );
};

Window.Content = WindowContent;

const TitleBar = (props) => {
  const {
    className,
    title,
    canClose,
    fancy,
    onDragStart,
    onClose,
    children,
  } = props;
  return (
    <div
      className={classes([
        'TitleBar',
        className,
      ])}>
      <div
        className="TitleBar__dragZone"
        onMousedown={e => fancy && onDragStart(e)} />
      <div className="TitleBar__title">
        {typeof title === 'string'
          && title === title.toLowerCase()
          && toTitleCase(title)
          || title}
        {!!children && (
          <div className="TitleBar__buttons">
            {children}
          </div>
        )}
      </div>
      {Boolean(fancy && canClose) && (
        <div
          className="TitleBar__close TitleBar__clickable"
          // IE8: Synthetic onClick event doesn't work on IE8.
          // IE8: Use a plain character instead of a unicode symbol.
          // eslint-disable-next-line react/no-unknown-property
          onclick={onClose}>
          {Byond.IS_LTE_IE8 ? 'x' : '×'}
        </div>
      )}
    </div>
  );
};
