#loaddata

add = Button("Add")
datadiam = DataFrames.DataFrame()
signal_connect(add, "clicked") do widget
  # Create window
  win2 = Window()
  # Position of win [3 == center]
  set_gtk_property!(win2, :title,"Add data")
  set_gtk_property!(win2, :window_position,3)
  set_gtk_property!(win2, :height_request,190)
  #set_gtk_property!(win2, :height_request,200)
  #set_gtk_property!(win2, :accept_focus,true)
  loadframe = Frame()

  gadd = Grid()
  set_gtk_property!(gadd, :margin_top,50)
  set_gtk_property!(gadd, :margin_left,10)
  set_gtk_property!(gadd, :margin_right,10)
  #set_gtk_property!(gadd, :column_homogeneous, true)
  set_gtk_property!(gadd, :column_spacing, 10)
  set_gtk_property!(gadd, :row_spacing, 10)

  labeldata = Entry()
  set_gtk_property!(labeldata, :tooltip_markup, "Enter the label")
  set_gtk_property!(labeldata, :width_request, 200)
  set_gtk_property!(labeldata, :text,"label")

  canceldata = Button("Cancel")
  signal_connect(canceldata, :clicked) do widget
    destroy(win2)
  end

  browsedata = Button("Browse")
  signal_connect(browsedata, :clicked) do widget
    global dlg
    dlg = open_dialog("Choose file...", win2, ("*.txt, *.csv",), select_multiple=false)
  end

  addtodata = Button("Add")
  signal_connect(addtodata, :clicked) do widget
    global dlg
    global datadiam
    label1 = get_gtk_property(labeldata, :text, String)
    data = CSV.read(dlg, datarow=1)
    datadiam[Symbol(label1)] = data[1]
    # save to global data
    ll = size(datadiam[Symbol(label1)],1)
    status = datadiam[Symbol(label1)] != String
    push!(datalist,(label1,ll,status))
    destroy(win2)
  end

  gadd2 = Grid()
  set_gtk_property!(gadd2, :column_spacing, 10)


  gadd[1:2,1] = gadd2
  gadd2[1,1] = labeldata
  gadd2[2,1] = browsedata
  gadd[1,2] = canceldata
  gadd[2,2] = addtodata

  push!(loadframe,gadd)
  push!(win2,loadframe)
  showall(win2)
end
