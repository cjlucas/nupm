import React from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as HomeActions from '../actions/HomeActions';

const PackageInfo = (props) => (
  <div className="border-bottom">
    <div className="h2 bold">
      {props.info.title}
    </div>
  </div>
);

class Home extends React.Component {
  componentWillMount() {
    this.props.getNewestPackages();
  }

  render() {
    const children = this.props.recentPackages.map(info => (
      <PackageInfo key={info.title} info={info} />
    ));

    return (
      <div>
        {children}
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    recentPackages: state.recentPackages,
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators(HomeActions, dispatch);
}

const HomePage = connect(mapStateToProps, mapDispatchToProps)(Home);

export default HomePage;
