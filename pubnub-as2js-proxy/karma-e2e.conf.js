// Karma configuration
// Generated on Tue Dec 17 2013 12:42:59 GMT-0800 (Pacific Standard Time)

module.exports = function (config) {
    config.set({

        testName: 'PubNub AS2JS Proxy: e2e',
        // base path, that will be used to resolve files and exclude
        basePath: '',


        // frameworks to use
        frameworks: ['mocha'],


        // list of files / patterns to load in the browser
        files: [
            'test/e2e/spec_helper.js',
            'test/vendor/pubnub.js',
            'src/config.js',
            'src/pubnubProxy.js',
            'src/utils.js',
            'src/wrapper.js',
            'src/init.js',
//            'dist/pubnub-as2js-proxy.js',
            'test/vendor/chai.js',
            'test/vendor/sinon-chai.js',
            'test/vendor/sinon-1.7.3.js',
            'test/e2e/**/*Spec.js'
        ],


        // list of files to exclude
        exclude: [

        ],


        // test results reporter to use
        // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
        reporters: ['progress'],


        // web server port
        port: 9877,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // Start these browsers, currently available:
        // - Chrome
        // - ChromeCanary
        // - Firefox
        // - Opera (has to be installed with `npm install karma-opera-launcher`)
        // - Safari (only Mac; has to be installed with `npm install karma-safari-launcher`)
        // - PhantomJS
        // - IE (only Windows; has to be installed with `npm install karma-ie-launcher`)
        browsers: ['Firefox'],


        // If browser does not capture in given timeout [ms], kill it
        captureTimeout: 60000,


        // Continuous Integration mode
        // if true, it capture browsers, run tests and exit
        singleRun: false
    });
};
