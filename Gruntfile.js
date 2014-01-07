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
        files: 'app.nw/*.coffee',
        tasks: ['coffee']
      }
    },
    coffee: {
      compile: {
        options: {
          join: true
        },
        files: {
          'app.nw/rimekit.js': ['app.nw/*.coffee']
        }
      }
    }
  });

  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');

  // Default task.
  grunt.registerTask('default', ['watch']);

  grunt.registerTask('build', ['coffee']);

  grunt.registerTask('run', 'Run node-webkit app', function () {
    exec('nw app.nw');
  });

};

// vim: set et sw=2 sts=2:
