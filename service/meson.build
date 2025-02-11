if get_option('with_service')
  subdir('po')
  subdir('data')

  service_vapi_sources = files(
    
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

  executable(
    service_name,
    service_sources,
    dependencies: dependencies,
    install: true,
  )
endif
