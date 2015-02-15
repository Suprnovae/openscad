$fn = 60;
width = 60;
height = 100;
thickness = 5;
edge_rounding = 2;
corner_size = 30;

font = "Open Sans:style=Bold";

icons = [
    ["all"],
    ["export-stl"],
    ["export-off"],
    ["export-amf"],
    ["export-dxf"],
    ["export-svg"],
    ["export-csg"],
    ["preview"],
    ["render"],
    ["zoom-in"],
    ["zoom-out"],
    ["undo"],
    ["redo"]
];

module outline(w) {
    difference() {
        offset(w) children();
        children();
    }
}

module inset(w) {
    difference() {
        children();
        offset(delta = -w) children();
    }
}

module paper() {
    w = edge_rounding + thickness;
    offset(edge_rounding)
        translate([w, w])
            square([width - 2 * w, height - 2 * w]);
}

module export_paper() {
    difference() {
        outline(thickness) paper();
        translate([-1, height - corner_size + 1]) square([corner_size, corner_size]);
        translate([-10, -10]) square([height, 55]);
    }
}

module export_paper_corner() {
    translate([corner_size, height - corner_size]) {
        rotate(90) {
            hull() {
                intersection() {
                    outline(thickness) paper();
                    translate([-1, -1]) square([corner_size + 1, corner_size + 1]);
                }
            }
        }
    }
}

module export(t) {
    export_paper();
    export_paper_corner();
    translate([width / 2, 0])
        text(t, 35, font = font, halign = "center");
}

module hourglass() {
    square([20, 3], center = true);
    translate([-5, 6]) rotate(60) square([15.6, 1], center = true);
    translate([-5, 25 - 6]) rotate(-60) square([15.6, 1], center = true);
    mirror([1, 0]) {
        translate([-5, 6]) rotate(60) square([15.6, 1], center = true);
        translate([-5, 25 - 6]) rotate(-60) square([15.6, 1], center = true);
    }
    polygon([[-5, 2.5], [5, 2.5], [0.1, 5], [0.2, 13.5], [4, 20], [-4, 20], [-0.2, 13.5], [-0.1, 5]]);
    translate([0, 25]) square([20, 3], center = true);
}

module line() {
    translate([-0.1, -0.1]) square([0.2, 40.2]);
}

module line_dotted() {
    difference() {
        translate([-0.1, -0.1]) square([0.2, 40.2]);
        for (a = [ 0 : 2 ]) {
            translate([-5, 4 + a * 12]) square([10, 8]);
        }
    }
}

module preview_cube() {
    offset(2) {
        children(0);
        rotate(-60) children(0);
        rotate(60) children(0);
        translate([0, 40]) rotate(-60) children(0);
        translate([0, 40]) rotate(60) children(0);
        translate([-sin(60) * 40, cos(60) * 40]) children(0);
        translate([sin(60) * 40, cos(60) * 40]) children(0);
        translate([-sin(60) * 40, cos(60) * 40 + 40]) rotate(-60) children(0);
        translate([sin(60) * 40, cos(60) * 40 + 40]) rotate(60) children(0);
    }
}

module render_() {
    difference() {
        preview_cube() line();
        polygon([[-14, 35], [14, 35], [3, 13], [30, -30], [-30, -30], [-3, 13]]);
    }
    translate([0, -10]) scale(1.6) hourglass();
}

module preview() {
    difference() {
        preview_cube() line_dotted();
        translate([0, 8]) square([35, 28], center = true);
    }
    translate([0, 4]) polygon([[-18, 15], [-9, 15], [0, 0], [-9, -15], [-18, -15], [-9, 0]]);
    translate([18, 4]) polygon([[-18, 15], [-9, 15], [0, 0], [-9, -15], [-18, -15], [-9, 0]]);
}

module zoom() {
    children();
    difference() {
        union() {
            circle(r = 40);
            rotate(45)
                translate([0, -50])
                    offset(thickness)
                        square([8, 80], center = true);
        }
        circle(r = 40 - thickness);
    }
}

module zoom_in() {
    zoom() {
        square([8, 40], center = true);
        square([40, 8], center = true);
    }
}

module zoom_out() {
    zoom() {
        square([40, 8], center = true);
    }
}

module undo() {
    offset(1) {
        difference() {
            circle(r = 40);
            translate([-8, 0]) circle(r = 32);
            translate([-50, -50]) square([100, 54]);
        }
    }
    translate([43, 0])
        polygon([[-35, 0], [0, 0], [0, 35]]);
}

module redo() {
    mirror([1, 0, 0]) undo();
}

module icon_translate(idx, icon, cols) {
    f = icon == "all" ? 200 : 0;
    show = let(i = search([icon], icons)[0]) icon == "all" || i == idx + 1;
    if (show) {
        translate(f * [idx % cols, floor(idx / cols)]) {
            children();
        }
    }
}

module icon(icon) {
    cols = 4;
    icon_translate(0, icon, cols) export("STL");
    icon_translate(1, icon, cols) export("OFF");
    icon_translate(2, icon, cols) export("AMF");
    icon_translate(3, icon, cols) export("DXF");
    icon_translate(4, icon, cols) export("SVG");
    icon_translate(5, icon, cols) export("CSG");
    icon_translate(6, icon, cols) preview();
    icon_translate(7, icon, cols) render_();
    icon_translate(8, icon, cols) zoom_in();
    icon_translate(9, icon, cols) zoom_out();
    icon_translate(10, icon, cols) undo();
    icon_translate(11, icon, cols) redo();
}

icon = "all";
icon(icon);

for (a = [ 1 : len(icons) - 1 ]) {
    echo(icon = icons[a][0]);
}