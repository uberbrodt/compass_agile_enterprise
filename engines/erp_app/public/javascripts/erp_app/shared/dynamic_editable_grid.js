Ext.define("Compass.ErpApp.Shared.DynamicEditableGrid",{
    extend:"Ext.grid.GridPanel",
    alias:'widget.shared_dynamiceditablegrid',
    initComponent: function() {
        var config = this.initialConfig;
        var store = Ext.create('Ext.data.Store', {
            fields:config['fields'],
            autoLoad: true,
            autoSync: true,
            proxy: {
                type: 'rest',
                url:config.url,
                reader: {
                    type: 'json',
                    successProperty: 'success',
                    root: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    writeAllFields:true,
                    root: 'data'
                },
                listeners: {
                    exception: function(proxy, response, operation){
                        Ext.MessageBox.show({
                            title: 'REMOTE EXCEPTION',
                            msg: operation.getError(),
                            icon: Ext.MessageBox.ERROR,
                            buttons: Ext.Msg.OK
                        });
                    }
                }
            }
        });

        this.store = store;

        if(config['page'] == true){
            this.bbar = new Ext.PagingToolbar({
                pageSize: config['pageSize'],
                store: store,
                displayInfo: true,
                displayMsg: config['displayMsg'],
                emptyMsg: config['emptyMsg']
            });
        }
        
        Compass.ErpApp.Shared.DynamicEditableGrid.superclass.initComponent.apply(this, arguments);
    },

    constructor : function(config) {
        this.editing = Ext.create('Ext.grid.plugin.RowEditing', {
            clicksToMoveEditor: 1
        });

        var Model = Ext.define(config.model,{
            extend:'Ext.data.Model',
            fields:config.fields,
            validations:config.validations
        });

        var plugins = [];
        var tbar = {}
        if(config['editable']){
            plugins.push(this.editing);
            tbar = {
                items:[{
                    text: 'Add',
                    iconCls: 'icon-add',
                    handler: function(button) {
                        var grid = button.findParentByType('shared_dynamiceditablegrid');
                        var edit = grid.editing;
                        grid.store.insert(0, new Model());
                        edit.startEdit(0,0);
                    }
                },
                '-',
                {
                    text: 'Delete',
                    iconCls: 'icon-delete',
                    handler: function(button) {
                        var grid = button.findParentByType('shared_dynamiceditablegrid');
                        var selection = grid.getView().getSelectionModel().getSelection()[0];
                        if (selection) {
                            grid.store.remove(selection);
                        }
                    }
                }]
            };
        }

        config = Ext.apply({
            layout:'fit',
            frame: false,
            autoScroll:true,
            loadMask:true,
            plugins:plugins,
            tbar:tbar
        }, config);
        Compass.ErpApp.Shared.DynamicEditableGrid.superclass.constructor.call(this, config);
    }
});