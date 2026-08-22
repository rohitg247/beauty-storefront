"""Preflight for the EMBRAE theme.

Checks the things `shopify theme check` does not:
  - every section type referenced by a JSON template exists
  - every setting id exists in that section's schema
  - select values are inside the schema options
  - range values are inside min/max
  - block types exist, and block setting ids exist
  - richtext values have a legal top-level node (<p>/<ul>/<ol>/<h1>-<h6>)
  - font_picker values look like real Shopify handles
"""
import json, io, re, os, sys, glob

RICHTEXT_OK = re.compile(r'^\s*<(p|ul|ol|h[1-6])[\s>]', re.I)
DYNAMIC = re.compile(r'^\s*\{\{.*\}\}\s*$', re.S)

errors, warnings = [], []


def err(m):
    errors.append(m)


def warn(m):
    warnings.append(m)


NO_SCHEMA = object()


def load_schema(section_type):
    p = os.path.join('sections', section_type + '.liquid')
    if not os.path.exists(p):
        return None
    s = io.open(p, encoding='utf-8').read()
    m = re.search(r'\{%-?\s*schema\s*-?%\}(.*?)\{%-?\s*endschema\s*-?%\}', s, re.S)
    if not m:
        # A real section with no settings at all, e.g. main-404. Nothing to check.
        return NO_SCHEMA
    try:
        return json.loads(m.group(1))
    except ValueError as e:
        err('%s: schema is not valid JSON: %s' % (p, e))
        return None


def strip_header(raw):
    if raw.lstrip().startswith('/*'):
        return raw[raw.index('*/') + 2:]
    return raw


def index_settings(defs):
    out = {}
    for st in defs or []:
        if st.get('type') in ('header', 'paragraph'):
            continue
        if st.get('id'):
            out[st['id']] = st
    return out


def check_value(where, spec, value):
    t = spec.get('type')

    if t == 'select':
        opts = [o['value'] for o in spec.get('options', [])]
        # Shopify compares the raw JSON value, so a select must be a STRING even
        # when its options look numeric ("3"). A bare 3 is rejected on upload.
        if not isinstance(value, str):
            err('%s: select value %r must be a JSON string, not %s'
                % (where, value, type(value).__name__))
        elif value not in opts:
            err('%s: value %r not in options %s' % (where, value, opts))

    elif t == 'range':
        # And the mirror image: a range must be a real JSON NUMBER. "3" is
        # rejected on upload with "Setting must be a valid number". Checking
        # with float() would silently accept the string, which is exactly how
        # this shipped once already.
        if isinstance(value, bool) or not isinstance(value, (int, float)):
            err('%s: range value %r must be a JSON number, not %s'
                % (where, value, type(value).__name__))
            return
        v = float(value)
        lo, hi = spec.get('min'), spec.get('max')
        if lo is not None and v < lo:
            err('%s: %s below min %s' % (where, v, lo))
        if hi is not None and v > hi:
            err('%s: %s above max %s' % (where, v, hi))

    elif t == 'richtext':
        if isinstance(value, str) and value.strip():
            if DYNAMIC.match(value):
                err('%s: richtext holds a dynamic source %r. Shopify upload '
                    'validation rejects it as bare text.' % (where, value[:60]))
            elif not RICHTEXT_OK.match(value):
                err('%s: richtext must start with <p>/<ul>/<ol>/<h1>-<h6>, got %r'
                    % (where, value[:60]))

    elif t == 'checkbox':
        if not isinstance(value, bool):
            warn('%s: checkbox value %r is not a boolean' % (where, value))

    elif t == 'font_picker':
        if isinstance(value, str) and not re.match(r'^[a-z0-9_]+_n[1-9]$', value):
            warn('%s: %r does not look like a Shopify font handle' % (where, value))


