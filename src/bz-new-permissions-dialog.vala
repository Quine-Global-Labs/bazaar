/*
 * bz-new-permissions-dialog.vala
 *
 * Copyright 2026 Alexander Vanhee
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Bz.NewPermissionsDialog : Adw.Dialog {
    private Dex.Promise promise;
    private bool responded = false;

    private NewPermissionsDialog (Bz.UpdatePermissionInfo[] infos) {
        Object ();

        content_width = 420;
        title =  _("New Permissions");

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 12) {
            margin_top = 12,
            margin_bottom = 8,
            margin_start = 18,
            margin_end = 18,
        };

        if (infos.length == 1)
            build_single_layout (box, infos[0]);
        else
            build_multi_layout (box, infos);

        var scrolled_window = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            propagate_natural_height = true,
            child = box,
        };

        var confirm_button = new Gtk.Button.with_mnemonic (_("_Accept")) {
            halign = Gtk.Align.CENTER,
            margin_top = 12,
            margin_bottom = 18,
        };
        confirm_button.add_css_class ("suggested-action");
        confirm_button.add_css_class ("pill");
        confirm_button.clicked.connect (() => {
            responded = true;
            promise.resolve_boolean (true);
            close ();
        });

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (new Adw.HeaderBar () {show_title = infos.length > 1});
        toolbar_view.content = scrolled_window;
        toolbar_view.add_bottom_bar (confirm_button);

        child = toolbar_view;

        promise = new Dex.Promise ();

        this.closed.connect (() => {
            if (!responded) {
                responded = true;
                promise.resolve_boolean (false);
            }
        });
    }

    private void build_single_layout (Gtk.Box box, Bz.UpdatePermissionInfo info) {
        var status_page = new Adw.StatusPage () {
            vexpand = false,
        };
        status_page.add_css_class ("compact");

        var permissions_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.NONE,
        };
        permissions_list.add_css_class ("boxed-list");

        var group = new Adw.PreferencesGroup ();
        group.add (permissions_list);

        box.append (status_page);
        box.append (group);

        status_page.paintable = info.entry.icon_paintable;

        uint n_items = populate_permissions_list (permissions_list, info);

        status_page.title = status_page.title = ngettext (
            "New Permission for %s",
            "New Permissions for %s",
            n_items
        ).printf (info.entry.title);
        status_page.description = ngettext (
            "This update requires the following additional permission",
            "This update requires the following additional permissions",
            n_items
        );
    }

    private void build_multi_layout (Gtk.Box box, Bz.UpdatePermissionInfo[] infos) {
        box.spacing = 24;
        foreach (var info in infos) {
            var entry = info.entry;

            var app_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 8);

            var header_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12) {
                valign = Gtk.Align.CENTER,
                margin_start = 8,
            };

            if (entry.icon_paintable != null) {
                var icon = new Gtk.Image.from_paintable (entry.icon_paintable) {
                    pixel_size = 48,
                };
                header_box.append (icon);
            }

            var title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                valign = Gtk.Align.CENTER,
            };

            var title_label = new Gtk.Label (entry.title) {
                halign = Gtk.Align.START,
                xalign = 0,
            };
            title_label.add_css_class ("heading");
            title_box.append (title_label);

            if (entry.developer != null) {
                var developer_label = new Gtk.Label (entry.developer) {
                    halign = Gtk.Align.START,
                    xalign = 0,
                };
                developer_label.add_css_class ("dim-label");
                title_box.append (developer_label);
            }

            header_box.append (title_box);

            var permissions_list = new Gtk.ListBox () {
                selection_mode = Gtk.SelectionMode.NONE,
            };
            permissions_list.add_css_class ("boxed-list");
            populate_permissions_list (permissions_list, info);

            app_box.append (header_box);
            app_box.append (permissions_list);

            box.append (app_box);
        }
    }

    private uint populate_permissions_list (Gtk.ListBox list, Bz.UpdatePermissionInfo info) {
        var permissions = info.additional_permissions;
        uint n_items = 0;

        if (permissions != null) {
            var model = Bz.SafetyCalculator.analyze_permissions (permissions, false);
            n_items = model.get_n_items ();

            for (int level = Bz.Importance.IMPORTANT; level >= Bz.Importance.UNIMPORTANT; level--) {
                for (uint j = 0; j < n_items; j++) {
                    var row_data = (Bz.SafetyRow) model.get_item (j);

                    if (row_data.importance != level)
                        continue;

                    var row = Bz.context_row_new (
                        row_data.icon_name,
                        row_data.importance,
                        row_data.title,
                        row_data.subtitle
                    );
                    list.append (row);
                }
            }
        }

        return n_items;
    }

    public static Dex.Future present_and_wait (Gtk.Widget parent, Bz.UpdatePermissionInfo[] infos) {
        var dialog = new NewPermissionsDialog (infos);
        dialog.present (parent);
        return dialog.promise;
    }
}
