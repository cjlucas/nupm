import css from './app.scss';

import { Provider } from 'react-redux';
import { createStore, applyMiddleware, bindActionCreators } from 'redux';
import React from 'react';
import { connect } from 'react-redux';
import ReactDOM from 'react-dom';
import reducer from './reducers';
import thunk from 'redux-thunk';

import Home from './containers/Home.jsx';
import * as Actions from './actions/HomeActions';

const store = createStore(
                          reducer,
                          applyMiddleware(thunk)
);

class Router extends React.Component {
  _onSubmit(e) {
    if (e) {
      e.preventDefault();
    }

    this.props.attemptLogin(this.emailInput.value, this.passwordInput.value);
  }

  render() {
    console.log('OMGHEREEE');
    const { loginState } = this.props;

    if (loginState.token) {
      return <Home />;
    } else {
      return (
        <div>
          <form onSubmit={this._onSubmit.bind(this)}>
            <input type="text" ref={el => this.emailInput = el} />
            <input type="password" ref={el => this.passwordInput = el} />
            <button type="submit">Login</button>
          </form>
        </div>
      );
    }
  }
}

function mapStateToProps(state) {
  return {
    loginState: state.loginState,
    currentPage: state.currentPage,
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(Actions, dispatch);
};

const RouterWrapped = connect(mapStateToProps, mapDispatchToProps)(Router);

const App = () => (
  <Provider store={store}>
    <RouterWrapped />
  </Provider>
);

function render() {
  ReactDOM.render(
    <App/>, document.getElementById("content"));
}

render();
store.subscribe(render);
