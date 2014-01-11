'use strict';
var exec = require('child_process').exec;
module.exports = function (grunt) {

  // Project configuration.
  grunt.initConfig({
    watch: {
      run: {
        files: 'app.nw/*',
        tasks: ['run']
      },
      coffee: {
        files: ['rime/*.coffee', 'app.nw/*.coffee'],
        tasks: ['coffee:compile']
      }
    },
    coffee: {
      compile: {
        options: {
          join: true
        },
        files: {
          'app.nw/rime.js': ['rime/*.coffee'],
          'app.nw/rimekit.js': ['app.nw/*.coffee']
        }
      },
      test: {
        expand: true,
        cwd: 'test',
        src: ['*.coffee'],
        dest: 'test',
        ext: '.js'
      }
    },
    nodeunit: {
      all: ['test/test-*.js']
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  // Default task.
  grunt.registerTask('default', ['watch']);

  grunt.registerTask('build', ['coffee']);

  grunt.registerTask('run', 'Run node-webkit app', function () {
    exec('nw app.nw');
  });

  grunt.registerTask('test', ['coffee:test', 'nodeunit']);
};

// vim: set et sw=2 sts=2:
