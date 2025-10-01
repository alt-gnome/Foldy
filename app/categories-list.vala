/*
 * Copyright (C) 2024-2025 Vladimir Romanov
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

using Foldy.Folder;

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/categories-list.ui")]
public sealed class Foldy.CategoriesList : Adw.ExpanderRow {

    CategoriesModel model;

    public string? folder_id { get; set; default = null; }

    Gee.ArrayList<CategoryRow> rows = new Gee.ArrayList<CategoryRow> ((a, b) => {
        return a.category_name == b.category_name;
    });

    public signal void selection_changed ();

    public CategoriesList () {
        Object ();
    }

    construct {
        notify["folder-id"].connect (() => {
            model = new CategoriesModel (folder_id);

            model.changed.connect (update_data);
            update_data ();
        });

        notify["expanded"].connect (update_subtitle);
    }

    void clear_expander_row () {
        foreach (var row in rows) {
            remove (row);
        }
        rows.clear ();
    }

    void update_subtitle () {
        if (expanded) {
            subtitle = "";
        } else {
            subtitle = string.joinv (", ", get_selected_categories ());
        }
    }

    void update_data () {
        clear_expander_row ();

        var folder_categories = new Gee.HashSet<string> ();

        if (folder_id != null) {
            folder_categories.add_all_array (Folder.get_folder_categories (folder_id));
        }

        foreach (var category in model.data) {
            var row = new CategoryRow (category);
            rows.add (row);
            add_row (row);

            row.notify["selected"].connect (() => {
                selection_changed ();
            });

            if (category in folder_categories) {
                row.selected = true;
            }
        }

        update_subtitle ();
    }

    public void refilter (string search_string) {
        foreach (var row in rows) {
            row.visible = search_string.match_string (row.category_name, true);
        }
    }

    public string[] get_selected_categories () {
        var array = new Gee.ArrayList<string> ();
        array.add_all_iterator (rows.filter (row => {
            return row.selected;
        }).map<string> (row => {
            return row.category_name;
        }));
        return array.to_array ();
    }
}
