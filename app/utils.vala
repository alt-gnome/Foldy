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

    public enum WindowType {
        NARROW,
        WIDE;
    }

    [DBus (name = "org.altlinux.FoldyService")]
    internal interface ServiceProxy : Object {
        public signal void folders_refreshed ();
        public signal void folder_refreshed (string folder_id);
    }
}

namespace Ridgets {

    public double inverse_lerp (double a, double b, double r) {
        return (r - a) / (b - a);
    }
}
