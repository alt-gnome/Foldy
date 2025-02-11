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

public sealed class Foldy.Application : Adw.Application {

    const ActionEntry[] ACTION_ENTRIES = {
        { "quit", quit },
    };

    public Application () {
        Object (
            application_id: Config.APP_ID,
            resource_base_path: "/org/altlinux/Foldy/",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    construct {
        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<primary>q" });
    }

    public static new Foldy.Application get_default () {
        return (Foldy.Application) GLib.Application.get_default ();
    }

    public void show_message (string message) {
        if (active_window != null) {
            ((Window) active_window).show_message (message);
        }
    }

    public override void activate () {
        base.activate ();

        if (active_window == null) {
            var win = new Window (this);

            win.present ();
        } else {
            active_window.present ();
        }
    }
}
