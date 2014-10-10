module.exports = (grunt) ->

  grunt.initConfig

    clean                :
      all                :
        options          :
          force          : yes
        src              : 'build'

    mkdir                :
      all                :
        options          :
          create         : [
            'src/lib'
            'src/externs'
            'src/images'
            'src/styl'
            'src/templates'
            'src/third-party'
            'build'
            'build/compiled'
            'build/images'
          ]

    coffee               :
      all                :
        options          :
          bare           : yes
        files            : [
          expand         : yes
          cwd            : 'src'
          src            : [ 'lib/**/*.coffee', 'tests/**/*.coffee' ]
          dest           : 'build/js/'
          ext            : '.js'
        ]

    sprites              :
      all                :
        files            :
          src            : 'src/images'
          dest           : 'build/images'

    coffee2closure       :
      all                :
        files            : [
          expand         : yes
          src            : 'build/js/**/*.js'
          ext            : '.js'
        ]

    stylus               :
      options            :
        'include css'    : true
        'compress'       : false
      all                :
        files            : [
          expand         : true
          src            : [ '*.styl' ]
          ext            : '.css'
          cwd            : 'src/styl'
          dest           : 'build/css'
        ]

    templates            :
      all                :
        src              : 'src/templates/**/*.soy'
        dest             : 'build/templates/'

    deps                 :
      all                :
        options          :
          outputFile     : 'build/deps.js'
          prefix         : '../../../../'
          root           : [
            'bower_components/closure-library'
            'bower_components/closure-templates'
            'build'
          ]

    tests                :
      app                :
        options          :
          depsPath       : '<%= deps.all.options.outputFile %>'
          prefix         : '<%= deps.all.options.prefix %>'
        src              : 'build/js/**/*_test.js'

    karma                :
      unit               :
        configFile       : 'karma.conf.js'

    coveralls            :
      options            :
        src              : 'build/coverage/**/lcov.info'
        force            : no

    builder              :
      all                :
        options          :
          namespace      : '*'
          outputFilePath : 'build/compiled/compiled.js'
      options            :
        root             : '<%= deps.all.options.root %>'
        depsPath         : '<%= deps.all.options.outputFile %>'
        namespace        : 'spark.Bootstrapper'
        compilerFlags    : [
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          '--create_source_map="build/compiled/source_map.js"'
          '--property_renaming_report="build/compiled/properties.out"'
          '--variable_renaming_report="build/compiled/variables.out"'
          # '--externs=src/externs/externs.js'
          '--jscomp_error=accessControls'
          '--jscomp_error=checkRegExp'
          '--formatting=PRETTY_PRINT'
          '--jscomp_error=checkTypes'
          '--jscomp_error=checkVars'
          '--jscomp_error=invalidCasts'
          '--jscomp_error=missingProperties'
          '--jscomp_error=nonStandardJsDocs'
          '--jscomp_error=strictModuleDepCheck'
          '--jscomp_error=undefinedVars'
          '--jscomp_error=unknownDefines'
          '--jscomp_error=visibility'
        ]

    "http-server"        :
      debug              :
        host             : '127.0.0.1'
        port             : 1111
        runInBackground  : yes
      compiled           :
        host             : '127.0.0.1'
        port             : 2222

    watch                :
      options            :
        livereload       : yes
      configFiles        :
        files            : [ 'Gruntfile.coffee', 'karma.conf.js' ]
        options          :
          reload         : yes
      html               :
        files            : [ '*.html' ]
      src                :
        files            : [ '**/*.coffee' ]
        tasks            : [ 'clean', 'mkdir', 'coffee', 'coffee2closure', 'deps', 'karma' ]
      styl               :
        files            : [ '*.styl' ]
        tasks            : [ 'stylus' ]


  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-mkdir'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-coveralls'
  grunt.loadNpmTasks 'grunt-closure-coffee-stack'
  grunt.loadNpmTasks 'grunt-http-server'
  grunt.loadNpmTasks 'grunt-npm'


  grunt.registerTask 'ci-test-only', 'Build stack.', (app = 'app') ->
    grunt.task.run [
      'clean'
      'mkdir'
      'sprites'
      'coffee'
      'coffee2closure'
      'stylus'
      'deps'
      'karma'
      'coveralls'
    ]

  grunt.registerTask 'ci-build-only', 'Build stack.', (app = 'app') ->
    grunt.task.run [
      'clean'
      'mkdir'
      'sprites'
      'coffee'
      'coffee2closure'
      'stylus'
      'deps'
      'karma'
      'builder'
    ]


  grunt.registerTask 'build', 'Build stack.', (app = 'app') ->
    grunt.task.run [
      'clean'
      'mkdir'
      'sprites'
      'coffee'
      'coffee2closure'
      'stylus'
      'deps'
      'karma'
      'builder'
      'http-server:compiled'
    ]

  grunt.registerTask 'default', 'Build stack.', (app = 'app') ->
    grunt.task.run [
      'clean'
      'mkdir'
      'sprites'
      'coffee'
      'coffee2closure'
      'stylus'
      'deps'
      'karma'
      'http-server:debug'
      'watch'
    ]
