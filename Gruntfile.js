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
        tasks: ['coffee']
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
      }
    },
    nodeunit: {
      all: ['test/test-*.coffee']
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-nodeunit');

  // Default task.
  grunt.registerTask('default', ['watch']);

  grunt.registerTask('build', ['coffee']);

  grunt.registerTask('test', ['nodeunit']);

  grunt.registerTask('run', 'Run node-webkit app', function () {
    exec('nw app.nw');
  });
};

// vim: set et sw=2 sts=2:
