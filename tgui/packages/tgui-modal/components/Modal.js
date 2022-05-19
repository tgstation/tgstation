
import { classes } from 'common/react';
import { toTitleCase } from 'common/string';
import { Component } from 'inferno';
import { dragStartHandler, recallWindowGeometry, resizeStartHandler } from '../../tgui/drag';
import { Layout } from '../../tgui/layouts/Layout';

const DEFAULT_SIZE = [400, 600];

export class Modal extends Component {
  componentDidMount() {
    const { canClose = true } = this.props;
    Byond.winset(Byond.windowId, {
      'can-close': Boolean(canClose),
    });
    this.updateGeometry();
  }

  componentDidUpdate(prevProps) {
    const shouldUpdateGeometry = (
      this.props.width !== prevProps.width
      || this.props.height !== prevProps.height
    );
    if (shouldUpdateGeometry) {
      this.updateGeometry();
    }
  }

  updateGeometry() {

    const options = {
      size: DEFAULT_SIZE,
    };
    if (this.props.width && this.props.height) {
      options.size = [this.props.width, this.props.height];
    }

    recallWindowGeometry(options);
  }

  render() {
    const {
      canClose = true,
      theme,
      title,
      children,
      buttons,
    } = this.props;
    const { debugLayout } = useDebug(this.context);
    const dispatch = useDispatch(this.context);
    return (
      <Layout
        className="Window"
        theme={theme}>
        <TitleBar
          className="Window__titleBar"
          title={title}
          onDragStart={dragStartHandler}
          onClose={() => {
            logger.log('pressed close');
            dispatch(backendSuspendStart());
          }}
          canClose={canClose}>
          {buttons}
        </TitleBar>
        <div
          className={classes([
            'Window__rest',
            debugLayout && 'debug-layout',
          ])}>
          {children}
          {showDimmer && (
            <div className="Window__dimmer" />
          )}
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
