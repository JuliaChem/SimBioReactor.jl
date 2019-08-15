using Gtk, Gtk.ShortNames, GR, Printf, CSV, LsqFit, Distributions, Mustache
import DefaultApplication, DataFrames

# Environmental variable to allow Windows decorations
ENV["GTK_CSD"] = 0

# Variable declaration for parEst Plots
canvas = nothing
plotStatus = 0
const xvals = Ref(zeros(0))
const yvals = Ref(zeros(0))

# Create window
mainWin = Window()
#sc = Gtk.GAccessor.style_context(mainWin)
#pr = CssProviderLeaf(data="* {background:white;}")
#push!(sc, StyleProvider(pr), 600)

# Properties for mainWin
set_gtk_property!(mainWin, :title, "SimBioReactor 1.0")
set_gtk_property!(mainWin, :window_position, 3)
set_gtk_property!(mainWin, :height_request, 500)
set_gtk_property!(mainWin, :width_request, 350)
set_gtk_property!(mainWin, :accept_focus, true)

# Properties for mainGrid
mainGrid = Grid()
set_gtk_property!(mainGrid, :column_spacing, 10)
set_gtk_property!(mainGrid, :row_spacing, 10)
set_gtk_property!(mainGrid, :margin_top, 15)
set_gtk_property!(mainGrid, :margin_bottom, 15)
set_gtk_property!(mainGrid, :margin_left, 15)
set_gtk_property!(mainGrid, :margin_right, 15)
set_gtk_property!(mainGrid, :column_homogeneous, true)
set_gtk_property!(mainGrid, :row_homogeneous, true)

################################################################################
# Main buttons
################################################################################
# Action for button "New simulation"
new = Button("New simulation")
signal_connect(new, :clicked) do widget
    newWin = Window()

    set_gtk_property!(newWin, :visible, true)
    set_gtk_property!(newWin, :title, "Blank simulation - SimBioReactor 1.0")
    set_gtk_property!(newWin, :window_position, 3)
    set_gtk_property!(newWin, :height_request, 600)
    set_gtk_property!(newWin, :width_request, 900)
    set_gtk_property!(newWin, :accept_focus, true)

    newWinGrid = Grid()
    set_gtk_property!(newWinGrid, :column_spacing, 10)
    set_gtk_property!(newWinGrid, :row_spacing, 10)
    set_gtk_property!(newWinGrid, :margin_top, 15)
    set_gtk_property!(newWinGrid, :margin_bottom, 15)
    set_gtk_property!(newWinGrid, :margin_left, 15)
    set_gtk_property!(newWinGrid, :margin_right, 15)
    set_gtk_property!(newWinGrid, :column_homogeneous, true)
    set_gtk_property!(newWinGrid, :row_homogeneous, false)

    newWinFrame = Frame()
    set_gtk_property!(newWinFrame, :width_request, 870)
    set_gtk_property!(newWinFrame, :height_request, 580)

    # Action for button "newExit"
    newExit = Button("Exit")
    signal_connect(newExit, :clicked) do widget
        destroy(newWin)
        destroy(mainWin)
    end

    newClose = Button("Close")
    signal_connect(newClose, :clicked) do widget
        destroy(newWin)
    end

    newSave = Button("Save")
    newSaveAs = Button("Save as...")

    newWinGrid[1:4,1] = newWinFrame
    newWinGrid[1,2] = newSave
    newWinGrid[2,2] = newSaveAs
    newWinGrid[3,2] = newClose
    newWinGrid[4,2] = newExit

    push!(newWin, newWinGrid)
    showall(newWin)
end

################################################################################
# Action for button "Open simulation"
################################################################################
open = Button("Open simulation")

