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

using Foldy.Folder;

[GtkTemplate (ui = "/space/rirusha/Foldy/ui/category-row.ui")]
public sealed class Foldy.CategoryRow : Adw.ActionRow {

    [GtkChild]
    unowned Gtk.CheckButton check_button;

    public string category_name {
        get {
            return title;
        }
        construct set {
            title = value;
        }
    }

    public bool selected {
        get {
            return check_button.active;
        }
        set {
            check_button.active = value;
        }
    }

    public CategoryRow (string category_name) {
        Object (category_name: category_name);
    }
}