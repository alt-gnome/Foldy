if get_option('with_application')
  subdir('data')
  subdir('po')

  conf = configuration_data()
  conf.set_quoted('APP_ID', app_id)
  conf.set_quoted('APP_ID_ORIG', app_id_orig)
  conf.set10('IS_DEVEL', get_option('is_devel'))
  conf.set_quoted('G_LOG_DOMAIN', app_id)
  conf.set_quoted('PACKAGE_NAME', meson.project_name())
  conf.set_quoted('PACKAGE_VERSION', meson.project_version())
  conf.set_quoted('VERSION', meson.project_version())
  conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
  conf.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))
  conf.set_quoted('GNOMELOCALEDIR', get_option('prefix') / get_option('localedir'))

  configure_file(output: 'config.h', configuration: conf)
  config_h_dir = include_directories('.')

  application_vapi_sources = files(
    'config.vapi',
  )

  application_vala_sources = files(
    'add-apps-page.vala',
    'app-info-dialog.vala',
    'app-row-add.vala',
    'app-row-remove.vala',
    'app-row.vala',
    'application.vala',
    'base-page.vala',
    'categories-list.vala',
    'categories-model.vala',
    'category-row.vala',
    'folder-dialog.vala',
    'folder-page.vala',
    'folder-row.vala',
    'folders-list-page.vala',
    'main.vala',
    'search-row.vala',
    'utils.vala',
    'window.vala',
  )

  application_sources = [
    application_vapi_sources,
    application_vala_sources,
    blueprints,
    resources,
  ]

  libadwaita_dep = dependency('libadwaita-1', version: '>= 1.6')
  gio_dep = dependency('gio-2.0', version: '>= 2.76')
  gee_dep = dependency('gee-0.8')
  libfoldy_dep = dependency(versioned_lib_name, required: false)
  if not libfoldy_dep.found()
    libfoldy_dep = lib_dep
  endif

  application_dependencies = [
    libadwaita_dep,
    gio_dep,
    gee_dep,
    libfoldy_dep,
  ]

  application_c_args = [
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    '-w',
  ]

  application_vala_args = [
    '--gresources', resource_files,
    '--gresourcesdir=app/data/',
  ]

  executable(
    meson.project_name(),
    application_sources,
    include_directories: config_h_dir,
    dependencies: application_dependencies,
    c_args: application_c_args,
    vala_args: application_vala_args,
    install: true,
  )

  gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true,
  )
endif
