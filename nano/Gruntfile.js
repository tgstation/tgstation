module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        concurrent: {
                compile: {
                    tasks: ['concat', 'less', 'dot']
                },
                minify: {
                    tasks: ['newer:uglify', 'newer:imagemin']
                },
        },
        concat: {
            options: {
                separator: '\n'
            },
            compile: {
                src: ['scripts/nanoui.js', 'scripts/*.js'],
                dest: 'compiled/nanoui.js'
            }
        },
        dot: {
            compile: {
                options: {
                    templateSettings: {
                        varname: 'data, config, helper',
                        selfcontained: true
                    }
                },
                files: {
                    'compiled/templates.js': ['templates/*.dot']
                }
            }
        },
        imagemin: {
            assets: {
                options: {
                    optimizationLevel: 7
                },
                files: [{
                    expand: true,
                    cwd: 'images/',
                    src: ['*.{png,jpg,gif}'],
                    dest: 'compiled/'
                }]
            }
        },
        jshint: {
            scripts: ['Gruntfile.js', 'scripts/*.js']
        },
        less: {
            options: {
                plugins: [
                    new (require('less-plugin-autoprefix'))({browsers: ["last 2 versions"]}),
                    new (require('less-plugin-clean-css'))({advanced: true})
                ]
            },
            compile: {
                files: {
                    "compiled/_generic.css": "styles/_generic.less",
                    "compiled/_nanotrasen.css": "styles/_nanotrasen.less"
                }
            }
        },
        lesslint: {
            options: {
                csslint: {
                    'adjoining-classes': false,
                    'box-model': false,
                    'box-sizing': false,
                    'floats': false,
                    'ids': false,
                    'important': false,
                    'unqualified-attributes': false
                }
            },
            styles: ['styles/*.less']
        },
        uglify: {
            options: {
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
            },
            main: {
                files: { 'compiled/nanoui.min.js': ['compiled/nanoui.js'] }
            },
            templates: {
                files: { 'compiled/templates.min.js': ['compiled/templates.js'] }
            }
        },
        watch: {
            files: ['scripts/*.js', 'styles/*.less', 'templates/*.dot'],
            tasks: ['lint', 'compile', 'minify']
        }
    });

    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-imagemin');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-dot');
    grunt.loadNpmTasks('grunt-lesslint');
    grunt.loadNpmTasks('grunt-newer');

    grunt.registerTask('lint', ['jshint', 'lesslint']);
    grunt.registerTask('compile', 'concurrent:compile');
    grunt.registerTask('minify', 'concurrent:minify');
    grunt.registerTask('default', ['lint', 'compile', 'minify']);

};
