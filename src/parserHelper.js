const parser = new DOMParser();

export function parseRawXML(text) {
    const rawParse = parser.parseFromString(text, 'text/xml');

    function convertToObject(curr) {
        if (curr.childNodes.length === 0) {
            return {
                NAME: 'leaf',
                VAL: [
                    curr.nodeName,
                    curr.data,
                ],
            };
        }
        return {
            NAME: 'node',
            VAL: [
                curr.nodeName,
                Array.from(curr.childNodes)
                    .map(v => convertToObject(v))
                    .filter(v => v.VAL[0] !== '#comment')
                    .filter(v => !(v.VAL[0] === '#text' && v.VAL[1].trim() === '')),
            ],
        };
    }

    return convertToObject(rawParse);
}