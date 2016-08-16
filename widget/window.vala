using Gtk;
using Config;
using Cairo;

namespace Widgets {
    public class Window : Widgets.BaseWindow {
        public int active_tab_underline_x;
		public int active_tab_underline_width;
		
		public Gdk.RGBA active_tab_color;

        public Window() {
            active_tab_color = Gdk.RGBA();
            active_tab_color.parse("#2CA7F8");
			
            int monitor = screen.get_monitor_at_window(screen.get_active_window());
            Gdk.Rectangle rect;
            screen.get_monitor_geometry(monitor, out rect);
            
            Gdk.Geometry geo = Gdk.Geometry();
            geo.min_width = rect.width / 3;
            geo.min_height = rect.height / 3;
            this.set_geometry_hints(null, geo, Gdk.WindowHints.MIN_SIZE);
            
            window_frame_box.margin_top = window_frame_margin_top;
            window_frame_box.margin_bottom = window_frame_margin_bottom;
            window_frame_box.margin_start = window_frame_margin_start;
            window_frame_box.margin_end = window_frame_margin_end;
            
            window_widget_box.margin_top = 2;
            window_widget_box.margin_bottom = 2;
            window_widget_box.margin_start = 2;
            window_widget_box.margin_end = 2;
                        
            try {
                var window_state = config.config_file.get_value("advanced", "window_state");
                var width = config.config_file.get_integer("advanced", "window_width");
                var height = config.config_file.get_integer("advanced", "window_height");
                if (width == 0 || height == 0) {
                    set_default_size(
                        rect.width * 2 / 3 + window_frame_margin_start + window_frame_margin_end,
                        rect.height * 2 / 3 + window_frame_margin_top + window_frame_margin_bottom);
                } else {
                    set_default_size(width, height);
                }
					
                    
                if (window_state == "maximize") {
                    maximize();
                } else if (window_state == "fullscreen") {
                    toggle_fullscreen();
                }
            } catch (GLib.KeyFileError e) {
                stdout.printf(e.message);
            }
            
            destroy.connect((w) => {
                    config.config_file.set_integer("advanced", "window_width", window_save_width);
                    config.config_file.set_integer("advanced", "window_height", window_save_height);
                    config.save();
                });

            try{
                set_icon_from_file(Utils.get_image_path("deepin-terminal.svg"));
            } catch(Error er) {
                stdout.printf(er.message);
            }
        }
		
        public override void draw_window_above(Cairo.Context cr) {
            Gtk.Allocation window_frame_rect;
            window_frame_box.get_allocation(out window_frame_rect);
            
            int x = window_frame_box.margin_start;
            int y = window_frame_box.margin_top;
            int width = window_frame_rect.width;
            Gdk.RGBA frame_color = Gdk.RGBA();
            try {
                frame_color.parse(config.config_file.get_string("theme", "color1"));
            } catch (GLib.KeyFileError e) {
                print(e.message);
            }
            
            try {
                if (window_is_fullscreen()) {
                    // Draw top line.
                    Utils.set_context_color(cr, frame_color);  // Draw terminal background color.
                    Draw.draw_rectangle(cr, x, y, width, 1);
                
                    cr.set_source_rgba(0, 0, 0, 0.2);  // Draw same black color as appbar.
                    Draw.draw_rectangle(cr, x, y, width, 1);
                
                    cr.set_source_rgba(1, 1, 1, 0.0625 * config.config_file.get_double("general", "opacity")); // Draw top line at window.
                    Draw.draw_rectangle(cr, x, y, width, 1);
                
                    // Draw line below at titlebar.
                    cr.save();
                    cr.set_source_rgba(0, 0, 0, 0.3);
                    // cr.set_source_rgba(1, 0, 0, 1);
                    Draw.draw_rectangle(cr, x, y + Constant.TITLEBAR_HEIGHT + 1, width, 1);
                    cr.restore();
						
                    // Draw active tab underline *above* titlebar underline.
                    cr.save();
                    Utils.set_context_color(cr, active_tab_color);
                    Draw.draw_rectangle(cr, x + active_tab_underline_x - window_frame_box.margin_start, y + Constant.TITLEBAR_HEIGHT, active_tab_underline_width, 2);
                    cr.restore();
            
                
                } else if (window_is_max() || window_is_tiled()) {
                    // Draw top line.
                    Utils.set_context_color(cr, frame_color);  // Draw terminal background color.
                    Draw.draw_rectangle(cr, x + 1, y + 1, width - 2, 1);
                
                    cr.set_source_rgba(0, 0, 0, 0.2);  // Draw same black color as appbar.
                    Draw.draw_rectangle(cr, x + 1, y + 1, width - 2, 1);
                
                    cr.set_source_rgba(1, 1, 1, 0.0625 * config.config_file.get_double("general", "opacity")); // Draw top line at window.
                    Draw.draw_rectangle(cr, x + 1, y + 1, width - 2, 1);
                
                    // Draw line below at titlebar.
                    cr.save();
                    cr.set_source_rgba(0, 0, 0, 0.3);
                    // cr.set_source_rgba(1, 0, 0, 1);
                    Draw.draw_rectangle(cr, x + 1, y + Constant.TITLEBAR_HEIGHT + 2, width - 2, 1);
                    cr.restore();
						
                    // Draw active tab underline *above* titlebar underline.
                    cr.save();
                    Utils.set_context_color(cr, active_tab_color);
                    Draw.draw_rectangle(cr, x + active_tab_underline_x - window_frame_box.margin_start, y + Constant.TITLEBAR_HEIGHT + 1, active_tab_underline_width, 2);
                    cr.restore();
                } else {
                    // Draw line around titlebar side.
                    Utils.set_context_color(cr, frame_color);
                    // Left.
                    Draw.draw_rectangle(cr, x + 1, y + 3, 1, 39);
                    // Right.
                    Draw.draw_rectangle(cr, x + width - 2, y + 3, 1, 39);
                
                    cr.set_source_rgba(0, 0, 0, 0.2);				
                    // Left.
                    Draw.draw_rectangle(cr, x + 1, y + 3, 1, 39);
                    // Right.
                    Draw.draw_rectangle(cr, x + width - 2, y + 3, 1, 39);
                
                    // Draw line above at titlebar.
                    Utils.set_context_color(cr, frame_color);
                    Draw.draw_rectangle(cr, x + 3, y + 1, width - 6, 1);

                    cr.set_source_rgba(0, 0, 0, 0.2);				
                    Draw.draw_rectangle(cr, x + 3, y + 1, width - 6, 1);
                
                    cr.set_source_rgba(1, 1, 1, 0.0625 * config.config_file.get_double("general", "opacity")); // Draw top line at window.
                    Draw.draw_rectangle(cr, x + 3, y + 1, width - 6, 1);
                
                    // Draw line below at titlebar.
                    cr.save();
                    cr.set_source_rgba(0, 0, 0, 0.3);
                    // cr.set_source_rgba(1, 0, 0, 1);
                    Draw.draw_rectangle(cr, x + 1, y + 41, width - 2, 1);
                    cr.restore();
						
                    // Draw active tab underline *above* titlebar underline.
                    cr.save();
                    Utils.set_context_color(cr, active_tab_color);
                    Draw.draw_rectangle(cr, x + active_tab_underline_x - window_frame_box.margin_start, y + Constant.TITLEBAR_HEIGHT, active_tab_underline_width, 2);
                    cr.restore();
                }
            } catch (Error e) {
                print(e.message);
            }
       }
    }
}