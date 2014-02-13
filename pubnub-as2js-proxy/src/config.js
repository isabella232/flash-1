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
            state: ['callback', 'error']
        },
        methods_with_callback_in_args: [
            'history', 'time', 'publish', 'unsubscribe', 'subscribe', 'here_now', 'grant',
            'audit', 'revoke', 'time', 'where_now', 'state'
        ],
        async_methods_to_delegate: ['history', 'replay', 'subscribe', 'publish', 'unsubscribe', 'here_now', 'grant', 'revoke',
            'audit', 'time', 'where_now', 'state'],
        sync_methods_to_delegate: ['set_uuid', 'get_uuid', 'uuid', 'auth', 'set_cipher_key', 'get_cipher_key', 'raw_encrypt',
            'raw_decrypt', 'set_heartbeat', 'get_heartbeat', 'set_heartbeat_interval', 'get_heartbeat_interval']
    };
};
