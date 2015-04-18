'use strict';

// Utilities
import angular from 'angular';
import moment from 'moment';

// Module:
import Posts from './Posts.module';

Posts.filter('date', () => {
    return (date) => {
        return moment(date).format('MM/DD/YYYY - hh:mm a');
    };
});
