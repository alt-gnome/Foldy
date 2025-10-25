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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/search-row.ui")]
public sealed class Foldy.SearchRow : Gtk.ListBoxRow {

    [GtkChild]
    unowned Gtk.SearchEntry search_entry;

    public string text {
        get {
            return search_entry.text;
        }
        set {
            search_entry.text = value;
        }
    }

    public signal void search_changed (string search_text);

    construct {
        search_entry.search_changed.connect (() => {
            search_changed (search_entry.text);
        });
    }
}
