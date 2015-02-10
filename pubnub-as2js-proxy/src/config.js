var config = function () {
    return {
        callback_fields: {
            leave: ['callback', 'error'],
            history: ['callback', 'error'],
            replay: ['callback'],
            publish: ['callback', 'error'],
            unsubscribe: ['callback', 'error'],
            subscribe: ['callback', 'message', 'connect', 'reconnect', 'disconnect', 'error', 'idle', 'presence'],
            here_now: ['callback', 'error', 'data'],
            grant: ['callback', 'error'],
            revoke: ['callback', 'error'],
            audit: ['callback', 'error'],
            where_now: ['callback', 'error'],
            state: ['callback', 'error'],
            channel_group: ['callback', 'error'],
            channel_group_list_channels: ['callback', 'error'],
            channel_group_list_groups: ['callback', 'error'],
            channel_group_list_namespaces: ['callback', 'error'],
            channel_group_remove_channel: ['callback', 'error'],
            channel_group_remove_group: ['callback', 'error'],
            channel_group_remove_namespace: ['callback', 'error'],
            channel_group_add_channel: ['callback', 'error'],
            channel_group_cloak: ['callback', 'error']
        },
        methods_with_callback_in_args: [
            'history', 'time', 'publish', 'unsubscribe', 'subscribe', 'here_now', 'grant',
            'audit', 'revoke', 'time', 'where_now', 'state',
            'channel_group', 'channel_group_list_channels', 'channel_group_list_groups', 'channel_group_list_namespaces',
            'channel_group_remove_channel', 'channel_group_remove_group', 'channel_group_remove_namespace',
            'channel_group_add_channel', 'channel_group_cloak'],
        async_methods_to_delegate: ['history', 'replay', 'subscribe', 'publish', 'unsubscribe', 'here_now', 'grant', 'revoke',
            'audit', 'time', 'where_now', 'state',
            'channel_group', 'channel_group_list_channels', 'channel_group_list_groups', 'channel_group_list_namespaces',
            'channel_group_remove_channel', 'channel_group_remove_group', 'channel_group_remove_namespace',
            'channel_group_add_channel', 'channel_group_cloak'],
        sync_methods_to_delegate: ['set_uuid', 'get_uuid', 'uuid', 'auth', 'set_cipher_key', 'get_cipher_key', 'raw_encrypt',
            'raw_decrypt', 'set_heartbeat', 'get_heartbeat', 'set_heartbeat_interval', 'get_heartbeat_interval']
    };
};
