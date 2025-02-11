/*
 * Copyright (C) 2024 Vladimir Vaskov
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 * 
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public sealed class Foldy.CategoriesModel : Object {

    public string[] data { get; private set; default = {}; }

    public string? excluded_folder_id { get; construct; }

    public signal void changed ();

    public CategoriesModel (string? excluded_folder_id) {
        Object (excluded_folder_id: excluded_folder_id);
    }

    construct {
        AppInfoMonitor.get ().changed.connect (app_changed);
        app_changed ();
    }

    void app_changed () {
        var new_cat = new Gee.ArrayList<string> ();

        new_cat.add_all_array (Foldy.get_installed_categories (excluded_folder_id));

        new_cat.sort ();
        data = new_cat.to_array ();

        changed ();
    }
}
