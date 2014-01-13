(function () {
    var o = document.createElement('object');
    o.setAttribute('id', 'pubnubFlashObject');
    o.callback = function () {};
    o.created = function () {};
    document.body.appendChild(o);
}());

function hashCode() {
    var hash = 0, i, char;
    if (this.length == 0) return hash;
    var l = this.length;
    for (i = 0; i < l; i++) {
        char = this.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
}