################################################################################
# Action for button "Parameter Estimation"
################################################################################
parEst = Button("Parameter estimation")
signal_connect(parEst, :clicked) do widget
    global parEstWin = Window()
    set_gtk_property!(parEstWin, :visible, true)
    set_gtk_property!(parEstWin, :title, "Parameter Estimation - SimBioReactor 1.0")
    set_gtk_property!(parEstWin, :window_position, 3)
    set_gtk_property!(parEstWin, :height_request, 600)
    set_gtk_property!(parEstWin, :width_request, 900)
    set_gtk_property!(parEstWin, :accept_focus, true)

    # Background color
    #sc_estPar = Gtk.GAccessor.style_context(parEstWin)
    #pr_estPar = CssProviderLeaf(data="* {background:white;}")
    #push!(sc_estPar, StyleProvider(pr_estPar), 600)

    # Main grid
    parEstWinGrid0 = Grid()
    set_gtk_property!(parEstWinGrid0, :column_homogeneous, false)
    set_gtk_property!(parEstWinGrid0, :row_homogeneous, false)
    set_gtk_property!(parEstWinGrid0, :column_spacing, 10)
    set_gtk_property!(parEstWinGrid0, :row_spacing, 10)
    set_gtk_property!(parEstWinGrid0, :margin_top, 10)
    set_gtk_property!(parEstWinGrid0, :margin_bottom, 10)
    set_gtk_property!(parEstWinGrid0, :margin_left, 10)
    set_gtk_property!(parEstWinGrid0, :margin_right, 10)

    ############################################################################
    # Sub Grids
    ############################################################################
    global parEstWinGridM1 = Grid()
    set_gtk_property!(parEstWinGridM1, :column_homogeneous, false)
    set_gtk_property!(parEstWinGridM1, :row_homogeneous, false)
    set_gtk_property!(parEstWinGridM1, :row_spacing, 10)

    global parEstWinGridM2 = Grid()
    set_gtk_property!(parEstWinGridM2, :column_homogeneous, false)
    set_gtk_property!(parEstWinGridM2, :row_homogeneous, false)
    set_gtk_property!(parEstWinGridM2, :row_spacing, 10)

    ############################################################################
    # Frame Grids
    ############################################################################
    global parEstFrame1Grid = Grid()
    set_gtk_property!(parEstFrame1Grid, :column_homogeneous, true)
    set_gtk_property!(parEstFrame1Grid, :row_homogeneous, false)
    set_gtk_property!(parEstFrame1Grid, :row_spacing, 10)
    set_gtk_property!(parEstFrame1Grid, :column_spacing, 10)
    set_gtk_property!(parEstFrame1Grid, :margin_top, 10)
    set_gtk_property!(parEstFrame1Grid, :margin_bottom, 10)
    set_gtk_property!(parEstFrame1Grid, :margin_left, 10)
    set_gtk_property!(parEstFrame1Grid, :margin_right, 10)

    global parEstFrame2Grid = Grid()
    set_gtk_property!(parEstFrame2Grid, :column_homogeneous, false)
    set_gtk_property!(parEstFrame2Grid, :row_homogeneous, false)
    set_gtk_property!(parEstFrame2Grid, :row_spacing, 10)

    global parEstFrame3Grid = Grid()
    set_gtk_property!(parEstFrame3Grid, :column_homogeneous, true)
    set_gtk_property!(parEstFrame3Grid, :row_homogeneous, false)
    set_gtk_property!(parEstFrame3Grid, :row_spacing, 10)
    set_gtk_property!(parEstFrame3Grid, :column_spacing, 10)
    set_gtk_property!(parEstFrame3Grid, :margin_top, 10)
    set_gtk_property!(parEstFrame3Grid, :margin_bottom, 10)
    set_gtk_property!(parEstFrame3Grid, :margin_left, 10)
    set_gtk_property!(parEstFrame3Grid, :margin_right, 10)

    global parEstFrame4Grid = Grid()
    set_gtk_property!(parEstFrame4Grid, :column_homogeneous, true)
    set_gtk_property!(parEstFrame4Grid, :row_homogeneous, true)
    set_gtk_property!(parEstFrame4Grid, :column_spacing, 10)
    set_gtk_property!(parEstFrame4Grid, :row_spacing, 10)
    set_gtk_property!(parEstFrame4Grid, :margin_top, 10)
    set_gtk_property!(parEstFrame4Grid, :margin_bottom, 10)
    set_gtk_property!(parEstFrame4Grid, :margin_left, 10)
    set_gtk_property!(parEstFrame4Grid, :margin_right, 10)

    ############################################################################
    # Frames
    ############################################################################
    global parEstWinFrame1 = Frame("Load data")
    set_gtk_property!(parEstWinFrame1, :width_request, 400)
    set_gtk_property!(parEstWinFrame1, :height_request, 300)
    set_gtk_property!(parEstWinFrame1, :label_xalign, 0.50)

    global parEstWinFrame2 = Frame("Graphics")
    set_gtk_property!(parEstWinFrame2, :width_request, 570)
    set_gtk_property!(parEstWinFrame2, :height_request, 470)
    set_gtk_property!(parEstWinFrame2, :label_xalign, 0.50)

    global parEstWinFrame3 = Frame("Fit Settings")
    set_gtk_property!(parEstWinFrame3, :width_request, 400)
    set_gtk_property!(parEstWinFrame3, :height_request, 300)
    set_gtk_property!(parEstWinFrame3, :label_xalign, 0.50)

    global parEstWinFrame4 = Frame()
    set_gtk_property!(parEstWinFrame4, :width_request, 400)
    set_gtk_property!(parEstWinFrame4, :height_request, 150)

    global parEstWinFrameData = Frame()
    global parEstWinFrameModel = Frame()
    set_gtk_property!(parEstWinFrameModel, :height_request, 150)

    ############################################################################
    # Buttons
    ############################################################################
    # Signal connect for load data
    parEstLoad = Button("Load")

    # Dataframe variable to storage data
    signal_connect(parEstLoad, "clicked") do widget
        parEstLoadWin = Window()
        set_gtk_property!(parEstLoadWin, :title, "Load data")
        set_gtk_property!(parEstLoadWin, :window_position, 3)
        set_gtk_property!(parEstLoadWin, :height_request, 10)
        set_gtk_property!(parEstLoadWin, :accept_focus, true)

        parEstGridLoad = Grid()
        set_gtk_property!(parEstGridLoad, :margin_top, 40)
        set_gtk_property!(parEstGridLoad, :margin_left, 20)
        set_gtk_property!(parEstGridLoad, :margin_right, 20)
        set_gtk_property!(parEstGridLoad, :margin_bottom, 20)
        set_gtk_property!(parEstGridLoad, :column_spacing, 10)
        set_gtk_property!(parEstGridLoad, :row_spacing, 10)
        set_gtk_property!(parEstGridLoad, :column_homogeneous, true)

        parEstLabelX = Entry()
        set_gtk_property!(parEstLabelX, :tooltip_markup, "X label")
        set_gtk_property!(parEstLabelX, :width_request, 150)
        set_gtk_property!(parEstLabelX, :text, "X label")
        signal_connect(parEstLabelX, :focus_in_event) do widget
            set_gtk_property!(parEstLabelX, :text, "")
        end

        parEstLabelY = Entry()
        set_gtk_property!(parEstLabelY, :tooltip_markup, "Y label")
        set_gtk_property!(parEstLabelY, :width_request, 150)
        set_gtk_property!(parEstLabelY, :text, "Y label")

        parEstCancelData = Button("Cancel")
        signal_connect(parEstCancelData, :clicked) do widget
            destroy(parEstLoadWin)
        end

        parEstBrowseData = Button("Browse")
        signal_connect(parEstBrowseData, :clicked) do widget
            global dlg
            dlg = open_dialog("Choose file...", parEstLoadWin, ("*.txt, *.csv",), select_multiple = false)

            if isempty(dlg) == false
                set_gtk_property!(parEstBrowseData, :label, "Browse ✔")
                set_gtk_property!(parEstClearData, :sensitive, true)
            end
        end

        # Add data to datasheet
        parEstAdd2Data = Button("Add")
        signal_connect(parEstAdd2Data, :clicked) do widget
            global dlg, parEstData, parEstDataView, parEstDataList
            global data, labelX, labelY, parEstClearData

            labelX = get_gtk_property(parEstLabelX, :text, String)
            labelY = get_gtk_property(parEstLabelY, :text, String)

            # Define the source of data
            # Define type of cell
            rTxt1 = CellRendererText()

            global c1 = TreeViewColumn(String(labelX), rTxt1, Dict([("text", 0)]))
            global c2 = TreeViewColumn(String(labelY), rTxt1, Dict([("text", 1)]))

            # Allows to select rows
            for c in [c1, c2]
                GAccessor.resizable(c, true)
            end

            push!(parEstDataView, c1, c2)

            global parEstData = DataFrames.DataFrame()

            data = CSV.read(dlg, datarow = 1)
            parEstData[!, Symbol(labelX)] = data[:,1]
            parEstData[!, Symbol(labelY)] = data[:,2]

            # save to global data
            for i = 1:size(data, 1)
                push!(parEstDataList, (data[i,1], data[i,2]))
            end
            destroy(parEstLoadWin)

            # Plot
            if plotStatus == 0
                visible(parEstFrame2Grid, true)
                global fitStatus = 0
                runme()
                global plotStatus = 1
            else
                visible(parEstFrame2Grid, true)
                on_button_clicked(1)
            end

            set_gtk_property!(parEstLoad, :sensitive, false)
        end

        parEstGridLoad2 = Grid()
        set_gtk_property!(parEstGridLoad2, :column_spacing, 10)
        set_gtk_property!(parEstGridLoad2, :row_spacing, 10)

        parEstGridLoad[1:2,1] = parEstGridLoad2
        parEstGridLoad2[1,1] = parEstLabelX
        parEstGridLoad2[1,2] = parEstLabelY
        parEstGridLoad2[2,1:2] = parEstBrowseData
        parEstGridLoad[1,2] = parEstCancelData
        parEstGridLoad[2,2] = parEstAdd2Data

        push!(parEstLoadWin, parEstGridLoad)
        showall(parEstLoadWin)
    end

    # Signal connect for exit parameter estimation
    parEstExit = Button("Exit")
    signal_connect(parEstExit, :clicked) do widget
        destroy(parEstWin)
        destroy(mainWin)
    end

    parEstClose = Button("Close")
    signal_connect(parEstClose, :clicked) do widget
        destroy(parEstWin)
    end

    # Signal connect to clear de listdata
    parEstClearData = Button("Clear")
    signal_connect(parEstClearData, "clicked") do widget
        global parEstWinFrameData

        destroy(parEstWinFrameData) # Delete treeview to clear data table

        global parEstGridData = Grid()
        global parEstWinDataScroll = ScrolledWindow(parEstGridData)

        # Redrawn TreeView after deletion of previous one.
        # Table for data
        global parEstDataList = ListStore(Float64, Float64)

        # Visual table
        global parEstDataView = TreeView(TreeModel(parEstDataList))
        set_gtk_property!(parEstDataView, :reorderable, true)
        set_gtk_property!(parEstDataView, :hover_selection, true)

        # Set selectable
        selmodel1 = G_.selection(parEstDataView)
        set_gtk_property!(parEstDataView, :height_request, 340)

        set_gtk_property!(parEstDataView, :enable_grid_lines, 3)
        set_gtk_property!(parEstDataView, :expand, true)

        parEstGridData[1,1] = parEstDataView
        push!(parEstWinFrameData, parEstWinDataScroll)
        parEstFrame1Grid[1:2,2] = parEstWinFrameData
        showall(parEstWin)

        visible(parEstFrame2Grid, false)
        set_gtk_property!(parEstLoad, :sensitive, true)
        set_gtk_property!(parEstClearData, :sensitive, false)
        set_gtk_property!(parEstReport, :sensitive, false)
    end

    parEstReport = Button("Report")
    
    parEstExport = Button("Export")

    # Signal connect to clear plot
    parEstClearPlot = Button("Clear all")
    signal_connect(parEstClearPlot, :clicked) do widget
    end

    parEstClearModel = Button("Clear")
    signal_connect(parEstClearModel, :clicked) do widget
        global parEstWinFrameModel

        Gtk.@sigatom set_gtk_property!(parEstComboBox, :active, -1)
        set_gtk_property!(parEstInitial, :sensitive, false)

        destroy(parEstWinFrameModel) # Delete treeview to clear data table

        global parEstGridModel = Grid()
        global parEstWinModel = ScrolledWindow(parEstGridModel)

        # Redrawn TreeView after deletion of previous one.
        # Table for data
        global parEstModelList = ListStore(String, Float64, Float64)

        # Visual table
        global parEstModelView = TreeView(TreeModel(parEstModelList))
        set_gtk_property!(parEstModelView, :reorderable, true)
        set_gtk_property!(parEstModelView, :hover_selection, true)

        # Set selectable
        selmodel2 = G_.selection(parEstModelView)
        set_gtk_property!(parEstModelView, :height_request, 340)

        set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
        set_gtk_property!(parEstModelView, :expand, true)

        parEstGridModel[1,1] = parEstModelView
        push!(parEstWinFrameModel, parEstWinModel)
        parEstFrame3Grid[1:2,2] = parEstWinFrameModel
        set_gtk_property!(parEstReport, :sensitive, false)
        showall(parEstWin)
        visible(parEstFrame2Grid, false)
    end

    parEstInitial = Button("Initial guess")

    ############################################################################
    # Fit button
    ############################################################################
    global fitStatus = 0
    parEstFit = Button("Fit")
    signal_connect(parEstFit, :clicked) do widget
        global p0, fit, yFit, squareR, SSE, idx, parEstData, parEstModel
        global parEstModelList

        xvals[] = parEstData[:,1]
        yvals[] = parEstData[:,2]

        ########################################################################
        # Clear treeview model
        ########################################################################
        global parEstWinFrameModel

        destroy(parEstWinFrameModel) # Delete treeview to clear data table

        global parEstGridModel = Grid()
        global parEstWinModel = ScrolledWindow(parEstGridModel)

        # Redrawn TreeView after deletion of previous one.
        # Table for data
        global parEstModelList = ListStore(String, Float64, Float64)

        # Visual table
        global parEstModelView = TreeView(TreeModel(parEstModelList))
        set_gtk_property!(parEstModelView, :reorderable, true)
        set_gtk_property!(parEstModelView, :hover_selection, true)

        # Set selectable
        selmodel2 = G_.selection(parEstModelView)
        set_gtk_property!(parEstModelView, :height_request, 340)

        set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
        set_gtk_property!(parEstModelView, :expand, true)

        parEstGridModel[1,1] = parEstModelView
        push!(parEstWinFrameModel, parEstWinModel)
        parEstFrame3Grid[1:2,2] = parEstWinFrameModel

        # Define type of cell
        rTxt2 = CellRendererText()

        # Define the source of data
        c11 = TreeViewColumn("Parameter", rTxt2, Dict([("text", 0)]))
        c12 = TreeViewColumn("Value", rTxt2, Dict([("text", 1)]))
        c13 = TreeViewColumn("Initial guess", rTxt2, Dict([("text", 2)]))

        # Allows to select rows
        for c in [c11, c12, c13]
            GAccessor.resizable(c, true)
        end

        push!(parEstModelView, c11, c12, c13)

        ########################################################################
        # Models
        ########################################################################
        # Bertalanffy
        if idx == 0
            # Model definition
            Bertalanffy(t, P) = P[1] .* (1 .- exp.(- P[2] .* (t .- P[3])))
            # Initial values
            p0 = [7000, 2.0, 5]

            global fit = curve_fit(Bertalanffy, xvals[], yvals[], p0)
            global yFit = Bertalanffy(xvals[], fit.param)
        end

        # Btody
        if idx == 1
            # Model definition
            Brody(t, P) = P[1] .* (1 .- P[2] .* exp.(- P[3] .* t))
            # Initial values
            p0 = [80000, 2.0, 5]

            global fit = curve_fit(Brody, xvals[], yvals[], p0)
            global yFit = Brody(xvals[], fit.param)
        end

        # Gompertz
        if idx == 2
            # Model definition
            Gompertz(t, p) = p[1]*exp.(-p[2]*exp.(-p[3]*t))

            # Initial values
            p0 = [31, 2, 0.5]

            global fit = curve_fit(Gompertz, xvals[], yvals[], p0)
            global yFit = Gompertz(xvals[], fit.param)
        end

        # Logistic
        if idx == 3
            # Model definition
            Logistic(t, P) = P[1]./(1 .+ P[2] .* exp.(-P[3] .* t))

            # Initial values
            p0 = [31, 2, 0.5]

            global fit = curve_fit(Logistic, xvals[], yvals[], p0)
            global yFit = Logistic(xvals[], fit.param)
        end

        if idx == 4

        end

        ########################################################################
        # Save data to treeview Model
        ########################################################################
        global SSE = sum(fit.resid.^2)
        global squareR = 1-SSE/sum((yvals[] .- mean(yvals[])).^2)

        # save data to dataframe
        for i=1:size(parEstModel,1)
            global parEstModel.Value[i] = fit.param[i]
        end

        push!(parEstModel, ("SSE", SSE, 0.0))
        push!(parEstModel, ("R^2", squareR, 0.0))

        # Show in treeview
        for i=1:size(parEstModel,1)
            # save to global data
            push!(parEstModelList,
            (parEstModel[i,1],parEstModel[i,2],parEstModel[i,3]))
        end

        set_gtk_property!(parEstReport, :sensitive, true)
        global fitStatus = 1
        runme()
    end

    ############################################################################
    # Plot
    ############################################################################
    function newplot(widget)
        global parEstData
        #random data to plot that gets shifted with every call
        xvals[] = parEstData[:,1]
        yvals[] = parEstData[:,2]
    end

    function mydraw(widget)
        global fitStatus, yFit, labelX, labelY
        ctx = Gtk.getgc(widget)
        ENV["GKS_WSTYPE"] = "142"
        ENV["GKSconid"] = @sprintf("%lu", UInt64(ctx.ptr))

        if fitStatus == 0
            plot(xvals[], yvals[], size=[540,440],"bo",
                xlabel = String(labelX), ylabel = String(labelY))
        end

        if fitStatus == 1
            GR.plot(xvals[], yvals[], size=[540,440],"bo")
            GR.oplot(xvals[], yFit, size=[540,440],
            xlabel = String(labelX), ylabel = String(labelY))
            #title="\$Histogram : \\sigma = \\sqrt {\\mu_2 }\$")
        end
    end
    function on_button_clicked(w)
        newplot(w)
        ctx = Gtk.getgc(canvas)
        draw(canvas)
    end

    function runme()
        #put a canvas for the plot and a button
        global canvas#, parEstFrame1Grid, parEstFrame2Grid
        canvas = Canvas(540, 440)
        parEstFrame2Grid[1,1] = canvas

        canvas.draw = mydraw
        newplot(canvas)
        signal_connect(on_button_clicked, parEstFit, "clicked")
        showall(parEstWin)
    end

    ############################################################################
    # Datasheet Data
    ############################################################################
    global parEstGridData = Grid()
    global parEstWinDataScroll = ScrolledWindow(parEstGridData)

    # Table for data
    global parEstDataList = ListStore(Float64, Float64)

    # Visual table
    global parEstDataView = TreeView(TreeModel(parEstDataList))
    set_gtk_property!(parEstDataView, :reorderable, true)
    set_gtk_property!(parEstDataView, :hover_selection, true)

    # Set selectable
    selmodel1 = G_.selection(parEstDataView)
    set_gtk_property!(parEstDataView, :height_request, 340)

    set_gtk_property!(parEstDataView, :enable_grid_lines, 3)
    set_gtk_property!(parEstDataView, :expand, true)

    parEstGridData[1,1] = parEstDataView
    push!(parEstWinFrameData, parEstWinDataScroll)
    parEstFrame1Grid[1:2,2] = parEstWinFrameData

    ############################################################################
    # Datasheet Model
    ############################################################################
    global parEstGridModel = Grid()
    global parEstWinModel = ScrolledWindow(parEstGridModel)

    # Table for data
    global parEstModelList = ListStore(String, Float64, Float64)

    # Visual table
    global parEstModelView = TreeView(TreeModel(parEstModelList))
    set_gtk_property!(parEstModelView, :reorderable, true)
    set_gtk_property!(parEstModelView, :hover_selection, true)

    # Set selectable
    selmodel2 = G_.selection(parEstModelView)
    set_gtk_property!(parEstModelView, :height_request, 340)

    set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
    set_gtk_property!(parEstModelView, :expand, true)

    parEstGridModel[1,1] = parEstModelView
    push!(parEstWinFrameModel, parEstWinModel)
    parEstFrame3Grid[1:2,2] = parEstWinFrameModel

    ############################################################################
    # ComboBox
    ############################################################################
    parEstComboBox = GtkComboBoxText()
    choices = ["Bertalanffy", "Brody",
               "Gompertz", "Logistic", "Best model"]
    for choice in choices
        push!(parEstComboBox, choice)
    end

    # Lets set the active element to be "0"
    set_gtk_property!(parEstComboBox, :active, -1)

    signal_connect(parEstComboBox, :changed) do widget
        ########################################################################
        # Clear treeview
        ########################################################################
        global parEstWinFrameModel

        destroy(parEstWinFrameModel) # Delete treeview to clear data table

        global parEstGridModel = Grid()
        global parEstWinModel = ScrolledWindow(parEstGridModel)

        # Redrawn TreeView after deletion of previous one.
        # Table for data
        global parEstModelList = ListStore(String, Float64, Float64)

        # Visual table
        global parEstModelView = TreeView(TreeModel(parEstModelList))
        set_gtk_property!(parEstModelView, :reorderable, true)
        set_gtk_property!(parEstModelView, :hover_selection, true)

        # Set selectable
        selmodel2 = G_.selection(parEstModelView)
        set_gtk_property!(parEstModelView, :height_request, 340)

        set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
        set_gtk_property!(parEstModelView, :expand, true)

        parEstGridModel[1,1] = parEstModelView
        push!(parEstWinFrameModel, parEstWinModel)
        parEstFrame3Grid[1:2,2] = parEstWinFrameModel

        # Define type of cell
        rTxt2 = CellRendererText()

        # Define the source of data
        c11 = TreeViewColumn("Parameter", rTxt2, Dict([("text", 0)]))
        c12 = TreeViewColumn("Value", rTxt2, Dict([("text", 1)]))
        c13 = TreeViewColumn("Initial guess", rTxt2, Dict([("text", 2)]))

        # Allows to select rows
        for c in [c11, c12, c13]
            GAccessor.resizable(c, true)
        end

        push!(parEstModelView, c11, c12, c13)

        # get the active index
        global idx = get_gtk_property(parEstComboBox, :active, Int)
        set_gtk_property!(parEstReport, :sensitive, false)

        ########################################################################
        # Initial push! to treeview model
        ########################################################################
        # Bertalanffy
        if idx ==  0
            global parEstModel = DataFrames.DataFrame(Parameter = ["A","K","t0"],
                            Value = [0.0,0.0,0.0], Initial=[0.0,0.0,0.0])
        end

        # Brody
        if idx ==  1
            global parEstModel = DataFrames.DataFrame(Parameter = ["A","B","K"],
                            Value = [0.0,0.0,0.0], Initial=[0.0,0.0,0.0])
        end

        # Gompertz
        if idx ==  2
            parEstModel = DataFrames.DataFrame(Parameter = ["A","B","K"],
                            Value = [0.0,0.0,.0], Initial=[0.0,0.0,0.0])
        end

        # Logistic
        if idx ==  3
            parEstModel = DataFrames.DataFrame(Parameter = ["A","B","K"],
                            Value = [0.0,0.0,0.0], Initial=[0.0,0.0,0.0])
        end

        # Best model
        if idx ==  4

        end

        # push! in treeview
        for i=1:size(parEstModel,1)
            # save to global data
            push!(parEstModelList,
            (parEstModel[i,1],parEstModel[i,2],parEstModel[i,3]))
        end

        set_gtk_property!(parEstClearModel, :sensitive, true)
        set_gtk_property!(parEstInitial, :sensitive, true)
        set_gtk_property!(parEstFit, :sensitive, true)
        showall(parEstWin)
    end

    ############################################################################
    # element location on parEstWin
    ############################################################################
    parEstWinGridM1[1,1] = parEstWinFrame1
    parEstWinGridM1[1,2] = parEstWinFrame3
    parEstWinGridM2[1,1] = parEstWinFrame2
    parEstWinGridM2[1,2] = parEstWinFrame4

    parEstFrame1Grid[1:2,1] = parEstLoad
    parEstFrame1Grid[1:2,3] = parEstClearData

    parEstFrame3Grid[1:2,1] = parEstComboBox
    parEstFrame3Grid[1,3] = parEstInitial
    parEstFrame3Grid[2,3] = parEstClearModel
    parEstFrame3Grid[1:2,4] = parEstFit

    parEstFrame4Grid[1,1] = parEstClearPlot
    parEstFrame4Grid[2,1] = parEstExport
    parEstFrame4Grid[1,2] = parEstReport
    parEstFrame4Grid[2,2] = parEstClose
    parEstFrame4Grid[1:2,3] = parEstExit

    parEstWinGrid0[1,1] = parEstWinGridM1
    parEstWinGrid0[2,1] = parEstWinGridM2

    push!(parEstWinFrame1, parEstFrame1Grid)
    push!(parEstWinFrame2, parEstFrame2Grid)
    push!(parEstWinFrame3, parEstFrame3Grid)
    push!(parEstWinFrame4, parEstFrame4Grid)

    push!(parEstWin, parEstWinGrid0)

    # Initial sensitive status
    set_gtk_property!(parEstFit, :sensitive, false)
    set_gtk_property!(parEstReport, :sensitive, false)
    set_gtk_property!(parEstClearPlot, :sensitive, false)
    set_gtk_property!(parEstInitial, :sensitive, false)
    set_gtk_property!(parEstExport, :sensitive, false)
    set_gtk_property!(parEstClearData, :sensitive, false)
    set_gtk_property!(parEstClearModel, :sensitive, false)

    showall(parEstWin)
