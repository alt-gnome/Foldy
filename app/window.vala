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

[GtkTemplate (ui = "/org/altlinux/Foldy/ui/window.ui")]
public sealed class Foldy.Window : Adw.ApplicationWindow {

    [GtkChild]
    unowned Adw.NavigationSplitView navigation_split_view;
    [GtkChild]
    unowned Adw.ToastOverlay toast_overlay;
    [GtkChild]
    unowned FoldersListPage folders_list_page;
    [GtkChild]
    unowned FolderPages folder_pages;

    public WindowType wintype { get; set; default = WindowType.WIDE; }

    const ActionEntry[] ACTION_ENTRIES = {
        { "about", on_about_action },
        { "export-folders", on_export_folders },
        { "import-folders", on_import_folders },
    };

    Xdp.Portal portal;
    Xdp.Parent xparent;

    public Window (Foldy.Application app) {
        Object (application: app);
    }

    construct {
        var settings = new Settings (Config.APP_ID_ORIG);

        portal = new Xdp.Portal ();

        add_action_entries (ACTION_ENTRIES, this);

        settings.bind ("window-width", this, "default-width", SettingsBindFlags.DEFAULT);
        settings.bind ("window-height", this, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-maximized", this, "maximized", SettingsBindFlags.DEFAULT);

        if (Config.IS_DEVEL == true) {
            add_css_class ("devel");
        }

        map.connect (() => {
            xparent = Xdp.parent_new_gtk (this);
        });
    }

    public void show_message (string message) {
        toast_overlay.add_toast (new Adw.Toast (message));
    }

    void on_about_action () {
        var about = new Adw.AboutDialog.from_appdata (
            "/org/altlinux/Foldy/org.altlinux.Foldy.metainfo.xml",
            Config.VERSION
        ) {
            application_icon = Config.APP_ID,
            artists = {
                "Arseniy Nechkin <krisgeniusnos@gmail.com>",
            },
            developers = {
                "Vladimir Vaskov <rirusha@altlinux.org>"
            },
            // Translators: NAME <EMAIL.COM> /n NAME <EMAIL.COM>
            translator_credits = _("translator-credits"),
            copyright = "© 2024-2025 ALT Linux Team"
        };

        about.present (this);
    }

    void on_export_folders () {
        portal.save_file.begin (
            xparent,
            _("Save folders file"),
            "%s.folders".printf (Environment.get_user_name ()),
            null,
            null,
            null,
            null,
            null,
            Xdp.SaveFileFlags.NONE,
            null,
            (obj, res) => {
                try {
                    var file_var = portal.save_file.end (res);

                    Variant uris_variant = file_var.lookup_value ("uris", new VariantType ("as"));
                    string[] uris = uris_variant.get_strv ();
                    string? uri = uris.length > 0 ? uris[0] : null;

                    if (uri == null) {
                        return;
                    }

                    save_folders (File.new_for_uri (uri).get_path ());
                } catch (Error e) {
                    warning (e.message);
                }
            }
        );
    }

    void on_import_folders () {
        portal.open_file.begin (
            xparent,
            _("Open folders file"),
            null,
            null,
            null,
            Xdp.OpenFileFlags.NONE,
            null,
            (obj, res) => {
                try {
                    var file_var = portal.open_file.end (res);

                    Variant uris_variant = file_var.lookup_value ("uris", new VariantType ("as"));
                    string[] uris = uris_variant.get_strv ();
                    string? uri = uris.length > 0 ? uris[0] : null;

                    if (uri == null) {
                        return;
                    }

                    restore_folders (File.new_for_uri (uri).get_path (), true);
                } catch (Error e) {
                    warning (e.message);
                }
            }
        );
    }

    [GtkCallback]
    void on_folder_choosed (string folder_id) {
        navigation_split_view.show_content = true;
        folder_pages.open_folder.begin (folder_id);
    }

    [GtkCallback]
    void on_nothing_to_show () {
        folders_list_page.unselect_all ();
    }
}
