api_version = meson.project_version().split('.')[0]

lib_name = 'lib' + meson.project_name()
gir_name = 'Foldy'

versioned_name = meson.project_name() + '-' + api_version
versioned_lib_name = lib_name + '-' + api_version
versioned_gir_name = gir_name + '-' + api_version

deps_name = versioned_lib_name + '.deps'
header_name = versioned_lib_name + '.h'
vapi_name = versioned_lib_name + '.vapi'
gir_name = versioned_gir_name + '.gir'
typelib_name = versioned_gir_name + '.typelib'

if get_option('with_library')
  library_vapi_sources = files(
    
  )

  library_vala_sources = files(
    'folder.vala',
    'folders.vala',
    'utils.vala',
  )

  library_sources = [
    library_vapi_sources,
    library_vala_sources,
  ]

  library_c_args = [
    '-DGETTEXT_PACKAGE="@0@"'.format(lib_name),
    '-w',
  ]

  deps_pkgs = [
    'gio-unix-2.0',
    'gee-0.8',
  ]

  gio_dep = dependency('gio-unix-2.0')
  gee_dep = dependency('gee-0.8')

  library_dependencies = [
    gio_dep,
    gee_dep,
  ]

  lib = shared_library(
    versioned_name,
    library_sources,
    dependencies: library_dependencies,
    vala_header: header_name,
    vala_vapi: vapi_name,
    vala_gir: gir_name,
    version: meson.project_version(),
    install: true,
    install_dir: [ true, true, true, true ],
    c_args: library_c_args,
  )

  lib_dep = declare_dependency(
    link_with: lib,
    include_directories: include_directories('.'),
    dependencies: library_dependencies
  )

  deps_conf = configuration_data()
  deps_conf.set ('DEPS',  '\n'.join (deps_pkgs))

  configure_file(
    input: 'lib.deps.in',
    output: deps_name,
    configuration: deps_conf,
    install: true,
    install_dir: get_option('datadir') / 'vala' / 'vapi',
  )

  if get_option('lib_introspection')
    g_ir_compiler = find_program('g-ir-compiler')
    custom_target(
      'typelib',
      command: [
        g_ir_compiler,
        '--shared-library', '@PLAINNAME@',
        '--output', '@OUTPUT@',
        '--includedir', gee_dep.get_variable('datadir') / 'gir-1.0',
        meson.current_build_dir() / gir_name,
      ],
      input: lib,
      output: typelib_name,
      depends: lib,
      install: true,
      install_dir: get_option('libdir') / 'girepository-1.0',
    )
  endif

  pkgconfig.generate(
    lib,
    name: versioned_lib_name,
    requires: library_dependencies,
    subdirs: [ versioned_name ],
    description: 'Functions for work with folders on GNOME',
    version: meson.project_version(),
    url: 'https://github.com/alt-gnome/libfoldy',
  )

  if get_option('lib_documentation')
    subdir('doc')
  endif
endif
