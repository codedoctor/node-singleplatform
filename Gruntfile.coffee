module.exports = (grunt) ->
  grunt.initConfig 
    #release:
    #  options:
    coffee:
      compile:
        options:
          sourceMap: true
        files: [
            expand: true
            flatten: true
            cwd: 'src'
            src: ['*.coffee']
            dest: 'lib/'
            ext: '.js'
        ]

    watch:
      scripts:
        files: ['src/*.coffee']
        tasks: 'coffee'


  grunt.loadNpmTasks 'grunt-release'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'default', 'watch'
