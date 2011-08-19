/**
 * @class Ext.ux.panel.CodeMirror
 * @extends Ext.Panel
 * Converts a panel into a code mirror editor with toolbar
 * @constructor
 * 
 * @author Dan Ungureanu - ungureanu.web@gmail.com / http://www.devweb.ro
 * @Enchnaced Russell Holmes
 */

Ext.ns("Compass.ErpApp.Shared");
Ext.ns("Compass.ErpApp.Shared.CodeMirrorConfig");
Ext.apply(Compass.ErpApp.Shared.CodeMirrorConfig, {
    cssPath: "/javascripts/erp_app/codemirror/",
    jsPath: "/javascripts/erp_app/codemirror/"
});
Ext.apply(Compass.ErpApp.Shared.CodeMirrorConfig, {
    parser: {
        sql: {
            parserfile: ["contrib/sql/js/parsesql.js"],
            stylesheet: Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/sql/css/sqlcolors.css"
        },
        rb:{
            parserfile: ["contrib/ruby/js/parseruby.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolors.css"
        },
        rhtml:{
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js","contrib/ruby/js/parserubyhtmlmixed.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolorshtml.css",Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
        },
        erb:{
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js","contrib/ruby/js/parseruby.js","contrib/ruby/js/parserubyhtmlmixed.js","contrib/ruby/js/tokenizeruby.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "contrib/ruby/css/rubycolorshtml.css",Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
        },
        dummy:{
            parserfile: ["parsedummy.js"]
        },
        css: {
            parserfile: ["parsecss.js"],
            stylesheet: "/javascripts/erp_app/codemirror/csscolors.css"
        },
        js: {
            parserfile: ["tokenizejavascript.js", "parsejavascript.js"],
            stylesheet: "/javascripts/erp_app/codemirror/jscolors.css"
        },
        html: {
            parserfile: ["parsexml.js", "parsecss.js", "tokenizejavascript.js", "parsejavascript.js", "parsehtmlmixed.js"],
            stylesheet: [Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "xmlcolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "jscolors.css", Compass.ErpApp.Shared.CodeMirrorConfig.cssPath + "csscolors.css"]
            
        }
    }
});

Ext.define("Compass.ErpApp.Shared.CodeMirror",{
    extend:"Ext.Panel",
    requires:["Ext.form.field.TextArea"],
    alias:'widget.codemirror',
    codeMirrorInstance : null,

    initComponent: function() {
        Compass.ErpApp.Shared.CodeMirror.superclass.initComponent.call(this, arguments);

        this.addEvents(
            /**
         * @event save
         * Fired when saving contents.
         * @param {Compass.ErpApp.Shared.CodeMirror} codemirror This object
         * @param (contents) contents needing to be saved
         */
            'save'
            );
    },

    constructor : function(config){
        var tbarItems = [];

        if(!config['disableSave']){
            tbarItems.push({
                text: 'Save',
                iconCls:'icon-save',
                handler: this.save,
                scope: this
            });
        }


        tbarItems = tbarItems.concat([{
            text: 'Undo',
            iconCls:'icon-undo',
            handler: function() {
                this.codeMirrorInstance.undo();
            },
            scope: this
        }, {
            text: 'Redo',
            iconCls:'icon-redo',
            handler: function() {
                this.codeMirrorInstance.redo();
            },
            scope: this
        }, {
            text: 'Indent',
            iconCls:'icon-arrow-right-blue',
            handler: function() {
                this.codeMirrorInstance.reindent();
            },
            scope: this
        }]);

        if(!Compass.ErpApp.Utility.isBlank(config['tbarItems'])){
            tbarItems = tbarItems.concat(config['tbarItems']);
        }

        if(Compass.ErpApp.Utility.isBlank(config['disableToolbar']) || !config['disableToolbar']){
            config['tbar'] = tbarItems
        }

        config = Ext.apply({
            items: [{
                xtype: 'textareafield',
                readOnly: false,
                hidden: true,
                value: config['sourceCode']
            }]
        },config);
        Compass.ErpApp.Shared.CodeMirror.superclass.constructor.call(this, config);
    },

    onRender : function(ct, position){
        Compass.ErpApp.Shared.CodeMirror.superclass.onRender.apply(this, arguments);
        this.on('afterlayout', this.setupCodeMirror, this, {
            single: true
        });
    },

    setupCodeMirror : function(){
        var textAreaComp = this.query('textareafield')[0];
        var self = this;
        this.initialConfig.codeMirrorConfig = Ext.apply({
            content:textAreaComp.getValue(),
            path: Compass.ErpApp.Shared.CodeMirrorConfig.jsPath,
            height: "100%",
            width: "100%",
            passDelay: 300,
            passTime: 35,
            continuousScanning: 1000,
            textWrapping: false,
            undoDepth: 3,
            enterMode:'indent',
            lineNumbers: true,
            onChange: function() {
                var code = self.codeMirrorInstance.getCode();
                textAreaComp.setValue(code);
            }
        },this.initialConfig.codeMirrorConfig);
		
        var parserType = this.parser || 'dummy';
        if(Compass.ErpApp.Utility.isBlank(Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType])){
            parserType = 'dummy';
        }
        var editorConfig = Ext.applyIf(this.initialConfig.codeMirrorConfig, Compass.ErpApp.Shared.CodeMirrorConfig.parser[parserType]);
        this.codeMirrorInstance = new CodeMirror.fromTextArea( Ext.getDom(textAreaComp.id).id, editorConfig);
    },

    save : function(){
        this.fireEvent('save', this, this.getValue());
    },

    setValue : function(value){
        this.codeMirrorInstance.setCode(value);
    },

    getValue : function(){
        return this.codeMirrorInstance.getCode();
    },

    insertContent : function(value){
        var currentCode = this.codeMirrorInstance.getCode();
        this.codeMirrorInstance.setCode(currentCode + value);
    }
});