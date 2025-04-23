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

    const OptionEntry[] OPTION_ENTRIES = {
        { "version", 'v', 0, OptionArg.NONE, null, N_("Print version information and exit"), null },
        { "save-folders", 's', 0, OptionArg.FILENAME, null, N_("Save folders to file"), "FILENAME" },
        { "restore-folders", 'r', 0, OptionArg.FILENAME, null, N_("Restore folders from file"), "FILENAME" },
        { null }
    };

    public Application () {
        Object (
            application_id: Config.APP_ID,
            resource_base_path: "/org/altlinux/Foldy/",
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    static construct {
        typeof (FoldersListPage).ensure ();
    }

    construct {
        add_main_option_entries (OPTION_ENTRIES);
        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<primary>q" });
    }

    protected override int handle_local_options (VariantDict options) {
        try {
            if (options.contains ("version")) {
                print ("%s\n", Config.VERSION);
                return 0;

            } else if (options.contains ("save-folders")) {
                string filename = options.lookup_value ("save-folders", null).get_bytestring ();
                save_folders (filename);
                return 0;

            } else if (options.contains ("restore-folders")) {
                string filename = options.lookup_value ("restore-folders", null).get_bytestring ();
                restore_folders (filename, true);
                return 0;
            }

        } catch (Error e) {
            error (e.message);
        }

        return -1;
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
