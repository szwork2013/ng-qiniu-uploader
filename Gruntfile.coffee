module.exports = (grunt)->

  require('load-grunt-tasks')(grunt)
  require('time-grunt')(grunt)

  grunt.initConfig({
    coffee:
      options:
        bare: true
      build:
        files:
          '.tmp/angular-dz-image-uploader.js': 'angular-dz-image-uploader.coffee'

    copy:
      build:
        files: [
          {
            expand: true
            cwd: 'lib/plupload-2.1.2/js/'
            src: ['plupload.full.min.js', 'Moxie.swf', 'Moxie.xap', 'i18n/zh_CN.js']
            dest: '.tmp/'
          }
          ,
          {
            expand: true
            cwd: 'lib/qiniu/'
            src: 'qiniu.js'
            dest: '.tmp/'
          }
          {
            src: ['style.css']
            dest: '.tmp/'
          }
          {
            src: ['images/*']
            dest: 'build/'
          }
          {
            src: ['large-uploader.html']
            dest: '.tmp/large-uploader.html'
          }
        ]

    html2js:
      options:
        seStrict: true
        module: 'ng-qiniu-uploader-tpl'
        base: 'build'
        singleModule: true
        rename: (moduleName)->
          return 'large-uploader-tpl.html'

        htmlmin:
          collapseBooleanAttributes: true
          collapseWhitespace: true
          removeAttributeQuotes: true
          removeComments: true
          removeEmptyAttributes: true
          removeRedundantAttributes: true
          removeScriptTypeAttributes: true
          removeStyleLinkTypeAttributes: true

      build:
        src: ['.tmp/large-uploader.html']
        dest: '.tmp/large-uploader-tpl.js'

    concat:
      options:
        separator: ';'
      build:
        src: ['.tmp/plupload.full.min.js', '.tmp/i18n/zh_CN.js', '.tmp/qiniu.js', '.tmp/large-uploader-tpl.js', '.tmp/angular-dz-image-uploader.js']
        dest: '.tmp/angular-uploader.js'

    uglify:
      build:
        src: ['.tmp/angular-uploader.js']
        dest: 'build/ng-qiniu-uploader.min.js'

    cssmin:
      build:
        src: ['.tmp/style.css']
        dest: 'build/style.css'

    clean:
      tmp: '.tmp'
      build: 'build'


  })

  grunt.registerTask 'build', ['clean', 'coffee', 'copy', 'html2js', 'concat', 'uglify', 'cssmin', 'clean:tmp']