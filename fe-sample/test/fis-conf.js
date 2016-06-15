var staticSuffix = 'js|less|css|jpg|jpeg|png|gif';
fis.config.merge({
    webname: '',
    // statics: '',
    namespace: 'xcall',
    roadmap: {
        ext: {
            less: 'css',
            ejs: 'js'
        },
        path: [{
            reg: /mod.js/i,
            release: '${statics}/${namespace}/js/mod.js',
            isMod: false
        }, {
            reg: /^\/(static)\/resource\/(.*)/i,
            release: '${statics}/${namespace}/resource/$2',
            useHash: false
        }, {
            reg: /^\/(static)\/(.*)/i,
            release: '${statics}/${namespace}/$2',
            isMod: true
        }, {
            reg: '**.ejs',
            //当做类js文件处理，可以识别__inline, __uri等资源定位标识
            isJsLike: true,
            //只是内嵌，不用发布
            release: false
        }]
    },
    settings: {
        spriter: {
            csssprites: {
                //图之间的边距
                margin: 5
            }
        },
        optimizer: {
            'png-compressor': {
                type: 'pngquant' //default is pngcrush
            }
        },
        parser: {
            ejs: {
                open: '<%',
                close: '%>'
            }
        }
    },
    pack: {},
    modules: {
        parser: {
            less: 'less',
            ejs: 'ejs'
        },
        optimizer: {
            tpl: 'html-compress'
        },
        spriter: 'csssprites'
    },
    deploy: {
        output: [{
            from: '/WEB-INF/views',
            to: './output/WEB-INF/classes'
        }, {
            from: '/WEB-INF/config',
            to: './output/WEB-INF'
        }, {
            from: '/static',
            to: './output/WEB-INF/classes'
        }]
    }
});
