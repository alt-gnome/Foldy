project(
  'foldy',
  ['c', 'vala'],
  version: '3.6',
  meson_version: '>= 1.0.0',
  license: 'GPL-3.0-or-later',
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

app_id = 'org.altlinux.Foldy'
service_name = 'org.altlinux.FoldyService'

subdir('lib')
subdir('service')
subdir('app')
