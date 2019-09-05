using Gtk, Gtk.ShortNames, GR, Printf, CSV, LsqFit, Distributions, Mustache
import DataFrames, Plots
import DefaultApplication, Dates
Plots.pyplot()

# Constant variables for canvas
const xvals = Ref(zeros(0))
const yvals = Ref(zeros(0))

# Variable declaration for parEst Plots
canvas = nothing
plotStatus = 0
parEstStatus = 0

function SimBioReactorGUI()
    # Environmental variable to allow Windows decorations
    ENV["GTK_CSD"] = 0

    # Create window
    mainWin = Window()
    # sc = Gtk.GAccessor.style_context(mainWin)
    # pr = CssProviderLeaf(data="* {background:white;}")
    # push!(sc, StyleProvider(pr), 600)

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

    ############################################################################
    # Main buttons
    ############################################################################
    # Action for button "New simulation"
    # TODO Simulation
    new = Button("New simulation")
    signal_connect(new, :clicked) do widget
        global newSim = Window()
        set_gtk_property!(newSim, :visible, true)
        set_gtk_property!(newSim, :title, "New simulation - SimBioReactor 1.0")
        set_gtk_property!(newSim, :window_position, 3)
        set_gtk_property!(newSim, :height_request, 600)
        set_gtk_property!(newSim, :width_request, 900)
        set_gtk_property!(newSim, :accept_focus, true)


        # Background color
        # sc_newSim = Gtk.GAccessor.style_context(newSim)
        # pr_newSim = CssProviderLeaf(data="* {background:white;}")
        # push!(sc_newSim, StyleProvider(pr_newSim), 600)

        # Main grid
        newSimWinGrid0 = Grid()
        set_gtk_property!(newSimWinGrid0, :column_homogeneous, false)
        set_gtk_property!(newSimWinGrid0, :row_homogeneous, false)
        set_gtk_property!(newSimWinGrid0, :column_spacing, 10)
        set_gtk_property!(newSimWinGrid0, :row_spacing, 10)
        set_gtk_property!(newSimWinGrid0, :margin_top, 10)
        set_gtk_property!(newSimWinGrid0, :margin_bottom, 10)
        set_gtk_property!(newSimWinGrid0, :margin_left, 10)
        set_gtk_property!(newSimWinGrid0, :margin_right, 10)

        ########################################################################
        # Sub Grids
        ########################################################################
        global newSimWinGridM1 = Grid()
        set_gtk_property!(newSimWinGridM1, :column_homogeneous, false)
        set_gtk_property!(newSimWinGridM1, :row_homogeneous, false)
        set_gtk_property!(newSimWinGridM1, :row_spacing, 10)

        global newSimWinGridM2 = Grid()
        set_gtk_property!(newSimWinGridM2, :column_homogeneous, false)
        set_gtk_property!(newSimWinGridM2, :row_homogeneous, false)
        set_gtk_property!(newSimWinGridM2, :row_spacing, 10)

        ########################################################################
        # Frame Grids
        ########################################################################
        global newSimFrame1Grid = Grid()
        set_gtk_property!(newSimFrame1Grid, :column_homogeneous, true)
        set_gtk_property!(newSimFrame1Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame1Grid, :margin_top, 5)
        set_gtk_property!(newSimFrame1Grid, :margin_bottom, 12)
        set_gtk_property!(newSimFrame1Grid, :margin_left, 40)
        set_gtk_property!(newSimFrame1Grid, :margin_right, 0)

        global newSimFrame2Grid = Grid()
        set_gtk_property!(newSimFrame2Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame2Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame2Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_right, 10)

        global newSimFrame3Grid = Grid()
        set_gtk_property!(newSimFrame3Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame3Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame3Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_right, 10)

        global newSimFrame4Grid = Grid()
        set_gtk_property!(newSimFrame4Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame4Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame4Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_right, 10)

        global newSimFrame5Grid = Grid()
        set_gtk_property!(newSimFrame5Grid, :column_homogeneous, true)
        set_gtk_property!(newSimFrame5Grid, :row_homogeneous, true)
        set_gtk_property!(newSimFrame5Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame5Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_right, 10)

        ########################################################################
        # Frames
        ########################################################################
        global newSimWinFrame1 = Frame("Reactor type")
        set_gtk_property!(newSimWinFrame1, :width_request, 400)
        set_gtk_property!(newSimWinFrame1, :height_request, 54)
        set_gtk_property!(newSimWinFrame1, :label_xalign, 0.50)

        global newSimWinFrame2 = Frame("Input streams")
        set_gtk_property!(newSimWinFrame2, :width_request, 400)
        set_gtk_property!(newSimWinFrame2, :height_request, 170)
        set_gtk_property!(newSimWinFrame2, :label_xalign, 0.50)

        global newSimWinFrame3 = Frame("Kinetic parameters")
        set_gtk_property!(newSimWinFrame3, :width_request, 400)
        set_gtk_property!(newSimWinFrame3, :height_request, 170)
        set_gtk_property!(newSimWinFrame3, :label_xalign, 0.50)

        global newSimWinFrame4 = Frame("Reactor properties")
        set_gtk_property!(newSimWinFrame4, :width_request, 400)
        set_gtk_property!(newSimWinFrame4, :height_request, 170)
        set_gtk_property!(newSimWinFrame4, :label_xalign, 0.50)

        # Frame for input streams treeview
        global newSimWinFrame5 = Frame()
        set_gtk_property!(newSimWinFrame5, :width_request, 220)
        set_gtk_property!(newSimWinFrame5, :height_request, 135)

        # Frame for kinetic parameters treeview
        global newSimWinFrame6 = Frame()
        set_gtk_property!(newSimWinFrame6, :width_request, 220)
        set_gtk_property!(newSimWinFrame6, :height_request, 135)

        # Frame for reactor properties treeview
        global newSimWinFrame7 = Frame()
        set_gtk_property!(newSimWinFrame7, :width_request, 220)
        set_gtk_property!(newSimWinFrame7, :height_request, 135)

        # Frame for canvas graphics
        global newSimWinFrame8 = Frame("Graphics")
        set_gtk_property!(newSimWinFrame8, :width_request, 570)
        set_gtk_property!(newSimWinFrame8, :height_request, 470)
        set_gtk_property!(newSimWinFrame8, :label_xalign, 0.50)

        # Frame for general buttons
        global newSimWinFrame9 = Frame()
        set_gtk_property!(newSimWinFrame9, :width_request, 400)
        set_gtk_property!(newSimWinFrame9, :height_request, 150)

        ########################################################################
        # RadioButtons
        ########################################################################
        global newSimRadio = Vector{RadioButton}(undef, 2)
        newSimRadio[1] = RadioButton("Batch")
        newSimFrame1Grid[1, 1] = newSimRadio[1]
        newSimRadio[2] = RadioButton(newSimRadio[1], "Continuous")
        newSimFrame1Grid[2, 1] = newSimRadio[2]
        set_gtk_property!(newSimRadio[1], :active, true)
        global newSimTRindex = get_gtk_property(newSimRadio[1], :active, Bool)

        signal_connect(newSimRadio[1], :clicked) do widget
            newSimTRindex = get_gtk_property(newSimRadio[1], :active, Bool)

            if newSimTRindex == false
                set_gtk_property!(newSimInputAdd, :sensitive, true)
            else
                set_gtk_property!(newSimInputAdd, :sensitive, false)
            end
        end

        ########################################################################
        # Datasheet Input Streams
        ########################################################################
        global newSimIS = Grid()
        global newSimISScroll = ScrolledWindow(newSimIS)

        # Table for data
        global newSimISList = ListStore(String, Float64)

        # Visual table
        global newSimISView = TreeView(TreeModel(newSimISList))
        set_gtk_property!(newSimISView, :reorderable, true)
        set_gtk_property!(newSimISView, :hover_selection, true)

        # Set selectable
        selmodelIS = G_.selection(newSimISView)
        set_gtk_property!(newSimISView, :height_request, 340)

        set_gtk_property!(newSimISView, :enable_grid_lines, 3)
        set_gtk_property!(newSimISView, :expand, true)

        newSimIS[1, 1] = newSimISView
        push!(newSimWinFrame6, newSimISScroll)

        ########################################################################
        # Datasheet Reactor Properties
        ########################################################################
        global newSimRP = Grid()
        global newSimRPScroll = ScrolledWindow(newSimRP)

        # Table for data
        global newSimRPList = ListStore(String, Float64)

        # Visual table
        global newSimRPView = TreeView(TreeModel(newSimRPList))
        set_gtk_property!(newSimRPView, :reorderable, true)
        set_gtk_property!(newSimRPView, :hover_selection, true)

        # Set selectable
        selmodelRP = G_.selection(newSimRPView)
        set_gtk_property!(newSimRPView, :height_request, 340)

        set_gtk_property!(newSimRPView, :enable_grid_lines, 3)
        set_gtk_property!(newSimRPView, :expand, true)

        newSimRP[1, 1] = newSimRPView
        push!(newSimWinFrame7, newSimRPScroll)

        ########################################################################
        # Datasheet Kinetic Parameters
        ########################################################################
        global newSimKP = Grid()
        global newSimKPScroll = ScrolledWindow(newSimKP)

        # Table for data
        global newSimKPList = ListStore(String, Float64)

        # Visual table
        global newSimKPView = TreeView(TreeModel(newSimKPList))
        set_gtk_property!(newSimKPView, :reorderable, true)
        set_gtk_property!(newSimKPView, :hover_selection, true)

        # Set selectable
        selmodelKP = G_.selection(newSimKPView)
        set_gtk_property!(newSimKPView, :height_request, 340)

        set_gtk_property!(newSimKPView, :enable_grid_lines, 3)
        set_gtk_property!(newSimKPView, :expand, true)

        newSimKP[1, 1] = newSimKPView
        push!(newSimWinFrame5, newSimKPScroll)

        ########################################################################
        # Buttons
        ########################################################################
        # Input streams
        newSimInputAdd = Button("Add")
        set_gtk_property!(newSimInputAdd, :width_request, 150)
        set_gtk_property!(newSimInputAdd, :sensitive, false)
        newSimInputDelete = Button("Delete")
        set_gtk_property!(newSimInputDelete, :width_request, 150)
        newSimInputClear = Button("Clear")
        set_gtk_property!(newSimInputClear, :width_request, 150)

        # Kinetic parameters
        newSimKPLoad = Button("Load")
        set_gtk_property!(newSimKPLoad, :width_request, 150)
        newSimKPEdit = Button("Edit")
        set_gtk_property!(newSimKPEdit, :width_request, 150)
        newSimKPClear = Button("Clear")
        set_gtk_property!(newSimKPClear, :width_request, 150)

        # Reactor properties
        newSimRPAdd = Button("Add")
        set_gtk_property!(newSimRPAdd, :width_request, 150)
        signal_connect(newSimRPAdd, :clicked) do widget
            if newSimTRindex == true
                newSimRPAdddWin = Window()
                set_gtk_property!(newSimRPAdddWin, :title, "Load data")
                set_gtk_property!(newSimRPAdddWin, :window_position, 3)
                set_gtk_property!(newSimRPAdddWin, :width_request, 250)
                set_gtk_property!(newSimRPAdddWin, :height_request, 100)
                set_gtk_property!(newSimRPAdddWin, :accept_focus, true)

                newSimRPAdddWinGrid = Grid()
                set_gtk_property!(newSimRPAdddWinGrid, :margin_top, 40)
                set_gtk_property!(newSimRPAdddWinGrid, :margin_left, 10)
                set_gtk_property!(newSimRPAdddWinGrid, :margin_right, 10)
                set_gtk_property!(newSimRPAdddWinGrid, :margin_bottom, 10)
                set_gtk_property!(newSimRPAdddWinGrid, :column_spacing, 10)
                set_gtk_property!(newSimRPAdddWinGrid, :row_spacing, 10)
                set_gtk_property!(
                    newSimRPAdddWinGrid,
                    :column_homogeneous,
                    true
                )

                newSimRPAdddWinLabel = Entry()
                set_gtk_property!(
                    newSimRPAdddWinLabel,
                    :tooltip_markup,
                    "X label"
                )
                set_gtk_property!(newSimRPAdddWinLabel, :width_request, 150)
                set_gtk_property!(newSimRPAdddWinLabel, :text, "X label")

                newSimRPAddClose = Button("Close")
                signal_connect(newSimRPAddClose, :clicked) do widget
                    destroy(newSimRPAdddWin)
                end

                newSimRPAddSet = Button("Set")
                signal_connect(newSimRPAddSet, :clicked) do widget
                end

                newSimRPAddComboBox = GtkComboBoxText()
                newSimRPAddSetChoices = ["X(0)", "S(0)", "tf"]
                for choice in newSimRPAddSetChoices
                    push!(newSimRPAddComboBox, choice)
                end

                # Lets set the active element to be "0"
                set_gtk_property!(newSimRPAddComboBox, :active, -1)

                newSimRPAdddWinGrid[1:2, 1] = newSimRPAddComboBox
                newSimRPAdddWinGrid[1, 2] = newSimRPAddClose
                newSimRPAdddWinGrid[2, 2] = newSimRPAddSet

                push!(newSimRPAdddWin, newSimRPAdddWinGrid)
                showall(newSimRPAdddWin)
            end
        end


        newSimRPEdit = Button("Edit")
        set_gtk_property!(newSimRPEdit, :width_request, 150)
        newSimRPClear = Button("Clear")
        set_gtk_property!(newSimRPClear, :width_request, 150)


        # Signal connect for exit parameter estimation
        newSimExit = Button("Exit")
        signal_connect(newSimExit, :clicked) do widget
            destroy(newSim)
            destroy(mainWin)
        end

        newSimClose = Button("Close")
        signal_connect(newSimClose, :clicked) do widget
            destroy(newSim)
        end

        newSimRun = Button("Run simulation")

        newSimReport = Button("Report")

        newSimExport = Button("Export")

        # Signal connect to clear plot
        newSimClearPlot = Button("Clear all")
        signal_connect(newSimClearPlot, :clicked) do widget
        end

        # Initial state of buttons
        set_gtk_property!(newSimRun, :sensitive, false)
        set_gtk_property!(newSimReport, :sensitive, false)
        set_gtk_property!(newSimExport, :sensitive, false)
        set_gtk_property!(newSimClearPlot, :sensitive, false)
        set_gtk_property!(newSimInputDelete, :sensitive, false)
        set_gtk_property!(newSimInputClear, :sensitive, false)
        set_gtk_property!(newSimKPEdit, :sensitive, false)
        set_gtk_property!(newSimKPClear, :sensitive, false)
        set_gtk_property!(newSimRPEdit, :sensitive, false)
        set_gtk_property!(newSimRPClear, :sensitive, false)

        ########################################################################
        # Element location
        ########################################################################

        newSimWinGrid0[1, 1] = newSimWinGridM1
        newSimWinGrid0[2, 1] = newSimWinGridM2

        newSimWinGridM1[1, 1] = newSimWinFrame1
        newSimWinGridM1[1, 2] = newSimWinFrame2
        newSimWinGridM1[1, 3] = newSimWinFrame3
        newSimWinGridM1[1, 4] = newSimWinFrame4

        newSimWinGridM2[1, 1] = newSimWinFrame8
        newSimWinGridM2[1, 2] = newSimWinFrame9

        newSimFrame2Grid[1, 1:3] = newSimWinFrame5
        newSimFrame2Grid[2, 1] = newSimInputAdd
        newSimFrame2Grid[2, 2] = newSimInputDelete
        newSimFrame2Grid[2, 3] = newSimInputClear

        newSimFrame3Grid[1, 1:3] = newSimWinFrame6
        newSimFrame3Grid[2, 1] = newSimKPLoad
        newSimFrame3Grid[2, 2] = newSimKPEdit
        newSimFrame3Grid[2, 3] = newSimKPClear

        newSimFrame4Grid[1, 1:3] = newSimWinFrame7
        newSimFrame4Grid[2, 1] = newSimRPAdd
        newSimFrame4Grid[2, 2] = newSimRPEdit
        newSimFrame4Grid[2, 3] = newSimRPClear

        newSimFrame5Grid[1, 1] = newSimRun
        newSimFrame5Grid[1, 2] = newSimClearPlot
        newSimFrame5Grid[2, 1] = newSimExport
        newSimFrame5Grid[2, 2] = newSimReport
        newSimFrame5Grid[1, 3] = newSimClose
        newSimFrame5Grid[2, 3] = newSimExit

        push!(newSimWinFrame1, newSimFrame1Grid)
        push!(newSimWinFrame2, newSimFrame2Grid)
        push!(newSimWinFrame3, newSimFrame3Grid)
        push!(newSimWinFrame4, newSimFrame4Grid)
        push!(newSimWinFrame9, newSimFrame5Grid)

        push!(newSim, newSimWinGrid0)
        showall(newSim)
    end

    ############################################################################
    # Action for button "Open simulation"
    ############################################################################
    open = Button("Open simulation")

    ############################################################################
    # Action for button "Parameter Estimation"
    ############################################################################
    parEst = Button("Parameter estimation")
    signal_connect(parEst, :clicked) do widget

        if parEstStatus == 0
            global parEstWin = Window()
            global parEstStatus = 1
            set_gtk_property!(parEstWin, :visible, true)
            set_gtk_property!(
                parEstWin,
                :title,
                "Parameter Estimation - SimBioReactor 1.0"
            )
            set_gtk_property!(parEstWin, :window_position, 3)
            set_gtk_property!(parEstWin, :height_request, 600)
            set_gtk_property!(parEstWin, :width_request, 900)
            set_gtk_property!(parEstWin, :accept_focus, true)

            # Background color
            # sc_estPar = Gtk.GAccessor.style_context(parEstWin)
            # pr_estPar = CssProviderLeaf(data="* {background:white;}")
            # push!(sc_estPar, StyleProvider(pr_estPar), 600)

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

            ####################################################################
            # Sub Grids
            ####################################################################
            global parEstWinGridM1 = Grid()
            set_gtk_property!(parEstWinGridM1, :column_homogeneous, false)
            set_gtk_property!(parEstWinGridM1, :row_homogeneous, false)
            set_gtk_property!(parEstWinGridM1, :row_spacing, 10)

            global parEstWinGridM2 = Grid()
            set_gtk_property!(parEstWinGridM2, :column_homogeneous, false)
            set_gtk_property!(parEstWinGridM2, :row_homogeneous, false)
            set_gtk_property!(parEstWinGridM2, :row_spacing, 10)

            ####################################################################
            # Frame Grids
            ####################################################################
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

            ####################################################################
            # Frames
            ####################################################################
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

            ####################################################################
            # Buttons
            ####################################################################
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
                    dlg = open_dialog_native(
                        "Choose file...",
                        parEstLoadWin,
                        ("*.txt, *.csv",),
                        select_multiple = false
                    )

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

                    global c1 = TreeViewColumn(
                        String(labelX),
                        rTxt1,
                        Dict([("text", 0)])
                    )
                    global c2 = TreeViewColumn(
                        String(labelY),
                        rTxt1,
                        Dict([("text", 1)])
                    )

                        # Allows to select rows
                    for c in [c1, c2]
                        GAccessor.resizable(c, true)
                    end

                    push!(parEstDataView, c1, c2)

                    global parEstData = DataFrames.DataFrame()

                    data = CSV.read(dlg, datarow = 1)
                    parEstData[!, Symbol(labelX)] = data[:, 1]
                    parEstData[!, Symbol(labelY)] = data[:, 2]

                        # save to global data
                    for i = 1:size(data, 1)
                        push!(parEstDataList, (data[i, 1], data[i, 2]))
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

                parEstGridLoad[1:2, 1] = parEstGridLoad2
                parEstGridLoad2[1, 1] = parEstLabelX
                parEstGridLoad2[1, 2] = parEstLabelY
                parEstGridLoad2[2, 1:2] = parEstBrowseData
                parEstGridLoad[1, 2] = parEstCancelData
                parEstGridLoad[2, 2] = parEstAdd2Data

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
                global parEstWinFrameData
                global parEstWinFrameData

                # Delete treeview to clear data table
                destroy(parEstWinFrameData)

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

                parEstGridData[1, 1] = parEstDataView
                push!(parEstWinFrameData, parEstWinDataScroll)
                parEstFrame1Grid[1:2, 2] = parEstWinFrameData
                #showall(parEstWin)

                visible(parEstFrame2Grid, false)
                set_gtk_property!(parEstLoad, :sensitive, true)
                set_gtk_property!(parEstClearData, :sensitive, false)
                set_gtk_property!(parEstReport, :sensitive, false)

                global parEstWinFrameModel

                Gtk.@sigatom set_gtk_property!(parEstComboBox, :active, -1)
                set_gtk_property!(parEstInitial, :sensitive, false)

                # Delete treeview to clear data table
                destroy(parEstWinFrameModel)

                global parEstGridModel = Grid()
                global parEstWinModel = ScrolledWindow(parEstGridModel)

                # Redrawn TreeView after deletion of previous one.
                # Table for data
                global parEstModelList = ListStore(String, Float64, Float64)

                # Visual table
                global parEstModelView = TreeView(TreeModel(parEstModelList))
                set_gtk_property!(parEstModelView, :reorderable, true)

                # Set selectable
                parEstModelSel = G_.selection(parEstModelView)
                set_gtk_property!(parEstModelView, :height_request, 340)

                set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
                set_gtk_property!(parEstModelView, :expand, true)

                parEstGridModel[1, 1] = parEstModelView
                push!(parEstWinFrameModel, parEstWinModel)
                parEstFrame3Grid[1:2, 2] = parEstWinFrameModel
                set_gtk_property!(parEstReport, :sensitive, false)
                set_gtk_property!(parEstClearData, :sensitive, false)
                set_gtk_property!(parEstReport, :sensitive, false)
                set_gtk_property!(parEstExport, :sensitive, false)
                set_gtk_property!(parEstClearPlot, :sensitive, false)
                showall(parEstWin)
                visible(parEstFrame2Grid, false)
                visible(parEstWin, false)
            end

            # Signal connect to clear de listdata
            parEstClearData = Button("Clear")
            signal_connect(parEstClearData, "clicked") do widget
                global parEstWinFrameData

                # Delete treeview to clear data table
                destroy(parEstWinFrameData)

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

                parEstGridData[1, 1] = parEstDataView
                push!(parEstWinFrameData, parEstWinDataScroll)
                parEstFrame1Grid[1:2, 2] = parEstWinFrameData
                showall(parEstWin)

                visible(parEstFrame2Grid, false)
                set_gtk_property!(parEstLoad, :sensitive, true)
                set_gtk_property!(parEstClearData, :sensitive, false)
                set_gtk_property!(parEstReport, :sensitive, false)
            end

            # Report for Parameter Estimation
            parEstReport = Button("Report")
            signal_connect(parEstReport, :clicked) do widget
                global parEstModel, modelName, parEstData, fitStatus
                global yFit, labelX, labelY
            #df = DataFrame(label=1:4, score=200:100:500, max=4:7)
                fmt = string("|", repeat("c|", size(parEstModel, 2)))
                row = join(
                    ["{{:$x}}" for x in map(string, names(parEstModel))],
                    " & "
                )
                header = join(string.(names(parEstModel)), " & ")

            # Time for report
                timenow = Dates.now()
                timenow1 = Dates.format(timenow, "dd u yyyy HH:MM:SS")

            # Plot using Plots and PyPlot Backend
                xvals[] = parEstData[:, 1]
                yvals[] = parEstData[:, 2]

                global plt1 = Plots.scatter(
                    xvals[],
                    yvals[],
                    xlabel = labelX,
                    ylabel = labelY,
                    label = "Experimental Data"
                )

                Plots.plot!(
                    xvals[],
                    yFit,
                    framestyle = :box,
                    label = "Predicted Data"
                )
                Plots.savefig(
                    plt1,
                    string("C:\\Windows\\Temp\\", "parEstFigReport.png")
                )


                marks_tmpl = """
                \\documentclass{article}
                \\usepackage{graphicx}
                \\graphicspath{ {C:/Windows/Temp/} }
                \\usepackage[letterpaper, portrait, margin=1in]{geometry}
                \\begin{document}
                \\begin{center}
                \\Huge{\\textbf{SimBioReactor v1.0}}\\\\
                \\vspace{2mm}
                \\large{\\textbf{Parameter Estimation}}\\break
                \\normalsize{{:time}}\n
                \\vspace{5mm}
                \\rule{15cm}{0.05cm}\n\n\n
                \\normalsize{Table 1 presents the parameters estimated by using the {{:mN}} model. Figure 1 display the experimental data vs predicted data.}\n
                \\vspace{2mm}
                \\normalsize{Table 1}\n
                  \\vspace{3mm}
                  \\begin{tabular}{$fmt}
                  \\hline
                  $header\\\\
                  \\hline
                    {{#:DF}} $row\\cr
                    {{/:DF}}
                  \\hline\n
                  \\end{tabular}
                  \\vspace{3mm}\n
                \\vspace{3mm}
                \\includegraphics[width=10cm, height=7cm]{parEstFigReport}\n
                \\normalsize{Figure 1}\n
                \\vspace{3mm}\n
                \\rule{15cm}{0.05cm}\n
                \\end{center}
                \\end{document}
                """

                rendered = render(
                    marks_tmpl,
                    time = timenow1,
                    DF = parEstModel,
                    mN = modelName
                )

                filename = string(
                    "C:\\Windows\\Temp\\",
                    "EstimationParameterReport.tex"
                )
                Base.open(filename, "w") do file
                    write(file, rendered)
                end
                run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "EstimationParameterReport.tex"`)
                DefaultApplication.open(string(
                    "C:\\Windows\\Temp\\",
                    "EstimationParameterReport.pdf"
                ))
            end

            parEstExport = Button("Export")
            signal_connect(parEstExport, :clicked) do widget
                global yFit, labelX, labelY, parEstData, userPath
                userPath = save_dialog_native("Save as...", Null(), ("*.png",))


                if isempty(userPath) != true
                # Plot using Plots and PyPlot Backend
                    xvals[] = parEstData[:, 1]
                    yvals[] = parEstData[:, 2]

                    plt2 = Plots.scatter(
                        xvals[],
                        yvals[],
                        xlabel = labelX,
                        ylabel = labelY,
                        label = "Experimental Data"
                    )
                    Plots.plot!(
                        xvals[],
                        yFit,
                        framestyle = :box,
                        label = "Predicted Data"
                    )
                    Plots.savefig(plt2, string(userPath, ".png"))
                end
            end

            # Signal connect to clear plot
            parEstClearPlot = Button("Clear all")
            signal_connect(parEstClearPlot, :clicked) do widget
                global parEstWinFrameData

                # Delete treeview to clear data table
                destroy(parEstWinFrameData)

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

                parEstGridData[1, 1] = parEstDataView
                push!(parEstWinFrameData, parEstWinDataScroll)
                parEstFrame1Grid[1:2, 2] = parEstWinFrameData
                showall(parEstWin)

                visible(parEstFrame2Grid, false)
                set_gtk_property!(parEstLoad, :sensitive, true)
                set_gtk_property!(parEstClearData, :sensitive, false)
                set_gtk_property!(parEstReport, :sensitive, false)
                set_gtk_property!(parEstExport, :sensitive, false)
                set_gtk_property!(parEstClearPlot, :sensitive, false)

                global parEstWinFrameModel

                Gtk.@sigatom set_gtk_property!(parEstComboBox, :active, -1)
                set_gtk_property!(parEstInitial, :sensitive, false)
                set_gtk_property!(parEstClearModel, :sensitive, false)

                # Delete treeview to clear data table model
                destroy(parEstWinFrameModel)

                global parEstGridModel = Grid()
                global parEstWinModel = ScrolledWindow(parEstGridModel)

                # Redrawn TreeView after deletion of previous one.
                # Table for data
                global parEstModelList = ListStore(String, Float64, Float64)

                # Visual table
                global parEstModelView = TreeView(TreeModel(parEstModelList))
                set_gtk_property!(parEstModelView, :reorderable, true)

                # Set selectable
                parEstModelSel = G_.selection(parEstModelView)
                set_gtk_property!(parEstModelView, :height_request, 340)

                set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
                set_gtk_property!(parEstModelView, :expand, true)

                parEstGridModel[1, 1] = parEstModelView
                push!(parEstWinFrameModel, parEstWinModel)
                parEstFrame3Grid[1:2, 2] = parEstWinFrameModel
                showall(parEstWin)
                visible(parEstFrame2Grid, false)
            end

            parEstClearModel = Button("Clear")
            signal_connect(parEstClearModel, :clicked) do widget
                global parEstWinFrameModel

                Gtk.@sigatom set_gtk_property!(parEstComboBox, :active, -1)
                set_gtk_property!(parEstInitial, :sensitive, false)

                # Delete treeview to clear data table
                destroy(parEstWinFrameModel)

                global parEstGridModel = Grid()
                global parEstWinModel = ScrolledWindow(parEstGridModel)

                # Redrawn TreeView after deletion of previous one.
                # Table for data
                global parEstModelList = ListStore(String, Float64, Float64)

                # Visual table
                global parEstModelView = TreeView(TreeModel(parEstModelList))
                set_gtk_property!(parEstModelView, :reorderable, true)

                # Set selectable
                parEstModelSel = G_.selection(parEstModelView)
                set_gtk_property!(parEstModelView, :height_request, 340)

                set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
                set_gtk_property!(parEstModelView, :expand, true)

                parEstGridModel[1, 1] = parEstModelView
                push!(parEstWinFrameModel, parEstWinModel)
                parEstFrame3Grid[1:2, 2] = parEstWinFrameModel
                set_gtk_property!(parEstReport, :sensitive, false)
                showall(parEstWin)
                visible(parEstFrame2Grid, false)
            end

            parEstInitial = Button("Initial guess")
            signal_connect(parEstInitial, :clicked) do widget
                global parEstModelSel, parEstModelList

                if hasselection(parEstModelSel)
                    parEstInitialWin = Window()
                    set_gtk_property!(parEstInitialWin, :title, "Initial guess")
                    set_gtk_property!(parEstInitialWin, :window_position, 3)
                    set_gtk_property!(parEstInitialWin, :width_request, 100)
                    set_gtk_property!(parEstInitialWin, :height_request, 70)
                    set_gtk_property!(parEstInitialWin, :accept_focus, true)

                    parEstInitialWinGrid = Grid()
                    set_gtk_property!(parEstInitialWinGrid, :margin_top, 25)
                    set_gtk_property!(parEstInitialWinGrid, :margin_left, 10)
                    set_gtk_property!(parEstInitialWinGrid, :margin_right, 10)
                    set_gtk_property!(parEstInitialWinGrid, :margin_bottom, 10)
                    set_gtk_property!(parEstInitialWinGrid, :column_spacing, 10)
                    set_gtk_property!(parEstInitialWinGrid, :row_spacing, 10)
                    set_gtk_property!(parEstInitialWinGrid, :column_homogeneous, true)

                    parEstInitialEntry = Entry()
                    set_gtk_property!(parEstInitialEntry, :tooltip_markup, "Enter value")
                    set_gtk_property!(parEstInitialEntry, :width_request, 80)
                    set_gtk_property!(parEstInitialEntry, :text, "")

                    parEstInitialLabel = Label("")
                    global parEstInitialIndex = Gtk.index_from_iter(parEstModelList,
                                            selected(parEstModelSel))
                    set_gtk_property!(
                    parEstInitialLabel, :label,
                    string("Parameter ", parEstModel[parEstInitialIndex,1], " ="))

                    parEstInitialWinClose = Button("Close")
                    signal_connect(parEstInitialWinClose, :clicked) do widget
                        destroy(parEstInitialWin)
                    end

                    parEstInitialSet = Button("Set")
                    signal_connect(parEstInitialSet, :clicked) do widget
                        global parEstModel, parEstModelList, parEstInitialIndex
                        # Check for non a number
                        try
                            global newPar
                            newPar = get_gtk_property(parEstInitialEntry, :text, String)
                            numNewPar = parse(Float64, newPar)
                            idx = parEstInitialIndex
                            parEstModel[idx,3] = numNewPar

                            for i=1:3
                                parEstModelList[idx, i] = parEstModel[idx,i]
                            end

                            destroy(parEstInitialWin)
                        catch
                            warn_dialog("Please write a number", parEstInitialWin)
                            set_gtk_property!(parEstInitialEntry, :text, "")
                        end
                    end

                    signal_connect(parEstInitialWin, "key-press-event") do widget, event
                        global parEstModel, parEstModelList, parEstInitialIndex
                        if event.keyval == 65293
                            # Check for non a number
                            try
                                global newPar
                                newPar = get_gtk_property(parEstInitialEntry, :text, String)
                                numNewPar = parse(Float64, newPar)
                                idx = parEstInitialIndex
                                parEstModel[idx,3] = numNewPar

                                for i=1:3
                                    parEstModelList[idx, i] = parEstModel[idx,i]
                                end

                                destroy(parEstInitialWin)
                            catch
                                warn_dialog("Please write a number", parEstInitialWin)
                                set_gtk_property!(parEstInitialEntry, :text, "")
                            end
                        end
                    end

                    parEstInitialWinGrid[1, 1] = parEstInitialLabel
                    parEstInitialWinGrid[1, 2] = parEstInitialEntry
                    parEstInitialWinGrid[1, 4] = parEstInitialWinClose
                    parEstInitialWinGrid[1, 3] = parEstInitialSet

                    push!(parEstInitialWin, parEstInitialWinGrid)
                    showall(parEstInitialWin)
                else
                    warn_dialog("Please select a parameter!", parEstWin)
                end
            end

            ####################################################################
            # Fit button
            ####################################################################
            global fitStatus = 0
            parEstFit = Button("Fit")
            signal_connect(parEstFit, :clicked) do widget
                global p0, fit, yFit, squareR, SSE, idx, parEstData, parEstModel
                global parEstModelList

                xvals[] = parEstData[:, 1]
                yvals[] = parEstData[:, 2]

                ################################################################
                # Clear treeview model
                ################################################################
                global parEstWinFrameModel

                # Delete treeview to clear data table
                destroy(parEstWinFrameModel)

                global parEstGridModel = Grid()
                global parEstWinModel = ScrolledWindow(parEstGridModel)

                # Redrawn TreeView after deletion of previous one.
                # Table for data
                global parEstModelList = ListStore(String, Float64, Float64)

                # Visual table
                global parEstModelView = TreeView(TreeModel(parEstModelList))
                set_gtk_property!(parEstModelView, :reorderable, true)

                # Set selectable
                global parEstModelSel = G_.selection(parEstModelView)
                set_gtk_property!(parEstModelView, :height_request, 340)

                set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
                set_gtk_property!(parEstModelView, :expand, true)

                parEstGridModel[1, 1] = parEstModelView
                push!(parEstWinFrameModel, parEstWinModel)
                parEstFrame3Grid[1:2, 2] = parEstWinFrameModel

                # Define type of cell
                rTxt2 = CellRendererText()

                # Define the source of data
                c11 = TreeViewColumn("Parameter", rTxt2, Dict([("text", 0)]))
                c12 = TreeViewColumn("Value", rTxt2, Dict([("text", 1)]))
                c13 = TreeViewColumn(
                    "Initial guess",
                    rTxt2,
                    Dict([("text", 2)])
                )

                # Allows to select rows
                for c in [c11, c12, c13]
                    GAccessor.resizable(c, true)
                end

                push!(parEstModelView, c11, c12, c13)

                ################################################################
                # Models
                ################################################################
                # Bertalanffy
                if idx == 0
                    # Model definition
                    Bertalanffy(t, P) =
                        P[1] .* (1 .- exp.(-P[2] .* (t .- P[3])))
                        # Initial values
                    p0 = [7000, 2.0, 5]
                    global modelName = "Bertalanffy"
                    global fit = curve_fit(Bertalanffy, xvals[], yvals[], p0)
                    global yFit = Bertalanffy(xvals[], fit.param)
                end

                # Brody
                if idx == 1
                    # Model definition
                    Brody(t, P) = P[1] .* (1 .- P[2] .* exp.(-P[3] .* t))
                    # Initial values
                    p0 = [80000, 2.0, 5]
                    global modelName = "Brody"
                    global fit = curve_fit(Brody, xvals[], yvals[], p0)
                    global yFit = Brody(xvals[], fit.param)
                end

                # Gompertz
                if idx == 2
                    # Model definition
                    Gompertz(t, p) = p[1] * exp.(-p[2] * exp.(-p[3] * t))

                    # Initial values
                    p0 = [31, 2, 0.5]
                    global modelName = "Gompertz"
                    global fit = curve_fit(Gompertz, xvals[], yvals[], p0)
                    global yFit = Gompertz(xvals[], fit.param)
                end

                # Logistic
                if idx == 3
                    # Model definition
                    Logistic(t, P) = P[1] ./ (1 .+ P[2] .* exp.(-P[3] .* t))

                    # Initial values
                    p0 = [31, 2, 0.5]
                    global modelName = "Logistic"
                    global fit = curve_fit(Logistic, xvals[], yvals[], p0)
                    global yFit = Logistic(xvals[], fit.param)
                end

                if idx == 4

                end

                ################################################################
                # Save data to treeview Model
                ################################################################
                global SSE = sum(fit.resid.^2)
                global squareR = 1 - SSE / sum((yvals[] .- mean(yvals[])).^2)

                # save data to dataframe
                for i = 1:size(parEstModel, 1)
                    global parEstModel.Value[i] = fit.param[i]
                end

                push!(parEstModel, ("SSE", SSE, 0.0))
                push!(parEstModel, ("Corr", squareR, 0.0))

                # Show in treeview
                for i = 1:size(parEstModel, 1)
                    # save to global data
                    push!(
                        parEstModelList,
                        (
                         parEstModel[i, 1],
                         parEstModel[i, 2],
                         parEstModel[i, 3]
                        )
                    )
                end

                set_gtk_property!(parEstReport, :sensitive, true)
                global fitStatus = 1
                runme()

                set_gtk_property!(parEstClearPlot, :sensitive, true)
                set_gtk_property!(parEstReport, :sensitive, true)
                set_gtk_property!(parEstExport, :sensitive, true)
            end

            ####################################################################
            # Plot
            ####################################################################
            function newplot(widget)
                global parEstData
                xvals[] = parEstData[:, 1]
                yvals[] = parEstData[:, 2]
            end

            function mydraw(widget)
                global fitStatus, yFit, labelX, labelY
                ctx = Gtk.getgc(widget)
                ENV["GKS_WSTYPE"] = "142"
                ENV["GKSconid"] = @sprintf("%lu", UInt64(ctx.ptr))

                if fitStatus == 0
                    plot(
                        xvals[],
                        yvals[],
                        size = [540, 440],
                        "bo",
                        xlabel = String(labelX),
                        ylabel = String(labelY)
                    )
                end

                if fitStatus == 1
                    GR.plot(xvals[], yvals[], size = [540, 440], "bo")
                    GR.oplot(
                        xvals[],
                        yFit,
                        size = [540, 440],
                        xlabel = String(labelX),
                        ylabel = String(labelY)
                    )
                end
            end

            function on_button_clicked(w)
                newplot(w)
                ctx = Gtk.getgc(canvas)
                draw(canvas)
            end

            function runme()
                global canvas
                canvas = Canvas(540, 440)

                parEstFrame2Grid[1, 1] = canvas

                canvas.draw = mydraw
                newplot(canvas)
                signal_connect(on_button_clicked, parEstFit, "clicked")
                showall(parEstWin)
            end

            ####################################################################
            # Datasheet Data
            ####################################################################
            global parEstGridData = Grid()
            global parEstWinDataScroll = ScrolledWindow(parEstGridData)

            # Table for data
            global parEstDataList = ListStore(Float64, Float64)

            # Visual table
            global parEstDataView = TreeView(TreeModel(parEstDataList))
            set_gtk_property!(parEstDataView, :reorderable, true)

            # Set selectable
            selmodel1 = G_.selection(parEstDataView)
            set_gtk_property!(parEstDataView, :height_request, 340)

            set_gtk_property!(parEstDataView, :enable_grid_lines, 3)
            set_gtk_property!(parEstDataView, :expand, true)

            parEstGridData[1, 1] = parEstDataView
            push!(parEstWinFrameData, parEstWinDataScroll)
            parEstFrame1Grid[1:2, 2] = parEstWinFrameData

            ####################################################################
            # Datasheet Model
            ####################################################################
            global parEstGridModel = Grid()
            global parEstWinModel = ScrolledWindow(parEstGridModel)

            # Table for data
            global parEstModelList = ListStore(String, Float64, Float64)

            # Visual table
            global parEstModelView = TreeView(TreeModel(parEstModelList))
            set_gtk_property!(parEstModelView, :reorderable, true)

            # Set selectable
            global parEstModelSel = G_.selection(parEstModelView)
            set_gtk_property!(parEstModelView, :height_request, 340)

            set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
            set_gtk_property!(parEstModelView, :expand, true)

            parEstGridModel[1, 1] = parEstModelView
            push!(parEstWinFrameModel, parEstWinModel)
            parEstFrame3Grid[1:2, 2] = parEstWinFrameModel

            ####################################################################
            # ComboBox
            ####################################################################
            parEstComboBox = GtkComboBoxText()
            choices = [
                "Bertalanffy",
                "Brody",
                "Gompertz",
                "Logistic",
                "Best model"
            ]
            for choice in choices
                push!(parEstComboBox, choice)
            end

            # Lets set the active element to be "0"
            set_gtk_property!(parEstComboBox, :active, -1)

            signal_connect(parEstComboBox, :changed) do widget
                ################################################################
                # Clear treeview
                ################################################################
                global parEstWinFrameModel

                # Delete treeview to clear data table
                destroy(parEstWinFrameModel)

                global parEstGridModel = Grid()
                global parEstWinModel = ScrolledWindow(parEstGridModel)

                # Redrawn TreeView after deletion of previous one.
                # Table for data
                global parEstModelList = ListStore(String, Float64, Float64)

                # Visual table
                global parEstModelView = TreeView(TreeModel(parEstModelList))
                set_gtk_property!(parEstModelView, :reorderable, true)

                # Set selectable
                parEstModelSel = G_.selection(parEstModelView)
                set_gtk_property!(parEstModelView, :height_request, 340)

                set_gtk_property!(parEstModelView, :enable_grid_lines, 3)
                set_gtk_property!(parEstModelView, :expand, true)

                parEstGridModel[1, 1] = parEstModelView
                push!(parEstWinFrameModel, parEstWinModel)
                parEstFrame3Grid[1:2, 2] = parEstWinFrameModel

                # Define type of cell
                rTxt2 = CellRendererText()

                # Define the source of data
                c11 = TreeViewColumn("Parameter", rTxt2, Dict([("text", 0)]))
                c12 = TreeViewColumn("Value", rTxt2, Dict([("text", 1)]))
                c13 = TreeViewColumn(
                    "Initial guess",
                    rTxt2,
                    Dict([("text", 2)])
                )

                # Allows to select rows
                for c in [c11, c12, c13]
                    GAccessor.resizable(c, true)
                end

                push!(parEstModelView, c11, c12, c13)

                # get the active index
                global idx = get_gtk_property(parEstComboBox, :active, Int)
                set_gtk_property!(parEstReport, :sensitive, false)

                ################################################################
                # Initial push! to treeview model
                ################################################################
                # Bertalanffy
                if idx == 0
                    global parEstModel = DataFrames.DataFrame(
                        Parameter = ["A", "K", "t0"],
                        Value = [0.0, 0.0, 0.0],
                        Initial = [0.0, 0.0, 0.0]
                    )
                end

                # Brody
                if idx == 1
                    global parEstModel = DataFrames.DataFrame(
                        Parameter = ["A", "B", "K"],
                        Value = [0.0, 0.0, 0.0],
                        Initial = [0.0, 0.0, 0.0]
                    )
                end

                # Gompertz
                if idx == 2
                    parEstModel = DataFrames.DataFrame(
                        Parameter = ["A", "B", "K"],
                        Value = [0.0, 0.0, .0],
                        Initial = [0.0, 0.0, 0.0]
                    )
                end

                # Logistic
                if idx == 3
                    parEstModel = DataFrames.DataFrame(
                        Parameter = ["A", "B", "K"],
                        Value = [0.0, 0.0, 0.0],
                        Initial = [0.0, 0.0, 0.0]
                    )
                end

                # Best model
                if idx == 4

                end

                # push! in treeview
                for i = 1:size(parEstModel, 1)
                    # save to global data
                    push!(
                        parEstModelList,
                        (
                         parEstModel[i, 1],
                         parEstModel[i, 2],
                         parEstModel[i, 3]
                        )
                    )
                end

                set_gtk_property!(parEstClearModel, :sensitive, true)
                set_gtk_property!(parEstInitial, :sensitive, true)
                set_gtk_property!(parEstFit, :sensitive, true)
                showall(parEstWin)
            end

            ####################################################################
            # element location on parEstWin
            ####################################################################
            parEstWinGridM1[1, 1] = parEstWinFrame1
            parEstWinGridM1[1, 2] = parEstWinFrame3
            parEstWinGridM2[1, 1] = parEstWinFrame2
            parEstWinGridM2[1, 2] = parEstWinFrame4

            parEstFrame1Grid[1, 3] = parEstLoad
            parEstFrame1Grid[2, 3] = parEstClearData

            parEstFrame3Grid[1:2, 1] = parEstComboBox
            parEstFrame3Grid[1, 3] = parEstInitial
            parEstFrame3Grid[2, 3] = parEstClearModel
            parEstFrame3Grid[1:2, 4] = parEstFit

            parEstFrame4Grid[1, 1] = parEstClearPlot
            parEstFrame4Grid[2, 1] = parEstExport
            parEstFrame4Grid[1, 2] = parEstReport
            parEstFrame4Grid[2, 2] = parEstClose
            parEstFrame4Grid[1:2, 3] = parEstExit

            parEstWinGrid0[1, 1] = parEstWinGridM1
            parEstWinGrid0[2, 1] = parEstWinGridM2

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
            signal_connect(parEstWin, "delete-event") do widget, event
                ccall(
                    (:gtk_widget_hide_on_delete, Gtk.libgtk),
                    Bool,
                    (Ptr{GObject},),
                    parEstWin
                )
            end
        else
            visible(parEstWin, true)
        end
    end

    ############################################################################
    # Action for button "Documentation"
    ############################################################################
    doc = Button("Documentation")
    signal_connect(doc, :clicked) do widget
        cd("C:\\Users\\Kelvyn\\Dropbox\\TecNM-Celaya\\04_Research\\Obj 1\\SimBioReactor.jl\\doc\\")
        DefaultApplication.open("docs.pdf")
        cd("C:\\Users\\Kelvyn\\Dropbox\\TecNM-Celaya\\04_Research\\Obj 1\\SimBioReactor.jl")
    end

    ############################################################################
    # Action for button "About"
    ############################################################################
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
        GAccessor.markup(
            label1,
            """<b>Dr. Kelvyn B. Sánchez Sánchez</b>
<i>Instituto Tecnológico de Celaya</i>\nkelvyn.baruc@gmail.com"""
        )

        GAccessor.justify(label1, Gtk.GConstants.GtkJustification.CENTER)
        label2 = Label("Hola")
        GAccessor.markup(
            label2,
            """<b>Dr. Arturo Jimenez Gutierrez</b>
<i>Instituto Tecnológico de Celaya</i>\narturo@iqcelaya.itc.mx"""
        )

        GAccessor.justify(label2, Gtk.GConstants.GtkJustification.CENTER)
        label3 = Label("Hola")
        GAccessor.markup(
            label3,
            """Free available at GitHub:
<a href=\"https://github.com/JuliaChem/SimBioReactor.jl"
title=\"Clic to download\">https://github.com/JuliaChem/SimBioReactor.jl</a>"""
        )
        GAccessor.justify(label3, Gtk.GConstants.GtkJustification.CENTER)

        aboutGrid[1:3,1] = label1
        aboutGrid[4:6,1] = label2
        aboutGrid[2:5,2] = label3
        aboutGrid[3:4,3] = closeAbout

        push!(aboutWin, aboutGrid)
        showall(aboutWin)
    end

    ############################################################################
    # Action for button "Exit"
    ############################################################################
    exit = Button("Exit")
    signal_connect(exit, :clicked) do widget
        destroy(mainWin)
    end

    ############################################################################
    # Set buttons to mainGrid
    ############################################################################

    mainGrid[1,1] = new
    mainGrid[1,2] = open
    mainGrid[1,3] = parEst
    mainGrid[1,4] = doc
    mainGrid[1,5] = about
    mainGrid[1,6] = exit

    # Set mainGrid to mainWin
    push!(mainWin, mainGrid)
    showall(mainWin)
end
