using Gtk.ShortNames, Gtk.GConstants

using Printf
using GR

function plot(ctx, w, h)

    ENV["GKS_WSTYPE"] = "142"
    ENV["GKSconid"] = @sprintf("%lu", UInt64(ctx.ptr))
    plt = gcf()
    plt[:size] = (w, h)

    GR.plot(1:20)
end

function draw(widget)
    ctx = Gtk.getgc(widget)
    w = Gtk.width(widget)
    h = Gtk.height(widget)

    plot(ctx, w, h)
end


win = Window("Gtk") |> (bx = Box(:v))
Gtk.set_gtk_property!(win, :double_buffered, false)
canvas = Canvas(600, 450)
push!(bx, canvas)


canvas.draw = draw

Gtk.showall(win)
