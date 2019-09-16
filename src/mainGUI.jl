using Gtk, Gtk.ShortNames, GR, Printf, CSV, LsqFit, Distributions, Mustache
using DifferentialEquations
import DataFrames, Plots
import DefaultApplication, Dates
Plots.pyplot()

# Constant variables for canvas
const xvals = Ref(zeros(0))
const yvals = Ref(zeros(0))

# Variable declaration for parEst Plots
canvas = nothing
newSimCanvas = nothing
newSimPlotStatus = 0
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
        # Left
        global newSimWinGridM1 = Grid()
        set_gtk_property!(newSimWinGridM1, :column_homogeneous, false)
        set_gtk_property!(newSimWinGridM1, :row_homogeneous, false)
        set_gtk_property!(newSimWinGridM1, :row_spacing, 10)

        # Right
        global newSimWinGridM2 = Grid()
        set_gtk_property!(newSimWinGridM2, :column_homogeneous, false)
        set_gtk_property!(newSimWinGridM2, :row_homogeneous, false)
        set_gtk_property!(newSimWinGridM2, :row_spacing, 10)

        ########################################################################
        # Frame Grids
        ########################################################################
        # TR
        global newSimFrame1Grid = Grid()
        set_gtk_property!(newSimFrame1Grid, :column_homogeneous, true)
        set_gtk_property!(newSimFrame1Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame1Grid, :margin_top, 5)
        set_gtk_property!(newSimFrame1Grid, :margin_bottom, 12)
        set_gtk_property!(newSimFrame1Grid, :margin_left, 40)
        set_gtk_property!(newSimFrame1Grid, :margin_right, 0)

        # Input
        global newSimFrame2Grid = Grid()
        set_gtk_property!(newSimFrame2Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame2Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame2Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame2Grid, :margin_right, 10)

        # KP
        global newSimFrame3Grid = Grid()
        set_gtk_property!(newSimFrame3Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame3Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame3Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame3Grid, :margin_right, 10)

        # RP
        global newSimFrame4Grid = Grid()
        set_gtk_property!(newSimFrame4Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame4Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame4Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame4Grid, :margin_right, 10)

        # Buttons sim
        global newSimFrame5Grid = Grid()
        set_gtk_property!(newSimFrame5Grid, :column_homogeneous, true)
        set_gtk_property!(newSimFrame5Grid, :row_homogeneous, true)
        set_gtk_property!(newSimFrame5Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame5Grid, :column_spacing, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_left, 10)
        set_gtk_property!(newSimFrame5Grid, :margin_right, 10)

        # Plot sim
        global newSimFrame6Grid = Grid()
        set_gtk_property!(newSimFrame6Grid, :column_homogeneous, false)
        set_gtk_property!(newSimFrame6Grid, :row_homogeneous, false)
        set_gtk_property!(newSimFrame6Grid, :row_spacing, 10)
        set_gtk_property!(newSimFrame6Grid, :margin_bottom, 10)

        # Type of Plot
        global newSimFrame7Grid = Grid()
        set_gtk_property!(newSimFrame7Grid, :column_homogeneous, true)
        set_gtk_property!(newSimFrame7Grid, :column_spacing, 0)
        set_gtk_property!(newSimFrame7Grid, :margin_top, 10)
        set_gtk_property!(newSimFrame7Grid, :margin_bottom, 10)
        set_gtk_property!(newSimFrame7Grid, :margin_left, 120)
        set_gtk_property!(newSimFrame7Grid, :margin_right, 0)

        ########################################################################
        # Frames
        ########################################################################
        global newSimWinFrame1 = Frame("Reactor type")
        set_gtk_property!(newSimWinFrame1, :width_request, 400)
        set_gtk_property!(newSimWinFrame1, :height_request, 54)
        set_gtk_property!(newSimWinFrame1, :label_xalign, 0.50)

        global newSimWinFrame2 = Frame("Input stream")
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

        # Frame for plots
        global newSimWinFrame10 = Frame()
        set_gtk_property!(newSimWinFrame10, :width_request, 400)
        set_gtk_property!(newSimWinFrame10, :height_request, 30)

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

            # clear KP
            global newSimKPDataBackup, newSimKPData
            empty!(newSimKPList)
            newSimKPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            global newSimKPDataBackup = DataFrames.DataFrame()
            newSimKPDataBackup.Parameter = ["Umax","Ks", "Y", "λ", "β"]

            set_gtk_property!(newSimKPEdit, :sensitive, false)
            set_gtk_property!(newSimKPClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)

            # clear RP
            global newSimRPDataBackup, newSimRPData
            empty!(newSimRPList)
            newSimRPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            newSimRPDataBackup = DataFrames.DataFrame()

            if newSimTRindex == true
                newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "t[0]", "t[f]"]
            else
                newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "V", "t[0]", "t[f]"]
            end

            set_gtk_property!(newSimRPEdit, :sensitive, false)
            set_gtk_property!(newSimRPClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)
            set_gtk_property!(newSimWinFrame10, :sensitive, false)

            if newSimTRindex == false
                set_gtk_property!(newSimInputAdd, :sensitive, true)
            else
                global newSimInputDataBackup, newSimInputData
                empty!(newSimInputList)
                newSimInputData = DataFrames.DataFrame(
                                Parameter = String[], Value = Float64[])
                newSimInputDataBackup = DataFrames.DataFrame()
                newSimInputDataBackup.Parameter = ["F", "S0"]


                set_gtk_property!(newSimInputEdit, :sensitive, false)
                set_gtk_property!(newSimInputClear, :sensitive, false)
                set_gtk_property!(newSimRun, :sensitive, false)
                set_gtk_property!(newSimReport, :sensitive, false)
                set_gtk_property!(newSimExport, :sensitive, false)
                set_gtk_property!(newSimClearPlot, :sensitive, false)
                set_gtk_property!(newSimInputAdd, :sensitive, false)
            end
        end

        ########################################################################
        # Type of plot
        ########################################################################
        global newSimRadioPlot = Vector{RadioButton}(undef, 2)
        newSimRadioPlot[1] = RadioButton("Growth")
        newSimFrame7Grid[1, 1] = newSimRadioPlot[1]
        newSimRadioPlot[2] = RadioButton(newSimRadioPlot[1], "Substrate")
        newSimFrame7Grid[2, 1] = newSimRadioPlot[2]
        set_gtk_property!(newSimRadioPlot[1], :active, true)

        signal_connect(newSimRadioPlot[1], :clicked) do widget
            global newSimPlotIdx
            newSimPlotIdx = get_gtk_property(newSimRadioPlot[1], :active, Bool)
            newSimRunMe()
        end

        ########################################################################
        # Datasheet Input Streams
        ########################################################################
        global newSimIS = Grid()
        global newSimISScroll = ScrolledWindow(newSimIS)

        # Table for data
        global newSimInputList = ListStore(String, Float64)

        # Visual table
        global newSimInputView = TreeView(TreeModel(newSimInputList))
        set_gtk_property!(newSimInputView, :reorderable, true)

        # Set selectable
        global selmodelInput = G_.selection(newSimInputView)
        set_gtk_property!(newSimInputView, :height_request, 340)

        set_gtk_property!(newSimInputView, :enable_grid_lines, 3)
        set_gtk_property!(newSimInputView, :expand, true)

        rTxtIS = CellRendererText()

        global c1 = TreeViewColumn(
            "Parameter",
            rTxtIS,
            Dict([("text", 0)])
        )
        global c2 = TreeViewColumn(
            "Value",
            rTxtIS,
            Dict([("text", 1)])
        )

            # Allows to select rows
        for c in [c1, c2]
            GAccessor.resizable(c, true)
        end

        push!(newSimInputView, c1, c2)

        newSimIS[1, 1] = newSimInputView
        push!(newSimWinFrame5, newSimISScroll)

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

        # Set selectable
        global selmodelRP = G_.selection(newSimRPView)
        set_gtk_property!(newSimRPView, :height_request, 340)

        set_gtk_property!(newSimRPView, :enable_grid_lines, 3)
        set_gtk_property!(newSimRPView, :expand, true)

        rTxtRP = CellRendererText()

        global c1 = TreeViewColumn(
            "Parameter",
            rTxtRP,
            Dict([("text", 0)])
        )
        global c2 = TreeViewColumn(
            "Value",
            rTxtRP,
            Dict([("text", 1)])
        )

            # Allows to select rows
        for c in [c1, c2]
            GAccessor.resizable(c, true)
        end

        push!(newSimRPView, c1, c2)

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

        # Set selectable
        global selmodelKP = G_.selection(newSimKPView)
        set_gtk_property!(newSimKPView, :height_request, 340)

        set_gtk_property!(newSimKPView, :enable_grid_lines, 3)
        set_gtk_property!(newSimKPView, :expand, true)

        rTxtKP = CellRendererText()

        global c1 = TreeViewColumn(
            "Parameter",
            rTxtKP,
            Dict([("text", 0)])
        )
        global c2 = TreeViewColumn(
            "Value",
            rTxtKP,
            Dict([("text", 1)])
        )

            # Allows to select rows
        for c in [c1, c2]
            GAccessor.resizable(c, true)
        end

        push!(newSimKPView, c1, c2)

        newSimKP[1, 2] = newSimKPView
        push!(newSimWinFrame6, newSimKPScroll)

        ########################################################################
        # Buttons
        ########################################################################

        ########################################################################
        # Input
        ########################################################################
        global newSimInputDataBackup = DataFrames.DataFrame()
        newSimInputDataBackup.Parameter = ["F", "S0"]
        global newSimInputData = DataFrames.DataFrame(
                        Parameter = String[], Value = Float64[])

        newSimInputAdd = Button("Add")
        set_gtk_property!(newSimInputAdd, :width_request, 150)
        set_gtk_property!(newSimInputAdd, :sensitive, false)
        set_gtk_property!(newSimInputAdd, :width_request, 150)
        signal_connect(newSimInputAdd, :clicked) do widget
            newSimInputAddWin = Window()
            set_gtk_property!(newSimInputAddWin, :title, "Load data")
            set_gtk_property!(newSimInputAddWin, :window_position, 3)
            set_gtk_property!(newSimInputAddWin, :width_request, 250)
            set_gtk_property!(newSimInputAddWin, :height_request, 100)
            set_gtk_property!(newSimInputAddWin, :accept_focus, true)

            newSimInputAddWinGrid = Grid()
            set_gtk_property!(newSimInputAddWinGrid, :margin_top, 25)
            set_gtk_property!(newSimInputAddWinGrid, :margin_left, 10)
            set_gtk_property!(newSimInputAddWinGrid, :margin_right, 10)
            set_gtk_property!(newSimInputAddWinGrid, :margin_bottom, 10)
            set_gtk_property!(newSimInputAddWinGrid, :column_spacing, 10)
            set_gtk_property!(newSimInputAddWinGrid, :row_spacing, 10)
            set_gtk_property!(
                    newSimInputAddWinGrid,
                    :column_homogeneous,
                    true)

            newSimInputAddWinLabel = Label("Select an option:")

            newSimInputAddWinEntry = Entry()
            set_gtk_property!(newSimInputAddWinEntry,
                    :tooltip_markup,
                    "Enter value"
                )
            set_gtk_property!(newSimInputAddWinEntry, :width_request, 150)
            set_gtk_property!(newSimInputAddWinEntry, :text, "")

            newSimInputAddClose = Button("Close")
            signal_connect(newSimInputAddClose, :clicked) do widget
                destroy(newSimInputAddWin)
            end

            signal_connect(newSimInputAddWin, "key-press-event") do widget, event
                if event.keyval == 65307
                    destroy(newSimInputAddWin)
                end
            end

            newSimInputAddSet = Button("Set")
            signal_connect(newSimInputAddSet, :clicked) do widget
                global newSimInputData, newSimInputDataBackup
                global Idx = get_gtk_property(newSimInputAddComboBox, :active, Int)

                if Idx == -1
                    warn_dialog("Please select a parameter!", newSimInputAddWin)
                else
                    try
                        global newSimInputPar
                        newSimInputPar = get_gtk_property(newSimInputAddWinEntry, :text, String)
                        numNewPar = parse(Float64, newSimInputPar)

                        newSimL = size(newSimInputData,1)
                        push!(newSimInputData, (newSimInputDataBackup[Idx+1,1], numNewPar))
                        push!(newSimInputList, (newSimInputData.Parameter[newSimL+1,1], numNewPar))

                        DataFrames.deleterows!(newSimInputDataBackup, Idx+1)

                        empty!(newSimInputAddComboBox)
                        for choice in newSimInputDataBackup.Parameter
                            push!(newSimInputAddComboBox, choice)
                        end

                        if size(newSimInputDataBackup,1) == 0
                            destroy(newSimInputAddWin)
                        end
                        set_gtk_property!(newSimInputAddWinEntry, :text, "")
                        set_gtk_property!(newSimInputEdit, :sensitive, true)
                        set_gtk_property!(newSimInputClear, :sensitive, true)
                        set_gtk_property!(newSimClearPlot, :sensitive, true)
                        set_gtk_property!(newSimInputAddComboBox, :active, 0)

                        # if size(newSimInputData,1) == 4
                        #     if (sum(newSimInputData.Parameter .== "Umax")) == 1 && (sum(newSimInputData.Parameter .== "Ks")) == 1 && (sum(newSimInputData.Parameter .== "Y")) == 1
                        #         set_gtk_property!(newSimRun, :sensitive, true)
                        #         set_gtk_property!(newSimReport, :sensitive, true)
                        #         set_gtk_property!(newSimExport, :sensitive, true)
                        #         set_gtk_property!(newSimClearPlot, :sensitive, true)
                        #     end
                        # end
                    catch
                        warn_dialog("Please write a number", newSimInputAddWin)
                        set_gtk_property!(newSimInputAddWinEntry, :text, "")
                    end
                end
            end

            signal_connect(newSimInputAddWin, "key-press-event") do widget, event
                global newSimInputData, newSimInputDataBackup
                if event.keyval == 65293
                    global Idx = get_gtk_property(newSimInputAddComboBox, :active, Int)

                    if Idx == -1
                        warn_dialog("Please select a parameter!", newSimInputAddWin)
                    else
                        try
                            global newSimInputPar
                            newSimInputPar = get_gtk_property(newSimInputAddWinEntry, :text, String)
                            numNewPar = parse(Float64, newSimInputPar)

                            newSimL = size(newSimInputData,1)
                            push!(newSimInputData, (newSimInputDataBackup[Idx+1,1], numNewPar))
                            push!(newSimInputList, (newSimInputData.Parameter[newSimL+1,1], numNewPar))

                            DataFrames.deleterows!(newSimInputDataBackup, Idx+1)

                            empty!(newSimInputAddComboBox)
                            for choice in newSimInputDataBackup.Parameter
                                push!(newSimInputAddComboBox, choice)
                            end

                            if size(newSimInputDataBackup,1) == 0
                                destroy(newSimInputAddWin)
                            end

                            set_gtk_property!(newSimInputEdit, :sensitive, true)
                            set_gtk_property!(newSimInputClear, :sensitive, true)
                            set_gtk_property!(newSimClearPlot, :sensitive, true)
                            set_gtk_property!(newSimInputAddWinEntry, :text, "")
                            set_gtk_property!(newSimInputAddComboBox, :active, 0)

                            # if size(newSimRPData,1) == 4
                            #     if (sum(newSimKPData.Parameter .== "Umax")) == 1 && (sum(newSimKPData.Parameter .== "Ks")) == 1 && (sum(newSimKPData.Parameter .== "Y")) == 1
                            #         set_gtk_property!(newSimRun, :sensitive, true)
                            #         set_gtk_property!(newSimReport, :sensitive, true)
                            #         set_gtk_property!(newSimExport, :sensitive, true)
                            #         set_gtk_property!(newSimClearPlot, :sensitive, true)
                            #     end
                            # end
                        catch
                            warn_dialog("Please write a number", newSimInputAddWin)
                            set_gtk_property!(newSimInputAddWinEntry, :text, "")
                        end
                    end
                end
            end

            newSimInputAddComboBox = GtkComboBoxText()
            for choice in newSimInputDataBackup.Parameter
                push!(newSimInputAddComboBox, choice)
            end

            # Lets set the active element to be "0"
            set_gtk_property!(newSimInputAddComboBox, :active, 0)

            newSimInputAddWinGrid[1:2, 1] = newSimInputAddWinLabel
            newSimInputAddWinGrid[1:2, 2] = newSimInputAddComboBox
            newSimInputAddWinGrid[1:2, 3] = newSimInputAddWinEntry
            newSimInputAddWinGrid[1, 4] = newSimInputAddClose
            newSimInputAddWinGrid[2, 4] = newSimInputAddSet

            push!(newSimInputAddWin, newSimInputAddWinGrid)
            showall(newSimInputAddWin)
        end

        # Edit vapues for input properties
        newSimInputEdit = Button("Edit")
        set_gtk_property!(newSimInputEdit, :width_request, 150)
        set_gtk_property!(newSimInputEdit, :width_request, 150)
        signal_connect(newSimInputEdit, :clicked) do widget
            global selmodelInput, newSimInputData, newSimInputList

            if hasselection(selmodelInput)
                editInputWin = Window()
                set_gtk_property!(editInputWin, :title, "Edit")
                set_gtk_property!(editInputWin, :window_position, 3)
                set_gtk_property!(editInputWin, :width_request, 100)
                set_gtk_property!(editInputWin, :height_request, 70)
                set_gtk_property!(editInputWin, :accept_focus, true)

                editInputWinGrid = Grid()
                set_gtk_property!(editInputWinGrid, :margin_top, 25)
                set_gtk_property!(editInputWinGrid, :margin_left, 10)
                set_gtk_property!(editInputWinGrid, :margin_right, 10)
                set_gtk_property!(editInputWinGrid, :margin_bottom, 10)
                set_gtk_property!(editInputWinGrid, :column_spacing, 10)
                set_gtk_property!(editInputWinGrid, :row_spacing, 10)
                set_gtk_property!(editInputWinGrid, :column_homogeneous, true)

                editInputEntry = Entry()
                set_gtk_property!(editInputEntry, :tooltip_markup, "Enter value")
                set_gtk_property!(editInputEntry, :width_request, 80)
                set_gtk_property!(editInputEntry, :text, "")

                editInputLabel = Label("")
                global editInputIndex = Gtk.index_from_iter(newSimInputList,
                                        selected(selmodelInput))
                set_gtk_property!(
                editInputLabel, :label,
                string("Parameter ", newSimInputData[editInputIndex,1], " ="))

                editInputWinClose = Button("Close")
                signal_connect(editInputWinClose, :clicked) do widget
                    destroy(editInputWin)
                end

                # Set button to apply values
                editInputSet = Button("Set")
                signal_connect(editInputSet, :clicked) do widget
                    global newSimInputData, newSimInputList, editInputIndex
                    # Check for non a number
                    try
                        global newPar
                        newPar = get_gtk_property(editInputEntry, :text, String)
                        numNewPar = parse(Float64, newPar)
                        idx = editInputIndex
                        newSimInputData[idx,2] = numNewPar

                        for i=1:2
                            newSimRPList[idx, i] = newSimInputData[idx,i]
                        end

                        destroy(editInputWin)
                    catch
                        warn_dialog("Please write a number", editInputWin)
                        set_gtk_property!(editInputEntry, :text, "")
                    end
                end

                # Same action as set
                signal_connect(editInputWin, "key-press-event") do widget, event
                    global newSimInputData, newSimInputList, editInputIndex
                    if event.keyval == 65293
                        # Check for non a number
                        try
                            global newPar
                            newPar = get_gtk_property(editInputEntry, :text, String)
                            numNewPar = parse(Float64, newPar)
                            idx = editInputIndex
                            newSimInputData[idx,2] = numNewPar

                            for i=1:2
                                newSimInputList[idx, i] = newSimInputData[idx,i]
                            end

                            destroy(editInputWin)
                        catch
                            warn_dialog("Please write a number", editInputWin)
                            set_gtk_property!(editInputEntry, :text, "")
                        end
                    end
                end

                signal_connect(editInputWin, "key-press-event") do widget, event
                    if event.keyval == 65307
                        destroy(editInputWin)
                    end
                end

                editInputWinGrid[1, 1] = editInputLabel
                editInputWinGrid[1, 2] = editInputEntry
                editInputWinGrid[1, 4] = editInputWinClose
                editInputWinGrid[1, 3] = editInputSet

                push!(editInputWin, editInputWinGrid)
                showall(editInputWin)
            else
                warn_dialog("Please select a parameter!", editInputWin)
            end
        end

        newSimInputClear = Button("Clear")
        set_gtk_property!(newSimInputClear, :width_request, 150)
        signal_connect(newSimInputClear, :clicked) do widget
            global newSimInputDataBackup, newSimInputData
            empty!(newSimInputList)
            newSimInputData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            newSimInputDataBackup = DataFrames.DataFrame()
            newSimInputDataBackup.Parameter = ["F", "S0"]


            set_gtk_property!(newSimInputEdit, :sensitive, false)
            set_gtk_property!(newSimInputClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)
        end

        ########################################################################
        # Kinetic
        ########################################################################
        global newSimKPDataBackup = DataFrames.DataFrame()
        newSimKPDataBackup.Parameter = ["Umax","Ks", "Y", "λ", "β"]
        global newSimKPData = DataFrames.DataFrame(
                        Parameter = String[], Value = Float64[])

        newSimKPAdd = Button("Add")
        set_gtk_property!(newSimKPAdd, :width_request, 150)
        signal_connect(newSimKPAdd, :clicked) do widget
            newSimKPAddWin = Window()
            set_gtk_property!(newSimKPAddWin, :title, "Load data")
            set_gtk_property!(newSimKPAddWin, :window_position, 3)
            set_gtk_property!(newSimKPAddWin, :width_request, 250)
            set_gtk_property!(newSimKPAddWin, :height_request, 100)
            set_gtk_property!(newSimKPAddWin, :accept_focus, true)

            newSimKPAddWinGrid = Grid()
            set_gtk_property!(newSimKPAddWinGrid, :margin_top, 25)
            set_gtk_property!(newSimKPAddWinGrid, :margin_left, 10)
            set_gtk_property!(newSimKPAddWinGrid, :margin_right, 10)
            set_gtk_property!(newSimKPAddWinGrid, :margin_bottom, 10)
            set_gtk_property!(newSimKPAddWinGrid, :column_spacing, 10)
            set_gtk_property!(newSimKPAddWinGrid, :row_spacing, 10)
            set_gtk_property!(
                    newSimKPAddWinGrid,
                    :column_homogeneous,
                    true
                )

            newSimKPAddWinLabel = Label("Select an option:")

            newSimKPAddWinEntry = Entry()
            set_gtk_property!(
                newSimKPAddWinEntry,
                :tooltip_markup,
                "Enter value"
                )
            set_gtk_property!(newSimKPAddWinEntry, :width_request, 150)
            set_gtk_property!(newSimKPAddWinEntry, :text, "")

            newSimKPAddClose = Button("Close")
            signal_connect(newSimKPAddClose, :clicked) do widget
                destroy(newSimKPAddWin)
            end

            signal_connect(newSimKPAddWin, "key-press-event") do widget, event
                if event.keyval == 65307
                    destroy(newSimKPAddWin)
                end
            end

            newSimKPAddSet = Button("Set")
            signal_connect(newSimKPAddSet, :clicked) do widget
                global newSimKPData, newSimKPDataBackup
                global Idx = get_gtk_property(newSimKPAddComboBox, :active, Int)

                if Idx == -1
                    warn_dialog("Please select a parameter!", newSimKPAddWin)
                else
                    try
                        global newSimKPPar
                        newSimKPPar = get_gtk_property(newSimKPAddWinEntry, :text, String)
                        numNewPar = parse(Float64, newSimKPPar)

                        newSimL = size(newSimKPData,1)
                        push!(newSimKPData, (newSimKPDataBackup[Idx+1,1], numNewPar))
                        push!(newSimKPList, (newSimKPData.Parameter[newSimL+1,1], numNewPar))

                        DataFrames.deleterows!(newSimKPDataBackup, Idx+1)

                        empty!(newSimKPAddComboBox)
                        for choice in newSimKPDataBackup.Parameter
                            push!(newSimKPAddComboBox, choice)
                        end

                        if size(newSimKPDataBackup,1) == 0
                            destroy(newSimKPAddWin)
                        end
                        set_gtk_property!(newSimKPAddWinEntry, :text, "")
                        set_gtk_property!(newSimKPEdit, :sensitive, true)
                        set_gtk_property!(newSimKPClear, :sensitive, true)
                        set_gtk_property!(newSimClearPlot, :sensitive, true)
                        set_gtk_property!(newSimKPAddComboBox, :active, 0)

                        if size(newSimRPData,1) == 4
                            if (sum(newSimKPData.Parameter .== "Umax")) == 1 && (sum(newSimKPData.Parameter .== "Ks")) == 1 && (sum(newSimKPData.Parameter .== "Y")) == 1
                                set_gtk_property!(newSimRun, :sensitive, true)
                                set_gtk_property!(newSimReport, :sensitive, true)
                                set_gtk_property!(newSimExport, :sensitive, true)
                                set_gtk_property!(newSimClearPlot, :sensitive, true)
                            end
                        end
                    catch
                        warn_dialog("Please write a number", newSimKPAddWin)
                        set_gtk_property!(newSimKPAddWinEntry, :text, "")
                    end
                end
            end

            signal_connect(newSimKPAddWin, "key-press-event") do widget, event
                global newSimKPData, newSimKPDataBackup
                if event.keyval == 65293
                    global Idx = get_gtk_property(newSimKPAddComboBox, :active, Int)

                    if Idx == -1
                        warn_dialog("Please select a parameter!", newSimKPAddWin)
                    else
                        try
                            global newSimKPPar
                            newSimKPPar = get_gtk_property(newSimKPAddWinEntry, :text, String)
                            numNewPar = parse(Float64, newSimKPPar)

                            newSimL = size(newSimKPData,1)
                            push!(newSimKPData, (newSimKPDataBackup[Idx+1,1], numNewPar))
                            push!(newSimKPList, (newSimKPData.Parameter[newSimL+1,1], numNewPar))

                            DataFrames.deleterows!(newSimKPDataBackup, Idx+1)

                            empty!(newSimKPAddComboBox)
                            for choice in newSimKPDataBackup.Parameter
                                push!(newSimKPAddComboBox, choice)
                            end

                            if size(newSimKPDataBackup,1) == 0
                                destroy(newSimKPAddWin)
                            end

                            set_gtk_property!(newSimKPEdit, :sensitive, true)
                            set_gtk_property!(newSimKPClear, :sensitive, true)
                            set_gtk_property!(newSimClearPlot, :sensitive, true)
                            set_gtk_property!(newSimKPAddWinEntry, :text, "")
                            set_gtk_property!(newSimKPAddComboBox, :active, 0)

                            if size(newSimRPData,1) == 4
                                if (sum(newSimKPData.Parameter .== "Umax")) == 1 && (sum(newSimKPData.Parameter .== "Ks")) == 1 && (sum(newSimKPData.Parameter .== "Y")) == 1
                                    set_gtk_property!(newSimRun, :sensitive, true)
                                    set_gtk_property!(newSimReport, :sensitive, true)
                                    set_gtk_property!(newSimExport, :sensitive, true)
                                    set_gtk_property!(newSimClearPlot, :sensitive, true)
                                end
                            end
                        catch
                            warn_dialog("Please write a number", newSimKPAddWin)
                            set_gtk_property!(newSimKPAddWinEntry, :text, "")
                        end
                    end
                end
            end

            newSimKPAddComboBox = GtkComboBoxText()
            for choice in newSimKPDataBackup.Parameter
                push!(newSimKPAddComboBox, choice)
            end

            # Lets set the active element to be "0"
            set_gtk_property!(newSimKPAddComboBox, :active, 0)

            newSimKPAddWinGrid[1:2, 1] = newSimKPAddWinLabel
            newSimKPAddWinGrid[1:2, 2] = newSimKPAddComboBox
            newSimKPAddWinGrid[1:2, 3] = newSimKPAddWinEntry
            newSimKPAddWinGrid[1, 4] = newSimKPAddClose
            newSimKPAddWinGrid[2, 4] = newSimKPAddSet

            push!(newSimKPAddWin, newSimKPAddWinGrid)
            showall(newSimKPAddWin)
        end

        newSimKPEdit = Button("Edit")
        set_gtk_property!(newSimKPEdit, :width_request, 150)
        signal_connect(newSimKPEdit, :clicked) do widget
            global selmodelKP, newSimKPEditPData, newSimKPEditPList

            if hasselection(selmodelKP)
                editKPWin = Window()
                set_gtk_property!(editKPWin, :title, "Edit")
                set_gtk_property!(editKPWin, :window_position, 3)
                set_gtk_property!(editKPWin, :width_request, 100)
                set_gtk_property!(editKPWin, :height_request, 70)
                set_gtk_property!(editKPWin, :accept_focus, true)

                editKPWinGrid = Grid()
                set_gtk_property!(editKPWinGrid, :margin_top, 25)
                set_gtk_property!(editKPWinGrid, :margin_left, 10)
                set_gtk_property!(editKPWinGrid, :margin_right, 10)
                set_gtk_property!(editKPWinGrid, :margin_bottom, 10)
                set_gtk_property!(editKPWinGrid, :column_spacing, 10)
                set_gtk_property!(editKPWinGrid, :row_spacing, 10)
                set_gtk_property!(editKPWinGrid, :column_homogeneous, true)

                editKPEntry = Entry()
                set_gtk_property!(editKPEntry, :tooltip_markup, "Enter value")
                set_gtk_property!(editKPEntry, :width_request, 80)
                set_gtk_property!(editKPEntry, :text, "")

                editKPLabel = Label("")
                global editKPIndex = Gtk.index_from_iter(newSimKPList,
                                        selected(selmodelKP))
                set_gtk_property!(
                editKPLabel, :label,
                string("Parameter ", newSimKPData[editKPIndex,1], " ="))

                editKPWinClose = Button("Close")
                signal_connect(editKPWinClose, :clicked) do widget
                    destroy(editKPWin)
                end

                # Set button to apply values
                editKPSet = Button("Set")
                signal_connect(editKPSet, :clicked) do widget
                    global newSimKPData, newSimKPList, editKPIndex
                    # Check for non a number
                    try
                        global newPar
                        newPar = get_gtk_property(editKPEntry, :text, String)
                        numNewPar = parse(Float64, newPar)
                        idx = editKPIndex
                        newSimKPData[idx,2] = numNewPar

                        for i=1:2
                            newSimKPList[idx, i] = newSimKPData[idx,i]
                        end

                        destroy(editKPWin)
                    catch
                        warn_dialog("Please write a number", editKPWin)
                        set_gtk_property!(editKPEntry, :text, "")
                    end
                end

                # Same action as set
                signal_connect(editKPWin, "key-press-event") do widget, event
                    global newSimKPData, newSimKPList, editKPIndex
                    if event.keyval == 65293
                        # Check for non a number
                        try
                            global newPar
                            newPar = get_gtk_property(editKPEntry, :text, String)
                            numNewPar = parse(Float64, newPar)
                            idx = editKPIndex
                            newSimKPData[idx,2] = numNewPar

                            for i=1:2
                                newSimKPList[idx, i] = newSimKPData[idx,i]
                            end

                            destroy(editKPWin)
                        catch
                            warn_dialog("Please write a number", editKPWin)
                            set_gtk_property!(editKPEntry, :text, "")
                        end
                    end
                end

                signal_connect(editKPWin, "key-press-event") do widget, event
                    if event.keyval == 65307
                        destroy(editKPWin)
                    end
                end

                editKPWinGrid[1, 1] = editKPLabel
                editKPWinGrid[1, 2] = editKPEntry
                editKPWinGrid[1, 4] = editKPWinClose
                editKPWinGrid[1, 3] = editKPSet

                push!(editKPWin, editKPWinGrid)
                showall(editKPWin)
            else
                warn_dialog("Please select a parameter!", editKPWin)
            end
        end

        newSimKPClear = Button("Clear")
        set_gtk_property!(newSimKPClear, :width_request, 150)
        signal_connect(newSimKPClear, :clicked) do widget
            global newSimKPDataBackup, newSimKPData
            empty!(newSimKPList)
            newSimKPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            global newSimKPDataBackup = DataFrames.DataFrame()
            newSimKPDataBackup.Parameter = ["Umax","Ks", "Y", "λ", "β"]

            set_gtk_property!(newSimKPEdit, :sensitive, false)
            set_gtk_property!(newSimKPClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)
        end

        ########################################################################
        # Reactor properties
        ########################################################################
        global newSimRPDataBackup = DataFrames.DataFrame()

        if newSimTRindex == true
            newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "t[0]", "t[f]"]
        else
            newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "V", "t[0]", "t[f]"]
        end

        global newSimRPData = DataFrames.DataFrame(
                        Parameter = String[], Value = Float64[])

        newSimRPAdd = Button("Add")
        set_gtk_property!(newSimRPAdd, :width_request, 150)
        signal_connect(newSimRPAdd, :clicked) do widget
            newSimRPAddWin = Window()
            set_gtk_property!(newSimRPAddWin, :title, "Load data")
            set_gtk_property!(newSimRPAddWin, :window_position, 3)
            set_gtk_property!(newSimRPAddWin, :width_request, 250)
            set_gtk_property!(newSimRPAddWin, :height_request, 100)
            set_gtk_property!(newSimRPAddWin, :accept_focus, true)

            newSimRPAddWinGrid = Grid()
            set_gtk_property!(newSimRPAddWinGrid, :margin_top, 25)
            set_gtk_property!(newSimRPAddWinGrid, :margin_left, 10)
            set_gtk_property!(newSimRPAddWinGrid, :margin_right, 10)
            set_gtk_property!(newSimRPAddWinGrid, :margin_bottom, 10)
            set_gtk_property!(newSimRPAddWinGrid, :column_spacing, 10)
            set_gtk_property!(newSimRPAddWinGrid, :row_spacing, 10)
            set_gtk_property!(
                newSimRPAddWinGrid,
                :column_homogeneous,
                true
            )

            newSimRPAddWinLabel = Label("Select an option:")

            newSimRPAddWinEntry = Entry()
            set_gtk_property!(
                newSimRPAddWinEntry,
                :tooltip_markup,
                "Enter value"
            )
            set_gtk_property!(newSimRPAddWinEntry, :width_request, 150)
            set_gtk_property!(newSimRPAddWinEntry, :text, "")

            newSimRPAddClose = Button("Close")
            signal_connect(newSimRPAddClose, :clicked) do widget
                destroy(newSimRPAddWin)
            end

            signal_connect(newSimRPAddWin, "key-press-event") do widget, event
                if event.keyval == 65307
                    destroy(newSimRPAddWin)
                end
            end

            newSimRPAddSet = Button("Set")
            signal_connect(newSimRPAddSet, :clicked) do widget
                global newSimRPData, newSimRPDataBackup
                global Idx = get_gtk_property(newSimRPAddComboBox, :active, Int)

                if Idx == -1
                    warn_dialog("Please select a parameter!", newSimRPAddWin)
                else
                    try
                        global newSimRPPar, newSimRPEdit
                        newSimRPPar = get_gtk_property(newSimRPAddWinEntry, :text, String)
                        numNewPar = parse(Float64, newSimRPPar)

                        newSimL = size(newSimRPData,1)
                        push!(newSimRPData, (newSimRPDataBackup[Idx+1,1], numNewPar))
                        push!(newSimRPList, (newSimRPData.Parameter[newSimL+1,1], numNewPar))

                        DataFrames.deleterows!(newSimRPDataBackup, Idx+1)

                        empty!(newSimRPAddComboBox)
                        for choice in newSimRPDataBackup.Parameter
                            push!(newSimRPAddComboBox, choice)
                        end

                        if size(newSimRPDataBackup,1) == 0
                            destroy(newSimRPAddWin)
                        end
                        set_gtk_property!(newSimRPAddWinEntry, :text, "")
                        set_gtk_property!(newSimRPEdit, :sensitive, true)
                        set_gtk_property!(newSimRPClear, :sensitive, true)
                        set_gtk_property!(newSimClearPlot, :sensitive, true)
                        set_gtk_property!(newSimRPAddComboBox, :active, 0)

                        if size(newSimRPData,1) == 4
                            if (sum(newSimKPData.Parameter .== "Umax")) == 1 && (sum(newSimKPData.Parameter .== "Ks")) == 1 && (sum(newSimKPData.Parameter .== "Y")) == 1
                                set_gtk_property!(newSimRun, :sensitive, true)
                                set_gtk_property!(newSimReport, :sensitive, true)
                                set_gtk_property!(newSimExport, :sensitive, true)
                                set_gtk_property!(newSimClearPlot, :sensitive, true)
                            end
                        end
                    catch
                        warn_dialog("Please write a number", newSimRPAddWin)
                        set_gtk_property!(newSimRPAddWinEntry, :text, "")
                    end
                end
            end

            signal_connect(newSimRPAddWin, "key-press-event") do widget, event
                global newSimRPData, newSimRPDataBackup
                if event.keyval == 65293
                    global Idx = get_gtk_property(newSimRPAddComboBox, :active, Int)

                    if Idx == -1
                        warn_dialog("Please select a parameter!", newSimRPAddWin)
                    else
                        try
                            global newSimRPPar
                            newSimRPPar = get_gtk_property(newSimRPAddWinEntry, :text, String)
                            numNewPar = parse(Float64, newSimRPPar)

                            newSimL = size(newSimRPData,1)
                            push!(newSimRPData, (newSimRPDataBackup[Idx+1,1], numNewPar))
                            push!(newSimRPList, (newSimRPData.Parameter[newSimL+1,1], numNewPar))

                            DataFrames.deleterows!(newSimRPDataBackup, Idx+1)

                            empty!(newSimRPAddComboBox)

                            for choice in newSimRPDataBackup.Parameter
                                push!(newSimRPAddComboBox, choice)
                            end

                            if size(newSimRPDataBackup,1) == 0
                                destroy(newSimRPAddWin)
                            end

                            set_gtk_property!(newSimRPAddWinEntry, :text, "")
                            set_gtk_property!(newSimRPEdit, :sensitive, true)
                            set_gtk_property!(newSimRPClear, :sensitive, true)
                            set_gtk_property!(newSimClearPlot, :sensitive, true)
                            set_gtk_property!(newSimRPAddComboBox, :active, 0)

                            if size(newSimRPData,1) == 4
                                if (sum(newSimKPData.Parameter .== "Umax")) == 1 && (sum(newSimKPData.Parameter .== "Ks")) == 1 && (sum(newSimKPData.Parameter .== "Y")) == 1
                                    set_gtk_property!(newSimRun, :sensitive, true)
                                    set_gtk_property!(newSimReport, :sensitive, true)
                                    set_gtk_property!(newSimExport, :sensitive, true)
                                    set_gtk_property!(newSimClearPlot, :sensitive, true)
                                end
                            end
                        catch
                            warn_dialog("Please write a number", newSimRPAddWin)
                            set_gtk_property!(newSimRPAddWinEntry, :text, "")
                            set_gtk_property!(newSimRPEdit, :sensitive, true)
                            set_gtk_property!(newSimRPClear, :sensitive, true)
                        end
                    end
                end
            end

            newSimRPAddComboBox = GtkComboBoxText()
            for choice in newSimRPDataBackup.Parameter
                push!(newSimRPAddComboBox, choice)
            end

            # Lets set the active element to be "0"
            set_gtk_property!(newSimRPAddComboBox, :active, 0)

            newSimRPAddWinGrid[1:2, 1] = newSimRPAddWinLabel
            newSimRPAddWinGrid[1:2, 2] = newSimRPAddComboBox
            newSimRPAddWinGrid[1:2, 3] = newSimRPAddWinEntry
            newSimRPAddWinGrid[1, 4] = newSimRPAddClose
            newSimRPAddWinGrid[2, 4] = newSimRPAddSet

            push!(newSimRPAddWin, newSimRPAddWinGrid)
            showall(newSimRPAddWin)
        end

        # Edit vapues for reactor properties
        global newSimRPEdit = Button("Edit")
        set_gtk_property!(newSimRPEdit, :width_request, 150)
        signal_connect(newSimRPEdit, :clicked) do widget
            global selmodelRP, newSimRPData, newSimRPList

            if hasselection(selmodelRP)
                editRPWin = Window()
                set_gtk_property!(editRPWin, :title, "Edit")
                set_gtk_property!(editRPWin, :window_position, 3)
                set_gtk_property!(editRPWin, :width_request, 100)
                set_gtk_property!(editRPWin, :height_request, 70)
                set_gtk_property!(editRPWin, :accept_focus, true)

                editRPWinGrid = Grid()
                set_gtk_property!(editRPWinGrid, :margin_top, 25)
                set_gtk_property!(editRPWinGrid, :margin_left, 10)
                set_gtk_property!(editRPWinGrid, :margin_right, 10)
                set_gtk_property!(editRPWinGrid, :margin_bottom, 10)
                set_gtk_property!(editRPWinGrid, :column_spacing, 10)
                set_gtk_property!(editRPWinGrid, :row_spacing, 10)
                set_gtk_property!(editRPWinGrid, :column_homogeneous, true)

                editRPEntry = Entry()
                set_gtk_property!(editRPEntry, :tooltip_markup, "Enter value")
                set_gtk_property!(editRPEntry, :width_request, 80)
                set_gtk_property!(editRPEntry, :text, "")

                editRPLabel = Label("")
                global editRPIndex = Gtk.index_from_iter(newSimRPList,
                                        selected(selmodelRP))
                set_gtk_property!(
                editRPLabel, :label,
                string("Parameter ", newSimRPData[editRPIndex,1], " ="))

                editRPWinClose = Button("Close")
                signal_connect(editRPWinClose, :clicked) do widget
                    destroy(editRPWin)
                end

                # Set button to apply values
                editRPSet = Button("Set")
                signal_connect(editRPSet, :clicked) do widget
                    global newSimRPData, newSimRPList, editRPIndex
                    # Check for non a number
                    try
                        global newPar
                        newPar = get_gtk_property(editRPEntry, :text, String)
                        numNewPar = parse(Float64, newPar)
                        idx = editRPIndex
                        newSimRPData[idx,2] = numNewPar

                        for i=1:2
                            newSimRPList[idx, i] = newSimRPData[idx,i]
                        end

                        destroy(editRPWin)
                    catch
                        warn_dialog("Please write a number", editRPWin)
                        set_gtk_property!(editRPEntry, :text, "")
                    end
                end

                # Same action as set
                signal_connect(editRPWin, "key-press-event") do widget, event
                    global newSimRPData, newSimRPList, editRPIndex
                    if event.keyval == 65293
                        # Check for non a number
                        try
                            global newPar
                            newPar = get_gtk_property(editRPEntry, :text, String)
                            numNewPar = parse(Float64, newPar)
                            idx = editRPIndex
                            newSimRPData[idx,2] = numNewPar

                            for i=1:2
                                newSimRPList[idx, i] = newSimRPData[idx,i]
                            end

                            destroy(editRPWin)
                        catch
                            warn_dialog("Please write a number", editRPWin)
                            set_gtk_property!(editRPEntry, :text, "")
                        end
                    end
                end

                signal_connect(editRPWin, "key-press-event") do widget, event
                    if event.keyval == 65307
                        destroy(editRPWin)
                    end
                end

                editRPWinGrid[1, 1] = editRPLabel
                editRPWinGrid[1, 2] = editRPEntry
                editRPWinGrid[1, 4] = editRPWinClose
                editRPWinGrid[1, 3] = editRPSet

                push!(editRPWin, editRPWinGrid)
                showall(editRPWin)
            else
                warn_dialog("Please select a parameter!", editRPWin)
            end
        end

        newSimRPClear = Button("Clear")
        set_gtk_property!(newSimRPClear, :width_request, 150)
        signal_connect(newSimRPClear, :clicked) do widget
            global newSimRPDataBackup, newSimRPData, newSimTRindex
            empty!(newSimRPList)
            newSimRPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            newSimRPDataBackup = DataFrames.DataFrame()

            if newSimTRindex == true
                newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "t[0]", "t[f]"]
            else
                newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "V", "t[0]", "t[f]"]
            end

            set_gtk_property!(newSimRPEdit, :sensitive, false)
            set_gtk_property!(newSimRPClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)
        end

        # Signal connect for exit parameter estimation
        newSimExit = Button("Exit")
        signal_connect(newSimExit, :clicked) do widget
            visible(newSimFrame6Grid, false)
            destroy(newSim)
            destroy(mainWin)
        end

        newSimClose = Button("Close")
        signal_connect(newSimClose, :clicked) do widget
            visible(newSim, false)
            visible(newSimFrame6Grid, false)
        end

        signal_connect(newSim, "key-press-event") do widget, event
            if event.keyval == 65307
                visible(newSim, false)
                visible(newSimFrame6Grid, false)
            end
        end

        # Run simulation
        newSimRun = Button("Run simulation")
        signal_connect(newSimRun, :clicked) do widget
            global newSimRPData, newSimKPData, sol
            if (sum(newSimKPData.Parameter .== "λ")) == 1 && (sum(newSimKPData.Parameter .== "β")) == 1
                # Model Equations with all kinetic parameters
                if newSimTRindex == true
                    function batch_model1(du,u,p,t)
                        # Monod model
                        U = p[1] * (u[2] / (p[2] + u[2]))
                        # Growth
                        du[1] = ((t^2)/(p[4] + t^2))*U*u[1] - p[5]*u[1]
                        # Substrate
                        du[2] = -(1/p[3])*U*u[1]
                    end

                    # Solving Model
                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1],tf[1])

                    # Parameters
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]
                    λ = newSimKPData[newSimKPData.Parameter .== "λ", 2]
                    β = newSimKPData[newSimKPData.Parameter .== "β", 2]
                    p = [Umax[1], Ks[1], Y[1], λ[1], β[1]]

                    # Solving Model
                    global prob1 = ODEProblem(batch_model1,u0,tspan, p)
                else
                    # Model Equations
                    function continuo_model1(du,u,p,t)
                        V = p[1]
                        U = p[2] * (u[2] / (p[3] + u[2]))
                        du[1] = ((t^2)/(p[4] + t^2))*U*u[1]- p[5]*u[1] -(p[6]/V)*u[1]
                        du[2] = -(1/p[7])*U*u[1] + (p[6]/V)*(p[8] - u[2])
                    end

                    # Solving Model
                    # Input
                    F = newSimInputData[newSimInputData.Parameter .== "F", 2]
                    S0 = newSimInputData[newSimInputData.Parameter .== "S0", 2]

                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1], tf[1])

                    # Parameters
                    Vr = newSimRPData[newSimRPData.Parameter .== "V", 2]
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    λ = newSimKPData[newSimKPData.Parameter .== "λ", 2]
                    β = newSimKPData[newSimKPData.Parameter .== "β", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]

                    p = [Vr[1], Umax[1], Ks[1], λ[1], β[1], F[1], Y[1], S0[1]]

                    # Solving Model
                    global prob1 = ODEProblem(continuo_model1,u0,tspan, p)
                end

                sol = solve(prob1, DP5(), saveat = 1)
                global newSimPlotIdx = true
                newSimRunMe()
                set_gtk_property!(newSimWinFrame10, :sensitive, true)
            end

            # Model Equations with λ
            if (sum(newSimKPData.Parameter .== "β")) == 0 && (sum(newSimKPData.Parameter .== "λ")) == 1
                if newSimTRindex == true
                    # Model Equations with λ
                    function batch_model2(du,u,p,t)
                        # Monod model
                        U = p[1] * (u[2] / (p[2] + u[2]))
                        # Growth
                        du[1] = ((t^2)/(p[4] + t^2))*U*u[1]
                        # Substrate
                        du[2] = -(1/p[3])*U*u[1]
                    end

                    # Solving Model
                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1],tf[1])

                    # Parameters
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]
                    λ = newSimKPData[newSimKPData.Parameter .== "λ", 2]
                    p = [Umax[1], Ks[1], Y[1], λ[1]]

                    # Solving Model
                    prob2 = ODEProblem(batch_model2,u0,tspan, p)
                    sol = solve(prob2, DP5(), saveat = 1)
                else
                    # Model Equations
                    function continuo_model2(du,u,p,t)
                        V = p[1]
                        U = p[2] * (u[2] / (p[3] + u[2]))
                        du[1] = ((t^2)/(p[4] + t^2))*U*u[1] - (p[5]/V)*u[1]
                        du[2] = -(1/p[6])*U*u[1] + (p[5]/V)*(p[7] - u[2])
                    end

                    # Solving Model
                    # Input
                    F = newSimInputData[newSimInputData.Parameter .== "F", 2]
                    S0 = newSimInputData[newSimInputData.Parameter .== "S0", 2]

                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1], tf[1])

                    # Parameters
                    Vr = newSimRPData[newSimRPData.Parameter .== "V", 2]
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    λ = newSimKPData[newSimKPData.Parameter .== "λ", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]

                    p = [Vr[1], Umax[1], Ks[1], λ[1], F[1], Y[1], S0[1]]

                    # Solving Model
                    global prob2 = ODEProblem(continuo_model2,u0,tspan, p)
                end

                sol = solve(prob2, DP5(), saveat = 1)
                global newSimPlotIdx = true
                newSimRunMe()
                set_gtk_property!(newSimWinFrame10, :sensitive, true)
            end

            # Model Equations with β
            if (sum(newSimKPData.Parameter .== "λ")) == 0 && (sum(newSimKPData.Parameter .== "β")) == 1
                if newSimTRindex == true
                    # Model Equations without λ
                    function batch_model3(du,u,p,t)
                        # Monod model
                        U = p[1] * (u[2] / (p[2] + u[2]))
                        # Growth
                        du[1] = U*u[1] - p[4]*u[1]
                        # Substrate
                        du[2] = -(1/p[3])*U*u[1]
                    end

                    # Solving Model
                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1],tf[1])

                    # Parameters
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]
                    β = newSimKPData[newSimKPData.Parameter .== "β", 2]
                    p = [Umax[1], Ks[1], Y[1], β[1]]

                    # Solving Model
                    prob3 = ODEProblem(batch_model3,u0,tspan, p)
                else
                    # Model Equations
                    function continuo_model3(du,u,p,t)
                        V = p[1]
                        U = p[2] * (u[2] / (p[3] + u[2]))
                        du[1] = U*u[1]- p[4]*u[1] -(p[5]/V)*u[1]
                        du[2] = -(1/p[6])*U*u[1] + (p[5]/V)*(p[7] - u[2])
                    end

                    # Solving Model
                    # Input
                    F = newSimInputData[newSimInputData.Parameter .== "F", 2]
                    S0 = newSimInputData[newSimInputData.Parameter .== "S0", 2]

                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1], tf[1])

                    # Parameters
                    Vr = newSimRPData[newSimRPData.Parameter .== "V", 2]
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    β = newSimKPData[newSimKPData.Parameter .== "β", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]

                    p = [Vr[1], Umax[1], Ks[1], β[1], F[1], Y[1], S0[1]]

                    # Solving Model
                    global prob3 = ODEProblem(continuo_model3,u0,tspan, p)
                end

                sol = solve(prob3, DP5(), saveat = 1)
                global newSimPlotIdx = true
                newSimRunMe()
                set_gtk_property!(newSimWinFrame10, :sensitive, true)
            end

            # Model Equations with β & λ
            if (sum(newSimKPData.Parameter .== "λ")) == 0 && (sum(newSimKPData.Parameter .== "β")) == 0
                if newSimTRindex == true
                    # Model Equations without λ
                    function batch_model4(du,u,p,t)
                        # Monod model
                        U = p[1] * (u[2] / (p[2] + u[2]))
                        # Growth
                        du[1] = U*u[1]
                        # Substrate
                        du[2] = -(1/p[3])*U*u[1]
                    end

                    # Solving Model
                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1],tf[1])

                    # Parameters
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]
                    p = [Umax[1], Ks[1], Y[1]]

                    # Solving Model
                    prob4 = ODEProblem(batch_model4,u0,tspan, p)
                else
                    # Model Equations
                    function continuo_model4(du,u,p,t)
                        V = p[1]
                        U = p[2] * (u[2] / (p[3] + u[2]))
                        du[1] = U*u[1] - (p[4]/V)*u[1]
                        du[2] = -(1/p[5])*U*u[1] + (p[4]/V)*(p[6] - u[2])
                    end

                    # Solving Model
                    # Input
                    F = newSimInputData[newSimInputData.Parameter .== "F", 2]
                    S0 = newSimInputData[newSimInputData.Parameter .== "S0", 2]

                    # Reactor properties
                    u0X = newSimRPData[newSimRPData.Parameter .== "X[0]", 2]
                    u0S = newSimRPData[newSimRPData.Parameter .== "S[0]", 2]
                    t0 = newSimRPData[newSimRPData.Parameter .== "t[0]", 2]
                    tf = newSimRPData[newSimRPData.Parameter .== "t[f]", 2]
                    u0 = [u0X[1]  u0S[1]]
                    tspan = (t0[1], tf[1])

                    # Parameters
                    Vr = newSimRPData[newSimRPData.Parameter .== "V", 2]
                    Umax = newSimKPData[newSimKPData.Parameter .== "Umax", 2]
                    Ks = newSimKPData[newSimKPData.Parameter .== "Ks", 2]
                    Y = newSimKPData[newSimKPData.Parameter .== "Y", 2]

                    p = [Vr[1], Umax[1], Ks[1], F[1], Y[1], S0[1]]

                    # Solving Model
                    global prob4 = ODEProblem(continuo_model4,u0,tspan, p)
                end

                sol = solve(prob4, DP5(), saveat = 1)
                global newSimPlotIdx = true
                newSimRunMe()
                set_gtk_property!(newSimWinFrame10, :sensitive, true)
            end

            visible(newSimFrame6Grid, true)
        end

        # TODO Report for sim
        newSimReport = Button("Report")
        signal_connect(newSimReport, :clicked) do widget
            global sol, tvals, Xvals, Yvals
            tvals = sol.t
            Xvals = sol[1,:]
            Yvals = sol[2,:]

            # Time for report
            timenow = Dates.now()
            timenow1 = Dates.format(timenow, "dd u yyyy HH:MM:SS")

            global plt2 = Plots.plot(
                tvals, Xvals,
                xlim=(tvals[1], tvals[end]),
                xticks=tvals[1]:((tvals[end]-tvals[1])/10):tvals[end],
                ylim=(Xvals[1], ceil(maximum(Xvals)*1.20)),
                yticks=range(Xvals[1], ceil(maximum(Xvals)*1.20), length=6),
                framestyle = :box)

            Plots.savefig(plt2,
                    string("C:\\Windows\\Temp\\", "SimulationReport1.png"))

            global plt3 = Plots.plot(
                tvals, Yvals,
                xlim=(tvals[1], tvals[end]),
                xticks=tvals[1]:((tvals[end]-tvals[1])/10):tvals[end],
                ylim=(Yvals[1], ceil(maximum(Yvals)*1.20)),
                yticks=range(Yvals[1], ceil(maximum(Yvals)*1.20), length=6),
                framestyle = :box)

            Plots.savefig(plt3,
                    string("C:\\Windows\\Temp\\", "SimulationReport2.png"))


            LSNS = """
            \\documentclass{article}
            \\usepackage{graphicx}
            \\graphicspath{ {C:/Windows/Temp/} }
            \\usepackage[letterpaper, portrait, margin=1in]{geometry}
            \\begin{document}
            \\begin{center}
            \\Huge{\\textbf{SimBioReactor v1.0}}\\\\
            \\vspace{2mm}
            \\large{\\textbf{Simulation Report}}\\break
            \\normalsize{{:time}}\n
            \\vspace{5mm}
            \\rule{15cm}{0.05cm}\n\n\n
            \\vspace{2mm}
            \\includegraphics[width=10cm, height=7cm]{SimulationReport1}\n
            \\normalsize{Figure 1. Growth}\n
            \\vspace{2mm}
            \\includegraphics[width=10cm, height=7cm]{SimulationReport2}\n
            \\normalsize{Figure 2. Substrate}\n
            \\vspace{3mm}\n
            \\rule{15cm}{0.05cm}\n
            \\end{center}
            \\end{document}
            """

            rendered = render(
                LSNS,
                time = timenow1)

            filename = string(
                "C:\\Windows\\Temp\\",
                "SimulationReport.tex"
            )
            Base.open(filename, "w") do file
                write(file, rendered)
            end
            run(`pdflatex -output-directory="C:\\Windows\\Temp\\" "SimulationReport.tex"`)
            DefaultApplication.open(string(
                "C:\\Windows\\Temp\\",
                "SimulationReport.pdf"
            ))
        end

        # Export figures for simulation section
        newSimExport = Button("Export")
        signal_connect(newSimExport, :clicked) do widget
            global sol, tvals, Xvals, Yvals, Lili, newSimPlotIdx
            tvals = sol.t
            Xvals = sol[1,:]
            Yvals = sol[2,:]

            global Lili = save_dialog_native("Save as...", Null(), ("*.png",))

            if isempty(Lili) != true
                if newSimPlotIdx == true
                    pltsim = Plots.plot!(
                        tvals, Xvals,
                        xlim=(tvals[1], tvals[end]),
                        xticks=tvals[1]:((tvals[end]-tvals[1])/10):tvals[end],
                        ylim=(Xvals[1], ceil(maximum(Xvals)*1.20)),
                        yticks=range(Xvals[1], ceil(maximum(Xvals)*1.20), length=6),
                        framestyle = :box, xlabel = "Time", ylabel = "Growth")
                        Plots.savefig(pltsim, string(Lili, ".png"))
                else
                    pltsim = Plots.plot(
                        tvals, Yvals,
                        xlim=(tvals[1], tvals[end]),
                        xticks=tvals[1]:((tvals[end]-tvals[1])/10):tvals[end],
                        ylim=(Yvals[1], ceil(maximum(Yvals)*1.20)),
                        yticks=range(Yvals[1], ceil(maximum(Yvals)*1.20), length=6),
                        framestyle = :box, xlabel = "Time", ylabel = "Substrate")
                        Plots.savefig(pltsim, string(Lili, ".png"))
                end
            end
        end

        # Signal connect to clear plot
        newSimClearPlot = Button("Clear all")
        signal_connect(newSimClearPlot, :clicked) do widget
            # clear KP
            global newSimKPDataBackup, newSimKPData
            empty!(newSimKPList)
            newSimKPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            global newSimKPDataBackup = DataFrames.DataFrame()
            newSimKPDataBackup.Parameter = ["Umax","Ks", "Y", "λ", "β"]

            set_gtk_property!(newSimKPEdit, :sensitive, false)
            set_gtk_property!(newSimKPClear, :sensitive, false)

            # clear RP
            global newSimRPDataBackup, newSimRPData
            empty!(newSimRPList)
            newSimRPData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            newSimRPDataBackup = DataFrames.DataFrame()
            newSimRPDataBackup.Parameter = ["X[0]", "S[0]", "t[0]", "t[f]"]

            set_gtk_property!(newSimRPEdit, :sensitive, false)
            set_gtk_property!(newSimRPClear, :sensitive, false)
            set_gtk_property!(newSimWinFrame10, :sensitive, false)

            global newSimInputDataBackup, newSimInputData
            empty!(newSimInputList)
            newSimInputData = DataFrames.DataFrame(
                            Parameter = String[], Value = Float64[])
            newSimInputDataBackup = DataFrames.DataFrame()
            newSimInputDataBackup.Parameter = ["F", "S0"]


            set_gtk_property!(newSimInputEdit, :sensitive, false)
            set_gtk_property!(newSimInputClear, :sensitive, false)
            set_gtk_property!(newSimRun, :sensitive, false)
            set_gtk_property!(newSimReport, :sensitive, false)
            set_gtk_property!(newSimExport, :sensitive, false)
            set_gtk_property!(newSimClearPlot, :sensitive, false)
            visible(newSimFrame6Grid, false)
        end

        # Initial state of buttons
        set_gtk_property!(newSimRun, :sensitive, false)
        set_gtk_property!(newSimReport, :sensitive, false)
        set_gtk_property!(newSimExport, :sensitive, false)
        set_gtk_property!(newSimClearPlot, :sensitive, false)
        set_gtk_property!(newSimInputEdit, :sensitive, false)
        set_gtk_property!(newSimInputClear, :sensitive, false)
        set_gtk_property!(newSimKPEdit, :sensitive, false)
        set_gtk_property!(newSimKPClear, :sensitive, false)
        set_gtk_property!(newSimRPEdit, :sensitive, false)
        set_gtk_property!(newSimRPClear, :sensitive, false)
        set_gtk_property!(newSimWinFrame10, :sensitive, false)

        visible(newSim, true)

        ####################################################################
        # Plot
        ####################################################################
        function newSimPlot(widget)
            global sol, tvals, Xvals, Yvals
            tvals = sol.t
            Xvals = sol[1,:]
            Yvals = sol[2,:]
        end

        function newSimMyDraw(widget)
            global sol, tvals, Xvals, Yvals, newSimPlotIdx
            ctx = Gtk.getgc(widget)
            ENV["GKS_WSTYPE"] = "142"
            ENV["GKSconid"] = @sprintf("%lu", UInt64(ctx.ptr))

            if newSimPlotIdx == true
                GR.plot(
                    tvals, Xvals,
                    size = [540, 440],
                    xlim = (tvals[1], tvals[end]),
                    ylim = (0, ceil(maximum(Xvals)*1.20)),
                    xlabel = "Time",
                    ylabel = "Growth"
                    )
            else
                GR.plot(
                    tvals, Yvals,
                    size = [540, 440],
                    xlim = (tvals[1], tvals[end]),
                    ylim = (0, ceil(maximum(Yvals)*1.20)),
                    xlabel = "Time",
                    ylabel = "Substrate"
                    )
            end

        end

        #function newSim_on_button_clicked(w)
        #    newSimPlot(w)
        #    ctx = Gtk.getgc(newSimCanvas)
        #    draw(newSimCanvas)
        #end

        function newSimRunMe()
            global newSimCanvas

            newSimCanvas = Canvas(540, 440)

            newSimFrame6Grid[1:4, 1] = newSimCanvas

            newSimCanvas.draw = newSimMyDraw
            newSimPlot(newSimCanvas)
            draw(newSimCanvas)
            #signal_connect(newSim_on_button_clicked, newSimSim, "clicked")
            showall(newSim)
        end

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
        newSimWinGridM2[1, 2] = newSimWinFrame10
        newSimWinGridM2[1, 3] = newSimWinFrame9

        newSimFrame2Grid[1, 1:3] = newSimWinFrame5
        newSimFrame2Grid[2, 1] = newSimInputAdd
        newSimFrame2Grid[2, 2] = newSimInputEdit
        newSimFrame2Grid[2, 3] = newSimInputClear

        newSimFrame3Grid[1, 1:3] = newSimWinFrame6
        newSimFrame3Grid[2, 1] = newSimKPAdd
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
        push!(newSimWinFrame8, newSimFrame6Grid)
        push!(newSimWinFrame9, newSimFrame5Grid)
        push!(newSimWinFrame10, newSimFrame7Grid)

        push!(newSim, newSimWinGrid0)
        showall(newSim)
    end

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

                signal_connect(parEstLoadWin, "key-press-event") do widget, event
                    if event.keyval == 65307
                        destroy(parEstLoadWin)
                    end
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

            signal_connect(parEstWin, "key-press-event") do widget, event
                if event.keyval == 65307
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
                    xvals[], yFit,
                    xlim=(xvals[][1], xvals[][end]),
                    xticks=xvals[][1]:((xvals[][end]-xvals[][1])/10):xvals[][end],
                    ylim=(yvals[][1], ceil(yvals[][end]*1.20)),
                    yticks=range(yvals[][1], ceil(yvals[][end]*1.20), length=6),
                    framestyle = :box,
                    label = "Predicted Data")
                    -
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
                        xvals[], yvals[],
                        xlabel = labelX,
                        ylabel = labelY,
                        label = "Experimental Data"
                    )
                    Plots.plot!(
                        xvals[], yFit,
                        xlim=(xvals[][1], xvals[][end]),
                        xticks=xvals[][1]:((xvals[][end]-xvals[][1])/10):xvals[][end],
                        ylim=(yvals[][1], ceil(yvals[][end]*1.20)),
                        yticks=range(yvals[][1], ceil(yvals[][end]*1.20), length=6),
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

                    signal_connect(parEstInitialWin, "key-press-event") do widget, event
                        if event.keyval == 65307
                            destroy(parEstInitialWin)
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
                    p0 = parEstModel.Initial
                    global modelName = "Bertalanffy"
                    global fit = curve_fit(Bertalanffy, xvals[], yvals[], p0)
                    global yFit = Bertalanffy(xvals[], fit.param)
                end

                # Brody
                if idx == 1
                    # Model definition
                    Brody(t, P) = P[1] .* (1 .- P[2] .* exp.(-P[3] .* t))
                    # Initial values
                    p0 = parEstModel.Initial
                    global modelName = "Brody"
                    global fit = curve_fit(Brody, xvals[], yvals[], p0)
                    global yFit = Brody(xvals[], fit.param)
                end

                # Gompertz
                if idx == 2
                    # Model definition
                    Gompertz(t, p) = p[1] * exp.(-p[2] * exp.(-p[3] * t))

                    # Initial values
                    p0 = parEstModel.Initial
                    global modelName = "Gompertz"
                    global fit = curve_fit(Gompertz, xvals[], yvals[], p0)
                    global yFit = Gompertz(xvals[], fit.param)
                end

                # Logistic
                if idx == 3
                    # Model definition
                    Logistic(t, P) = P[1] ./ (1 .+ P[2] .* exp.(-P[3] .* t))

                    # Initial values
                    p0 = parEstModel.Initial
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
                    GR.plot(
                        xvals[], yvals[], "bo",
                        size = [540, 440],
                        xlim = (xvals[][1], xvals[][end]),
                        ylim = (yvals[][1], ceil(yvals[][end]*1.20)),
                        xlabel = String(labelX),
                        ylabel = String(labelY)
                    )
                end

                if fitStatus == 1
                    GR.plot(xvals[], yvals[], size = [540, 440], "bo")
                    GR.oplot(
                        xvals[], yFit,
                        size = [540, 440],
                        xlim = (xvals[][1], xvals[][end]),
                        ylim = (0, ceil(maximum(yvals[])*1.20)),
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

    signal_connect(mainWin, "key-press-event") do widget, event
        if event.keyval == 65307
            destroy(mainWin)
        end
    end
    ############################################################################
    # Set buttons to mainGrid
    ############################################################################

    mainGrid[1,1] = new
    mainGrid[1,2] = parEst
    mainGrid[1,3] = doc
    mainGrid[1,4] = about
    mainGrid[1,5] = exit

    # Set mainGrid to mainWin
    push!(mainWin, mainGrid)
    showall(mainWin)
end
