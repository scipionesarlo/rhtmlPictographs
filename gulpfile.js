'use strict';

var widgetName = 'rhtmlPictographs';

var _ = require('lodash');
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();

gulp.task('clean', function(cb) {
  var fs = require('fs-extra');
  fs.remove('dist', cb);
  fs.remove('inst', cb);
});

gulp.task('less', function () {
  var less = require('gulp-less');
  return gulp.src('theSrc/styles/**/*.less')
    .pipe(less({}))
    .pipe(gulp.dest('dist/browser/styles'))
    .pipe(gulp.dest('inst/htmlwidgets/lib/style'));
});

gulp.task('compile-coffee', function () {
  var gulp_coffee = require("gulp-coffee");

  gulp.src('theSrc/scripts/**/*.coffee')
    .pipe(gulp_coffee({ bare: true }))
    .pipe(gulp.dest('dist/browser/scripts'))
    .pipe(gulp.dest('inst/htmlwidgets/'));
});

gulp.task('images', function () {
  return gulp.src('theSrc/images/**/*')
    .pipe($.cache($.imagemin({
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('dist/browser/images'));
});

gulp.task('copy', function () {
  gulp.src([
    'theSrc/**/*.html'
  ], {}).pipe(gulp.dest('dist/browser'));

  gulp.src([
    'resources/**/*.json'
  ], {}).pipe(gulp.dest('dist/browser/resources'));

  var rename = require('gulp-rename');
  gulp.src('htmlwidget.yaml')
    .pipe(rename(widgetName + '.yaml'))
    .pipe(gulp.dest('inst/htmlwidgets/'));

  var extLibs = [
    {
      src: 'node_modules/lodash/lodash.min.js',
      dest: [
        'inst/htmlwidgets/lib/lodash-4.6.1/',
        'dist/browser/external/'
      ]
    },
    {
      src: 'node_modules/jquery/dist/jquery.min.js',
      dest: [
        'inst/htmlwidgets/lib/jquery-2.2.2/',
        'dist/browser/external/'
      ]
    },
    {
      src: 'node_modules/d3/d3.min.js',
      dest: [
        'inst/htmlwidgets/lib/d3-3.5.16/',
        'dist/browser/external/'
      ]
    },
    {
      src: 'node_modules/d3-grid/d3-grid.js',
      dest: [
        'inst/htmlwidgets/lib/d3-grid-0.1.2/',
        'dist/browser/external/'
      ]
    }
  ]

  _.forEach(extLibs, function(extLib) {
    var gulpSrc = gulp.src([
      extLib.src
    ], {
      dot: true
    })

    _.forEach(extLib.dest, function(dest) {
      gulpSrc.pipe(gulp.dest(dest));
    });
  });

});

gulp.task('connect', ['build'], function () {
  var serveStatic = require('serve-static');
  var serveIndex = require('serve-index');
  var app = require('connect')()
    .use(require('connect-livereload')({port: 35729}))
    .use(serveStatic('dist/browser'))
    .use(serveIndex('dist/browser'));

  require('http').createServer(app)
    .listen(9000)
    .on('listening', function () {
      console.log('Started connect web server on http://localhost:9000');
    });
});

gulp.task('serve', ['connect', 'watch'], function () {
  require('opn')('http://localhost:9000');
});

gulp.task('watch', ['connect'], function () {
  $.livereload.listen();

  // watch for changes
  gulp.watch([
    'dist/browser/**/*',
  ]).on('change', $.livereload.changed);

  gulp.watch('resources/**/*.json', ['copy']);
  gulp.watch('theSrc/**/*.html', ['copy']);
  gulp.watch('theSrc/images/**/*', ['images']);
  gulp.watch('theSrc/styles/**/*.less', ['less']);
  gulp.watch('theSrc/scripts/**/*.coffee', ['compile-coffee']);

});

//@TODO clean doesn't finish before next task ..
//gulp.task('build', ['clean', 'compile-coffee', 'images', 'less', 'copy'], function () {
gulp.task('build', ['compile-coffee', 'images', 'less', 'copy'], function () {
  return gulp.src('dist/**/*').pipe($.size({title: 'build', gzip: true}));
});

gulp.task('default', function () {
  gulp.start('build');
});
