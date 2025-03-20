if get_option('with_service')
  subdir('po')
  subdir('data')

  conf = configuration_data()
    conf.set_quoted('G_LOG_DOMAIN', service_name)
  conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
  conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
  conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))

  configure_file(output: 'config.h', configuration: conf)
  config_h_dir = include_directories('.')

  service_vapi_sources = files(
    'config.vapi',
  )

  service_vala_sources = files(
    'folder-data.vala',
    'folders-watcher.vala',
    'main.vala',
    'utils.vala',
  )

  service_sources = [
    service_vapi_sources,
    service_vala_sources,
  ]

  gio_dep = dependency('gio-unix-2.0', version: '>= ' + glib_min_version)
  gee_dep = dependency('gee-0.8')
  libfoldy_dep = dependency(versioned_lib_name, required: false)
  if not libfoldy_dep.found()
    libfoldy_dep = lib_dep
  endif

  dependencies = [
    gio_dep,
    gee_dep,
    libfoldy_dep,
  ]

  service_c_args = [
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  ]

  executable(
    service_name,
    service_sources,
    dependencies: dependencies,
    c_args: service_c_args,
    install: true,
  )
endif
