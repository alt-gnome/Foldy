desktop_file = configure_file(
  input: service_name + '.desktop.in.in',
  output: service_name + '.desktop.in',
  configuration: { 'SERVICE_NAME': service_name }
)

appstream_file = i18n.merge_file(
  input: service_name + '.metainfo.xml.in',
  output: service_name + '.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
  test(
    'Validate service appstream file',
    appstreamcli,
    args: ['validate', appstream_file],
  )
endif

i18n.merge_file(
    type: 'desktop',
    input: desktop_file,
    output: service_name + '.desktop',
    po_dir: '../po',
    install: true,
    install_dir: get_option('prefix') / get_option ('datadir') / 'applications'
)

install_data(
    desktop_file,
    rename: service_name + '.desktop',
    install_dir: get_option('sysconfdir') / 'xdg' / 'autostart'
)

# D-Bus activation

configure_file(
  input: service_name + '.service.in',
  output: service_name + '.service',
  configuration: { 'BINDIR': get_option('prefix') / get_option('bindir'), 'SERVICE_NAME': service_name },
  install_dir: get_option('prefix') / get_option ('datadir') / 'dbus-1' / 'services'
)
gnome.post_install(
  update_desktop_database: true,
)

subdir('icons')
