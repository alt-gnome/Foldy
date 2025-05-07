project(
  'foldy',
  ['c', 'vala'],
  version: '4.1',
  meson_version: '>= 1.0.0',
  license: 'GPL-3.0-or-later',
  default_options: [
    'prefix=/usr',
  ]
)

i18n = import('i18n')
gnome = import('gnome')
pkgconfig = import('pkgconfig')

glib_min_version = '2.76'

add_project_arguments(
  # GCC14 COMPILE ERROR
  '-Wno-int-conversion',
  language: ['c'],
)

add_project_arguments(
  '--target-glib', glib_min_version,
  '--vapidir', meson.current_source_dir(),
  language: ['vala'],
)

app_id_orig = 'org.altlinux.Foldy'
app_id = app_id_orig

if get_option('is_devel')
  app_id = 'org.altlinux.Foldy.Devel'
endif

service_name = 'org.altlinux.FoldyService'

subdir('lib')
subdir('service')
subdir('app')
