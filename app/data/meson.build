desktop_file = i18n.merge_file(
  input: app_id + '.desktop.in',
  output: app_id + '.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate application desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
  input: app_id_orig + '.metainfo.xml.in',
  output: app_id_orig + '.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test(
    'Validate appstream file',
    appstreamcli,
    args: ['validate', appstream_file],
  )
endif

install_data(
  app_id_orig + '.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test(
    'Validate schema file',
    compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()],
  )
endif

blueprints = custom_target(
  'blueprints',
  input: files(
    'ui/add-apps-page.blp',
    'ui/app-info-dialog.blp',
    'ui/app-row.blp',
    'ui/base-page.blp',
    'ui/base-row.blp',
    'ui/categories-list.blp',
    'ui/category-row.blp',
    'ui/folder-dialog.blp',
    'ui/folder-page.blp',
    'ui/folder-pages.blp',
    'ui/folder-rename-dialog.blp',
    'ui/folders-list-page.blp',
    'ui/search-row.blp',
    'ui/start-page.blp',
    'ui/window.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

resource_files = files(app_id_orig + '.gresource.xml')
resources = gnome.compile_resources('foldy-resources', resource_files, dependencies: blueprints, c_name: 'foldy')

subdir('icons')
