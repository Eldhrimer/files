/***
    Copyright (c) 2007, 2011 Red Hat, Inc.
    Copyright (c) 2013-2018 elementary LLC <https://elementary.io>

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program. If not, see <http://www.gnu.org/licenses/>.

    Authors: Alexander Larsson <alexl@redhat.com>
             Cosimo Cecchi <cosimoc@redhat.com>
             Julián Unrrein <junrrein@gmail.com>
***/

public class Marlin.Progress.InfoWidget : Gtk.Box {
    Gtk.Widget status;
    Gtk.Widget details;
    Gtk.Widget progress_bar;
    public PF.Progress.Info info { get; construct; }

    public signal void cancelled ();

    public InfoWidget (PF.Progress.Info info) {
        Object (info: info);

    }

    construct {
        this.orientation = Gtk.Orientation.VERTICAL;
        this.homogeneous = false;
        this.spacing = 5;

        this.status = new Gtk.Label ("status");
        (this.status as Gtk.Label).set_size_request (500, -1);
        (this.status as Gtk.Label).set_line_wrap (true);
        (this.status as Gtk.Label).set_line_wrap_mode (Pango.WrapMode.WORD_CHAR);
        (this.status as Gtk.Misc).set_alignment ((float) 0.0, (float) 0.5);
        pack_start (status, true, false, 0);

        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

        this.progress_bar = new Gtk.ProgressBar ();
        (this.progress_bar as Gtk.ProgressBar).pulse_step = 0.05;
        box.pack_start (this.progress_bar, true, false, 0);
        hbox.pack_start (box, true, true, 0);

        var button = new Gtk.Button.from_icon_name ("process-stop-symbolic", Gtk.IconSize.BUTTON);
        button.get_style_context ().add_class ("flat");
        button.clicked.connect (() => {
            cancelled ();
            button.sensitive = false;
        });

        hbox.pack_start (button, false, false, 0);

        pack_start (hbox, false, false, 0);

        this.details = new Gtk.Label ("details");
        (this.details as Gtk.Label).set_line_wrap (true);
        (this.details as Gtk.Misc).set_alignment ((float) 0.0, (float) 0.5);
        pack_start (details, true, false, 0);

        show_all ();

        update_data ();
        update_progress ();

        info.changed.connect (update_data);
        info.progress_changed.connect (update_progress);
        info.progress_finished.connect (() => { destroy (); });
    }

    public void update_data () {
        (this.status as Gtk.Label).set_text (info.status);
        string markup = Markup.printf_escaped ("<span size='small'>%s</span>", info.details);
        (this.details as Gtk.Label).set_markup (markup);
    }

    public void update_progress () {
        double progress = info.progress;

        if (progress < 0) {
            (this.progress_bar as Gtk.ProgressBar).pulse ();
        } else {
            (this.progress_bar as Gtk.ProgressBar).set_fraction (progress);
        }
    }
}
