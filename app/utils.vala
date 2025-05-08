/* Copyright 2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

public class Foldy.AppInfo : Object {

    public string id { get; set; }

    public string name { get; set; }

    public string display_name { get; set; }

    public string description { get; set; }

    public bool should_show { get; set; }

    public Icon? icon { get; set; }

    public bool selected { get; set; default = false; }

    public AppInfo (GLib.AppInfo app_info) {
        Object (
            id: app_info.get_id (),
            name: app_info.get_name (),
            display_name: app_info.get_display_name (),
            description: app_info.get_description (),
            icon: app_info.get_icon (),
            should_show: app_info.should_show ()
        );
    }
}


namespace Foldy {

    public enum FolderDialogType {
        CREATE,
        EDIT;
    }

    public enum WindowType {
        NARROW,
        WIDE;
    }

    [DBus (name = "org.altlinux.FoldyService")]
    internal interface ServiceProxy : Object {
        public signal void folders_refreshed ();
        public signal void folder_refreshed (string folder_id);
    }

    string get_folder_real_name (string folder_id) {
        string name = Folder.get_folder_name (folder_id);

        if (name.has_suffix (".directory")) {
            File? dir_file = null;

            foreach (var dir in Environment.get_system_data_dirs ()) {
                var tdir_file = File.new_build_filename (dir, "desktop-directories", name);

                if (tdir_file.query_exists ()) {
                    dir_file = tdir_file;
                    break;
                }
            }

            if (dir_file != null) {
                var d = new KeyFile ();

                try {
                    d.load_from_file (dir_file.peek_path (), KeyFileFlags.NONE);
                    name = d.get_locale_string ("Desktop Entry", "Name", null);

                } catch (Error e) {
                    warning (e.message);
                }
            }
        }

        return name;
    }
}

namespace Ridgets {

    public double inverse_lerp (double a, double b, double r) {
        return (r - a) / (b - a);
    }
}
