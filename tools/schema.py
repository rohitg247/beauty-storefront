import json, io, re, sys, os

def load_schema(section_type):
    p = os.path.join('sections', section_type + '.liquid')
    if not os.path.exists(p): return None
    s = io.open(p, encoding='utf-8').read()
    m = re.search(r'\{%\s*schema\s*%\}(.*?)\{%\s*endschema\s*%\}', s, re.S)
    if not m: return None
    return json.loads(m.group(1))

def describe(t, verbose=False):
    sch = load_schema(t)
    if sch is None:
        print('!! no schema for', t); return
    print('=== %s ===' % t)
    for st in sch.get('settings', []):
        if st.get('type') in ('header','paragraph'): continue
        extra = ''
        if st.get('type') == 'select':
            extra = ' opts=' + ','.join(o['value'] for o in st.get('options', []))
        if st.get('type') == 'range':
            extra = ' min=%s max=%s step=%s' % (st.get('min'), st.get('max'), st.get('step'))
        print('  %-28s %-18s%s' % (st.get('id'), st.get('type'), extra))
    for b in sch.get('blocks', []):
        ids = [x.get('id') for x in b.get('settings', []) if x.get('type') not in ('header','paragraph')]
        print('  BLOCK %-18s %s' % (b.get('type'), ids))

for t in sys.argv[1:]:
    describe(t); print()