end

################################################################################
# Action for button "Documentation"
################################################################################
doc = Button("Documentation")
signal_connect(doc, :clicked) do widget
    cd("C:\\Users\\Kelvyn\\Dropbox\\TecNM-Celaya\\04_Research\\Obj 1\\SimBioReactor.jl\\doc\\")
    DefaultApplication.open("docs.pdf")
    cd("C:\\Users\\Kelvyn\\Dropbox\\TecNM-Celaya\\04_Research\\Obj 1\\SimBioReactor.jl")
end

################################################################################
# Action for button "About"
################################################################################
about = Button("About")

signal_connect(about, :clicked) do widget
    aboutWin = Window()
    set_gtk_property!(aboutWin, :title, "About")
    set_gtk_property!(aboutWin, :window_position, 3)
    set_gtk_property!(aboutWin, :width_request, 100)

    aboutGrid = Grid()
    set_gtk_property!(aboutGrid, :column_spacing, 30)
    set_gtk_property!(aboutGrid, :row_spacing, 30)
    set_gtk_property!(aboutGrid, :margin_bottom, 30)
    set_gtk_property!(aboutGrid, :margin_top, 30)
    set_gtk_property!(aboutGrid, :column_homogeneous, true)
    set_gtk_property!(aboutGrid, :row_homogeneous, false)
    set_gtk_property!(aboutGrid, :margin_left, 30)
    set_gtk_property!(aboutGrid, :margin_right, 30)

    closeAbout = Button("Close")
    signal_connect(closeAbout, :clicked) do widget
        destroy(aboutWin)
    end

    label1 = Label("Hola")
    GAccessor.markup(label1,
    """<b>Dr. Kelvyn B. Sánchez Sánchez</b>
<i>Instituto Tecnológico de Celaya</i>\nkelvyn.baruc@gmail.com""")
    GAccessor.justify(label1, Gtk.GConstants.GtkJustification.CENTER)
    label2 = Label("Hola")
    GAccessor.markup(label2,
    """<b>Dr. Arturo Jimenez Gutierrez</b>
<i>Instituto Tecnológico de Celaya</i>\narturo@iqcelaya.itc.mx""")
    GAccessor.justify(label2, Gtk.GConstants.GtkJustification.CENTER)
    label3 = Label("Hola")
    GAccessor.markup(label3, """Free available at GitHub:
    <a href=\"https://github.com/JuliaChem/SimBioReactor.jl"
    title=\"Clic to download\">https://github.com/JuliaChem/SimBioReactor.jl</a>""")
    GAccessor.justify(label3, Gtk.GConstants.GtkJustification.CENTER)

    aboutGrid[1:3,1] = label1
    aboutGrid[4:6,1] = label2
    aboutGrid[2:5,2] = label3
    aboutGrid[3:4,3] = closeAbout

    push!(aboutWin, aboutGrid)
    showall(aboutWin)
end

################################################################################
# Action for button "Exit"
################################################################################
exit = Button("Exit")
signal_connect(exit, :clicked) do widget
    destroy(mainWin)
end

################################################################################
# Set buttons to mainGrid
################################################################################

mainGrid[1,1] = new
mainGrid[1,2] = open
mainGrid[1,3] = parEst
mainGrid[1,4] = doc
mainGrid[1,5] = about
mainGrid[1,6] = exit

# Set mainGrid to mainWin
push!(mainWin, mainGrid)
showall(mainWin)