def check_template(path):
    raw = io.open(path, encoding='utf-8').read()
    try:
        d = json.loads(strip_header(raw))
    except ValueError as e:
        err('%s: not valid JSON: %s' % (path, e))
        return

    sections = d.get('sections')
    if not isinstance(sections, dict):
        return

    for sid, sdata in sections.items():
        stype = sdata.get('type')
        sch = load_schema(stype)
        if sch is None:
            err('%s: section "%s" -> sections/%s.liquid not found' % (path, sid, stype))
            continue
        if sch is NO_SCHEMA:
            if sdata.get('settings') or sdata.get('blocks'):
                warn('%s [%s]: %s has no schema but the template sets values on it'
                     % (path, sid, stype))
            continue

        specs = index_settings(sch.get('settings'))
        for k, v in (sdata.get('settings') or {}).items():
            where = '%s [%s.%s]' % (path, sid, k)
            if k not in specs:
                err('%s: no such setting in %s schema' % (where, stype))
            else:
                check_value(where, specs[k], v)

        bspecs = {b['type']: index_settings(b.get('settings')) for b in sch.get('blocks', [])}
        blocks = sdata.get('blocks') or {}
        for bid, bdata in blocks.items():
            btype = bdata.get('type')
            if btype == '@app':
                continue
            if btype not in bspecs:
                err('%s [%s.%s]: block type "%s" not in %s schema (has: %s)'
                    % (path, sid, bid, btype, stype, sorted(bspecs)))
                continue
            for k, v in (bdata.get('settings') or {}).items():
                where = '%s [%s.%s.%s]' % (path, sid, bid, k)
                if k not in bspecs[btype]:
                    err('%s: no such block setting on "%s"' % (where, btype))
                else:
                    check_value(where, bspecs[btype][k], v)

        for bid in sdata.get('block_order') or []:
            if bid not in blocks:
                err('%s [%s]: block_order references missing block "%s"' % (path, sid, bid))
        if blocks and 'block_order' in sdata:
            for bid in blocks:
                if bid not in sdata['block_order']:
                    warn('%s [%s]: block "%s" is not in block_order, so it will not render'
                         % (path, sid, bid))

    for sid in d.get('order') or []:
        if sid not in sections:
            err('%s: order references missing section "%s"' % (path, sid))


def check_metaobject_template_paths():
    # templates/metaobject.<type>.json is rejected on upload with
    # "Template type 'metaobject' does not support JSON templates".
    # It has to be templates/metaobject/<type>.json - a subdirectory.
    for p in glob.glob('templates/metaobject.*.json'):
        name = p.replace('\\', '/').split('metaobject.')[-1]
        err('%s: metaobject templates must live in the templates/metaobject/ '
            'subdirectory. Rename to templates/metaobject/%s' % (p, name))


def check_settings_data():
    path = 'config/settings_data.json'
    raw = io.open(path, encoding='utf-8').read()
    data = json.loads(strip_header(raw))
    schema = json.loads(io.open('config/settings_schema.json', encoding='utf-8').read())

    specs = {}
    for group in schema:
        for st in group.get('settings', []) or []:
            if st.get('id'):
                specs[st['id']] = st

    blocks = {'current': data.get('current', {})}
    for name, preset in (data.get('presets') or {}).items():
        blocks['preset:' + name] = preset

    for label, block in blocks.items():
        for k, v in block.items():
            if k in ('sections', 'color_schemes', 'blocks'):
                continue
            if k == 'animations_hover_elements':
                # Known and deliberate: 'none' is not a schema option but Shopify
                # accepts it, and changing it would switch hover animations on.
                # See docs/changes.md, 2026-08-21.
                warn('%s [%s.%s]: %r is outside the schema options but is accepted '
                     'by Shopify and deliberately left alone' % (path, label, k, v))
                continue
            if k not in specs:
                warn('%s [%s.%s]: not in settings_schema.json' % (path, label, k))
            else:
                check_value('%s [%s.%s]' % (path, label, k), specs[k], v)


os.chdir(sys.argv[1] if len(sys.argv) > 1 else '.')

# Metaobject templates are templates/metaobject/<type>.json - a SUBDIRECTORY,
# not templates/metaobject.<type>.json. Shopify rejects the dotted form with
# "Template type 'metaobject' does not support JSON templates".
for p in sorted(set(glob.glob('templates/*.json')
                    + glob.glob('templates/metaobject/*.json')
                    + glob.glob('templates/customers/*.json')
                    + glob.glob('sections/*-group.json'))):
    check_template(p.replace('\\', '/'))

check_metaobject_template_paths()
check_settings_data()

for w in warnings:
    print('WARN  ' + w)
for e in errors:
    print('ERROR ' + e)
print('\n%d error(s), %d warning(s)' % (len(errors), len(warnings)))
sys.exit(1 if errors else 0)
