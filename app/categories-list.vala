/*
 * Copyright (C) 2024-2025 Vladimir Vaskov
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

    public string folder_id { get; construct; }

    SearchRow search_row;

    Gee.ArrayList<CategoryRow> rows = new Gee.ArrayList<CategoryRow> ((a, b) => {
        return a.category_name == b.category_name;
    });

    public CategoriesList () {
        Object ();
    }

    public CategoriesList.with_folder_id (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        model = new CategoriesModel (folder_id);
        search_row = new SearchRow ();

        search_row.search_changed.connect (refilter);

        model.changed.connect (update_data);
        notify["expanded"].connect (update_subtitle);

        update_data ();
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

        add_row (search_row);

        foreach (var category in model.data) {
            var row = new CategoryRow (category);
            rows.add (row);
            add_row (row);

            if (category in folder_categories) {
                row.selected = true;
            }
        }

        update_subtitle ();
    }

    void refilter (string search_string) {
        foreach (var row in rows) {
            row.visible = search_string.down () in row.category_name.down ();
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
