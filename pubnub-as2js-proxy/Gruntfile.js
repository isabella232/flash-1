module.exports = function (grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        concat: {
            options: {
                separator: '\n\n',
                banner: "(function (root) {\n'use strict';\n\n",
                footer: "\n\n}(this));",
                process: function (src, filepath) {
                    return '// Source: ' + filepath + '\n' +
                        src.replace(/(^|\n)[ \t]*('use strict'|"use strict");?\s*/g, '$1');
                }
            },
            dist: {
                src: [
                    'src/config.js',
                    'src/wrapper.js',
                    'src/pubnubProxy.js',
                    'src/utils.js',
                    'src/init.js'
                ],
                dest: 'dist/<%= pkg.name %>.js'
            }
        },
        uglify: {
            dist: {
                options: {
                    sourceMap: true,
                    maxLineLen: 120,
                    mangle: {
                        expect: []
                    }
                },
                files: {
                    'dist/<%= pkg.name %>.min.js': ['<%= concat.dist.dest %>']
                }
            }
        },
        test: {
            end2end: 'karma-e2e.conf.js',
            unit: 'karma.conf.js'
        }
    });

    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-concat');

    grunt.registerTask('default', ['concat', 'uglify']);
//    grunt.registerTask('test:e2e', ['concat', 'test:e2e']);
//    grunt.registerTask('test:unit', 'Runt the Karma unit test', ['test:unit']);
};
