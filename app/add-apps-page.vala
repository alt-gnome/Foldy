/*
 * Copyright 2024 Rirusha
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

using Foldy.Folder;

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/add-apps-page.ui")]
public sealed class Foldy.AddAppsPage : BasePage {

    [GtkChild]
    unowned Adw.ButtonRow add_button;

    public string folder_id { get; construct; }

    public AddAppsPage (string folder_id) {
        Object (folder_id: folder_id);
    }

    construct {
        model = new Gtk.NoSelection (
            new Gtk.FilterListModel (
                new Gtk.SortListModel (
                    new AppsModel (folder_id, true),
                    get_sorter ()
                ),
                get_search_filter ()
            )
        );

        title = _("Add apps to folder '%s'").printf (get_folder_real_name (folder_id));
    }

    Gtk.Sorter get_sorter () {
        var sorter = new Gtk.StringSorter (new Gtk.PropertyExpression (
            typeof (AppInfo),
            null,
            "display-name"
        ));

        return sorter;
    }

    protected override void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new AppRowAdd ();
        item.child.add_css_class ("card");
    }

    protected override void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var row = (AppRowAdd) item.child;

        row.app_info = (AppInfo) item.item;

        bind_property (
            "selection-enabled",
            row,
            "selection-enabled",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );
    }

    [GtkCallback]
    void add_selected_apps () {
        add_folder_apps (folder_id, get_selected_apps ());
        close_requested ();
    }

    protected override void on_activate (uint position) {
        if (!selection_enabled) {
            return;
        }

        var app = (AppInfo) model.get_item (position);
        app.selected = !app.selected;

        add_button.sensitive = get_selected_apps ().length > 0;
    }
}
